//
//  BillingIdentityManager.swift
//  HeartRateSenior
//
//  Firebase identity + StoreKit billing linkage for server-authoritative accounting
//

import Foundation
import Security
import FirebaseCore
import FirebaseAuth
import FirebaseFunctions

@MainActor
final class BillingIdentityManager: ObservableObject {
    static let shared = BillingIdentityManager()

    @Published private(set) var firebaseUID: String?

    let appAccountToken: UUID

    private let functionsRegion = "us-central1"
    private let linkedTransactionIDsKey = "billing_linked_transaction_ids_v1"
    private let requestedBackfillOriginalIDsKey = "billing_backfill_original_ids_v1"

    private enum KeychainKeys {
        static let service = "com.heartrateios.senior.billing"
        static let account = "appAccountToken"
    }

    private init() {
        self.appAccountToken = Self.loadOrCreateAppAccountToken()
        if FirebaseApp.app() != nil {
            self.firebaseUID = Auth.auth().currentUser?.uid
        } else {
            self.firebaseUID = nil
        }
    }

    // MARK: - Launch Setup

    func configureOnLaunch() async {
        _ = await ensureAnonymousUserSignedIn()
    }

    // MARK: - Identity Linking

    func linkSubscriptionIdentity(
        originalTransactionId: String,
        transactionId: String,
        productId: String,
        purchaseDate: Date,
        amountDecimal: Decimal?,
        currency: String?,
        source: String,
        isRestore: Bool
    ) async {
        if hasLinkedTransaction(transactionId) {
            return
        }

        guard let uid = await ensureAnonymousUserSignedIn() else {
            print("🔥 BillingIdentity: Missing Firebase UID, skip transaction link")
            return
        }

        let payload: [String: Any] = [
            "uid": uid,
            "appAccountToken": appAccountToken.uuidString,
            "originalTransactionId": originalTransactionId,
            "transactionId": transactionId,
            "productId": productId,
            "purchaseDateMs": Int64(purchaseDate.timeIntervalSince1970 * 1000),
            "amountDecimal": amountDecimal.map { NSDecimalNumber(decimal: $0).doubleValue } as Any,
            "currency": currency as Any,
            "source": source,
            "isRestore": isRestore,
        ]

        do {
            _ = try await callFunction(name: "linkSubscriptionIdentity", data: payload)
            markTransactionAsLinked(transactionId)
        } catch {
            print("🔥 BillingIdentity: linkSubscriptionIdentity failed: \(error)")
        }
    }

    func requestBackfill(originalTransactionIds: [String], source: String) async {
        let candidates = Set(originalTransactionIds.filter { !$0.isEmpty })
        guard !candidates.isEmpty else { return }

        let requested = requestedBackfillOriginalIDs()
        let newIDs = Array(candidates.subtracting(requested))
        guard !newIDs.isEmpty else { return }

        guard await ensureAnonymousUserSignedIn() != nil else {
            print("🔥 BillingIdentity: Missing Firebase UID, skip backfill request")
            return
        }

        do {
            _ = try await callFunction(name: "backfillTransactions", data: [
                "originalTransactionIds": newIDs,
                "source": source,
            ])
            markBackfillRequested(newIDs)
        } catch {
            print("🔥 BillingIdentity: backfillTransactions failed: \(error)")
        }
    }

    // MARK: - Private Firebase Helpers

    private func ensureAnonymousUserSignedIn() async -> String? {
        if let existingUID = firebaseUID {
            return existingUID
        }

        guard FirebaseApp.app() != nil else {
            print("🔥 BillingIdentity: FirebaseApp not configured")
            return nil
        }

        if let current = Auth.auth().currentUser {
            firebaseUID = current.uid
            return current.uid
        }

        do {
            let authResult = try await signInAnonymously()
            firebaseUID = authResult.user.uid
            return authResult.user.uid
        } catch {
            print("🔥 BillingIdentity: Anonymous sign-in failed: \(error)")
            return nil
        }
    }

    private func signInAnonymously() async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signInAnonymously { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let result else {
                    continuation.resume(throwing: NSError(domain: "BillingIdentity", code: -1, userInfo: [NSLocalizedDescriptionKey: "Anonymous sign-in returned nil result"]))
                    return
                }
                continuation.resume(returning: result)
            }
        }
    }

    private func callFunction(name: String, data: [String: Any]) async throws -> HTTPSCallableResult {
        guard FirebaseApp.app() != nil else {
            throw NSError(domain: "BillingIdentity", code: -2, userInfo: [NSLocalizedDescriptionKey: "FirebaseApp is not configured"]) 
        }

        return try await withCheckedThrowingContinuation { continuation in
            Functions.functions(region: functionsRegion)
                .httpsCallable(name)
                .call(data) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let result else {
                        continuation.resume(throwing: NSError(domain: "BillingIdentity", code: -3, userInfo: [NSLocalizedDescriptionKey: "Cloud Function returned nil result"]))
                        return
                    }
                    continuation.resume(returning: result)
                }
        }
    }

    // MARK: - Local Dedup State

    private func hasLinkedTransaction(_ transactionId: String) -> Bool {
        linkedTransactionIDs().contains(transactionId)
    }

    private func markTransactionAsLinked(_ transactionId: String) {
        var ids = linkedTransactionIDs()
        ids.insert(transactionId)
        UserDefaults.standard.set(Array(ids), forKey: linkedTransactionIDsKey)
    }

    private func linkedTransactionIDs() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: linkedTransactionIDsKey) ?? [])
    }

    private func requestedBackfillOriginalIDs() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: requestedBackfillOriginalIDsKey) ?? [])
    }

    private func markBackfillRequested(_ ids: [String]) {
        var current = requestedBackfillOriginalIDs()
        for id in ids {
            current.insert(id)
        }
        UserDefaults.standard.set(Array(current), forKey: requestedBackfillOriginalIDsKey)
    }

    // MARK: - Keychain

    private static func loadOrCreateAppAccountToken() -> UUID {
        if let existing = readAppAccountToken(), let uuid = UUID(uuidString: existing) {
            return uuid
        }

        let newToken = UUID().uuidString
        _ = storeAppAccountToken(newToken)
        return UUID(uuidString: newToken) ?? UUID()
    }

    private static func readAppAccountToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKeys.service,
            kSecAttrAccount as String: KeychainKeys.account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    @discardableResult
    private static func storeAppAccountToken(_ value: String) -> Bool {
        let data = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainKeys.service,
            kSecAttrAccount as String: KeychainKeys.account,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return true
        }

        var insertQuery = query
        insertQuery[kSecValueData as String] = data
        let addStatus = SecItemAdd(insertQuery as CFDictionary, nil)
        return addStatus == errSecSuccess
    }
}
