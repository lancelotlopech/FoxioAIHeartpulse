//
//  PregnancyProbabilityView.swift
//  HeartRateSenior
//
//  Pregnancy probability assessment view
//

import SwiftUI

struct PregnancyProbabilityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int: [Int]] = [:] // questionId: [optionIndices]
    @State private var showResult = false
    
    private let questions = ProbabilityAssessmentData.questions
    private let primaryColor = Color(red: 1.0, green: 0.6, blue: 0.7)
    
    private var canProceed: Bool {
        guard let answers = selectedAnswers[questions[currentQuestionIndex].id] else {
            return false
        }
        return !answers.isEmpty
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if showResult {
                ProbabilityResultView(
                    result: calculateResult(),
                    onDismiss: { dismiss() }
                )
            } else {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            if currentQuestionIndex > 0 {
                                currentQuestionIndex -= 1
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: currentQuestionIndex > 0 ? "chevron.left" : "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Text("Pregnancy Check")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(primaryColor)
                                .frame(width: geometry.size.width * CGFloat(currentQuestionIndex + 1) / CGFloat(questions.count), height: 4)
                                .animation(.spring(response: 0.3), value: currentQuestionIndex)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Question Content
                    TabView(selection: $currentQuestionIndex) {
                        ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                            QuestionContentView(
                                question: question,
                                questionNumber: index + 1,
                                totalQuestions: questions.count,
                                selectedIndices: selectedAnswers[question.id] ?? [],
                                onSelect: { optionIndex in
                                    handleOptionSelection(questionId: question.id, optionIndex: optionIndex, questionType: question.type)
                                }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .allowsHitTesting(true)
                    
                    // Navigation Button
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        if currentQuestionIndex < questions.count - 1 {
                            withAnimation {
                                currentQuestionIndex += 1
                            }
                        } else {
                            showResult = true
                        }
                    }) {
                        Text(currentQuestionIndex < questions.count - 1 ? "Next" : "See Result")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(canProceed ? primaryColor : Color.gray.opacity(0.3))
                            )
                    }
                    .disabled(!canProceed)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func handleOptionSelection(questionId: Int, optionIndex: Int, questionType: ProbabilityQuestion.QuestionType) {
        HapticManager.shared.selectionChanged()
        
        switch questionType {
        case .singleChoice:
            selectedAnswers[questionId] = [optionIndex]
        case .multipleChoice:
            var current = selectedAnswers[questionId] ?? []
            if let index = current.firstIndex(of: optionIndex) {
                current.remove(at: index)
            } else {
                current.append(optionIndex)
            }
            selectedAnswers[questionId] = current
        }
    }
    
    private func calculateResult() -> ProbabilityResult {
        var totalScore = 0
        var timingAnswer: TimingOption?
        
        for question in questions {
            guard let selectedIndices = selectedAnswers[question.id] else { continue }
            
            // Question 1 is timing
            if question.id == 1, let firstIndex = selectedIndices.first {
                timingAnswer = TimingOption(rawValue: firstIndex)
            }
            
            // Calculate score
            switch question.type {
            case .singleChoice:
                if let index = selectedIndices.first, index < question.options.count {
                    totalScore += question.options[index].score
                }
            case .multipleChoice(let maxScore):
                let questionScore = selectedIndices.reduce(0) { sum, index in
                    guard index < question.options.count else { return sum }
                    return sum + question.options[index].score
                }
                totalScore += min(questionScore, maxScore)
            }
        }
        
        return ProbabilityResult(
            totalScore: totalScore,
            timingAnswer: timingAnswer,
            selectedAnswers: selectedAnswers
        )
    }
}

// MARK: - Question Content View
struct QuestionContentView: View {
    let question: ProbabilityQuestion
    let questionNumber: Int
    let totalQuestions: Int
    let selectedIndices: [Int]
    let onSelect: (Int) -> Void
    
    private let primaryColor = Color(red: 1.0, green: 0.6, blue: 0.7)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Section Badge
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(primaryColor.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Text("\(questionNumber)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(primaryColor)
                    }
                    
                    Text("Question \(questionNumber) of \(totalQuestions)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(primaryColor)
                    
                    Text(question.section)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
                // Question Title
                Text(question.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                
                // Note if available
                if let note = question.note {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text(note)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
                
                // Options
                VStack(spacing: 12) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                        OptionButtonView(
                            text: option.text,
                            isSelected: selectedIndices.contains(index),
                            isMultipleChoice: isMultipleChoice(question.type),
                            onTap: { onSelect(index) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
        }
    }
    
    private func isMultipleChoice(_ type: ProbabilityQuestion.QuestionType) -> Bool {
        if case .multipleChoice = type {
            return true
        }
        return false
    }
}

// MARK: - Option Button View
struct OptionButtonView: View {
    let text: String
    let isSelected: Bool
    let isMultipleChoice: Bool
    let onTap: () -> Void
    
    private let primaryColor = Color(red: 1.0, green: 0.6, blue: 0.7)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if isMultipleChoice {
                    // Checkbox for multiple choice
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(isSelected ? primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(primaryColor)
                        }
                    }
                } else {
                    // Radio button for single choice
                    ZStack {
                        Circle()
                            .strokeBorder(isSelected ? primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Circle()
                                .fill(primaryColor)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                
                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? primaryColor.opacity(0.08) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? primaryColor : Color.gray.opacity(0.2), lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Result View
struct ProbabilityResultView: View {
    let result: ProbabilityResult
    let onDismiss: () -> Void
    
    @State private var navigateToTiming = false
    @State private var navigateToGuide = false
    @State private var navigateToReminders = false
    
    private let primaryColor = Color(red: 1.0, green: 0.6, blue: 0.7)
    
    private var level: ProbabilityLevel {
        result.probabilityLevel
    }
    
    private var iconColor: Color {
        switch level {
        case .low: return .green
        case .moderate: return .yellow
        case .higher: return .orange
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: level.icon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(iconColor)
                }
                .padding(.top, 40)
                
                // Result Level
                Text(level.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                // Score
                Text("Score: \(result.totalScore)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                // Description
                Text(level.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                
                // Recommendations
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recommendations")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    ForEach(level.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(primaryColor)
                            
                            Text(recommendation)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
                .padding(.horizontal, 20)
                
                // Retest Date if applicable
                if let retestDate = result.suggestedRetestDate {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(primaryColor)
                            Text("Suggested Retest Date")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Text(retestDate, style: .date)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(primaryColor)
                        
                        Text(ProbabilityAssessmentData.retestRecommendationText)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(primaryColor.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                
                // CTA Buttons with Navigation
                VStack(spacing: 12) {
                    ForEach(level.ctaButtons, id: \.title) { button in
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            handleCTAAction(button: button)
                        }) {
                            HStack {
                                Image(systemName: button.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                Text(button.title)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(primaryColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(primaryColor, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        
                        Text("Important")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                    Text(ProbabilityAssessmentData.disclaimerText)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.blue.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Done Button
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    onDismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(primaryColor)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .background(
            NavigationLink(destination: PregnancyTestTimingView(), isActive: $navigateToTiming) { EmptyView() }
        )
        .background(
            NavigationLink(destination: PregnancyTestGuideView(), isActive: $navigateToGuide) { EmptyView() }
        )
        .background(
            NavigationLink(destination: PregnancyReminderCenterView(), isActive: $navigateToReminders) { EmptyView() }
        )
    }
    
    private func handleCTAAction(button: CTAButton) {
        switch button.title {
        case "When Should I Test":
            navigateToTiming = true
        case "Testing Guide":
            navigateToGuide = true
        case "Set Reminder":
            navigateToReminders = true
        default:
            break
        }
    }
}

#Preview {
    PregnancyProbabilityView()
}
