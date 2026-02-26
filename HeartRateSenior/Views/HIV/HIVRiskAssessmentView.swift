//
//  HIVRiskAssessmentView.swift
//  HeartRateSenior
//
//  HIV Risk Self-Assessment - Complete Implementation
//

import SwiftUI

struct HIVRiskAssessmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: AssessmentPage = .intro
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int: [Int]] = [:] // questionId: [optionIndices]
    @State private var assessmentResult: AssessmentResult?
    
    private let questions = HIVAssessmentData.localizedQuestions
    
    enum AssessmentPage {
        case intro
        case question
        case result
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                switch currentPage {
                case .intro:
                    IntroPageView(onStart: {
                        HapticManager.shared.mediumImpact()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = .question
                        }
                    })
                    
                case .question:
                    QuestionPageView(
                        question: questions[currentQuestionIndex],
                        questionNumber: currentQuestionIndex + 1,
                        totalQuestions: questions.count,
                        selectedOptions: selectedAnswers[questions[currentQuestionIndex].id] ?? [],
                        onOptionSelected: { optionIndex in
                            handleOptionSelection(optionIndex)
                        },
                        onNext: {
                            moveToNextQuestion()
                        },
                        onBack: {
                            moveToPreviousQuestion()
                        }
                    )
                    
                case .result:
                    if let result = assessmentResult {
                        ResultPageView(
                            result: result,
                            onRetake: {
                                retakeAssessment()
                            },
                            onClose: {
                                dismiss()
                            }
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleOptionSelection(_ optionIndex: Int) {
        let question = questions[currentQuestionIndex]
        
        switch question.type {
        case .singleChoice:
            selectedAnswers[question.id] = [optionIndex]
            // 单选题：自动进入下一题
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                moveToNextQuestion()
            }
            
        case .multipleChoice:
            var current = selectedAnswers[question.id] ?? []
            if let index = current.firstIndex(of: optionIndex) {
                current.remove(at: index)
            } else {
                current.append(optionIndex)
            }
            selectedAnswers[question.id] = current
        }
        
        HapticManager.shared.selectionChanged()
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex += 1
            }
        } else {
            // 完成问卷，计算结果
            calculateResult()
        }
    }
    
    private func moveToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex -= 1
            }
            HapticManager.shared.lightImpact()
        }
    }
    
    private func calculateResult() {
        var totalScore = 0
        var exposureTimeframe: ExposureTimeframe?
        
        for (questionId, optionIndices) in selectedAnswers {
            guard let question = questions.first(where: { $0.id == questionId }) else { continue }
            
            switch question.type {
            case .singleChoice:
                if let index = optionIndices.first, index < question.options.count {
                    totalScore += question.options[index].score
                    
                    // 记录 Q1 的暴露时间
                    if questionId == 1 {
                        exposureTimeframe = ExposureTimeframe.allCases[index]
                    }
                }
                
            case .multipleChoice(let maxScore):
                let score = optionIndices.reduce(0) { sum, index in
                    sum + (index < question.options.count ? question.options[index].score : 0)
                }
                totalScore += min(score, maxScore)
            }
        }
        
        assessmentResult = AssessmentResult(
            totalScore: totalScore,
            exposureTimeframe: exposureTimeframe,
            selectedAnswers: selectedAnswers
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage = .result
        }
        
        HapticManager.shared.heavyImpact()
    }
    
    private func retakeAssessment() {
        selectedAnswers.removeAll()
        currentQuestionIndex = 0
        assessmentResult = nil
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage = .intro
        }
        
        HapticManager.shared.mediumImpact()
    }
}

