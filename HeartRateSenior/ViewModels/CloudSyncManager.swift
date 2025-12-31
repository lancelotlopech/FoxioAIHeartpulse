//
//  CloudSyncManager.swift
//  HeartRateSenior
//
//  Manages iCloud sync and data backup/restore
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class CloudSyncManager: ObservableObject {
    static let shared = CloudSyncManager()
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    @Published var isCloudAvailable = false
    
    private let fileManager = FileManager.default
    private let ubiquityContainerID: String? = nil // Use default container
    
    private init() {
        checkCloudAvailability()
    }
    
    // MARK: - Cloud Availability
    
    func checkCloudAvailability() {
        Task {
            let available = fileManager.ubiquityIdentityToken != nil
            await MainActor.run {
                self.isCloudAvailable = available
            }
        }
    }
    
    // MARK: - Export Data
    
    func exportAllData(modelContext: ModelContext) async throws -> URL {
        isSyncing = true
        defer { isSyncing = false }
        
        var exportData = ExportData()
        
        // Fetch all records
        let heartRateDescriptor = FetchDescriptor<HeartRateRecord>()
        let bloodPressureDescriptor = FetchDescriptor<BloodPressureRecord>()
        let bloodGlucoseDescriptor = FetchDescriptor<BloodGlucoseRecord>()
        let reminderDescriptor = FetchDescriptor<Reminder>()
        let contactDescriptor = FetchDescriptor<EmergencyContact>()
        
        do {
            let heartRates = try modelContext.fetch(heartRateDescriptor)
            let bloodPressures = try modelContext.fetch(bloodPressureDescriptor)
            let bloodGlucoses = try modelContext.fetch(bloodGlucoseDescriptor)
            let reminders = try modelContext.fetch(reminderDescriptor)
            let contacts = try modelContext.fetch(contactDescriptor)
            
            exportData.heartRateRecords = heartRates.map { ExportHeartRate(from: $0) }
            exportData.bloodPressureRecords = bloodPressures.map { ExportBloodPressure(from: $0) }
            exportData.bloodGlucoseRecords = bloodGlucoses.map { ExportBloodGlucose(from: $0) }
            exportData.reminders = reminders.map { ExportReminder(from: $0) }
            exportData.emergencyContacts = contacts.map { ExportContact(from: $0) }
            exportData.exportDate = Date()
            exportData.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        } catch {
            throw CloudSyncError.fetchFailed(error.localizedDescription)
        }
        
        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let jsonData: Data
        do {
            jsonData = try encoder.encode(exportData)
        } catch {
            throw CloudSyncError.encodingFailed(error.localizedDescription)
        }
        
        // Save to temp file
        let fileName = "HeartRateSenior_Backup_\(Date().ISO8601Format()).json"
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try jsonData.write(to: tempURL)
        } catch {
            throw CloudSyncError.writeFailed(error.localizedDescription)
        }
        
        return tempURL
    }
    
    // MARK: - Import Data
    
    func importData(from url: URL, modelContext: ModelContext) async throws -> ImportResult {
        isSyncing = true
        defer { isSyncing = false }
        
        // Read file
        let jsonData: Data
        do {
            jsonData = try Data(contentsOf: url)
        } catch {
            throw CloudSyncError.readFailed(error.localizedDescription)
        }
        
        // Decode JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let importData: ExportData
        do {
            importData = try decoder.decode(ExportData.self, from: jsonData)
        } catch {
            throw CloudSyncError.decodingFailed(error.localizedDescription)
        }
        
        var result = ImportResult()
        
        // Import heart rate records
        for record in importData.heartRateRecords {
            let newRecord = HeartRateRecord(
                bpm: record.bpm,
                timestamp: record.timestamp,
                tag: record.tag ?? MeasurementTag.resting.rawValue,
                notes: record.notes
            )
            modelContext.insert(newRecord)
            result.heartRateCount += 1
        }
        
        // Import blood pressure records
        for record in importData.bloodPressureRecords {
            let newRecord = BloodPressureRecord(
                systolic: record.systolic,
                diastolic: record.diastolic,
                pulse: record.pulse,
                timestamp: record.timestamp,
                note: record.note
            )
            modelContext.insert(newRecord)
            result.bloodPressureCount += 1
        }
        
        // Import blood glucose records
        for record in importData.bloodGlucoseRecords {
            let mealContext = MealContext(rawValue: record.context ?? "") ?? .random
            let newRecord = BloodGlucoseRecord(
                value: record.value,
                unit: .mgdL,
                mealContext: mealContext,
                timestamp: record.timestamp,
                note: record.note
            )
            modelContext.insert(newRecord)
            result.bloodGlucoseCount += 1
        }
        
        // Import reminders
        for record in importData.reminders {
            let newReminder = Reminder(
                title: record.title,
                reminderType: ReminderType(rawValue: record.type) ?? .heartRate,
                time: record.time,
                repeatFrequency: RepeatFrequency(rawValue: record.repeatFrequency) ?? .daily,
                isEnabled: record.isEnabled,
                medicationName: record.medicationName,
                medicationDosage: record.medicationDosage,
                notes: record.notes
            )
            modelContext.insert(newReminder)
            result.reminderCount += 1
        }
        
        // Import emergency contacts
        for record in importData.emergencyContacts {
            let newContact = EmergencyContact(
                name: record.name,
                phoneNumber: record.phoneNumber,
                relationship: record.relationship,
                isPrimary: record.isPrimary,
                notifyOnAbnormal: record.notifyOnAbnormal
            )
            modelContext.insert(newContact)
            result.contactCount += 1
        }
        
        lastSyncDate = Date()
        return result
    }
}

