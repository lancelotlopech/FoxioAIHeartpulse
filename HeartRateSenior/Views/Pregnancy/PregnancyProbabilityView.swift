//
//  PregnancyProbabilityView.swift
//  HeartRateSenior
//
//  Pregnancy probability assessment view — Minimalist redesign
//

import SwiftUI

struct PregnancyProbabilityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int: [Int]] = [:]
    @State private var showResult = false
    
    private let questions = ProbabilityAssessmentData.questions
    private let primaryColor = Color(red: 0.93, green: 0.17, blue: 0.36)
    
    private var canProceed: Bool {
        guard let answers = selectedAnswers[questions[currentQuestionIndex].id] else { return false }
        return !answers.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if showResult {
                ProbabilityResultView(
                    result: calculateResult(),
                    onDismiss: { dismiss() }
                )
            } else {
                VStack(spacing: 0) {
                    // Top bar
                    HStack {
                        Button {
                            HapticManager.shared.lightImpact()
                            if currentQuestionIndex > 0 {
                                withAnimation(.easeInOut(duration: 0.25)) { currentQuestionIndex -= 1 }
                            } else {
                                dismiss()
                            }
                        } label: {
                            Image(systemName: currentQuestionIndex > 0 ? "chevron.left" : "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "1a1a1a"))
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color(hex: "f8f6f6")))
                        }
                        
                        Spacer()
                        
                        Text("\(currentQuestionIndex + 1) / \(questions.count)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "666666"))
                        
                        Spacer()
                        
                        Color.clear.frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "f0eeee"))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(primaryColor)
                                .frame(width: geo.size.width * CGFloat(currentQuestionIndex + 1) / CGFloat(questions.count), height: 4)
                                .animation(.easeInOut(duration: 0.3), value: currentQuestionIndex)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Question content
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
                    
                    // Next button
                    Button {
                        HapticManager.shared.mediumImpact()
                        if currentQuestionIndex < questions.count - 1 {
                            withAnimation(.easeInOut(duration: 0.25)) { currentQuestionIndex += 1 }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) { showResult = true }
                        }
                    } label: {
                        Text(currentQuestionIndex < questions.count - 1 ? "Next" : "See Result")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(canProceed ? primaryColor : Color(hex: "e0dede"))
                            )
                    }
                    .disabled(!canProceed)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
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
            if let idx = current.firstIndex(of: optionIndex) {
                current.remove(at: idx)
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
            if question.id == 1, let firstIndex = selectedIndices.first {
                timingAnswer = TimingOption(rawValue: firstIndex)
            }
            switch question.type {
            case .singleChoice:
                if let index = selectedIndices.first, index < question.options.count {
                    totalScore += question.options[index].score
                }
            case .multipleChoice(let maxScore):
                let qScore = selectedIndices.reduce(0) { sum, index in
                    guard index < question.options.count else { return sum }
                    return sum + question.options[index].score
                }
                totalScore += min(qScore, maxScore)
            }
        }
        return ProbabilityResult(totalScore: totalScore, timingAnswer: timingAnswer, selectedAnswers: selectedAnswers)
    }
}

// MARK: - Question Content View
struct QuestionContentView: View {
    let question: ProbabilityQuestion
    let questionNumber: Int
    let totalQuestions: Int
    let selectedIndices: [Int]
    let onSelect: (Int) -> Void
    
    private let primaryColor = Color(red: 0.93, green: 0.17, blue: 0.36)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Section label
                Text(question.section.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(primaryColor)
                    .tracking(1.2)
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                
                // Question title
                Text(question.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "1a1a1a"))
                    .lineSpacing(4)
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                
                // Note
                if let note = question.note {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "999999"))
                        Text(note)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "888888"))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "f8f6f6"))
                    )
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                }
                
                // Options
                VStack(spacing: 10) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                        OptionButtonView(
                            text: option.text,
                            isSelected: selectedIndices.contains(index),
                            isMultipleChoice: isMultipleChoice(question.type),
                            onTap: { onSelect(index) }
                        )
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
                
                // Multiple choice hint
                if isMultipleChoice(question.type) {
                    Text("Select all that apply")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "aaaaaa"))
                        .padding(.top, 8)
                        .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 40)
            }
        }
    }
    
    private func isMultipleChoice(_ type: ProbabilityQuestion.QuestionType) -> Bool {
        if case .multipleChoice = type { return true }
        return false
    }
}