// MARK: - Intro Page View
struct IntroPageView: View {
    let onStart: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 40)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(AppColors.primaryRed.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checklist.checked")
                        .font(.system(size: 56))
                        .foregroundColor(AppColors.primaryRed)
                }
                
                // Title
                VStack(spacing: 12) {
                    Text(hivRawText("HIV Risk Self-Assessment"))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(hivText(.beforeYouStart))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.primaryRed)
                }
                
                // Intro Text
                VStack(alignment: .leading, spacing: 16) {
                    Text(HIVAssessmentData.localizedIntroText)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(6)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Start Button
                Button(action: onStart) {
                    HStack(spacing: 12) {
                        Text(hivText(.startAssessment))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.primaryRed)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Question Page View
struct QuestionPageView: View {
    let question: AssessmentQuestion
    let questionNumber: Int
    let totalQuestions: Int
    let selectedOptions: [Int]
    let onOptionSelected: (Int) -> Void
    let onNext: () -> Void
    let onBack: () -> Void
    
    private var isMultipleChoice: Bool {
        if case .multipleChoice = question.type {
            return true
        }
        return false
    }
    
    private var canProceed: Bool {
        !selectedOptions.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressView(value: Double(questionNumber), total: Double(totalQuestions))
                .tint(AppColors.primaryRed)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Question Header
                    VStack(spacing: 12) {
                        Text(hivFormat(.questionProgressFormat, questionNumber, totalQuestions))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.primaryRed)
                        
                        Text(question.section)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(question.title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Options
                    VStack(spacing: 12) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            OptionCardView(
                                option: option,
                                isSelected: selectedOptions.contains(index),
                                isMultipleChoice: isMultipleChoice,
                                onTap: {
                                    onOptionSelected(index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Note (if exists)
                    if let note = question.note {
                        Text(note)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer().frame(height: 100)
                }
            }
            
            // Bottom Navigation
            VStack(spacing: 12) {
                // Next Button (for multiple choice)
                if isMultipleChoice {
                    Button(action: onNext) {
                        Text(hivText(.next))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(canProceed ? AppColors.primaryRed : Color.gray.opacity(0.3))
                            .cornerRadius(16)
                    }
                    .disabled(!canProceed)
                }
                
                // Back Button
                if questionNumber > 1 {
                    Button(action: onBack) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text(hivText(.previousQuestion))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white.shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4))
        }
    }
}

// MARK: - Option Card View
struct OptionCardView: View {
    let option: AssessmentOption
    let isSelected: Bool
    let isMultipleChoice: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection Indicator
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? AppColors.primaryRed : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(AppColors.primaryRed)
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Option Text
                Text(option.text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColors.primaryRed.opacity(0.05) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? AppColors.primaryRed : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Result Page View
struct ResultPageView: View {
    let result: AssessmentResult
    let onRetake: () -> Void
    let onClose: () -> Void
    @State private var showingHIVOverview = false
    
    private var riskColor: Color {
        switch result.riskLevel {
        case .low: return .green
        case .moderate: return .orange
        case .high: return .red
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)
                
                // Risk Level Icon
                ZStack {
                    Circle()
                        .fill(riskColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: result.riskLevel.icon)
                        .font(.system(size: 56))
                        .foregroundColor(riskColor)
                }
                
                // Risk Level Title
                VStack(spacing: 8) {
                    Text(result.riskLevel.localizedTitle)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(hivFormat(.scoreFormat, result.totalScore))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Description
                Text(result.riskLevel.localizedDescription)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                // Recommendations
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(result.riskLevel.localizedRecommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(riskColor)
                            
                            Text(recommendation)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                
                // Retest Recommendation (if applicable)
                if let timeframe = result.exposureTimeframe, !timeframe.retestDays.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(hivText(.smartRetestSuggestion))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(HIVAssessmentData.localizedRetestRecommendationText)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(4)
                        
                        HStack(spacing: 12) {
                            ForEach(timeframe.retestDays, id: \.self) { days in
                                VStack(spacing: 4) {
                                    Text("\(days)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.primaryRed)
                                    
                                    Text(hivText(.days))
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.primaryRed.opacity(0.1))
                                )
                            }
                        }
                        
                        Text(hivText(.repeatTestingImprovesAccuracy))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .italic()
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                }
                
                // CTA Buttons
                VStack(spacing: 12) {
                    ForEach(result.riskLevel.localizedCTAButtons, id: \.title) { button in
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            showingHIVOverview = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: button.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text(button.title)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(riskColor)
                            .cornerRadius(14)
                        }
                    }
                    
                    // Retake Button
                    Button(action: onRetake) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .semibold))
                            Text(hivText(.retakeAssessment))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Disclaimer
                VStack(spacing: 12) {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    Text(hivText(.complianceDisclaimer))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(HIVAssessmentData.localizedDisclaimerText)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                
                Spacer().frame(height: 20)
            }
        }
        .fullScreenCover(isPresented: $showingHIVOverview) {
            HIVAwarenessView()
        }
    }
}

#Preview {
    HIVRiskAssessmentView()
}
