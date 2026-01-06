//
//  OxygenRecord.swift
//  HeartRateSenior
//
//  SwiftData model for blood oxygen saturation (SpO2) measurements
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class OxygenRecord {
    var id: UUID
    var spo2: Int           // Oxygen saturation percentage (0-100)
    var timestamp: Date
    var notes: String?
    
    init(
        id: UUID = UUID(),
        spo2: Int,
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.spo2 = spo2
        self.timestamp = timestamp
        self.notes = notes
    }
    
    // Formatted display string
    var displayString: String {
        "\(spo2)%"
    }
    
    // Category based on SpO2 level
    var category: OxygenCategory {
        switch spo2 {
        case 95...100:
            return .normal
        case 91...94:
            return .mild
        case 86...90:
            return .moderate
        default:
            return .severe
        }
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
}

// MARK: - Oxygen Saturation Category
enum OxygenCategory: String, CaseIterable {
    case normal = "Normal"
    case mild = "Mild Hypoxemia"
    case moderate = "Moderate Hypoxemia"
    case severe = "Severe Hypoxemia"
    
    var color: Color {
        switch self {
        case .normal:
            return Color(red: 0.2, green: 0.75, blue: 0.4)    // Green
        case .mild:
            return Color(red: 0.95, green: 0.7, blue: 0.2)    // Yellow/Orange
        case .moderate:
            return Color(red: 0.95, green: 0.5, blue: 0.2)    // Orange
        case .severe:
            return Color(red: 0.9, green: 0.3, blue: 0.3)     // Red
        }
    }
    
    var description: String {
        switch self {
        case .normal:
            return "95-100%: Normal oxygen levels"
        case .mild:
            return "91-94%: Mild decrease, monitor closely"
        case .moderate:
            return "86-90%: Moderate decrease, consult doctor"
        case .severe:
            return "<86%: Severe decrease, seek medical attention"
        }
    }
    
    var icon: String {
        switch self {
        case .normal:
            return "checkmark.circle.fill"
        case .mild:
            return "exclamationmark.triangle.fill"
        case .moderate:
            return "exclamationmark.triangle.fill"
        case .severe:
            return "xmark.octagon.fill"
        }
    }
}
