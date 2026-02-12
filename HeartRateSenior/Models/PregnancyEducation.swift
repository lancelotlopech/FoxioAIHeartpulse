//
//  PregnancyEducation.swift
//  HeartRateSenior
//
//  Pregnancy Education Content Data Models
//

import Foundation

// MARK: - Pregnancy Education Section
struct PregnancySection: Identifiable {
    let id: Int
    let title: String
    let subtitle: String?
    let content: String
    let keyPoints: [PregnancyKeyPoint]?
    let steps: [PregnancyStep]?
    let symptoms: [String]?
    let importantNote: String?
    let infoNote: String?
    let ctaTitle: String?
    let ctaDestination: PregnancyCTADestination?
}

enum PregnancyCTADestination {
    case probabilityCheck
    case testTiming
    case testGuide
    case reminderCenter
}

struct PregnancyKeyPoint: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

struct PregnancyStep: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Test Guide Section
struct TestGuideSection: Identifiable {
    let id: Int
    let title: String
    let content: String
    let steps: [TestGuideStep]?
    let results: [TestResult]?
    let tips: [TestGuideTip]?
}

struct TestGuideStep: Identifiable {
    let id = UUID()
    let icon: String
    let instruction: String
}

struct TestResult: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let meaning: String
    let color: String
}

struct TestGuideTip: Identifiable {
    let id = UUID()
    let condition: String
    let advice: String
}

// MARK: - Emotional Support Section
struct EmotionalSection: Identifiable {
    let id: Int
    let title: String
    let content: String
    let suggestions: [EmotionalSuggestion]?
    let emotions: [EmotionItem]?
    let nextSteps: [String]?
    let breathingExercise: BreathingExercise?
}

struct EmotionalSuggestion: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

struct EmotionItem: Identifiable {
    let id = UUID()
    let emoji: String
    let label: String
}

struct BreathingExercise {
    let inhale: Int
    let hold: Int
    let exhale: Int
    let repeats: Int
}

// MARK: - Education Page Section (for carousel view)
struct EducationPageSection: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let description: String
    let keyPoints: [EducationKeyPoint]
    
    static let allSections: [EducationPageSection] = [
        EducationPageSection(
            id: 1,
            icon: "heart.circle.fill",
            title: "Learn About Pregnancy",
            description: "Pregnancy happens when a fertilized egg implants in the uterus.\n\nKnowing how this process works can help you better understand timing and testing.",
            keyPoints: [
                EducationKeyPoint(icon: "info.circle.fill", title: "What is Pregnancy?", description: "A natural process where a fertilized egg develops into a baby inside the uterus."),
                EducationKeyPoint(icon: "lightbulb.fill", title: "Why Learn?", description: "Understanding the basics helps you make informed decisions about your health.")
            ]
        ),
        EducationPageSection(
            id: 2,
            icon: "arrow.triangle.merge",
            title: "How Pregnancy Happens",
            description: "Understanding the biological process helps you know when testing is most effective.",
            keyPoints: [
                EducationKeyPoint(icon: "circle.fill", title: "Ovulation", description: "The ovary releases an egg, usually 10–16 days before your next period."),
                EducationKeyPoint(icon: "arrow.triangle.merge", title: "Fertilization", description: "Sperm meets the egg in the fallopian tube."),
                EducationKeyPoint(icon: "house.fill", title: "Implantation", description: "The fertilized egg attaches to the uterine wall, starting pregnancy.")
            ]
        ),
        EducationPageSection(
            id: 3,
            icon: "waveform.path.ecg",
            title: "What Is hCG?",
            description: "hCG (human chorionic gonadotropin) is a hormone produced after implantation. Pregnancy tests detect this hormone.",
            keyPoints: [
                EducationKeyPoint(icon: "chart.line.uptrend.xyaxis", title: "Rises in Early Pregnancy", description: "hCG levels increase rapidly in the first weeks."),
                EducationKeyPoint(icon: "clock.fill", title: "Timing Matters", description: "Testing too early may not detect hCG levels."),
                EducationKeyPoint(icon: "arrow.up.right", title: "Levels Increase Over Time", description: "hCG doubles roughly every 48–72 hours in early pregnancy.")
            ]
        ),
        EducationPageSection(
            id: 4,
            icon: "list.bullet.clipboard",
            title: "Possible Early Signs",
            description: "Some women may notice changes in the early weeks. These vary from person to person.",
            keyPoints: [
                EducationKeyPoint(icon: "calendar.badge.exclamationmark", title: "Missed Period", description: "Often the first noticeable sign."),
                EducationKeyPoint(icon: "bed.double.fill", title: "Fatigue & Nausea", description: "Feeling unusually tired or experiencing morning sickness."),
                EducationKeyPoint(icon: "hand.raised.fill", title: "Other Changes", description: "Breast tenderness, mild cramping, frequent urination."),
                EducationKeyPoint(icon: "exclamationmark.triangle.fill", title: "Important", description: "Symptoms alone cannot confirm pregnancy. Testing is required.")
            ]
        )
    ]
}

struct EducationKeyPoint: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Education Data
struct PregnancyEducationData {
    
