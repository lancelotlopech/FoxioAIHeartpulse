//
//  HealthKitManager.swift
//  HeartRateSenior
//
//  HealthKit integration for syncing heart rate data
//

import Foundation
import HealthKit

@MainActor
class HealthKitManager: ObservableObject {
    
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized: Bool = false
    @Published var authorizationError: String?
    
    // Heart rate type
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    // MARK: - Authorization
    
    /// Check if HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /// Request authorization to WRITE heart rate data only
    /// Note: We only save measurements to Apple Health - we do not read from it
    func requestAuthorization() async -> Bool {
        guard isHealthKitAvailable else {
            authorizationError = "HealthKit is not available on this device"
            return false
        }
        
        // Only request WRITE permission - we don't read from HealthKit
        let typesToShare: Set<HKSampleType> = [heartRateType]
        let typesToRead: Set<HKObjectType> = []  // Empty - we don't read
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            
            // Check authorization status for writing
            let status = healthStore.authorizationStatus(for: heartRateType)
            isAuthorized = status == .sharingAuthorized
            
            return isAuthorized
        } catch {
            authorizationError = "Failed to request HealthKit authorization: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Check current authorization status for writing
    func checkAuthorizationStatus() {
        guard isHealthKitAvailable else {
            isAuthorized = false
            return
        }
        
        let status = healthStore.authorizationStatus(for: heartRateType)
        isAuthorized = status == .sharingAuthorized
    }
    
    // MARK: - Save Heart Rate
    
    /// Save a heart rate measurement to HealthKit
    func saveHeartRate(bpm: Int, date: Date = Date()) async -> Bool {
        if !isAuthorized {
            // Try to request authorization first
            let authorized = await requestAuthorization()
            guard authorized else { return false }
        }
        
        // Create heart rate quantity
        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let quantity = HKQuantity(unit: heartRateUnit, doubleValue: Double(bpm))
        
        // Create sample
        let sample = HKQuantitySample(
            type: heartRateType,
            quantity: quantity,
            start: date,
            end: date
        )
        
        do {
            try await healthStore.save(sample)
            return true
        } catch {
            print("Failed to save heart rate to HealthKit: \(error.localizedDescription)")
            return false
        }
    }
    
    // NOTE: We intentionally do NOT implement any read functions.
    // This app only SAVES heart rate data to Apple Health.
    // Measurements are taken using the device camera (PPG technology),
    // not imported from Apple Health or Apple Watch.
}
