//
//  PregnancyAssessmentRecord.swift
//  HeartRateSenior
//
//  Stores Pregnancy Probability self-check results (educational only).
//

import Foundation
import SwiftData

@Model
final class PregnancyAssessmentRecord {
    var id: UUID
    var createdAt: Date
    
    var totalScore: Int
    var probabilityLevelRaw: String
    var timingAnswerRaw: Int?
    var suggestedRetestDate: Date?
    
    /// JSON payload: {"answers": {"1":[0],"2":[1],...}}
    var answersSnapshotJSON: Data
    
    init(
        createdAt: Date = Date(),
        totalScore: Int,
        probabilityLevelRaw: String,
        timingAnswerRaw: Int?,
        suggestedRetestDate: Date?,
        answersSnapshotJSON: Data
    ) {
        self.id = UUID()
        self.createdAt = createdAt
        self.totalScore = totalScore
        self.probabilityLevelRaw = probabilityLevelRaw
        self.timingAnswerRaw = timingAnswerRaw
        self.suggestedRetestDate = suggestedRetestDate
        self.answersSnapshotJSON = answersSnapshotJSON
    }
}