    static let sections: [PregnancySection] = [
        // Section 1: Introduction
        PregnancySection(
            id: 1,
            title: "Learn About Pregnancy",
            subtitle: "Understanding the basics helps you make informed decisions.",
            content: "Pregnancy happens when a fertilized egg implants in the uterus.\n\nKnowing how this process works can help you better understand timing and testing.",
            keyPoints: nil, steps: nil, symptoms: nil, importantNote: nil, infoNote: nil,
            ctaTitle: nil, ctaDestination: nil
        ),
        
        // Section 2: How Pregnancy Happens
        PregnancySection(
            id: 2,
            title: "How Pregnancy Happens",
            subtitle: nil,
            content: "Understanding the biological process helps you know when testing is most effective.",
            keyPoints: nil,
            steps: [
                PregnancyStep(icon: "circle.fill", title: "Ovulation", description: "The ovary releases an egg"),
                PregnancyStep(icon: "arrow.triangle.merge", title: "Fertilization", description: "Sperm meets the egg"),
                PregnancyStep(icon: "house.fill", title: "Implantation", description: "The fertilized egg attaches to the uterus")
            ],
            symptoms: nil, importantNote: nil,
            infoNote: "Ovulation usually occurs 10–16 days before your next period.",
            ctaTitle: nil, ctaDestination: nil
        ),
        
        // Section 3: What Is hCG?
        PregnancySection(
            id: 3,
            title: "What Is hCG?",
            subtitle: nil,
            content: "hCG (human chorionic gonadotropin) is a hormone produced after implantation.\n\nPregnancy tests detect this hormone.",
            keyPoints: [
                PregnancyKeyPoint(icon: "chart.line.uptrend.xyaxis", text: "hCG rises in early pregnancy"),
                PregnancyKeyPoint(icon: "clock.fill", text: "Testing too early may not detect it"),
                PregnancyKeyPoint(icon: "arrow.up.right", text: "Levels increase over time")
            ],
            steps: nil, symptoms: nil, importantNote: nil, infoNote: nil,
            ctaTitle: nil, ctaDestination: nil
        ),
        
        // Section 4: Early Signs
        PregnancySection(
            id: 4,
            title: "Possible Early Signs",
            subtitle: nil,
            content: "Some women may notice changes in the early weeks. These vary from person to person.",
            keyPoints: nil, steps: nil,
            symptoms: [
                "Missed period", "Breast tenderness",
                "Fatigue", "Nausea",
                "Mild cramping", "Frequent urination"
            ],
            importantNote: "Symptoms alone cannot confirm pregnancy. Testing is required.",
            infoNote: nil,
            ctaTitle: "Go to Probability Check",
            ctaDestination: .probabilityCheck
        )
    ]
    
    // MARK: - Test Guide Data
    static let testGuide: [TestGuideSection] = [
        TestGuideSection(
            id: 1,
            title: "How to Use a Pregnancy Test",
            content: "Following the correct steps ensures accurate results.",
            steps: nil, results: nil, tips: nil
        ),
        TestGuideSection(
            id: 2,
            title: "Step-by-Step Guide",
            content: "Follow these steps carefully for the most accurate result.",
            steps: [
                TestGuideStep(icon: "calendar.badge.checkmark", instruction: "Check expiration date"),
                TestGuideStep(icon: "sunrise.fill", instruction: "Use first morning urine"),
                TestGuideStep(icon: "doc.text.fill", instruction: "Follow instructions carefully"),
                TestGuideStep(icon: "timer", instruction: "Wait recommended time")
            ],
            results: nil, tips: nil
        ),
        TestGuideSection(
            id: 3,
            title: "Understanding Results",
            content: "Here's what different results mean.",
            steps: nil,
            results: [
                TestResult(icon: "checkmark.circle.fill", label: "Two lines", meaning: "Positive", color: "pink"),
                TestResult(icon: "minus.circle.fill", label: "One control line", meaning: "Negative", color: "gray"),
                TestResult(icon: "exclamationmark.triangle.fill", label: "No control line", meaning: "Invalid", color: "orange")
            ],
            tips: nil
        ),
        TestGuideSection(
            id: 4,
            title: "If Unsure",
            content: "Not sure about your result? Here's what to do.",
            steps: nil, results: nil,
            tips: [
                TestGuideTip(condition: "If negative but period is late", advice: "Retest in 2–3 days."),
                TestGuideTip(condition: "If positive", advice: "Consider medical confirmation.")
            ]
        )
    ]
    
    // MARK: - Emotional Support Data
    static let emotionalSections: [EmotionalSection] = [
        EmotionalSection(
            id: 1,
            title: "While Waiting",
            content: "It's normal to feel anxious while waiting for results.",
            suggestions: [
                EmotionalSuggestion(icon: "wind", text: "Deep breathing"),
                EmotionalSuggestion(icon: "paintpalette.fill", text: "Gentle distractions"),
                EmotionalSuggestion(icon: "xmark.circle", text: "Avoid overanalyzing symptoms")
            ],
            emotions: nil, nextSteps: nil, breathingExercise: nil
        ),
        EmotionalSection(
            id: 2,
            title: "If Negative",
            content: "Mixed feelings are normal.",
            suggestions: nil,
            emotions: [
                EmotionItem(emoji: "😌", label: "Relief"),
                EmotionItem(emoji: "😔", label: "Disappointment"),
                EmotionItem(emoji: "🤔", label: "Uncertainty")
            ],
            nextSteps: nil, breathingExercise: nil
        ),
        EmotionalSection(
            id: 3,
            title: "If Positive",
            content: "Take a moment to breathe.",
            suggestions: nil, emotions: nil,
            nextSteps: [
                "Confirm with healthcare provider",
                "Discuss options",
                "Seek support"
            ],
            breathingExercise: nil
        ),
        EmotionalSection(
            id: 4,
            title: "Breathing Exercise",
            content: "A simple exercise to help you feel calm.",
            suggestions: nil, emotions: nil, nextSteps: nil,
            breathingExercise: BreathingExercise(inhale: 4, hold: 4, exhale: 6, repeats: 5)
        )
    ]
    
    static let disclaimer = """
    This feature provides educational information only. It does not replace medical advice or laboratory testing. Consult a healthcare professional for medical concerns.
    """
}
