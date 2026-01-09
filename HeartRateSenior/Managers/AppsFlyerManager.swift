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
        // Subscription events
        static let startTrial = "start_trial"
        static let subscribe = "subscribe"
        static let purchase = "purchase"
        static let purchaseWeek = "purchase_week"
        static let purchaseYear = "purchase_year"
        
        // Heart rate measurement events
        static let firstStartHeartRate = "first_start_heart_rate"
        static let firstCompleteHeartRate = "first_complete_heart_rate"
        static let startHeartRate = "start_heart_rate"
        static let completeHeartRate = "complete_heart_rate"
        
        // Report events
        static let firstViewReport = "first_view_report"
        
        // Blood record events - First time
        static let firstBloodPressure = "first_blood_pressure"
        static let firstBloodGlucose = "first_blood_glucose"
        static let firstWeight = "first_weight"
        static let firstOxygen = "first_oxygen"
        
        // Blood record events - Every time
        static let bloodPressureInput = "blood_pressure_input"
        static let bloodGlucoseInput = "blood_glucose_input"
        static let weightInput = "weight_input"
        static let oxygenInput = "oxygen_input"
    }
    
    // MARK: - UserDefaults Keys for One-Time Events
    private struct EventKeys {
        // Subscription
        static let startTrialTriggered = "af_event_triggered_start_trial"
        static let subscribeTriggered = "af_event_triggered_subscribe"
        static let purchaseTriggered = "af_event_triggered_purchase"
        static let purchaseWeekTriggered = "af_event_triggered_purchase_week"
        static let purchaseYearTriggered = "af_event_triggered_purchase_year"
        
        // Heart rate
        static let firstStartHeartRateTriggered = "af_event_triggered_first_start_heart_rate"
        static let firstCompleteHeartRateTriggered = "af_event_triggered_first_complete_heart_rate"
        
        // Report
        static let firstViewReportTriggered = "af_event_triggered_first_view_report"
        
        // Blood record
        static let firstBloodPressureTriggered = "af_event_triggered_first_blood_pressure"
        static let firstBloodGlucoseTriggered = "af_event_triggered_first_blood_glucose"
        static let firstWeightTriggered = "af_event_triggered_first_weight"
        static let firstOxygenTriggered = "af_event_triggered_first_oxygen"
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
    
    // MARK: - Subscription Event Tracking Methods
    
    /// Track start_trial event (first-time free trial, $0)
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
    
    /// Track subscribe event (first-time subscription)
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
    
    /// Track purchase_week event
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
    
    /// Track purchase_year event
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
    
    /// Combined subscription purchase handler
    func trackSubscriptionPurchase(productId: String, price: Decimal, currency: String, isFreeTrial: Bool, isWeekly: Bool) {
        trackSubscribe(productId: productId, price: price, currency: currency)
        
        if isFreeTrial {
            trackStartTrial(productId: productId)
        } else {
            trackPurchase(revenue: price, currency: currency)
            
            if isWeekly {
                trackPurchaseWeek(revenue: price, currency: currency)
            } else {
                trackPurchaseYear(revenue: price, currency: currency)
            }
        }
    }
    
    // MARK: - Heart Rate Measurement Events
    
    /// Track start heart rate measurement (both first-time and every-time)
    func trackStartHeartRate() {
        // First time event
        if !hasEventBeenTriggered(EventKeys.firstStartHeartRateTriggered) {
            AppsFlyerLib.shared().logEvent(Events.firstStartHeartRate, withValues: nil)
            markEventTriggered(EventKeys.firstStartHeartRateTriggered)
            print("📊 AppsFlyer: Tracked first_start_heart_rate")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.startHeartRate, withValues: nil)
        print("📊 AppsFlyer: Tracked start_heart_rate")
    }
    
    /// Track complete heart rate measurement (both first-time and every-time)
    func trackCompleteHeartRate(bpm: Int) {
        let params: [String: Any] = ["bpm": bpm]
        
        // First time event
        if !hasEventBeenTriggered(EventKeys.firstCompleteHeartRateTriggered) {
            AppsFlyerLib.shared().logEvent(Events.firstCompleteHeartRate, withValues: params)
            markEventTriggered(EventKeys.firstCompleteHeartRateTriggered)
            print("📊 AppsFlyer: Tracked first_complete_heart_rate - bpm: \(bpm)")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.completeHeartRate, withValues: params)
        print("📊 AppsFlyer: Tracked complete_heart_rate - bpm: \(bpm)")
    }
    
    // MARK: - Report Events
    
    /// Track first view report
    func trackViewReport() {
        if !hasEventBeenTriggered(EventKeys.firstViewReportTriggered) {
            AppsFlyerLib.shared().logEvent(Events.firstViewReport, withValues: nil)
            markEventTriggered(EventKeys.firstViewReportTriggered)
            print("📊 AppsFlyer: Tracked first_view_report")
        }
    }
    
    // MARK: - Blood Record Events
    
    /// Track blood pressure input (both first-time and every-time)
    func trackBloodPressureInput(systolic: Int, diastolic: Int) {
        let params: [String: Any] = ["systolic": systolic, "diastolic": diastolic]
        
        // First time event
        if !hasEventBeenTriggered(EventKeys.firstBloodPressureTriggered) {
            AppsFlyerLib.shared().logEvent(Events.firstBloodPressure, withValues: params)
            markEventTriggered(EventKeys.firstBloodPressureTriggered)
            print("📊 AppsFlyer: Tracked first_blood_pressure")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.bloodPressureInput, withValues: params)
        print("📊 AppsFlyer: Tracked blood_pressure_input - \(systolic)/\(diastolic)")
    }
    
    /// Track blood glucose input (both first-time and every-time)
    func trackBloodGlucoseInput(value: Double) {
        let params: [String: Any] = ["value": value]
        
        // First time event
        if !hasEventBeenTriggered(EventKeys.firstBloodGlucoseTriggered) {
            AppsFlyerLib.shared().logEvent(Events.firstBloodGlucose, withValues: params)
            markEventTriggered(EventKeys.firstBloodGlucoseTriggered)
            print("📊 AppsFlyer: Tracked first_blood_glucose")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.bloodGlucoseInput, withValues: params)
        print("📊 AppsFlyer: Tracked blood_glucose_input - \(value)")
    }
    
    /// Track weight input (both first-time and every-time)
    func trackWeightInput(weight: Double) {
        let params: [String: Any] = ["weight": weight]
        
        // First time event
        if !hasEventBeenTriggered(EventKeys.firstWeightTriggered) {
            AppsFlyerLib.shared().logEvent(Events.firstWeight, withValues: params)
            markEventTriggered(EventKeys.firstWeightTriggered)
            print("📊 AppsFlyer: Tracked first_weight")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.weightInput, withValues: params)
        print("📊 AppsFlyer: Tracked weight_input - \(weight)")
    }
    
    /// Track oxygen input (both first-time and every-time)
    func trackOxygenInput(value: Int) {
        let params: [String: Any] = ["value": value]
        
        // First time event
        if !hasEventBeenTriggered(EventKeys.firstOxygenTriggered) {
            AppsFlyerLib.shared().logEvent(Events.firstOxygen, withValues: params)
            markEventTriggered(EventKeys.firstOxygenTriggered)
            print("📊 AppsFlyer: Tracked first_oxygen")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.oxygenInput, withValues: params)
        print("📊 AppsFlyer: Tracked oxygen_input - \(value)")
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
        let allKeys = [
            EventKeys.startTrialTriggered,
            EventKeys.subscribeTriggered,
            EventKeys.purchaseTriggered,
            EventKeys.purchaseWeekTriggered,
            EventKeys.purchaseYearTriggered,
            EventKeys.firstStartHeartRateTriggered,
            EventKeys.firstCompleteHeartRateTriggered,
            EventKeys.firstViewReportTriggered,
            EventKeys.firstBloodPressureTriggered,
            EventKeys.firstBloodGlucoseTriggered,
            EventKeys.firstWeightTriggered,
            EventKeys.firstOxygenTriggered
        ]
        
        for key in allKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
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
