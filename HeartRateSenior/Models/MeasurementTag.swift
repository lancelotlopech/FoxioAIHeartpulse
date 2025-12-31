//
//  MeasurementTag.swift
//  HeartRateSenior
//
//  Tags for categorizing heart rate measurements
//

import SwiftUI

enum MeasurementTag: String, CaseIterable, Identifiable {
    case resting = "Resting"
    case walking = "Walking"
    case exercise = "Exercise"
    case coffee = "Coffee"
    case justWoke = "Just Woke"
    case afterMeal = "After Meal"
    case relaxing = "Relaxing"
    case stressed = "Stressed"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .resting:
            return "bed.double.fill"
        case .walking:
            return "figure.walk"
        case .exercise:
            return "figure.run"
        case .coffee:
            return "cup.and.saucer.fill"
        case .justWoke:
            return "sun.horizon.fill"
        case .afterMeal:
            return "fork.knife"
        case .relaxing:
            return "leaf.fill"
        case .stressed:
            return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .resting:
            return Color(red: 0.3, green: 0.5, blue: 0.9)
        case .walking:
            return Color(red: 0.2, green: 0.75, blue: 0.4)
        case .exercise:
            return Color(red: 0.95, green: 0.6, blue: 0.2)
        case .coffee:
            return Color(red: 0.55, green: 0.35, blue: 0.2)
        case .justWoke:
            return Color(red: 0.6, green: 0.65, blue: 0.75)
        case .afterMeal:
            return Color(red: 0.9, green: 0.75, blue: 0.2)
        case .relaxing:
            return Color(red: 0.5, green: 0.4, blue: 0.75)
        case .stressed:
            return Color(red: 0.9, green: 0.3, blue: 0.35)
        }
    }
    
    var shortName: String {
        switch self {
        case .resting: return "Rest"
        case .walking: return "Walk"
        case .exercise: return "Run"
        case .coffee: return "Coffee"
        case .justWoke: return "Woke"
        case .afterMeal: return "Meal"
        case .relaxing: return "Relax"
        case .stressed: return "Stress"
        }
    }
}