// MARK: - Error Types

enum CloudSyncError: LocalizedError {
    case fetchFailed(String)
    case encodingFailed(String)
    case decodingFailed(String)
    case writeFailed(String)
    case readFailed(String)
    case cloudUnavailable
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let msg): return "Failed to fetch data: \(msg)"
        case .encodingFailed(let msg): return "Failed to encode data: \(msg)"
        case .decodingFailed(let msg): return "Failed to decode data: \(msg)"
        case .writeFailed(let msg): return "Failed to write file: \(msg)"
        case .readFailed(let msg): return "Failed to read file: \(msg)"
        case .cloudUnavailable: return "iCloud is not available"
        }
    }
}

// MARK: - Import Result

struct ImportResult {
    var heartRateCount = 0
    var bloodPressureCount = 0
    var bloodGlucoseCount = 0
    var reminderCount = 0
    var contactCount = 0
    
    var totalCount: Int {
        heartRateCount + bloodPressureCount + bloodGlucoseCount + reminderCount + contactCount
    }
}

// MARK: - Export Data Structures

struct ExportData: Codable {
    var heartRateRecords: [ExportHeartRate] = []
    var bloodPressureRecords: [ExportBloodPressure] = []
    var bloodGlucoseRecords: [ExportBloodGlucose] = []
    var reminders: [ExportReminder] = []
    var emergencyContacts: [ExportContact] = []
    var exportDate: Date = Date()
    var appVersion: String = "1.0"
}

struct ExportHeartRate: Codable {
    let bpm: Int
    let timestamp: Date
    let tag: String?
    let notes: String?
    
    init(from record: HeartRateRecord) {
        self.bpm = record.bpm
        self.timestamp = record.timestamp
        self.tag = record.tag
        self.notes = record.notes
    }
}

struct ExportBloodPressure: Codable {
    let systolic: Int
    let diastolic: Int
    let pulse: Int?
    let timestamp: Date
    let note: String?
    
    init(from record: BloodPressureRecord) {
        self.systolic = record.systolic
        self.diastolic = record.diastolic
        self.pulse = record.pulse
        self.timestamp = record.timestamp
        self.note = record.note
    }
}

struct ExportBloodGlucose: Codable {
    let value: Double
    let timestamp: Date
    let context: String?
    let note: String?
    
    init(from record: BloodGlucoseRecord) {
        self.value = record.value
        self.timestamp = record.timestamp
        self.context = record.mealContext
        self.note = record.note
    }
}

struct ExportReminder: Codable {
    let title: String
    let type: String
    let time: Date
    let repeatFrequency: String
    let isEnabled: Bool
    let medicationName: String?
    let medicationDosage: String?
    let notes: String?
    
    init(from reminder: Reminder) {
        self.title = reminder.title
        self.type = reminder.reminderType.rawValue
        self.time = reminder.time
        self.repeatFrequency = reminder.repeatFrequency.rawValue
        self.isEnabled = reminder.isEnabled
        self.medicationName = reminder.medicationName
        self.medicationDosage = reminder.medicationDosage
        self.notes = reminder.notes
    }
}

struct ExportContact: Codable {
    let name: String
    let phoneNumber: String
    let relationship: String
    let isPrimary: Bool
    let notifyOnAbnormal: Bool
    
    init(from contact: EmergencyContact) {
        self.name = contact.name
        self.phoneNumber = contact.phoneNumber
        self.relationship = contact.relationship
        self.isPrimary = contact.isPrimary
        self.notifyOnAbnormal = contact.notifyOnAbnormal
    }
}
