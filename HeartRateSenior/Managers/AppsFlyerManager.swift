//
//  AppsFlyerManager.swift
//  HeartRateSenior
//
//  AppsFlyer SDK integration for attribution and event tracking
//

import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import FacebookCore

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
    
    // Use unified event tracking manager
    private let eventManager = EventTrackingManager.shared
    
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
        guard eventManager.canTriggerStartTrial() else {
            print("📊 AppsFlyer: start_trial already triggered, skipping")
            return
        }
        
        let params: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamContentType: "subscription"
        ]
        
        AppsFlyerLib.shared().logEvent(Events.startTrial, withValues: params)
        eventManager.markStartTrialTriggered()
        print("📊 AppsFlyer: Tracked start_trial - productId: \(productId)")
        FacebookSDKManager.shared.trackStartTrial(productId: productId)
    }
    
    /// Track subscribe event (first-time subscription)
    func trackSubscribe(productId: String, price: Decimal, currency: String) {
        guard eventManager.canTriggerSubscribe() else {
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
        eventManager.markSubscribeTriggered()
        print("📊 AppsFlyer: Tracked subscribe - productId: \(productId), price: \(price) \(currency)")
        FacebookSDKManager.shared.trackSubscribe(productId: productId, price: price, currency: currency)
    }
    
    /// Track purchase event (actual payment, all types)
    func trackPurchase(revenue: Decimal, currency: String) {
        guard eventManager.canTriggerPurchase() else {
            print("📊 AppsFlyer: purchase already triggered, skipping")
            return
        }
        
        let params: [String: Any] = [
            AFEventParamRevenue: NSDecimalNumber(decimal: revenue).doubleValue,
            AFEventParamCurrency: currency,
            AFEventParamContentType: "subscription"
        ]
        
        AppsFlyerLib.shared().logEvent(Events.purchase, withValues: params)
        eventManager.markPurchaseTriggered()
        print("📊 AppsFlyer: Tracked purchase - revenue: \(revenue) \(currency)")
        FacebookSDKManager.shared.trackPurchase(revenue: revenue, currency: currency)
    }
    
    /// Track purchase_week event
    func trackPurchaseWeek(revenue: Decimal, currency: String) {
        guard eventManager.canTriggerPurchaseWeek() else {
            print("📊 AppsFlyer: purchase_week already triggered, skipping")
            return
        }
        
        let params: [String: Any] = [
            AFEventParamRevenue: NSDecimalNumber(decimal: revenue).doubleValue,
            AFEventParamCurrency: currency,
            AFEventParamContentType: "weekly_subscription"
        ]
        
        AppsFlyerLib.shared().logEvent(Events.purchaseWeek, withValues: params)
        eventManager.markPurchaseWeekTriggered()
        print("📊 AppsFlyer: Tracked purchase_week - revenue: \(revenue) \(currency)")
        FacebookSDKManager.shared.trackPurchaseWeek(revenue: revenue, currency: currency)
    }
    
    /// Track purchase_year event
    func trackPurchaseYear(revenue: Decimal, currency: String) {
        guard eventManager.canTriggerPurchaseYear() else {
            print("📊 AppsFlyer: purchase_year already triggered, skipping")
            return
        }
        
        let params: [String: Any] = [
            AFEventParamRevenue: NSDecimalNumber(decimal: revenue).doubleValue,
            AFEventParamCurrency: currency,
            AFEventParamContentType: "yearly_subscription"
        ]
        
        AppsFlyerLib.shared().logEvent(Events.purchaseYear, withValues: params)
        eventManager.markPurchaseYearTriggered()
        print("📊 AppsFlyer: Tracked purchase_year - revenue: \(revenue) \(currency)")
        FacebookSDKManager.shared.trackPurchaseYear(revenue: revenue, currency: currency)
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
        if eventManager.canTriggerFirstStartHeartRate() {
            AppsFlyerLib.shared().logEvent(Events.firstStartHeartRate, withValues: nil)
            eventManager.markFirstStartHeartRateTriggered()
            print("📊 AppsFlyer: Tracked first_start_heart_rate")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.startHeartRate, withValues: nil)
        print("📊 AppsFlyer: Tracked start_heart_rate")
        FacebookSDKManager.shared.trackStartHeartRate()
    }
    
    /// Track complete heart rate measurement (both first-time and every-time)
    func trackCompleteHeartRate(bpm: Int) {
        let params: [String: Any] = ["bpm": bpm]
        
        // First time event
        if eventManager.canTriggerFirstCompleteHeartRate() {
            AppsFlyerLib.shared().logEvent(Events.firstCompleteHeartRate, withValues: params)
            eventManager.markFirstCompleteHeartRateTriggered()
            print("📊 AppsFlyer: Tracked first_complete_heart_rate - bpm: \(bpm)")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.completeHeartRate, withValues: params)
        print("📊 AppsFlyer: Tracked complete_heart_rate - bpm: \(bpm)")
        FacebookSDKManager.shared.trackCompleteHeartRate(bpm: bpm)
    }
    
    // MARK: - Report Events
    
    /// Track first view report
    func trackViewReport() {
        if eventManager.canTriggerFirstViewReport() {
            AppsFlyerLib.shared().logEvent(Events.firstViewReport, withValues: nil)
            eventManager.markFirstViewReportTriggered()
            print("📊 AppsFlyer: Tracked first_view_report")
            FacebookSDKManager.shared.trackViewReport()
        }
    }
    
    // MARK: - Blood Record Events
    
    /// Track blood pressure input (both first-time and every-time)
    func trackBloodPressureInput(systolic: Int, diastolic: Int) {
        let params: [String: Any] = ["systolic": systolic, "diastolic": diastolic]
        
        // First time event
        if eventManager.canTriggerFirstBloodPressure() {
            AppsFlyerLib.shared().logEvent(Events.firstBloodPressure, withValues: params)
            eventManager.markFirstBloodPressureTriggered()
            print("📊 AppsFlyer: Tracked first_blood_pressure")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.bloodPressureInput, withValues: params)
        print("📊 AppsFlyer: Tracked blood_pressure_input - \(systolic)/\(diastolic)")
        FacebookSDKManager.shared.trackBloodPressureInput(systolic: systolic, diastolic: diastolic)
    }
    
    /// Track blood glucose input (both first-time and every-time)
    func trackBloodGlucoseInput(value: Double) {
        let params: [String: Any] = ["value": value]
        
        // First time event
        if eventManager.canTriggerFirstBloodGlucose() {
            AppsFlyerLib.shared().logEvent(Events.firstBloodGlucose, withValues: params)
            eventManager.markFirstBloodGlucoseTriggered()
            print("📊 AppsFlyer: Tracked first_blood_glucose")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.bloodGlucoseInput, withValues: params)
        print("📊 AppsFlyer: Tracked blood_glucose_input - \(value)")
        FacebookSDKManager.shared.trackBloodGlucoseInput(value: value)
    }
    
    /// Track weight input (both first-time and every-time)
    func trackWeightInput(weight: Double) {
        let params: [String: Any] = ["weight": weight]
        
        // First time event
        if eventManager.canTriggerFirstWeight() {
            AppsFlyerLib.shared().logEvent(Events.firstWeight, withValues: params)
            eventManager.markFirstWeightTriggered()
            print("📊 AppsFlyer: Tracked first_weight")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.weightInput, withValues: params)
        print("📊 AppsFlyer: Tracked weight_input - \(weight)")
        FacebookSDKManager.shared.trackWeightInput(weight: weight)
    }
    
    /// Track oxygen input (both first-time and every-time)
    func trackOxygenInput(value: Int) {
        let params: [String: Any] = ["value": value]
        
        // First time event
        if eventManager.canTriggerFirstOxygen() {
            AppsFlyerLib.shared().logEvent(Events.firstOxygen, withValues: params)
            eventManager.markFirstOxygenTriggered()
            print("📊 AppsFlyer: Tracked first_oxygen")
        }
        
        // Every time event
        AppsFlyerLib.shared().logEvent(Events.oxygenInput, withValues: params)
        print("📊 AppsFlyer: Tracked oxygen_input - \(value)")
        FacebookSDKManager.shared.trackOxygenInput(value: value)
    }
    
    // MARK: - Reset (for testing)
    
    /// Reset all event triggers (for testing purposes)
    func resetAllEventTriggers() {
        eventManager.resetAllEventTriggers()
        print("📊 AppsFlyer: All event triggers reset via EventTrackingManager")
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
