//
//  WeightRecord.swift
//  HeartRateSenior
//
//  SwiftData model for weight measurements
//

import Foundation
import SwiftData

@Model
final class WeightRecord {
    var id: UUID
    var weight: Double      // in kg
    var timestamp: Date
    var notes: String?
    
    init(
        id: UUID = UUID(),
        weight: Double,
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.weight = weight
        self.timestamp = timestamp
        self.notes = notes
    }
    
    // Weight in pounds (for US users)
    var weightInPounds: Double {
        weight * 2.20462
    }
    
    // Formatted weight string
    var displayString: String {
        String(format: "%.1f kg", weight)
    }
    
    var displayStringLbs: String {
        String(format: "%.1f lbs", weightInPounds)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // Calculate BMI given height in cm
    func bmi(heightCm: Double) -> Double? {
        guard heightCm > 0 else { return nil }
        let heightM = heightCm / 100
        return weight / (heightM * heightM)
    }
    
    // BMI Category
    static func bmiCategory(bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
}
