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
    var countryCode: String
    var phoneNumber: String
    var relationship: String
    var isPrimary: Bool
    var notifyOnAbnormal: Bool
    var createdAt: Date
    
    /// Full phone number with country code
    var fullPhoneNumber: String {
        let digits = phoneNumber.filter { $0.isNumber }
        return "\(countryCode)\(digits)"
    }
    
    /// Formatted phone number for display
    var formattedPhoneNumber: String {
        let digits = phoneNumber.filter { $0.isNumber }
        if digits.count == 10 {
            let areaCode = digits.prefix(3)
            let middle = digits.dropFirst(3).prefix(3)
            let last = digits.suffix(4)
            return "\(countryCode) (\(areaCode)) \(middle)-\(last)"
        } else if digits.count >= 7 {
            return "\(countryCode) \(digits)"
        }
        return "\(countryCode) \(phoneNumber)"
    }
    
    /// Phone URL for calling (uses full number with country code)
    var phoneURL: URL? {
        let digits = phoneNumber.filter { $0.isNumber }
        let countryDigits = countryCode.filter { $0.isNumber || $0 == "+" }
        let fullNumber = countryDigits + digits
        return URL(string: "tel://\(fullNumber)")
    }
    
    /// SMS URL for messaging
    var smsURL: URL? {
        let digits = phoneNumber.filter { $0.isNumber }
        let countryDigits = countryCode.filter { $0.isNumber || $0 == "+" }
        let fullNumber = countryDigits + digits
        return URL(string: "sms://\(fullNumber)")
    }
    
    init(
        name: String,
        countryCode: String = "+1",
        phoneNumber: String,
        relationship: String = "",
        isPrimary: Bool = false,
        notifyOnAbnormal: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.isPrimary = isPrimary
        self.notifyOnAbnormal = notifyOnAbnormal
        self.createdAt = Date()
    }
}

// MARK: - Country Code Options
enum CountryCode: String, CaseIterable {
    case us = "+1"
    case uk = "+44"
    case china = "+86"
    case india = "+91"
    case germany = "+49"
    case france = "+33"
    case japan = "+81"
    case korea = "+82"
    case australia = "+61"
    case canada = "+1 CA"
    case mexico = "+52"
    case brazil = "+55"
    
    var displayName: String {
        switch self {
        case .us: return "🇺🇸 +1"
        case .uk: return "🇬🇧 +44"
        case .china: return "🇨🇳 +86"
        case .india: return "🇮🇳 +91"
        case .germany: return "🇩🇪 +49"
        case .france: return "🇫🇷 +33"
        case .japan: return "🇯🇵 +81"
        case .korea: return "🇰🇷 +82"
        case .australia: return "🇦🇺 +61"
        case .canada: return "🇨🇦 +1"
        case .mexico: return "🇲🇽 +52"
        case .brazil: return "🇧🇷 +55"
        }
    }
    
    var dialCode: String {
        switch self {
        case .canada: return "+1"
        default: return self.rawValue
        }
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
