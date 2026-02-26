//
//  PregnancyProbability.swift
//  HeartRateSenior
//
//  Pregnancy Probability Assessment Data Models
//

import Foundation

// MARK: - Assessment Question
struct ProbabilityQuestion: Identifiable {
    let id: Int
    let section: String
    let title: String
    let options: [ProbabilityOption]
    let type: QuestionType
    let note: String?
    
    enum QuestionType {
        case singleChoice
        case multipleChoice(maxScore: Int)
    }
}

struct ProbabilityOption: Identifiable {
    let id = UUID()
    let text: String
    let score: Int
}

// MARK: - Assessment Result
struct ProbabilityResult {
    let totalScore: Int
    let timingAnswer: TimingOption?
    let selectedAnswers: [Int: [Int]]
    
    var probabilityLevel: ProbabilityLevel {
        switch totalScore {
        case 0...7:
            return .low
        case 8...15:
            return .moderate
        default:
            return .higher
        }
    }
    
    var suggestedRetestDate: Date? {
        guard let timing = timingAnswer else { return nil }
        return timing.suggestedRetestDate
    }
}

enum TimingOption: Int, CaseIterable {
    case within3Days = 0
    case days4to7 = 1
    case weeks1to2 = 2
    case moreThan2Weeks = 3
    case notApplicable = 4
    
    var suggestedRetestDate: Date? {
        let calendar = Calendar.current
        let today = Date()
        
        switch self {
        case .within3Days:
            return calendar.date(byAdding: .day, value: 14, to: today)
        case .days4to7:
            return calendar.date(byAdding: .day, value: 10, to: today)
        case .weeks1to2:
            return calendar.date(byAdding: .day, value: 7, to: today)
        case .moreThan2Weeks, .notApplicable:
            return nil
        }
    }
}

enum ProbabilityLevel {
    case low
    case moderate
    case higher
    
    var title: String {
        switch self {
        case .low: return pregnancyRawText("Low Probability")
        case .moderate: return pregnancyRawText("Moderate Probability")
        case .higher: return pregnancyRawText("Higher Probability")
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .higher: return "exclamationmark.octagon.fill"
        }
    }
    
    var description: String {
        switch self {
        case .low:
            return pregnancyRawText("Your answers suggest a low likelihood of pregnancy.")
        case .moderate:
            return pregnancyRawText("There is some possibility.")
        case .higher:
            return pregnancyRawText("Pregnancy may be possible.")
        }
    }
    
    var recommendations: [String] {
        switch self {
        case .low:
            return [
                pregnancyRawText("Wait for expected period"),
                pregnancyRawText("Test if period is late")
            ]
        case .moderate:
            return [
                pregnancyRawText("Test after missed period"),
                pregnancyRawText("Consider retesting if negative")
            ]
        case .higher:
            return [
                pregnancyRawText("Take a home pregnancy test"),
                pregnancyRawText("Consider medical confirmation")
            ]
        }
    }
    
    var ctaButtons: [CTAButton] {
        switch self {
        case .low:
            return [
                CTAButton(title: pregnancyRawText("When Should I Test"), icon: "calendar.badge.clock", action: .timing)
            ]
        case .moderate:
            return [
                CTAButton(title: pregnancyRawText("When Should I Test"), icon: "calendar.badge.clock", action: .timing),
                CTAButton(title: pregnancyRawText("Set Reminder"), icon: "bell.fill", action: .reminder)
            ]
        case .higher:
            return [
                CTAButton(title: pregnancyRawText("Testing Guide"), icon: "doc.text.fill", action: .guide),
                CTAButton(title: pregnancyRawText("Set Reminder"), icon: "bell.fill", action: .reminder)
            ]
        }
    }
}

enum PregnancyCTAAction {
    case timing
    case guide
    case reminder
}

struct CTAButton {
    let title: String
    let icon: String
    let action: PregnancyCTAAction
}

// MARK: - Assessment Data
struct ProbabilityAssessmentData {
    
    static var introText: String {
        pregnancyRawText("""
    This self-check provides educational guidance based on your answers.
    
    It does not diagnose pregnancy.
    """
        )
    }
    
    static let questions: [ProbabilityQuestion] = [
        // Q1: Timing
        ProbabilityQuestion(
            id: 1,
            section: "Timing",
            title: "When was your last unprotected intercourse?",
            options: [
                ProbabilityOption(text: "Within 3 days", score: 4),
                ProbabilityOption(text: "4–7 days ago", score: 3),
                ProbabilityOption(text: "1–2 weeks ago", score: 2),
                ProbabilityOption(text: "More than 2 weeks ago", score: 1),
                ProbabilityOption(text: "Not applicable", score: 0)
            ],
            type: .singleChoice,
            note: nil
        ),
        
        // Q2: Ovulation
        ProbabilityQuestion(
            id: 2,
            section: "Ovulation Window",
            title: "Was it during your ovulation window?",
            options: [
                ProbabilityOption(text: "Yes", score: 4),
                ProbabilityOption(text: "Possibly", score: 3),
                ProbabilityOption(text: "No", score: 1),
                ProbabilityOption(text: "I don't know", score: 2)
            ],
            type: .singleChoice,
            note: "Ovulation typically occurs 10-16 days before your next period"
        ),
        
        // Q3: Contraception
        ProbabilityQuestion(
            id: 3,
            section: "Protection",
            title: "Did you use contraception?",
            options: [
                ProbabilityOption(text: "No protection", score: 5),
                ProbabilityOption(text: "Condom used", score: 2),
                ProbabilityOption(text: "Birth control pill", score: 1),
                ProbabilityOption(text: "Emergency contraception", score: 1),
                ProbabilityOption(text: "I'm not sure", score: 3)
            ],
            type: .singleChoice,
            note: nil
        ),
        
        // Q4: Period Status
        ProbabilityQuestion(
            id: 4,
            section: "Period Status",
            title: "Has your period been missed?",
            options: [
                ProbabilityOption(text: "Yes", score: 5),
                ProbabilityOption(text: "No", score: 0),
                ProbabilityOption(text: "Too early to know", score: 2)
            ],
            type: .singleChoice,
            note: nil
        ),
        
        // Q5: Symptoms
        ProbabilityQuestion(
            id: 5,
            section: "Symptoms",
            title: "Have you noticed any symptoms?",
            options: [
                ProbabilityOption(text: "Nausea", score: 1),
                ProbabilityOption(text: "Fatigue", score: 1),
                ProbabilityOption(text: "Breast tenderness", score: 1),
                ProbabilityOption(text: "Cramping", score: 1),
                ProbabilityOption(text: "None", score: 0)
            ],
            type: .multipleChoice(maxScore: 3),
            note: "⚠️ Symptoms alone do not confirm pregnancy"
        )
    ]
    
    static var retestRecommendationText: String {
        pregnancyRawText("""
    If your exposure was recent, testing may be too early for accurate results.
    
    Consider retesting on the suggested date for more reliable results.
    """
        )
    }
    
    static var disclaimerText: String {
        pregnancyRawText("""
    This assessment is for informational purposes only. It does not diagnose pregnancy or replace medical testing. Only certified pregnancy tests can determine pregnancy status. Please consult a healthcare professional for medical advice.
    """
        )
    }
}
