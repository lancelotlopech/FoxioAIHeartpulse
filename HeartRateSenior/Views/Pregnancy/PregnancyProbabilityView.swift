//
//  PregnancyProbabilityView.swift
//  HeartRateSenior
//
//  Pregnancy probability assessment view — Minimalist redesign
//

import SwiftUI
import SwiftData
import UIKit

struct PregnancyProbabilityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int: [Int]] = [:]
    @State private var showResult = false
    @State private var computedResult: ProbabilityResult?
    
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
                    result: computedResult ?? calculateResult(),
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
                            let result = calculateResult()
                            computedResult = result
                            persistAssessmentRecord(result)
                            withAnimation(.easeInOut(duration: 0.3)) { showResult = true }
                        }
                    } label: {
                        Text(currentQuestionIndex < questions.count - 1 ? pregnancyText(.next) : pregnancyRawText("See Result"))
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
    
    private func persistAssessmentRecord(_ result: ProbabilityResult) {
        struct Snapshot: Encodable {
            let answers: [String: [Int]]
        }
        
        let answers: [String: [Int]] = result.selectedAnswers.reduce(into: [:]) { partial, pair in
            partial[String(pair.key)] = pair.value
        }
        let snapshotData = (try? JSONEncoder().encode(Snapshot(answers: answers))) ?? Data()
        
        let levelRaw: String
        switch result.probabilityLevel {
        case .low: levelRaw = "low"
        case .moderate: levelRaw = "moderate"
        case .higher: levelRaw = "higher"
        }
        
        let record = PregnancyAssessmentRecord(
            totalScore: result.totalScore,
            probabilityLevelRaw: levelRaw,
            timingAnswerRaw: result.timingAnswer?.rawValue,
            suggestedRetestDate: result.suggestedRetestDate,
            answersSnapshotJSON: snapshotData
        )
        modelContext.insert(record)
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
                Text(pregnancyRawText(question.section).uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(primaryColor)
                    .tracking(1.2)
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                
                // Question title
                Text(pregnancyRawText(question.title))
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
                        Text(pregnancyRawText(note))
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
                            text: pregnancyRawText(option.text),
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
                    Text(pregnancyRawText("Select all that apply"))
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
    
    @Environment(\.modelContext) private var modelContext
    @Query private var cycleProfiles: [CycleProfile]
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var reminderManager = ReminderManager.shared
    
    @State private var navigateToTiming = false
    @State private var navigateToGuide = false
    @State private var navigateToReminders = false
    @State private var animateIn = false
    @State private var showingSubscription = false
    @State private var showingHistory = false
    @State private var showingPermissionAlert = false
    @State private var showingReminderCreatedAlert = false
    
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
                    Text(pregnancyText(.score))
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
                    Text(pregnancyText(.recommendations))
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
                            Text(pregnancyRawText("Suggested Retest Date"))
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

                // Smart Retest Plan (Premium)
                PremiumSectionContainer(
                    showSubscription: $showingSubscription,
                    title: pregnancyRawText("Unlock Smart Retest Plan"),
                    subtitle: pregnancyRawText("Get a personalized testing window and one-tap reminders")
                ) {
                    SmartRetestPlanCard(
                        primaryColor: primaryColor,
                        windowStart: smartTestWindowStart,
                        windowEnd: smartTestWindowEnd,
                        followUpDate: smartFollowUpDate,
                        onAddReminder: addRetestReminder
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
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

                Button {
                    HapticManager.shared.lightImpact()
                    showingHistory = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14, weight: .semibold))
                        Text(pregnancyText(.viewHistory))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "666666"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "f8f6f6"))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "999999"))
                        Text(pregnancyText(.important))
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
                    Text(pregnancyText(.done))
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
            Task { @MainActor in
                await reminderManager.checkAuthorizationStatus()
            }
        }
        .fullScreenCover(isPresented: $showingSubscription) {
            SubscriptionView(isPresented: $showingSubscription)
        }
        .sheet(isPresented: $showingHistory) {
            PregnancyAssessmentHistoryView()
        }
        .alert(pregnancyText(.enableNotificationsTitle), isPresented: $showingPermissionAlert) {
            Button(pregnancyText(.openSettings)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(pregnancyText(.cancel), role: .cancel) {}
        } message: {
            Text(pregnancyText(.enableNotificationsMessage))
        }
        .alert(pregnancyText(.reminderCreatedTitle), isPresented: $showingReminderCreatedAlert) {
            Button(pregnancyText(.ok), role: .cancel) {}
        } message: {
            Text(pregnancyText(.reminderCreatedMessage))
        }
    }
    
    private func handleCTAAction(button: CTAButton) {
        switch button.action {
        case .timing:
            navigateToTiming = true
        case .guide:
            navigateToGuide = true
        case .reminder:
            navigateToReminders = true
        }
    }
    
    private var activeCycleProfile: CycleProfile? {
        cycleProfiles.max(by: { $0.updatedAt < $1.updatedAt })
    }
    
    private var nextExpectedPeriodDate: Date? {
        guard let profile = activeCycleProfile else { return nil }
        return Calendar.current.date(byAdding: .day, value: profile.cycleLengthDays, to: profile.lastPeriodDate)
    }
    
    private var smartTestWindowStart: Date {
        let calendar = Calendar.current
        let today = Date()
        let base = result.suggestedRetestDate ?? nextExpectedPeriodDate ?? (calendar.date(byAdding: .day, value: 7, to: today) ?? today)
        if let next = nextExpectedPeriodDate {
            return max(base, next)
        }
        return base
    }
    
    private var smartTestWindowEnd: Date {
        Calendar.current.date(byAdding: .day, value: 2, to: smartTestWindowStart) ?? smartTestWindowStart
    }
    
    private var smartFollowUpDate: Date {
        Calendar.current.date(byAdding: .day, value: 3, to: smartTestWindowEnd) ?? smartTestWindowEnd
    }
    
    private func addRetestReminder() {
        guard subscriptionManager.isPremium else {
            showingSubscription = true
            return
        }
        
        let status = reminderManager.authorizationStatus
        if status == .notDetermined {
            Task { @MainActor in
                let granted = await reminderManager.requestAuthorization()
                if granted {
                    createRetestReminder()
                } else {
                    showingPermissionAlert = true
                }
            }
            return
        }
        if status == .denied {
            showingPermissionAlert = true
            return
        }
        
        createRetestReminder()
    }
    
    private func createRetestReminder() {
        let reminderTime = setHourMinute(9, 0, on: smartTestWindowStart)
        let reminder = Reminder(
            title: pregnancyRawText("Pregnancy Test (Retest)"),
            reminderType: .pregnancyTest,
            time: reminderTime,
            repeatFrequency: .once,
            notes: pregnancyRawText("Suggested retest date from Pregnancy self-check.")
        )
        modelContext.insert(reminder)
        Task { @MainActor in
            await reminderManager.scheduleNotification(for: reminder)
        }
        showingReminderCreatedAlert = true
    }
    
    private func setHourMinute(_ hour: Int, _ minute: Int, on date: Date) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? date
    }
}

