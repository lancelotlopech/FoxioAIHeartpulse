//
//  AppsFlyerManager.swift
//  HeartRateSenior
//
//  AppsFlyer SDK integration for attribution and event tracking
//

import Foundation
import AppsFlyerLib
import AppTrackingTransparency

@MainActor
class AppsFlyerManager: NSObject, ObservableObject {
    static let shared = AppsFlyerManager()
    
    // MARK: - Configuration
    private let devKey = "CtmGi8XvHDGY2jrdXcSCyN"
    private let appleAppID = "6757157988"
    
    // MARK: - Event Names
    struct Events {
        static let startTrial = "start_trial"
        static let subscribe = "subscribe"
        static let purchase = "purchase"
        static let purchaseWeek = "purchase_week"
        static let purchaseYear = "purchase_year"
    }
    
    // MARK: - UserDefaults Keys for One-Time Events
    private struct EventKeys {
        static let startTrialTriggered = "af_event_triggered_start_trial"
        static let subscribeTriggered = "af_event_triggered_subscribe"
        static let purchaseTriggered = "af_event_triggered_purchase"
        static let purchaseWeekTriggered = "af_event_triggered_purchase_week"
        static let purchaseYearTriggered = "af_event_triggered_purchase_year"
    }
    
    // MARK: - Initialization
    private override init() {
        super.init()
    }
    
    // MARK: - SDK Configuration
    func configure() {
        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().appleAppID = appleAppID
        AppsFlyerLib.shared().delegate = self
        
        // Enable debug mode in DEBUG builds
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif
        
        // Wait for ATT before starting
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        print("📊 AppsFlyer: SDK configured")
    }
    
    // MARK: - Start SDK (call after ATT authorization)
    func start() {
        AppsFlyerLib.shared().start()
        print("📊 AppsFlyer: SDK started")
    }
    
    // MARK: - ATT Authorization Handler
    func handleATTAuthorization(status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            print("📊 AppsFlyer: ATT authorized - starting with IDFA")
        case .denied, .restricted:
            print("📊 AppsFlyer: ATT denied/restricted - starting without IDFA")
        case .notDetermined:
            print("📊 AppsFlyer: ATT not determined")
        @unknown default:
            print("📊 AppsFlyer: ATT unknown status")
        }
        
