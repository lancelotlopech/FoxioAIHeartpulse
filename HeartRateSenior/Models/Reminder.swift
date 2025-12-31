//
//  Reminder.swift
//  HeartRateSenior
//
//  Reminder data model for health measurement and medication reminders
//

import Foundation
import SwiftData

/// Type of reminder
enum ReminderType: String, Codable, CaseIterable {
    case heartRate = "Heart Rate"
    case bloodPressure = "Blood Pressure"
    case bloodGlucose = "Blood Glucose"
    case medication = "Medication"
    
    var icon: String {
        switch self {
        case .heartRate: return "heart.fill"
        case .bloodPressure: return "waveform.path.ecg"
        case .bloodGlucose: return "drop.fill"
        case .medication: return "pills.fill"
        }
    }
    
    var color: String {
        switch self {
        case .heartRate: return "systemRed"
        case .bloodPressure: return "systemBlue"
        case .bloodGlucose: return "systemPurple"
        case .medication: return "systemGreen"
        }
    }
}

/// Repeat frequency for reminders
enum RepeatFrequency: String, Codable, CaseIterable {
    case once = "Once"
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
}

/// Days of the week for custom repeat
struct WeekDays: Codable, Equatable {
    var sunday: Bool = false
    var monday: Bool = false
    var tuesday: Bool = false
    var wednesday: Bool = false
    var thursday: Bool = false
    var friday: Bool = false
    var saturday: Bool = false
    
    var selectedDays: [Int] {
        var days: [Int] = []
        if sunday { days.append(1) }
        if monday { days.append(2) }
        if tuesday { days.append(3) }
        if wednesday { days.append(4) }
        if thursday { days.append(5) }
        if friday { days.append(6) }
        if saturday { days.append(7) }
        return days
    }
    
    var shortDescription: String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        var selected: [String] = []
        if sunday { selected.append(dayNames[0]) }
        if monday { selected.append(dayNames[1]) }
        if tuesday { selected.append(dayNames[2]) }
        if wednesday { selected.append(dayNames[3]) }
        if thursday { selected.append(dayNames[4]) }
        if friday { selected.append(dayNames[5]) }
        if saturday { selected.append(dayNames[6]) }
        return selected.joined(separator: ", ")
    }
    
    static var weekdays: WeekDays {
        WeekDays(monday: true, tuesday: true, wednesday: true, thursday: true, friday: true)
    }
    
    static var weekends: WeekDays {
        WeekDays(sunday: true, saturday: true)
    }
    
    static var everyday: WeekDays {
        WeekDays(sunday: true, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: true)
    }
}

@Model
final class Reminder {
    var id: UUID
    var title: String
    var reminderTypeRaw: String
    var time: Date
    var repeatFrequencyRaw: String
    var customDaysData: Data?
    var isEnabled: Bool
    var medicationName: String?
    var medicationDosage: String?
    var notes: String?
    var createdAt: Date
    var lastTriggered: Date?
    var notificationIdentifier: String
    
    var reminderType: ReminderType {
        get { ReminderType(rawValue: reminderTypeRaw) ?? .heartRate }
        set { reminderTypeRaw = newValue.rawValue }
    }
    
    var repeatFrequency: RepeatFrequency {
        get { RepeatFrequency(rawValue: repeatFrequencyRaw) ?? .daily }
        set { repeatFrequencyRaw = newValue.rawValue }
    }
    
    var customDays: WeekDays {
        get {
            guard let data = customDaysData else { return WeekDays() }
            return (try? JSONDecoder().decode(WeekDays.self, from: data)) ?? WeekDays()
        }
        set {
            customDaysData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    var repeatDescription: String {
        switch repeatFrequency {
        case .once:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: time)
        case .daily:
            return "Every day"
        case .weekdays:
            return "Mon - Fri"
        case .weekends:
            return "Sat & Sun"
        case .custom:
            return customDays.shortDescription
        }
    }
    
    init(
        title: String,
        reminderType: ReminderType,
        time: Date,
        repeatFrequency: RepeatFrequency = .daily,
        customDays: WeekDays = WeekDays(),
        isEnabled: Bool = true,
        medicationName: String? = nil,
        medicationDosage: String? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.reminderTypeRaw = reminderType.rawValue
        self.time = time
        self.repeatFrequencyRaw = repeatFrequency.rawValue
        self.isEnabled = isEnabled
        self.medicationName = medicationName
        self.medicationDosage = medicationDosage
        self.notes = notes
        self.createdAt = Date()
        self.notificationIdentifier = UUID().uuidString
        
        // Encode custom days
        self.customDaysData = try? JSONEncoder().encode(customDays)
    }
}
