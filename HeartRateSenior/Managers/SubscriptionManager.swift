//
//  SubscriptionManager.swift
//  HeartRateSenior
//
//  StoreKit subscription management
//

import StoreKit
import SwiftUI

// MARK: - Debug Settings (仅 DEBUG 模式下有效)
#if DEBUG
@MainActor
class DebugSettings: ObservableObject {
    static let shared = DebugSettings()
    
    enum PremiumOverride: String, CaseIterable {
        case realStatus = "Real"
        case mockFree = "Free"
        case mockPro = "Pro"
    }
    
    @Published var premiumOverride: PremiumOverride = .realStatus
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    private init() {}
    
    /// 返回是否应该模拟 Premium 状态
    var shouldMockPremium: Bool? {
        switch premiumOverride {
        case .realStatus: return nil
        case .mockFree: return false
        case .mockPro: return true
        }
    }
    
    /// 重置引导页状态
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
    
    /// 标记引导页已完成
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}
#endif

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Feature Gating Properties
    @AppStorage("dailyMeasurementCount") private var dailyMeasurementCount: Int = 0
    @AppStorage("lastMeasurementDate") private var lastMeasurementDateString: String = ""
    @AppStorage("totalMeasurementCount") private var totalMeasurementCount: Int = 0
    
    // MARK: - Computed Properties
    var isPremium: Bool {
        #if DEBUG
        // Debug 模式下支持覆盖订阅状态
        if let override = DebugSettings.shared.shouldMockPremium {
            return override
        }
        #endif
        return !purchasedProductIDs.isEmpty
    }
    
    // MARK: - Feature Gating Computed Properties
    var canMeasureToday: Bool {
        if isPremium { return true }
        resetDailyCountIfNeeded()
        return dailyMeasurementCount < PaywallConfiguration.freeDailyMeasurements
    }
    
    var remainingMeasurementsToday: Int {
        if isPremium { return 999 }
        resetDailyCountIfNeeded()
        return max(0, PaywallConfiguration.freeDailyMeasurements - dailyMeasurementCount)
    }
    
    var shouldShowPaywallUpsell: Bool {
        if isPremium { return false }
        return totalMeasurementCount >= PaywallConfiguration.showPaywallAfterMeasurements
    }
    
    var canAccessAdvancedHRV: Bool {
        isPremium || !PaywallConfiguration.lockAdvancedHRV
    }
    
    var canExportPDF: Bool {
        isPremium || !PaywallConfiguration.lockPDFExport
    }
    
    var canAccessUnlimitedHistory: Bool {
        isPremium || !PaywallConfiguration.lockUnlimitedHistory
    }
    
    var historyDaysLimit: Int? {
        if isPremium { return nil }
        return PaywallConfiguration.freeHistoryDays
    }
    
    var weeklyProduct: Product? {
        products.first { $0.id == PaywallConfiguration.weeklyProductID }
    }
    
    var yearlyProduct: Product? {
        products.first { $0.id == PaywallConfiguration.yearlyProductID }
    }
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    private let productIDs = [
        PaywallConfiguration.weeklyProductID,
        PaywallConfiguration.yearlyProductID
    ]
    
    // MARK: - Initialization
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Failed to load products: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Product
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                
                // Track AppsFlyer events
                await trackAppsFlyerPurchase(product: product, transaction: transaction)
                
                return true
                
            case .userCancelled:
                return false
                
            case .pending:
                errorMessage = "Purchase is pending approval"
                return false
                
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Update Purchased Products
    func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.revocationDate == nil {
                purchased.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchased
    }
    
    // MARK: - Listen for Transactions
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - AppsFlyer Event Tracking
    private func trackAppsFlyerPurchase(product: Product, transaction: StoreKit.Transaction) async {
        let productId = product.id
        let price = product.price
        let currency = product.priceFormatStyle.currencyCode ?? "USD"
        let isWeekly = product.id == PaywallConfiguration.weeklyProductID
        
        // Check if this transaction has an introductory offer (free trial)
        let isFreeTrial = transaction.offerType == StoreKit.Transaction.OfferType.introductory && transaction.offerID != nil
        
        // Track subscription purchase with AppsFlyer
        AppsFlyerManager.shared.trackSubscriptionPurchase(
            productId: productId,
            price: price,
            currency: currency,
            isFreeTrial: isFreeTrial,
            isWeekly: isWeekly
        )
    }
    
    // MARK: - Format Price
    func formattedPrice(for product: Product) -> String {
        product.displayPrice
    }
    
    func pricePerWeek(for product: Product) -> String? {
        guard product.id == PaywallConfiguration.yearlyProductID else { return nil }
        let weeklyPrice = product.price / 52
        return weeklyPrice.formatted(.currency(code: product.priceFormatStyle.currencyCode ?? "USD"))
    }
    
    // MARK: - Feature Gating Methods
    
    /// 重置每日计数（如果是新的一天）
    private func resetDailyCountIfNeeded() {
        let today = formattedDate(Date())
        if lastMeasurementDateString != today {
            dailyMeasurementCount = 0
            lastMeasurementDateString = today
        }
    }
    
    /// 记录一次测量
    func recordMeasurement() {
        resetDailyCountIfNeeded()
        dailyMeasurementCount += 1
        totalMeasurementCount += 1
    }
    
    /// 格式化日期为字符串
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// 获取历史记录的截止日期（免费用户）
    func historyStartDate() -> Date? {
        guard let days = historyDaysLimit else { return nil }
        return Calendar.current.date(byAdding: .day, value: -days, to: Date())
    }
}

// MARK: - Store Error
enum StoreError: Error, LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
