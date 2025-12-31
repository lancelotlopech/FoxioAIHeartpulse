//
//  BloodPressureRecord.swift
//  HeartRateSenior
//
//  Blood Pressure Record Model for SwiftData
//

import Foundation
import SwiftData

// MARK: - Blood Pressure Category
enum BloodPressureCategory: String, CaseIterable {
    case low = "Low"
    case normal = "Normal"
    case elevated = "Elevated"
    case hypertensionStage1 = "High (Stage 1)"
    case hypertensionStage2 = "High (Stage 2)"
    case crisis = "Crisis"
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .normal: return "green"
        case .elevated: return "yellow"
        case .hypertensionStage1: return "orange"
        case .hypertensionStage2: return "red"
        case .crisis: return "purple"
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Blood pressure is lower than normal"
        case .normal: return "Blood pressure is in healthy range"
        case .elevated: return "Blood pressure is slightly elevated"
        case .hypertensionStage1: return "Consult your doctor"
        case .hypertensionStage2: return "Seek medical attention"
        case .crisis: return "Seek emergency care immediately"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .normal: return "checkmark.circle.fill"
        case .elevated: return "exclamationmark.circle"
        case .hypertensionStage1: return "exclamationmark.circle.fill"
        case .hypertensionStage2: return "exclamationmark.triangle.fill"
        case .crisis: return "xmark.octagon.fill"
        }
    }
    
    /// Determine category based on systolic and diastolic values
    static func category(systolic: Int, diastolic: Int) -> BloodPressureCategory {
        // Based on American Heart Association guidelines
        if systolic < 90 || diastolic < 60 {
            return .low
        } else if systolic < 120 && diastolic < 80 {
            return .normal
        } else if systolic < 130 && diastolic < 80 {
            return .elevated
        } else if systolic < 140 || diastolic < 90 {
            return .hypertensionStage1
        } else if systolic < 180 && diastolic < 120 {
            return .hypertensionStage2
        } else {
            return .crisis
        }
    }
}

// MARK: - Blood Pressure Record Model
@Model
final class BloodPressureRecord {
    var id: UUID
    var systolic: Int           // Systolic pressure (mmHg)
    var diastolic: Int          // Diastolic pressure (mmHg)
    var pulse: Int?             // Pulse rate (optional)
    var timestamp: Date
    var note: String?
    var syncedToHealth: Bool
    
    // Computed property for category
    var category: BloodPressureCategory {
        BloodPressureCategory.category(systolic: systolic, diastolic: diastolic)
    }
    
    // Formatted display string
    var displayString: String {
        "\(systolic)/\(diastolic)"
    }
    
    init(
        systolic: Int,
        diastolic: Int,
        pulse: Int? = nil,
        timestamp: Date = Date(),
        note: String? = nil
    ) {
        self.id = UUID()
        self.systolic = systolic
        self.diastolic = diastolic
        self.pulse = pulse
        self.timestamp = timestamp
        self.note = note
        self.syncedToHealth = false
    }
}
