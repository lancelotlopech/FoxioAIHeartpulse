//
//  HIVRiskAssessment.swift
//  HeartRateSenior
//
//  HIV Risk Self-Assessment Data Models
//

import Foundation

// MARK: - Exposure Timeframe (用于 Q1 和动态复测建议)
enum ExposureTimeframe: String, CaseIterable {
    case within7Days = "Within the last 7 days"
    case days8to28 = "8–28 days ago"
    case months1to3 = "1–3 months ago"
    case moreThan3Months = "More than 3 months ago"
    case notSure = "I'm not sure"
    
    var score: Int {
        switch self {
        case .within7Days: return 4
        case .days8to28: return 3
        case .months1to3: return 2
        case .moreThan3Months: return 1
        case .notSure: return 2
        }
    }
    
    // 动态复测建议
    var retestDays: [Int] {
        switch self {
        case .within7Days: return [14, 28, 90]
        case .days8to28: return [28, 90]
        case .months1to3: return [90]
        case .moreThan3Months: return []
        case .notSure: return [14, 28, 90]
        }
    }

    var localizedText: String {
        hivRawText(rawValue)
    }
}

// MARK: - Assessment Option (问题选项)
struct AssessmentOption: Identifiable {
    let id = UUID()
    let text: String
    let score: Int
    let explanation: String?
    
    init(text: String, score: Int, explanation: String? = nil) {
        self.text = text
        self.score = score
        self.explanation = explanation
    }
}

// MARK: - Question Type
enum QuestionType {
    case singleChoice
    case multipleChoice(maxScore: Int)
}

// MARK: - Assessment Question
struct AssessmentQuestion: Identifiable {
    let id: Int
    let section: String
    let title: String
    let options: [AssessmentOption]
    let type: QuestionType
    let note: String?
    
    init(id: Int, section: String, title: String, options: [AssessmentOption], type: QuestionType = .singleChoice, note: String? = nil) {
        self.id = id
        self.section = section
        self.title = title
        self.options = options
        self.type = type
        self.note = note
    }
}

// MARK: - Risk Level
enum RiskLevel {
    case low      // 0-6
    case moderate // 7-14
    case high     // 15+
    
    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .high: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon.fill"
        }
    }
    
    var title: String {
        switch self {
        case .low: return "Low Risk"
        case .moderate: return "Moderate Risk"
        case .high: return "Higher Risk"
        }
    }
    
    var description: String {
        switch self {
        case .low:
            return "Your answers suggest a low level of HIV exposure risk."
        case .moderate:
            return "Your answers indicate a moderate potential risk."
        case .high:
            return "Your answers suggest a higher potential exposure risk."
        }
    }
    
    var recommendations: [String] {
        switch self {
        case .low:
            return [
                "Risk appears minimal",
                "Routine testing is still recommended if sexually active",
                "Continue practicing safer behaviors"
            ]
        case .moderate:
            return [
                "Consider HIV testing for reassurance",
                "If exposure was recent, testing again after the window period may be helpful",
                "Safer sex practices can reduce future risk"
            ]
        case .high:
            return [
                "HIV testing is strongly recommended",
                "If exposure was recent, results may change after the window period",
                "Professional medical advice can provide clarity and support"
            ]
        }
    }
    
    var ctaButtons: [(title: String, icon: String)] {
        switch self {
        case .low:
            return [
                ("Learn About Prevention", "shield.checkered"),
                ("Retake Assessment Later", "arrow.clockwise")
            ]
        case .moderate:
            return [
                ("Find Testing Information", "mappin.and.ellipse"),
                ("Set a Reminder to Retest", "bell.badge")
            ]
        case .high:
            return [
                ("Testing Guidance", "cross.case.fill"),
                ("Emotional Support Resources", "heart.text.square")
            ]
        }
    }
    
    static func from(score: Int) -> RiskLevel {
        if score <= 6 {
            return .low
        } else if score <= 14 {
            return .moderate
        } else {
            return .high
        }
    }
}

// MARK: - Assessment Result
struct AssessmentResult {
    let totalScore: Int
    let riskLevel: RiskLevel
    let exposureTimeframe: ExposureTimeframe?
    let selectedAnswers: [Int: [Int]] // questionId: [optionIndices]
    let completedDate: Date
    
    init(totalScore: Int, exposureTimeframe: ExposureTimeframe?, selectedAnswers: [Int: [Int]]) {
        self.totalScore = totalScore
        self.riskLevel = RiskLevel.from(score: totalScore)
        self.exposureTimeframe = exposureTimeframe
        self.selectedAnswers = selectedAnswers
        self.completedDate = Date()
    }
}

