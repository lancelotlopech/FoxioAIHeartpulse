//
//  EmergencyContact.swift
//  HeartRateSenior
//
//  Emergency contact data model
//

import Foundation
import SwiftData

@Model
final class EmergencyContact {
    var id: UUID
    var name: String
    var phoneNumber: String
    var relationship: String
    var isPrimary: Bool
    var notifyOnAbnormal: Bool
    var createdAt: Date
    
    /// Formatted phone number for display
    var formattedPhoneNumber: String {
        // Simple US phone formatting
        let digits = phoneNumber.filter { $0.isNumber }
        if digits.count == 10 {
            let areaCode = digits.prefix(3)
            let middle = digits.dropFirst(3).prefix(3)
            let last = digits.suffix(4)
            return "(\(areaCode)) \(middle)-\(last)"
        } else if digits.count == 11 && digits.first == "1" {
            let withoutCountry = digits.dropFirst()
            let areaCode = withoutCountry.prefix(3)
            let middle = withoutCountry.dropFirst(3).prefix(3)
            let last = withoutCountry.suffix(4)
            return "+1 (\(areaCode)) \(middle)-\(last)"
        }
        return phoneNumber
    }
    
    /// Phone URL for calling
    var phoneURL: URL? {
        let digits = phoneNumber.filter { $0.isNumber }
        return URL(string: "tel://\(digits)")
    }
    
    /// SMS URL for messaging
    var smsURL: URL? {
        let digits = phoneNumber.filter { $0.isNumber }
        return URL(string: "sms://\(digits)")
    }
    
    init(
        name: String,
        phoneNumber: String,
        relationship: String = "",
        isPrimary: Bool = false,
        notifyOnAbnormal: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.isPrimary = isPrimary
        self.notifyOnAbnormal = notifyOnAbnormal
        self.createdAt = Date()
    }
}

// MARK: - Relationship Options

enum ContactRelationship: String, CaseIterable {
    case spouse = "Spouse"
    case child = "Child"
    case parent = "Parent"
    case sibling = "Sibling"
    case friend = "Friend"
    case caregiver = "Caregiver"
    case doctor = "Doctor"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .spouse: return "heart.fill"
        case .child: return "figure.child"
        case .parent: return "figure.stand"
        case .sibling: return "person.2.fill"
        case .friend: return "person.fill"
        case .caregiver: return "cross.case.fill"
        case .doctor: return "stethoscope"
        case .other: return "person.crop.circle"
        }
    }
}

// MARK: - Alert Thresholds

struct HealthAlertThresholds {
    // Heart Rate
    static let heartRateLow = 50
    static let heartRateHigh = 120
    
    // Blood Pressure
    static let systolicHigh = 180
    static let diastolicHigh = 120
    static let systolicLow = 90
    static let diastolicLow = 60
    
    // Blood Glucose
    static let glucoseLow = 70.0
    static let glucoseHigh = 250.0
    
    static func isHeartRateAbnormal(_ bpm: Int) -> Bool {
        return bpm < heartRateLow || bpm > heartRateHigh
    }
    
    static func isBloodPressureAbnormal(systolic: Int, diastolic: Int) -> Bool {
        return systolic >= systolicHigh || diastolic >= diastolicHigh ||
               systolic <= systolicLow || diastolic <= diastolicLow
    }
    
    static func isBloodGlucoseAbnormal(_ value: Double) -> Bool {
        return value < glucoseLow || value > glucoseHigh
    }
    
    static func heartRateAlertMessage(_ bpm: Int) -> String {
        if bpm < heartRateLow {
            return "Low heart rate detected: \(bpm) BPM"
        } else if bpm > heartRateHigh {
            return "High heart rate detected: \(bpm) BPM"
        }
        return ""
    }
    
    static func bloodPressureAlertMessage(systolic: Int, diastolic: Int) -> String {
        if systolic >= systolicHigh || diastolic >= diastolicHigh {
            return "Hypertensive crisis detected: \(systolic)/\(diastolic) mmHg"
        } else if systolic <= systolicLow || diastolic <= diastolicLow {
            return "Low blood pressure detected: \(systolic)/\(diastolic) mmHg"
        }
        return ""
    }
    
    static func bloodGlucoseAlertMessage(_ value: Double) -> String {
        if value < glucoseLow {
            return String(format: "Low blood glucose detected: %.0f mg/dL", value)
        } else if value > glucoseHigh {
            return String(format: "High blood glucose detected: %.0f mg/dL", value)
        }
        return ""
    }
}
