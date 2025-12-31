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
    
    /// Request authorization to read and write heart rate data
    func requestAuthorization() async -> Bool {
        guard isHealthKitAvailable else {
            authorizationError = "HealthKit is not available on this device"
            return false
        }
        
        let typesToShare: Set<HKSampleType> = [heartRateType]
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            
            // Check authorization status
            let status = healthStore.authorizationStatus(for: heartRateType)
            isAuthorized = status == .sharingAuthorized
            
            return isAuthorized
        } catch {
            authorizationError = "Failed to request HealthKit authorization: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Check current authorization status
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
    
    // MARK: - Read Heart Rate History
    
    /// Fetch heart rate samples from the past week
    func fetchWeeklyHeartRates() async -> [HKQuantitySample] {
        guard isHealthKitAvailable else { return [] }
        
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            return []
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching heart rates: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                    return
                }
                
                let heartRateSamples = samples as? [HKQuantitySample] ?? []
                continuation.resume(returning: heartRateSamples)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Get the latest heart rate from HealthKit
    func fetchLatestHeartRate() async -> Int? {
        guard isHealthKitAvailable else { return nil }
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching latest heart rate: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let bpm = Int(sample.quantity.doubleValue(for: heartRateUnit))
                continuation.resume(returning: bpm)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Get average heart rate for a specific day
    func fetchAverageHeartRate(for date: Date) async -> Int? {
        guard isHealthKitAvailable else { return nil }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: heartRateType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, error in
                if let error = error {
                    print("Error fetching average heart rate: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let avgQuantity = statistics?.averageQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let avgBPM = Int(avgQuantity.doubleValue(for: heartRateUnit))
                continuation.resume(returning: avgBPM)
            }
            
            healthStore.execute(query)
        }
    }
}
