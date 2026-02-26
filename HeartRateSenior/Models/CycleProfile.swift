//
//  CycleProfile.swift
//  HeartRateSenior
//
//  Stored cycle profile used by Pregnancy tools (educational only).
//

import Foundation
import SwiftData

@Model
final class CycleProfile {
    var id: UUID
    var lastPeriodDate: Date
    var cycleLengthDays: Int
    var periodLengthDays: Int
    var isIrregular: Bool
    var updatedAt: Date
    
    init(
        lastPeriodDate: Date,
        cycleLengthDays: Int = 28,
        periodLengthDays: Int = 5,
        isIrregular: Bool = false
    ) {
        self.id = UUID()
        self.lastPeriodDate = lastPeriodDate
        self.cycleLengthDays = cycleLengthDays
        self.periodLengthDays = periodLengthDays
        self.isIrregular = isIrregular
        self.updatedAt = Date()
    }
}

