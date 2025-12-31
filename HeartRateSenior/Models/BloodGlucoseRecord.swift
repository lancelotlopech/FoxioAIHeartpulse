//
//  BloodGlucoseRecord.swift
//  HeartRateSenior
//
//  Blood Glucose Record Model for SwiftData
//

import Foundation
import SwiftData

// MARK: - Meal Context
enum MealContext: String, CaseIterable, Identifiable {
    case fasting = "Fasting"
    case beforeMeal = "Before Meal"
    case afterMeal = "After Meal"
    case bedtime = "Bedtime"
    case random = "Random"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .fasting: return "sunrise.fill"
        case .beforeMeal: return "fork.knife"
        case .afterMeal: return "takeoutbag.and.cup.and.straw.fill"
        case .bedtime: return "moon.fill"
        case .random: return "clock.fill"
        }
    }
}

// MARK: - Glucose Unit
enum GlucoseUnit: String, CaseIterable {
    case mgdL = "mg/dL"
    case mmolL = "mmol/L"
    
    /// Convert mg/dL to mmol/L
    static func toMmolL(_ mgdL: Double) -> Double {
        return mgdL / 18.0182
    }
    
    /// Convert mmol/L to mg/dL
    static func toMgdL(_ mmolL: Double) -> Double {
        return mmolL * 18.0182
    }
}

// MARK: - Blood Glucose Category
enum BloodGlucoseCategory: String, CaseIterable {
    case low = "Low"
    case normal = "Normal"
    case prediabetes = "Prediabetes"
    case diabetes = "High"
    case veryHigh = "Very High"
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .normal: return "green"
        case .prediabetes: return "yellow"
        case .diabetes: return "orange"
        case .veryHigh: return "red"
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Blood sugar is low - eat something"
        case .normal: return "Blood sugar is in healthy range"
        case .prediabetes: return "Blood sugar is slightly elevated"
        case .diabetes: return "Blood sugar is high"
        case .veryHigh: return "Seek medical attention"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .normal: return "checkmark.circle.fill"
        case .prediabetes: return "exclamationmark.circle"
        case .diabetes: return "exclamationmark.circle.fill"
        case .veryHigh: return "exclamationmark.triangle.fill"
        }
    }
    
    /// Determine category based on glucose value (in mg/dL) and meal context
    static func category(value: Double, context: MealContext) -> BloodGlucoseCategory {
        switch context {
        case .fasting:
            // Fasting glucose targets
            if value < 70 {
                return .low
            } else if value < 100 {
                return .normal
            } else if value < 126 {
                return .prediabetes
            } else if value < 200 {
                return .diabetes
            } else {
                return .veryHigh
            }
            
        case .afterMeal:
            // Post-meal glucose targets (2 hours after eating)
            if value < 70 {
                return .low
            } else if value < 140 {
                return .normal
            } else if value < 180 {
                return .prediabetes
            } else if value < 250 {
                return .diabetes
            } else {
                return .veryHigh
            }
            
        default:
            // General targets for before meal, bedtime, random
            if value < 70 {
                return .low
            } else if value < 130 {
                return .normal
            } else if value < 180 {
                return .prediabetes
            } else if value < 250 {
                return .diabetes
            } else {
                return .veryHigh
            }
        }
    }
}

// MARK: - Blood Glucose Record Model
@Model
final class BloodGlucoseRecord {
    var id: UUID
    var value: Double           // Glucose value (stored in mg/dL)
    var mealContext: String     // MealContext raw value
    var timestamp: Date
    var note: String?
    var syncedToHealth: Bool
    
    // Get meal context enum
    var context: MealContext {
        MealContext(rawValue: mealContext) ?? .random
    }
    
    // Computed property for category
    var category: BloodGlucoseCategory {
        BloodGlucoseCategory.category(value: value, context: context)
    }
    
    // Get value in specified unit
    func getValue(in unit: GlucoseUnit) -> Double {
        switch unit {
        case .mgdL:
            return value
        case .mmolL:
            return GlucoseUnit.toMmolL(value)
        }
    }
    
    // Formatted display string
    func displayString(unit: GlucoseUnit) -> String {
        let displayValue = getValue(in: unit)
        switch unit {
        case .mgdL:
            return String(format: "%.0f", displayValue)
        case .mmolL:
            return String(format: "%.1f", displayValue)
        }
    }
    
    init(
        value: Double,
        unit: GlucoseUnit = .mgdL,
        mealContext: MealContext = .random,
        timestamp: Date = Date(),
        note: String? = nil
    ) {
        self.id = UUID()
        // Always store in mg/dL
        self.value = unit == .mgdL ? value : GlucoseUnit.toMgdL(value)
        self.mealContext = mealContext.rawValue
        self.timestamp = timestamp
        self.note = note
        self.syncedToHealth = false
    }
}
