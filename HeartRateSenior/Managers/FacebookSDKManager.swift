//
//  FacebookSDKManager.swift
//  HeartRateSenior
//
//  Facebook SDK integration for event tracking (mirrors AppsFlyer events)
//

import Foundation
import FacebookCore

@MainActor
class FacebookSDKManager: ObservableObject {
    static let shared = FacebookSDKManager()
    
    // MARK: - Configuration
    static let appID = "905154591983080"
    static let clientToken = "d35f41b45b80899af61789d2aa590351"
    static let displayName = "i heart"
    
    // Use unified event tracking manager
    private let eventManager = EventTrackingManager.shared
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - SDK Configuration
    func configure() {
        Settings.shared.appID = FacebookSDKManager.appID
        Settings.shared.clientToken = FacebookSDKManager.clientToken
        Settings.shared.displayName = FacebookSDKManager.displayName
        
        // Enable advertiser tracking if ATT authorized
        Settings.shared.isAdvertiserTrackingEnabled = true
        
        // Enable auto log app events
        Settings.shared.isAutoLogAppEventsEnabled = true
        
        #if DEBUG
        Settings.shared.enableLoggingBehavior(.appEvents)
        #endif
        
        print("📘 Facebook: SDK configured - AppID: \(FacebookSDKManager.appID)")
    }
    
    // MARK: - ATT Authorization Handler
    func handleATTAuthorization(authorized: Bool) {
        Settings.shared.isAdvertiserTrackingEnabled = authorized
        print("📘 Facebook: Advertiser tracking \(authorized ? "enabled" : "disabled")")
    }
    
    // MARK: - Subscription Event Tracking
    
    func trackStartTrial(productId: String) {
        guard eventManager.canTriggerStartTrial() else {
            print("📘 Facebook: start_trial already triggered, skipping")
            return
        }
        
        // Use Facebook standard StartTrial event
        AppEvents.shared.logEvent(.startTrial, parameters: [
            AppEvents.ParameterName.content: productId,
            AppEvents.ParameterName.contentType: "subscription"
        ])
        
        eventManager.markStartTrialTriggered()
        print("📘 Facebook: Tracked StartTrial - productId: \(productId)")
    }
    
    func trackSubscribe(productId: String, price: Decimal, currency: String) {
        guard eventManager.canTriggerSubscribe() else {
            print("📘 Facebook: subscribe already triggered, skipping")
            return
        }
        
        // Use Facebook standard Subscribe event
        AppEvents.shared.logEvent(.subscribe, valueToSum: NSDecimalNumber(decimal: price).doubleValue, parameters: [
            AppEvents.ParameterName.content: productId,
            AppEvents.ParameterName.contentType: "subscription",
            AppEvents.ParameterName.currency: currency
        ])
        
        eventManager.markSubscribeTriggered()
        print("📘 Facebook: Tracked Subscribe - productId: \(productId), price: \(price) \(currency)")
    }
    
    func trackPurchase(revenue: Decimal, currency: String) {
        guard eventManager.canTriggerPurchase() else {
            print("📘 Facebook: purchase already triggered, skipping")
            return
        }
        
        // Use Facebook standard Purchase event
        AppEvents.shared.logPurchase(amount: NSDecimalNumber(decimal: revenue).doubleValue, currency: currency, parameters: [
            AppEvents.ParameterName.contentType: "subscription"
        ])
        
        eventManager.markPurchaseTriggered()
        print("📘 Facebook: Tracked Purchase - revenue: \(revenue) \(currency)")
    }
    
    func trackPurchaseWeek(revenue: Decimal, currency: String) {
        guard eventManager.canTriggerPurchaseWeek() else {
            print("📘 Facebook: purchase_week already triggered, skipping")
            return
        }
        
        // Custom event for weekly subscription
        AppEvents.shared.logEvent(AppEvents.Name("purchase_week"), valueToSum: NSDecimalNumber(decimal: revenue).doubleValue, parameters: [
            AppEvents.ParameterName.currency: currency,
            AppEvents.ParameterName.contentType: "weekly_subscription"
        ])
        
        eventManager.markPurchaseWeekTriggered()
        print("📘 Facebook: Tracked purchase_week - revenue: \(revenue) \(currency)")
    }
    
    func trackPurchaseYear(revenue: Decimal, currency: String) {
        guard eventManager.canTriggerPurchaseYear() else {
            print("📘 Facebook: purchase_year already triggered, skipping")
            return
        }
        
        // Custom event for yearly subscription
        AppEvents.shared.logEvent(AppEvents.Name("purchase_year"), valueToSum: NSDecimalNumber(decimal: revenue).doubleValue, parameters: [
            AppEvents.ParameterName.currency: currency,
            AppEvents.ParameterName.contentType: "yearly_subscription"
        ])
        
        eventManager.markPurchaseYearTriggered()
        print("📘 Facebook: Tracked purchase_year - revenue: \(revenue) \(currency)")
    }
    
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
    