// MARK: - Option Button View
struct OptionButtonView: View {
    let text: String
    let isSelected: Bool
    let isMultipleChoice: Bool
    let onTap: () -> Void
    
    private let primaryColor = Color(red: 0.93, green: 0.17, blue: 0.36)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Indicator
                if isMultipleChoice {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(isSelected ? primaryColor : Color(hex: "d5d5d5"), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Group {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(primaryColor)
                                        .frame(width: 14, height: 14)
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                        )
                } else {
                    Circle()
                        .strokeBorder(isSelected ? primaryColor : Color(hex: "d5d5d5"), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Group {
                                if isSelected {
                                    Circle()
                                        .fill(primaryColor)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        )
                }
                
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "1a1a1a"))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? primaryColor.opacity(0.06) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? primaryColor : Color(hex: "ebebeb"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Result View
struct ProbabilityResultView: View {
    let result: ProbabilityResult
    let onDismiss: () -> Void
    
    @State private var navigateToTiming = false
    @State private var navigateToGuide = false
    @State private var navigateToReminders = false
    @State private var animateIn = false
    
    private let primaryColor = Color(red: 0.93, green: 0.17, blue: 0.36)
    
    private var level: ProbabilityLevel { result.probabilityLevel }
    
    private var levelColor: Color {
        switch level {
        case .low: return Color(hex: "34c759")
        case .moderate: return Color(hex: "ff9500")
        case .higher: return primaryColor
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Result header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(levelColor.opacity(0.12))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: level.icon)
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(levelColor)
                    }
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)
                    
                    Text(level.title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Text(level.description)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "888888"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 48)
                .padding(.bottom, 32)
                
                // Score pill
                HStack(spacing: 6) {
                    Text("Score")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "888888"))
                    Text("\(result.totalScore)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(levelColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(levelColor.opacity(0.1))
                )
                .padding(.bottom, 28)
                
                // Recommendations
                VStack(alignment: .leading, spacing: 14) {
                    Text("Recommendations")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    ForEach(level.recommendations, id: \.self) { rec in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(primaryColor)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(primaryColor.opacity(0.1)))
                            
                            Text(rec)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "555555"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "f8f6f6"))
                )
                .padding(.horizontal, 20)
                
                // Retest date
                if let retestDate = result.suggestedRetestDate {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 16))
                                .foregroundColor(primaryColor)
                            Text("Suggested Retest Date")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "1a1a1a"))
                        }
                        
                        Text(retestDate, style: .date)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(primaryColor)
                        
                        Text(ProbabilityAssessmentData.retestRecommendationText)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "888888"))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(primaryColor.opacity(0.06))
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                
                // CTA Buttons
                VStack(spacing: 10) {
                    ForEach(level.ctaButtons, id: \.title) { button in
                        Button {
                            HapticManager.shared.mediumImpact()
                            handleCTAAction(button: button)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: button.icon)
                                    .font(.system(size: 15, weight: .semibold))
                                Text(button.title)
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(primaryColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(primaryColor, lineWidth: 1.5)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "999999"))
                        Text("Important")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "999999"))
                    }
                    
                    Text(ProbabilityAssessmentData.disclaimerText)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "aaaaaa"))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "f8f6f6"))
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Done button
                Button {
                    HapticManager.shared.mediumImpact()
                    onDismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(primaryColor)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .background(
            NavigationLink(destination: PregnancyTestTimingView(), isActive: $navigateToTiming) { EmptyView() }
        )
        .background(
            NavigationLink(destination: PregnancyTestGuideView(), isActive: $navigateToGuide) { EmptyView() }
        )
        .background(
            NavigationLink(destination: PregnancyReminderCenterView(), isActive: $navigateToReminders) { EmptyView() }
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateIn = true
            }
        }
    }
    
    private func handleCTAAction(button: CTAButton) {
        switch button.title {
        case "When Should I Test": navigateToTiming = true
        case "Testing Guide": navigateToGuide = true
        case "Set Reminder": navigateToReminders = true
        default: break
        }
    }
}

#Preview {
    NavigationStack {
        PregnancyProbabilityView()
    }
}
