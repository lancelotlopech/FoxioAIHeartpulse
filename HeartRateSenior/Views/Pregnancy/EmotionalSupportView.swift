//
//  EmotionalSupportView.swift
//  HeartRateSenior
//
//  Modern emotional support view matching Dashboard design system
//

import SwiftUI

struct EmotionalSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    private let pages = PregnancyEducationData.emotionalSections
    private let accentColor = AppColors.primaryRed
    private let accentGradient = LinearGradient(
        colors: [
            Color(red: 0.937, green: 0.267, blue: 0.267),
            AppColors.primaryRed,
            Color(red: 0.98, green: 0.55, blue: 0.24)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let sectionColors: [Color] = [
        AppColors.primaryRed,
        Color(red: 0.35, green: 0.6, blue: 0.95),
        Color(red: 0.6, green: 0.35, blue: 0.85),
        Color(red: 0.2, green: 0.78, blue: 0.35)
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Progress bar
                progressBar
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, section in
                        ScrollView {
                            VStack(spacing: 20) {
                                // Hero icon card
                                heroIconCard(index: index, section: section)
                                
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
                                
                                Spacer(minLength: 100)
                            }
                            .padding(.top, 8)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, _ in
                    HapticManager.shared.selectionChanged()
                }
                
                // Navigation buttons
                navigationButtons
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                HapticManager.shared.lightImpact()
                dismiss()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                }
            }
            
            Spacer()
            
            Text("Emotional Support")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
            
            Spacer()
            
            // Page counter badge
            Text("\(currentPage + 1)/\(pages.count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(accentColor))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.06))
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(accentGradient)
                    .frame(width: geo.size.width * CGFloat(currentPage + 1) / CGFloat(pages.count), height: 4)
                    .animation(.spring(response: 0.4), value: currentPage)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Hero Icon Card
    private func heroIconCard(index: Int, section: EmotionalSection) -> some View {
        let color = sectionColors[min(index, sectionColors.count - 1)]
        
        return VStack(spacing: 16) {
            // Gradient hero card
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.25), radius: 12, x: 0, y: 6)
                
                // Glow
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .offset(x: 50, y: -30)
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Text(section.content)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))
                            .lineSpacing(4)
                            .lineLimit(4)
                    }
                    
                    Spacer(minLength: 16)
                    
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: iconForSection(index))
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(24)
            }
            .frame(height: 160)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentPage > 0 {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.3)) { currentPage -= 1 }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Previous")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(accentColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(accentColor.opacity(0.3), lineWidth: 1.5)
                            )
                    )
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            Button(action: {
                HapticManager.shared.mediumImpact()
                if currentPage < pages.count - 1 {
                    withAnimation(.spring(response: 0.3)) { currentPage += 1 }
                } else {
                    dismiss()
                }
            }) {
                HStack(spacing: 6) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Done")
                        .font(.system(size: 16, weight: .bold))
                    if currentPage < pages.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(accentGradient)
                        .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 8)
        .animation(.spring(response: 0.3), value: currentPage)
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

// MARK: - Suggestions View (Dashboard card style)
struct SuggestionsView: View {
    let suggestions: [EmotionalSuggestion]
    private let accentColor = AppColors.primaryRed
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(suggestions) { suggestion in
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.1))
                            .frame(width: 42, height: 42)
                        Image(systemName: suggestion.icon)
                            .font(.system(size: 18))
                            .foregroundColor(accentColor)
                    }
                    
                    Text(suggestion.text)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                        .lineSpacing(2)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.75, green: 0.78, blue: 0.82))
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Emotions View (Modern grid)
struct EmotionsView: View {
    let emotions: [EmotionItem]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(emotions) { emotion in
                VStack(spacing: 10) {
                    Text(emotion.emoji)
                        .font(.system(size: 40))
                    Text(emotion.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Next Steps View (Dashboard numbered list)
struct NextStepsView: View {
    let steps: [String]
    private let accentColor = AppColors.primaryRed
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Next Steps")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
            
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.1))
                            .frame(width: 30, height: 30)
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(accentColor)
                    }
                    
                    Text(step)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                        .lineSpacing(3)
                        .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Breathing View (Modern animated)
struct BreathingView: View {
    let exercise: BreathingExercise
    @State private var isAnimating = false
    @State private var circleScale: CGFloat = 0.5
    @State private var phaseText = "Tap to Start"
    @State private var glowOpacity: Double = 0.15
    
    private let accentColor = AppColors.primaryRed
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            HStack {
                Image(systemName: "wind")
                    .font(.system(size: 16))
                    .foregroundColor(accentColor)
                Text("Breathing Exercise")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                Spacer()
            }
            
            // Breathing Circle
            ZStack {
                // Outer glow
                Circle()
                    .fill(accentColor.opacity(glowOpacity))
                    .frame(width: 180, height: 180)
                    .blur(radius: 20)
                
                // Track ring
                Circle()
                    .stroke(accentColor.opacity(0.1), lineWidth: 3)
                    .frame(width: 160, height: 160)
                
                // Animated circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accentColor.opacity(0.4), accentColor.opacity(0.15)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160 * circleScale, height: 160 * circleScale)
                    .animation(.easeInOut(duration: Double(exercise.inhale)), value: circleScale)
                
                // Center content
                VStack(spacing: 4) {
                    Text(phaseText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accentColor)
                    
                    if !isAnimating && phaseText == "Tap to Start" {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor.opacity(0.5))
                    }
                }
            }
            .frame(height: 180)
            .onTapGesture {
                if !isAnimating {
                    HapticManager.shared.mediumImpact()
                    startBreathing()
                }
            }
            
            // Instructions
            HStack(spacing: 16) {
                breathStep("Inhale", "\(exercise.inhale)s", "arrow.up.circle.fill")
                breathStep("Hold", "\(exercise.hold)s", "pause.circle.fill")
                breathStep("Exhale", "\(exercise.exhale)s", "arrow.down.circle.fill")
            }
            
            Text("Repeat \(exercise.repeats) times")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545).opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
    
    private func breathStep(_ label: String, _ duration: String, _ icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(accentColor.opacity(0.6))
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
            Text(duration)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func startBreathing() {
        isAnimating = true
        var currentRepeat = 0
        
        func doOneBreath() {
            guard currentRepeat < exercise.repeats else {
                phaseText = "Done ✓"
                isAnimating = false
                HapticManager.shared.success()
                withAnimation(.easeInOut(duration: 0.5)) {
                    glowOpacity = 0.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { glowOpacity = 0.15 }
                    phaseText = "Tap to Start"
                }
                return
            }
            
            // Inhale
            phaseText = "Inhale..."
            HapticManager.shared.lightImpact()
            withAnimation(.easeInOut(duration: Double(exercise.inhale))) {
                circleScale = 1.0
                glowOpacity = 0.3
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(exercise.inhale)) {
                // Hold
                phaseText = "Hold..."
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(exercise.hold)) {
                    // Exhale
                    phaseText = "Exhale..."
                    HapticManager.shared.lightImpact()
                    withAnimation(.easeInOut(duration: Double(exercise.exhale))) {
                        circleScale = 0.5
                        glowOpacity = 0.15
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