    func trackStartHeartRate() {
        if eventManager.canTriggerFirstStartHeartRate() {
            AppEvents.shared.logEvent(AppEvents.Name("first_start_heart_rate"))
            eventManager.markFirstStartHeartRateTriggered()
            print("📘 Facebook: Tracked first_start_heart_rate")
        }
        
        AppEvents.shared.logEvent(AppEvents.Name("start_heart_rate"))
        print("📘 Facebook: Tracked start_heart_rate")
    }
    
    func trackCompleteHeartRate(bpm: Int) {
        let params: [AppEvents.ParameterName: Any] = [
            AppEvents.ParameterName("bpm"): bpm
        ]
        
        if eventManager.canTriggerFirstCompleteHeartRate() {
            AppEvents.shared.logEvent(AppEvents.Name("first_complete_heart_rate"), parameters: params)
            eventManager.markFirstCompleteHeartRateTriggered()
            print("📘 Facebook: Tracked first_complete_heart_rate - bpm: \(bpm)")
        }
        
        AppEvents.shared.logEvent(AppEvents.Name("complete_heart_rate"), parameters: params)
        print("📘 Facebook: Tracked complete_heart_rate - bpm: \(bpm)")
    }
    
    // MARK: - Report Events
    
    func trackViewReport() {
        if eventManager.canTriggerFirstViewReport() {
            AppEvents.shared.logEvent(AppEvents.Name("first_view_report"))
            eventManager.markFirstViewReportTriggered()
            print("📘 Facebook: Tracked first_view_report")
        }
    }
    
    // MARK: - Blood Record Events
    
    func trackBloodPressureInput(systolic: Int, diastolic: Int) {
        let params: [AppEvents.ParameterName: Any] = [
            AppEvents.ParameterName("systolic"): systolic,
            AppEvents.ParameterName("diastolic"): diastolic
        ]
        
        if eventManager.canTriggerFirstBloodPressure() {
            AppEvents.shared.logEvent(AppEvents.Name("first_blood_pressure"), parameters: params)
            eventManager.markFirstBloodPressureTriggered()
            print("📘 Facebook: Tracked first_blood_pressure")
        }
        
        AppEvents.shared.logEvent(AppEvents.Name("blood_pressure_input"), parameters: params)
        print("📘 Facebook: Tracked blood_pressure_input - \(systolic)/\(diastolic)")
    }
    
    func trackBloodGlucoseInput(value: Double) {
        let params: [AppEvents.ParameterName: Any] = [
            AppEvents.ParameterName("value"): value
        ]
        
        if eventManager.canTriggerFirstBloodGlucose() {
            AppEvents.shared.logEvent(AppEvents.Name("first_blood_glucose"), parameters: params)
            eventManager.markFirstBloodGlucoseTriggered()
            print("📘 Facebook: Tracked first_blood_glucose")
        }
        
        AppEvents.shared.logEvent(AppEvents.Name("blood_glucose_input"), parameters: params)
        print("📘 Facebook: Tracked blood_glucose_input - \(value)")
    }
    
    func trackWeightInput(weight: Double) {
        let params: [AppEvents.ParameterName: Any] = [
            AppEvents.ParameterName("weight"): weight
        ]
        
        if eventManager.canTriggerFirstWeight() {
            AppEvents.shared.logEvent(AppEvents.Name("first_weight"), parameters: params)
            eventManager.markFirstWeightTriggered()
            print("📘 Facebook: Tracked first_weight")
        }
        
        AppEvents.shared.logEvent(AppEvents.Name("weight_input"), parameters: params)
        print("📘 Facebook: Tracked weight_input - \(weight)")
    }
    
    func trackOxygenInput(value: Int) {
        let params: [AppEvents.ParameterName: Any] = [
            AppEvents.ParameterName("value"): value
        ]
        
        if eventManager.canTriggerFirstOxygen() {
            AppEvents.shared.logEvent(AppEvents.Name("first_oxygen"), parameters: params)
            eventManager.markFirstOxygenTriggered()
            print("📘 Facebook: Tracked first_oxygen")
        }
        
        AppEvents.shared.logEvent(AppEvents.Name("oxygen_input"), parameters: params)
        print("📘 Facebook: Tracked oxygen_input - \(value)")
    }
    
    // MARK: - Reset (for testing)
    
    func resetAllEventTriggers() {
        eventManager.resetAllEventTriggers()
        print("📘 Facebook: All event triggers reset via EventTrackingManager")
    }
}