        // Always start SDK after ATT response
        start()
    }
    
    // MARK: - Event Tracking Methods
    
    /// Track start_trial event (first-time free trial, $0)
    /// - Parameter productId: The product identifier
    func trackStartTrial(productId: String) {
        guard !hasEventBeenTriggered(EventKeys.startTrialTriggered) else {
            print("📊 AppsFlyer: start_trial already triggered, skipping")
            return
        }
        
        let params: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamContentType: "subscription"
        ]
        
        AppsFlyerLib.shared().logEvent(Events.startTrial, withValues: params)
        markEventTriggered(EventKeys.startTrialTriggered)
        print("📊 AppsFlyer: Tracked start_trial - productId: \(productId)")
    }
    
    /// Track subscribe event (first-time subscription, includes trial + paid)
    /// - Parameters:
    ///   - productId: The product identifier
    ///   - price: The subscription price
    ///   - currency: The currency code (e.g., "USD")
    func trackSubscribe(productId: String, price: Decimal, currency: String) {
        guard !hasEventBeenTriggered(EventKeys.subscribeTriggered) else {
            print("📊 AppsFlyer: subscribe already triggered, skipping")
            return
        }
        
        let params: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamContentType: "subscription",
            AFEventParamPrice: NSDecimalNumber(decimal: price).doubleValue,
            AFEventParamCurrency: currency
        ]
        
        AppsFlyerLib.shared().logEvent(Events.subscribe, withValues: params)
        markEventTriggered(EventKeys.subscribeTriggered)
        print("📊 AppsFlyer: Tracked subscribe - productId: \(productId), price: \(price) \(currency)")
    }
    
    /// Track purchase event (actual payment, all types)
    /// - Parameters:
    ///   - revenue: The actual revenue amount
    ///   - currency: The currency code
    func trackPurchase(revenue: Decimal, currency: String) {
        guard !hasEventBeenTriggered(EventKeys.purchaseTriggered) else {
            print("📊 AppsFlyer: purchase already triggered, skipping")
            return
        }
        
        let params: [String: Any] = [
            AFEventParamRevenue: NSDecimalNumber(decimal: revenue).doubleValue,
            AFEventParamCurrency: currency,
            AFEventParamContentType: "subscription"
        ]
        
        AppsFlyerLib.shared().logEvent(Events.purchase, withValues: params)
        markEventTriggered(EventKeys.purchaseTriggered)
        print("📊 AppsFlyer: Tracked purchase - revenue: \(revenue) \(currency)")
    }
    
    /// Track purchase_week event (weekly subscription actual payment)
    /// - Parameters:
    ///   - revenue: The actual revenue amount
    ///   - currency: The currency code
    func trackPurchaseWeek(revenue: Decimal, currency: String) {
        guard !hasEventBeenTriggered(EventKeys.purchaseWeekTriggered) else {
            print("📊 AppsFlyer: purchase_week already triggered, skipping")
            return
        }
        
        let params: [String: Any] = [
            AFEventParamRevenue: NSDecimalNumber(decimal: revenue).doubleValue,
            AFEventParamCurrency: currency,
            AFEventParamContentType: "weekly_subscription"
        ]
        
        AppsFlyerLib.shared().logEvent(Events.purchaseWeek, withValues: params)
        markEventTriggered(EventKeys.purchaseWeekTriggered)
        print("📊 AppsFlyer: Tracked purchase_week - revenue: \(revenue) \(currency)")
    }
    
    /// Track purchase_year event (yearly subscription actual payment)
    /// - Parameters:
    ///   - revenue: The actual revenue amount
    ///   - currency: The currency code
    func trackPurchaseYear(revenue: Decimal, currency: String) {
        guard !hasEventBeenTriggered(EventKeys.purchaseYearTriggered) else {
            print("📊 AppsFlyer: purchase_year already triggered, skipping")
            return
        }
        
        let params: [String: Any] = [
            AFEventParamRevenue: NSDecimalNumber(decimal: revenue).doubleValue,
            AFEventParamCurrency: currency,
            AFEventParamContentType: "yearly_subscription"
        ]
        
        AppsFlyerLib.shared().logEvent(Events.purchaseYear, withValues: params)
        markEventTriggered(EventKeys.purchaseYearTriggered)
        print("📊 AppsFlyer: Tracked purchase_year - revenue: \(revenue) \(currency)")
    }
    
    // MARK: - Subscription Purchase Handler
    /// Call this method when a subscription purchase is successful
    /// - Parameters:
    ///   - productId: The product identifier
    ///   - price: The subscription price
    ///   - currency: The currency code
    ///   - isFreeTrial: Whether this is a free trial
    ///   - isWeekly: Whether this is a weekly subscription
    func trackSubscriptionPurchase(productId: String, price: Decimal, currency: String, isFreeTrial: Bool, isWeekly: Bool) {
        // 1. Track subscribe (first-time, includes trial + paid)
        trackSubscribe(productId: productId, price: price, currency: currency)
        
        // 2. Track start_trial if it's a free trial ($0)
        if isFreeTrial {
            trackStartTrial(productId: productId)
        } else {
            // 3. Track actual payment events (only for non-trial)
            trackPurchase(revenue: price, currency: currency)
            
            if isWeekly {
                trackPurchaseWeek(revenue: price, currency: currency)
            } else {
                trackPurchaseYear(revenue: price, currency: currency)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func hasEventBeenTriggered(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    private func markEventTriggered(_ key: String) {
        UserDefaults.standard.set(true, forKey: key)
    }
    
    /// Reset all event triggers (for testing purposes)
    func resetAllEventTriggers() {
        UserDefaults.standard.removeObject(forKey: EventKeys.startTrialTriggered)
        UserDefaults.standard.removeObject(forKey: EventKeys.subscribeTriggered)
        UserDefaults.standard.removeObject(forKey: EventKeys.purchaseTriggered)
        UserDefaults.standard.removeObject(forKey: EventKeys.purchaseWeekTriggered)
        UserDefaults.standard.removeObject(forKey: EventKeys.purchaseYearTriggered)
        print("📊 AppsFlyer: All event triggers reset")
    }
}

// MARK: - AppsFlyerLibDelegate
extension AppsFlyerManager: AppsFlyerLibDelegate {
    nonisolated func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("📊 AppsFlyer: Conversion data received")
        
        if let status = conversionInfo["af_status"] as? String {
            if status == "Non-organic" {
                if let sourceID = conversionInfo["media_source"],
                   let campaign = conversionInfo["campaign"] {
                    print("📊 AppsFlyer: Non-organic install - Source: \(sourceID), Campaign: \(campaign)")
                }
            } else {
                print("📊 AppsFlyer: Organic install")
            }
        }
    }
    
    nonisolated func onConversionDataFail(_ error: Error) {
        print("📊 AppsFlyer: Conversion data error - \(error.localizedDescription)")
    }
    
    nonisolated func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        print("📊 AppsFlyer: App open attribution received")
        if let sourceID = attributionData["media_source"] {
            print("📊 AppsFlyer: Attribution source: \(sourceID)")
        }
    }
    
    nonisolated func onAppOpenAttributionFailure(_ error: Error) {
        print("📊 AppsFlyer: App open attribution error - \(error.localizedDescription)")
    }
}
