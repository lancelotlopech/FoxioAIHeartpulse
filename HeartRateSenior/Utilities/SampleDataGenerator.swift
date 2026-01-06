//
//  SampleDataGenerator.swift
//  HeartRateSenior
//
//  Generates 100 days of realistic senior heart rate data for testing
//

import Foundation
import SwiftData

class SampleDataGenerator {
    
    /// Generate 100 days of sample heart rate data for an elderly person
    static func generateSeniorHeartRateData(modelContext: ModelContext, days: Int = 100) -> Int {
        let calendar = Calendar.current
        let today = Date()
        var totalRecords = 0
        
        // 遍历每一天
        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // 10% 概率当天无数据（模拟休息/忘记）
            if Double.random(in: 0...1) < 0.1 {
                continue
            }
            
            // 每天 1-4 次测量
            let measurementsToday = Int.random(in: 1...4)
            
            for _ in 0..<measurementsToday {
                if let record = generateSingleRecord(for: date, calendar: calendar) {
                    modelContext.insert(record)
                    totalRecords += 1
                }
            }
        }
        
        // 保存
        try? modelContext.save()
        
        return totalRecords
    }
    
    /// Generate a single heart rate record
    private static func generateSingleRecord(for date: Date, calendar: Calendar) -> HeartRateRecord? {
        // 随机选择一个时段和对应场景
        let (hour, minute, tag, bpmRange) = selectTimeAndScenario()
        
        // 设置时间
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        components.second = Int.random(in: 0...59)
        
        guard let timestamp = calendar.date(from: components) else { return nil }
        
        // 如果时间在未来，跳过
        if timestamp > Date() { return nil }
        
        // 生成 BPM
        let bpm = Int.random(in: bpmRange)
        
        // 生成 HRV（老年人 RMSSD 偏低：15-40 ms）
        let baseRMSSD = Double.random(in: 15...35)
        let rmssd = adjustHRVForBPM(baseRMSSD: baseRMSSD, bpm: bpm)
        let sdnn = rmssd * Double.random(in: 1.1...1.4)
        let pnn50 = Double.random(in: 5...20)  // 老年人 pNN50 偏低
        
        // 创建记录
        let record = HeartRateRecord(
            bpm: bpm,
            timestamp: timestamp,
            tag: tag.rawValue,
            hrvSDNN: sdnn,
            hrvRMSSD: rmssd,
            hrvPNN50: pnn50
        )
        
        return record
    }
    
    /// Select time of day and corresponding scenario based on elderly lifestyle
    private static func selectTimeAndScenario() -> (hour: Int, minute: Int, tag: MeasurementTag, bpmRange: ClosedRange<Int>) {
        // 根据加权随机选择场景
        let roll = Double.random(in: 0...100)
        
        if roll < 15 {
            // Just Woke (15%) - 6:00-8:00 AM
            let hour = Int.random(in: 6...7)
            let minute = Int.random(in: 0...59)
            return (hour, minute, .justWoke, 55...72)
        } else if roll < 35 {
            // After Meal (20%) - 早餐/午餐/晚餐后
            let mealTime = [8, 12, 18].randomElement()!
            let hour = mealTime + Int.random(in: 0...1)
            let minute = Int.random(in: 15...55)
            return (hour, minute, .afterMeal, 68...85)
        } else if roll < 50 {
            // Walking (15%) - 上午/下午散步
            let walkTime = Bool.random() ? Int.random(in: 9...11) : Int.random(in: 15...17)
            let minute = Int.random(in: 0...59)
            return (walkTime, minute, .walking, 75...95)
        } else if roll < 70 {
            // Resting (20%) - 午休/下午/晚间
            let restTime = [14, 15, 20, 21, 22].randomElement()!
            let minute = Int.random(in: 0...59)
            return (restTime, minute, .resting, 58...72)
        } else if roll < 82 {
            // Relaxing (12%) - 晚间放松
            let hour = Int.random(in: 19...21)
            let minute = Int.random(in: 0...59)
            return (hour, minute, .relaxing, 60...75)
        } else if roll < 90 {
            // Exercise (8%) - 太极/体操
            let hour = Int.random(in: 7...9)
            let minute = Int.random(in: 0...45)
            return (hour, minute, .exercise, 82...105)
        } else if roll < 95 {
            // Coffee (5%) - 早上喝咖啡
            let hour = Int.random(in: 8...10)
            let minute = Int.random(in: 0...59)
            return (hour, minute, .coffee, 72...88)
        } else {
            // Stressed (5%) - 偶发压力/不适
            let hour = Int.random(in: 10...20)
            let minute = Int.random(in: 0...59)
            // 老年人压力下心率可能较高
            return (hour, minute, .stressed, 88...115)
        }
    }
    
    /// Adjust HRV based on heart rate (higher BPM = lower HRV)
    private static func adjustHRVForBPM(baseRMSSD: Double, bpm: Int) -> Double {
        // 心率越高，HRV 越低
        if bpm > 90 {
            return baseRMSSD * 0.8
        } else if bpm > 80 {
            return baseRMSSD * 0.9
        } else if bpm < 60 {
            return baseRMSSD * 1.1
        }
        return baseRMSSD
    }
    
    /// Delete all sample data (all records)
    static func deleteAllRecords(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: HeartRateRecord.self)
            try modelContext.save()
        } catch {
            print("Failed to delete records: \(error)")
        }
    }
}