// MARK: - Assessment Data Provider
struct HIVAssessmentData {
    static let questions: [AssessmentQuestion] = [
        // Q1: Time Since Possible Exposure
        AssessmentQuestion(
            id: 1,
            section: "Section A: Time Since Possible Exposure",
            title: "When was your most recent possible exposure?",
            options: [
                AssessmentOption(text: "Within the last 7 days", score: 4),
                AssessmentOption(text: "8–28 days ago", score: 3),
                AssessmentOption(text: "1–3 months ago", score: 2),
                AssessmentOption(text: "More than 3 months ago", score: 1),
                AssessmentOption(text: "I'm not sure", score: 2)
            ],
            note: "Recent exposure = higher uncertainty + window period risk"
        ),
        
        // Q2: Sexual Activity
        AssessmentQuestion(
            id: 2,
            section: "Section B: Sexual Activity",
            title: "Have you had sexual contact that may carry HIV risk?",
            options: [
                AssessmentOption(text: "Yes, unprotected anal sex", score: 6),
                AssessmentOption(text: "Yes, unprotected vaginal sex", score: 5),
                AssessmentOption(text: "Yes, but condom was used", score: 2),
                AssessmentOption(text: "Oral sex only", score: 1),
                AssessmentOption(text: "No sexual contact", score: 0)
            ]
        ),
        
        // Q3: Partner's HIV Status
        AssessmentQuestion(
            id: 3,
            section: "Section B: Sexual Activity",
            title: "Do you know your partner's HIV status?",
            options: [
                AssessmentOption(text: "Partner is HIV-positive or unknown", score: 4),
                AssessmentOption(text: "Partner's status unclear", score: 3),
                AssessmentOption(text: "Partner tested HIV-negative recently", score: 1),
                AssessmentOption(text: "I have only one long-term partner", score: 0)
            ]
        ),
        
        // Q4: Needle Sharing
        AssessmentQuestion(
            id: 4,
            section: "Section C: Other Exposure Risks",
            title: "Have you ever shared needles or injection equipment?",
            options: [
                AssessmentOption(text: "Yes", score: 6),
                AssessmentOption(text: "Not sure", score: 3),
                AssessmentOption(text: "No", score: 0)
            ]
        ),
        
        // Q5: Blood Exposure
        AssessmentQuestion(
            id: 5,
            section: "Section C: Other Exposure Risks",
            title: "Have you had a blood exposure or medical procedure with uncertain safety?",
            options: [
                AssessmentOption(text: "Yes", score: 4),
                AssessmentOption(text: "Not sure", score: 2),
                AssessmentOption(text: "No", score: 0)
            ]
        ),
        
        // Q6: Symptoms (Multiple Choice)
        AssessmentQuestion(
            id: 6,
            section: "Section D: Symptoms Awareness (Non-Diagnostic)",
            title: "Have you experienced any of the following in the past 2–6 weeks?",
            options: [
                AssessmentOption(text: "Fever", score: 1),
                AssessmentOption(text: "Fatigue", score: 1),
                AssessmentOption(text: "Sore throat", score: 1),
                AssessmentOption(text: "Rash", score: 1),
                AssessmentOption(text: "Swollen lymph nodes", score: 1),
                AssessmentOption(text: "None of the above", score: 0)
            ],
            type: .multipleChoice(maxScore: 3),
            note: "⚠️ Symptoms alone do not indicate HIV"
        ),
        
        // Q7: Testing History
        AssessmentQuestion(
            id: 7,
            section: "Section E: Testing History",
            title: "Have you been tested for HIV after this exposure?",
            options: [
                AssessmentOption(text: "No, I have not been tested", score: 3),
                AssessmentOption(text: "Yes, but within the window period", score: 2),
                AssessmentOption(text: "Yes, after the window period", score: 0),
                AssessmentOption(text: "I don't remember", score: 2)
            ]
        )
    ]
    
    static let introText = """
This self-assessment is designed to help you understand your potential HIV risk.

• It is not a medical test
• It does not provide a diagnosis
• Results are based on your answers

Answer honestly to get the most accurate result.
"""
    
    static let disclaimerText = """
This assessment is for informational purposes only.
It does not diagnose HIV or replace laboratory testing.

Only certified medical tests can determine HIV status.
Please consult a healthcare professional for medical advice.
"""
    
    static let retestRecommendationText = """
Because HIV tests may not detect infection immediately after exposure, you may consider testing again in:
"""

    static var localizedQuestions: [AssessmentQuestion] {
        questions.map { $0.localized() }
    }

    static var localizedIntroText: String {
        hivRawText(introText)
    }

    static var localizedDisclaimerText: String {
        hivRawText(disclaimerText)
    }

    static var localizedRetestRecommendationText: String {
        hivRawText(retestRecommendationText)
    }
}

// MARK: - Localization Helpers
extension AssessmentOption {
    func localized() -> AssessmentOption {
        AssessmentOption(text: hivRawText(text), score: score, explanation: explanation.map { hivRawText($0) })
    }
}

extension AssessmentQuestion {
    func localized() -> AssessmentQuestion {
        AssessmentQuestion(
            id: id,
            section: hivRawText(section),
            title: hivRawText(title),
            options: options.map { $0.localized() },
            type: type,
            note: note.map { hivRawText($0) }
        )
    }
}

extension RiskLevel {
    var localizedTitle: String {
        hivRawText(title)
    }

    var localizedDescription: String {
        hivRawText(description)
    }

    var localizedRecommendations: [String] {
        recommendations.map { hivRawText($0) }
    }

    var localizedCTAButtons: [(title: String, icon: String)] {
        ctaButtons.map { (hivRawText($0.title), $0.icon) }
    }
}
