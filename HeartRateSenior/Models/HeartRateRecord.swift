//
//  HeartRateRecord.swift
//  HeartRateSenior
//
//  SwiftData model for heart rate measurements with HRV support
//

import Foundation
import SwiftData

@Model
final class HeartRateRecord {
    var id: UUID
    var bpm: Int
    var timestamp: Date
    var tag: String
    var notes: String?
    var syncedToHealth: Bool
    
    // HRV Metrics (optional - may not be available for all measurements)
    var hrvSDNN: Double?      // Standard deviation of NN intervals (ms)
    var hrvRMSSD: Double?     // Root mean square of successive differences (ms)
    var hrvPNN50: Double?     // Percentage of successive differences > 50ms
    
    init(
        id: UUID = UUID(),
        bpm: Int,
        timestamp: Date = Date(),
        tag: String = MeasurementTag.resting.rawValue,
        notes: String? = nil,
        syncedToHealth: Bool = false,
        hrvSDNN: Double? = nil,
        hrvRMSSD: Double? = nil,
        hrvPNN50: Double? = nil
    ) {
        self.id = id
        self.bpm = bpm
        self.timestamp = timestamp
        self.tag = tag
        self.notes = notes
        self.syncedToHealth = syncedToHealth
        self.hrvSDNN = hrvSDNN
        self.hrvRMSSD = hrvRMSSD
        self.hrvPNN50 = hrvPNN50
    }
    
    // Convenience initializer with HRVMetrics
    convenience init(
        bpm: Int,
        timestamp: Date = Date(),
        tag: String = MeasurementTag.resting.rawValue,
        hrvMetrics: HRVMetrics?
    ) {
        self.init(
            bpm: bpm,
            timestamp: timestamp,
            tag: tag,
            hrvSDNN: hrvMetrics?.sdnn,
            hrvRMSSD: hrvMetrics?.rmssd,
            hrvPNN50: hrvMetrics?.pnn50
        )
    }
    
    // Check if HRV data is available
    var hasHRVData: Bool {
        hrvRMSSD != nil
    }
    
    // Get HRV status based on RMSSD
    var hrvStatus: HRVStatus? {
        guard let rmssd = hrvRMSSD else { return nil }
        switch rmssd {
        case ..<20:
            return .low
        case 20..<50:
            return .normal
        default:
            return .high
        }
    }
    
    // Formatted HRV string
    var formattedHRV: String? {
        guard let rmssd = hrvRMSSD else { return nil }
        return String(format: "%.0f ms", rmssd)
    }
    
    // Reconstruct HRVMetrics from stored values (for history viewing)
    var hrvMetrics: HRVMetrics? {
        guard let rmssd = hrvRMSSD else { return nil }
        
        let sdnn = hrvSDNN ?? rmssd * 1.2
        let pnn50 = hrvPNN50 ?? 10.0
        let meanRR = 60000.0 / Double(bpm)
        
        return HRVMetrics(
            sdnn: sdnn,
            rmssd: rmssd,
            pnn50: pnn50,
            meanRR: meanRR,
            minRR: meanRR - sdnn,
            maxRR: meanRR + sdnn,
            sd1: sqrt(0.5) * rmssd,
            sd2: sqrt(max(0, 2 * sdnn * sdnn - 0.5 * rmssd * rmssd)),
            quality: .estimated,
            sampleCount: 20
        )
    }
    
    var measurementTag: MeasurementTag {
        get { MeasurementTag(rawValue: tag) ?? .resting }
        set { tag = newValue.rawValue }
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
    
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: timestamp)
    }
}
