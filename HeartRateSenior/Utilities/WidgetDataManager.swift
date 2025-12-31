//
//  WidgetDataManager.swift
//  HeartRateSenior
//
//  Manages data sharing between main app and widget via App Groups
//

import Foundation
import WidgetKit

class WidgetDataManager {
    
    static let shared = WidgetDataManager()
    
    private let appGroupID = "group.com.heartrate.senior"
    private var defaults: UserDefaults?
    
    private init() {
        defaults = UserDefaults(suiteName: appGroupID)
    }
    
    // MARK: - Update Widget Data
    
    /// Update widget with latest heart rate measurement
    func updateLatestMeasurement(bpm: Int, timestamp: Date) {
        defaults?.set(bpm, forKey: "lastBPM")
        defaults?.set(timestamp.timeIntervalSince1970, forKey: "lastMeasuredTimestamp")
        
        // Trigger widget refresh
        reloadWidgets()
    }
    
    /// Update widget with weekly data
    func updateWeeklyData(_ records: [HeartRateRecord]) {
        // Get last 7 days of data
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentRecords = records.filter { $0.timestamp >= sevenDaysAgo }
        
        // Calculate daily averages
        var dailyAverages: [Int] = []
        let calendar = Calendar.current
        
        for dayOffset in (0..<7).reversed() {
            guard let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: calendar.startOfDay(for: Date())),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }
            
            let dayRecords = recentRecords.filter { $0.timestamp >= dayStart && $0.timestamp < dayEnd }
            if !dayRecords.isEmpty {
                let avg = dayRecords.map { $0.bpm }.reduce(0, +) / dayRecords.count
                dailyAverages.append(avg)
            }
        }
        
        // Store as comma-separated string
        let weeklyDataString = dailyAverages.map { String($0) }.joined(separator: ",")
        defaults?.set(weeklyDataString, forKey: "weeklyData")
        
        // Calculate overall average
        if !recentRecords.isEmpty {
            let avg = recentRecords.map { $0.bpm }.reduce(0, +) / recentRecords.count
            defaults?.set(avg, forKey: "averageBPM")
        }
        
        // Count today's measurements
        let todayStart = calendar.startOfDay(for: Date())
        let todayRecords = records.filter { $0.timestamp >= todayStart }
        defaults?.set(todayRecords.count, forKey: "measurementCount")
        
        // Trigger widget refresh
        reloadWidgets()
    }
    
    /// Update all widget data at once
    func updateAllData(latestBPM: Int?, latestTimestamp: Date?, records: [HeartRateRecord]) {
        if let bpm = latestBPM, let timestamp = latestTimestamp {
            defaults?.set(bpm, forKey: "lastBPM")
            defaults?.set(timestamp.timeIntervalSince1970, forKey: "lastMeasuredTimestamp")
        }
        
        updateWeeklyData(records)
    }
    
    /// Clear all widget data
    func clearData() {
        defaults?.removeObject(forKey: "lastBPM")
        defaults?.removeObject(forKey: "lastMeasuredTimestamp")
        defaults?.removeObject(forKey: "weeklyData")
        defaults?.removeObject(forKey: "averageBPM")
        defaults?.removeObject(forKey: "measurementCount")
        
        reloadWidgets()
    }
    
    // MARK: - Widget Refresh
    
    /// Trigger widget timeline refresh
    private func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "HeartRateSeniorWidget")
    }
    
    /// Reload all widgets
    func reloadAllWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
