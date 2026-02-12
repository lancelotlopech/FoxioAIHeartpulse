//
//  EmotionalSupportView.swift
//  HeartRateSenior
//
//  Emotional support during pregnancy testing (4-page carousel)
//

import SwiftUI

struct EmotionalSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathProgress: CGFloat = 0
    
    private let pages = PregnancyEducationData.emotionalSections
    private let primaryColor = Color(red: 1.0, green: 0.55, blue: 0.65)
    
    enum BreathPhase: String {
        case inhale = "Inhale"
        case hold = "Hold"
        case exhale = "Exhale"}
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Emotional Support")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? primaryColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 16)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, section in
                        ScrollView {
                            VStack(spacing: 24) {
                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(primaryColor.opacity(0.15))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: iconForSection(index))
                                        .font(.system(size: 36, weight: .medium))
                                        .foregroundColor(primaryColor)
                                }
                                .padding(.top, 20)
                                
                                // Title
                                Text(section.title)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                // Content
                                Text(section.content)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                                    .padding(.horizontal, 32)
                                
                                // Section-specific content
                                if let suggestions = section.suggestions {
                                    SuggestionsView(suggestions: suggestions)
                                }
                                
                                if let emotions = section.emotions {
                                    EmotionsView(emotions: emotions)
                                }
                                
                                if let nextSteps = section.nextSteps {
                                    NextStepsView(steps: nextSteps)
                                }
                                
                                if let exercise = section.breathingExercise {
                                    BreathingView(exercise: exercise)
                                }
                                
                                Spacer(minLength: 40)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, _ in
                    HapticManager.shared.selectionChanged()
                }
                
                // Navigation
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            withAnimation { currentPage -= 1 }
                        }) {
                            Text("Previous")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(primaryColor)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(primaryColor, lineWidth: 2)
                                )
                        }
                    }
                    
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        if currentPage < pages.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            dismiss()
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Done")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(primaryColor)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func iconForSection(_ index: Int) -> String {
        switch index {
        case 0: return "hourglass"
        case 1: return "face.smiling"
        case 2: return "heart.fill"
        case 3: return "wind"
        default: return "heart.fill"
        }
    }
}

// MARK: - Suggestions View
struct SuggestionsView: View {
    let suggestions: [EmotionalSuggestion]
    private let primaryColor = Color(red: 1.0, green: 0.55, blue: 0.65)
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(suggestions) { suggestion in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(primaryColor.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: suggestion.icon)
                            .font(.system(size: 20))
                            .foregroundColor(primaryColor)
                    }
                    
                    Text(suggestion.text)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Emotions View
struct EmotionsView: View {
    let emotions: [EmotionItem]
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(emotions) { emotion in
                VStack(spacing: 8) {
                    Text(emotion.emoji)
                        .font(.system(size: 48))
                    Text(emotion.label)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Next Steps View
struct NextStepsView: View {
    let steps: [String]
    private let primaryColor = Color(red: 1.0, green: 0.55, blue: 0.65)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Next Steps")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(primaryColor.opacity(0.15))
                            .frame(width: 28, height: 28)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(primaryColor)
                    }
                    
                    Text(step)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
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
    }
}

// MARK: - Breathing View
struct BreathingView: View {
    let exercise: BreathingExercise
    @State private var isAnimating = false
    @State private var circleScale: CGFloat = 0.6
    @State private var phaseText = "Tap to Start"
    
    private let primaryColor = Color(red: 1.0, green: 0.55, blue: 0.65)
    
    var body: some View {
        VStack(spacing: 24) {
            // Breathing Circle
            ZStack {
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(primaryColor.opacity(0.3))
                    .frame(width: 200 * circleScale, height: 200 * circleScale).animation(.easeInOut(duration: Double(exercise.inhale)), value: circleScale)
                
                Text(phaseText)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(primaryColor)
            }
            .onTapGesture {
                if !isAnimating {
                    startBreathing()
                }
            }
            
            // Instructions
            VStack(spacing: 8) {
                Text("Inhale \(exercise.inhale)s → Hold \(exercise.hold)s → Exhale \(exercise.exhale)s")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                Text("Repeat \(exercise.repeats) times")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal, 20)
    }
    
    private func startBreathing() {
        isAnimating = true
        var currentRepeat = 0
        
        func doOneBreath() {
            guard currentRepeat < exercise.repeats else {
                phaseText = "Done ✓"
                isAnimating = false
                return
            }
            
            // Inhale
            phaseText = "Inhale..."
            withAnimation(.easeInOut(duration: Double(exercise.inhale))) {
                circleScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(exercise.inhale)) {
                // Hold
                phaseText = "Hold..."
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(exercise.hold)) {
                    // Exhale
                    phaseText = "Exhale..."
                    withAnimation(.easeInOut(duration: Double(exercise.exhale))) {
                        circleScale = 0.6
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(exercise.exhale)) {
                        currentRepeat += 1
                        doOneBreath()
                    }
                }
            }
        }
        
        doOneBreath()
    }
}

#Preview {
    EmotionalSupportView()
}
