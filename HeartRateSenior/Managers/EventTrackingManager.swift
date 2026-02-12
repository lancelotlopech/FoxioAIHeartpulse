//
//  EventTrackingManager.swift
//  HeartRateSenior
//
//  Unified event tracking manager for AppsFlyer and Facebook SDK
//  Ensures data consistency between both platforms
//

import Foundation

/// 统一的事件追踪管理器,确保 AppsFlyer 和 Facebook SDK 数据一致
class EventTrackingManager {
    static let shared = EventTrackingManager()
    
    // MARK: - Unified UserDefaults Keys
    private struct EventKeys {
        // Subscription events
        static let startTrialTriggered = "event_triggered_start_trial"
        static let subscribeTriggered = "event_triggered_subscribe"
        static let purchaseTriggered = "event_triggered_purchase"
        static let purchaseWeekTriggered = "event_triggered_purchase_week"
        static let purchaseYearTriggered = "event_triggered_purchase_year"
        
        // Heart rate events
        static let firstStartHeartRateTriggered = "event_triggered_first_start_heart_rate"
        static let firstCompleteHeartRateTriggered = "event_triggered_first_complete_heart_rate"
        
        // Report events
        static let firstViewReportTriggered = "event_triggered_first_view_report"
        
        // Blood record events
        static let firstBloodPressureTriggered = "event_triggered_first_blood_pressure"
        static let firstBloodGlucoseTriggered = "event_triggered_first_blood_glucose"
        static let firstWeightTriggered = "event_triggered_first_weight"
        static let firstOxygenTriggered = "event_triggered_first_oxygen"
    }
    
    private init() {}
    
    // MARK: - Event Status Check
    
    func hasEventBeenTriggered(_ key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func markEventTriggered(_ key: String) {
        UserDefaults.standard.set(true, forKey: key)
        print("🔄 EventTracking: Marked '\(key)' as triggered")
    }
    
    // MARK: - Subscription Events
    
    func canTriggerStartTrial() -> Bool {
        return !hasEventBeenTriggered(EventKeys.startTrialTriggered)
    }
    
    func markStartTrialTriggered() {
        markEventTriggered(EventKeys.startTrialTriggered)
    }
    
    func canTriggerSubscribe() -> Bool {
        return !hasEventBeenTriggered(EventKeys.subscribeTriggered)
    }
    
    func markSubscribeTriggered() {
        markEventTriggered(EventKeys.subscribeTriggered)
    }
    
    func canTriggerPurchase() -> Bool {
        return !hasEventBeenTriggered(EventKeys.purchaseTriggered)
    }
    
    func markPurchaseTriggered() {
        markEventTriggered(EventKeys.purchaseTriggered)
    }
    
    func canTriggerPurchaseWeek() -> Bool {
        return !hasEventBeenTriggered(EventKeys.purchaseWeekTriggered)
    }
    
    func markPurchaseWeekTriggered() {
        markEventTriggered(EventKeys.purchaseWeekTriggered)
    }
    
    func canTriggerPurchaseYear() -> Bool {
        return !hasEventBeenTriggered(EventKeys.purchaseYearTriggered)
    }
    
    func markPurchaseYearTriggered() {
        markEventTriggered(EventKeys.purchaseYearTriggered)
    }
    
    // MARK: - Heart Rate Events
    
    func canTriggerFirstStartHeartRate() -> Bool {
        return !hasEventBeenTriggered(EventKeys.firstStartHeartRateTriggered)
    }
    
    func markFirstStartHeartRateTriggered() {
        markEventTriggered(EventKeys.firstStartHeartRateTriggered)
    }
    
    func canTriggerFirstCompleteHeartRate() -> Bool {
        return !hasEventBeenTriggered(EventKeys.firstCompleteHeartRateTriggered)
    }
    
    func markFirstCompleteHeartRateTriggered() {
        markEventTriggered(EventKeys.firstCompleteHeartRateTriggered)
    }
    
    // MARK: - Report Events
    
    func canTriggerFirstViewReport() -> Bool {
        return !hasEventBeenTriggered(EventKeys.firstViewReportTriggered)
    }
    
    func markFirstViewReportTriggered() {
        markEventTriggered(EventKeys.firstViewReportTriggered)
    }
    
    // MARK: - Blood Record Events
    
    func canTriggerFirstBloodPressure() -> Bool {
        return !hasEventBeenTriggered(EventKeys.firstBloodPressureTriggered)
    }
    
    func markFirstBloodPressureTriggered() {
        markEventTriggered(EventKeys.firstBloodPressureTriggered)
    }
    
    func canTriggerFirstBloodGlucose() -> Bool {
        return !hasEventBeenTriggered(EventKeys.firstBloodGlucoseTriggered)
    }
    
    func markFirstBloodGlucoseTriggered() {
        markEventTriggered(EventKeys.firstBloodGlucoseTriggered)
    }
    
    func canTriggerFirstWeight() -> Bool {
        return !hasEventBeenTriggered(EventKeys.firstWeightTriggered)
    }
    
    func markFirstWeightTriggered() {
        markEventTriggered(EventKeys.firstWeightTriggered)
    }
    
    func canTriggerFirstOxygen() -> Bool {
        return !hasEventBeenTriggered(EventKeys.firstOxygenTriggered)
    }
    
    func markFirstOxygenTriggered() {
        markEventTriggered(EventKeys.firstOxygenTriggered)
    }
    
    // MARK: - Reset (for testing)
    
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
        print("🔄 EventTracking: All event triggers reset")
    }
}