private struct SmartRetestPlanCard: View {
    let primaryColor: Color
    let windowStart: Date
    let windowEnd: Date
    let followUpDate: Date
    let onAddReminder: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(pregnancyRawText("Smart Retest Plan"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    Text(pregnancyRawText("Personalized next steps"))
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "888888"))
                }
                
                Spacer()
                
                Text(pregnancyRawText("PRO"))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(primaryColor))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(pregnancyRawText("Best testing window"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "666666"))
                
                HStack(spacing: 10) {
                    SmartPlanDatePill(label: pregnancyRawText("Start"), date: windowStart, color: primaryColor)
                    SmartPlanDatePill(label: pregnancyRawText("End"), date: windowEnd, color: primaryColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(pregnancyRawText("If the result is negative"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "666666"))
                Text(pregnancyFormat(.retestOnDateFormat, followUpDate.formatted(date: .abbreviated, time: .omitted)))
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "777777"))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SmartPlanBullet(text: pregnancyRawText("Use first morning urine when possible."))
                SmartPlanBullet(text: pregnancyRawText("Follow the test instructions and timing exactly."))
                SmartPlanBullet(text: pregnancyRawText("This is educational guidance, not a diagnosis."))
            }
            .padding(.top, 4)
            
            Button(action: onAddReminder) {
                HStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(pregnancyRawText("Add Retest Reminder"))
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(primaryColor)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(hex: "ebebeb"), lineWidth: 1)
                )
        )
    }
}

private struct SmartPlanDatePill: View {
    let label: String
    let date: Date
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "999999"))
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: "1a1a1a"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
        )
    }
}

private struct SmartPlanBullet: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color(hex: "dddddd"))
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "777777"))
        }
    }
}

#Preview {
    NavigationStack {
        PregnancyProbabilityView()
    }
}
