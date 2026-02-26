//
//  CycleTrackerView.swift
//  HeartRateSenior
//
//  Modern cycle tracker matching Dashboard design system
//

import SwiftUI
import SwiftData

struct CycleTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var cycleProfiles: [CycleProfile]
    @State private var lastPeriodDate = Date()
    @State private var cycleLength: Double = 28
    @State private var periodLength: Double = 5
    @State private var isPulsing = false
    @State private var didLoadProfile = false
    @State private var hasUnsavedChanges = false
    @State private var showProfileSetupHint = false
    
    // Dashboard-consistent colors
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
    private let ovulationColor = Color(red: 0.35, green: 0.6, blue: 0.95)
    private let fertileColor = Color(red: 0.6, green: 0.35, blue: 0.85)
    
    // Computed properties
    private var nextPeriodDate: Date {
        Calendar.current.date(byAdding: .day, value: Int(cycleLength), to: lastPeriodDate) ?? Date()
    }
    
    private var ovulationDate: Date {
        Calendar.current.date(byAdding: .day, value: Int(cycleLength) - 14, to: lastPeriodDate) ?? Date()
    }
    
    private var fertileStart: Date {
        Calendar.current.date(byAdding: .day, value: Int(cycleLength) - 16, to: lastPeriodDate) ?? Date()
    }
    
    private var fertileEnd: Date {
        Calendar.current.date(byAdding: .day, value: Int(cycleLength) - 12, to: lastPeriodDate) ?? Date()
    }
    
    private var daysUntilNextPeriod: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextPeriodDate).day ?? 0
    }
    
    private var cycleProgress: Double {
        let days = Calendar.current.dateComponents([.day], from: lastPeriodDate, to: Date()).day ?? 0
        return min(Double(days) / cycleLength, 1.0)
    }
    
    private enum CyclePhase {
        case period
        case follicular
        case fertileWindow
        case luteal

        var localizedTitle: String {
            switch self {
            case .period:
                return pregnancyRawText("Period")
            case .follicular:
                return pregnancyRawText("Follicular")
            case .fertileWindow:
                return pregnancyRawText("Fertile Window")
            case .luteal:
                return pregnancyRawText("Luteal")
            }
        }

        var icon: String {
            switch self {
            case .period:
                return "drop.fill"
            case .follicular:
                return "leaf.fill"
            case .fertileWindow:
                return "sparkles"
            case .luteal:
                return "moon.fill"
            }
        }
    }

    private var currentPhase: CyclePhase {
        let days = Calendar.current.dateComponents([.day], from: lastPeriodDate, to: Date()).day ?? 0
        if days < Int(periodLength) { return .period }
        if days < Int(cycleLength) - 16 { return .follicular }
        if days < Int(cycleLength) - 12 { return .fertileWindow }
        return .luteal
    }
    
    private var phaseIcon: String {
        currentPhase.icon
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Modern Header
                    headerSection
                    
                    // Hero Progress Ring Card
                    progressRingCard
                    
                    // Quick Stats Row
                    quickStatsRow
                    
                    // Settings Card
                    settingsCard
                    
                    // Predictions Card
                    predictionsCard
                    
                    // Disclaimer
                    disclaimerSection
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    HapticManager.shared.lightImpact()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(pregnancyText(.save)) {
                    HapticManager.shared.lightImpact()
                    persistCycleProfile()
                }
                .disabled(!hasUnsavedChanges)
                .foregroundColor(accentColor)
            }
        }
        .onAppear {
            loadOrCreateCycleProfileIfNeeded()
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .onChange(of: lastPeriodDate) { _, _ in
            if didLoadProfile { hasUnsavedChanges = true }
        }
        .onChange(of: cycleLength) { _, _ in
            if didLoadProfile { hasUnsavedChanges = true }
        }
        .onChange(of: periodLength) { _, _ in
            if didLoadProfile { hasUnsavedChanges = true }
        }
        .alert(pregnancyRawText("Set Up Your Cycle"), isPresented: $showProfileSetupHint) {
            Button(pregnancyText(.ok), role: .cancel) {}
        } message: {
            Text(pregnancyRawText("Enter your last period date and typical cycle length to get more accurate predictions."))
        }
    }
    
    private var activeCycleProfile: CycleProfile? {
        cycleProfiles.max(by: { $0.updatedAt < $1.updatedAt })
    }
    
    private func loadOrCreateCycleProfileIfNeeded() {
        guard !didLoadProfile else { return }
        
        if let profile = activeCycleProfile {
            lastPeriodDate = profile.lastPeriodDate
            cycleLength = Double(profile.cycleLengthDays)
            periodLength = Double(profile.periodLengthDays)
            didLoadProfile = true
            hasUnsavedChanges = false
            return
        }
        
        let newProfile = CycleProfile(
            lastPeriodDate: lastPeriodDate,
            cycleLengthDays: Int(cycleLength),
            periodLengthDays: Int(periodLength),
            isIrregular: false
        )
        modelContext.insert(newProfile)
        didLoadProfile = true
        hasUnsavedChanges = false
        showProfileSetupHint = true
    }
    
    private func persistCycleProfile() {
        let profile = activeCycleProfile ?? CycleProfile(lastPeriodDate: lastPeriodDate)
        if activeCycleProfile == nil {
            modelContext.insert(profile)
        }
        
        profile.lastPeriodDate = lastPeriodDate
        profile.cycleLengthDays = Int(cycleLength)
        profile.periodLengthDays = Int(periodLength)
        profile.updatedAt = Date()
        
        hasUnsavedChanges = false
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(pregnancyRawText("Cycle Tracker"))
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                .tracking(-0.5)
            
            Text(pregnancyRawText("Track your menstrual cycle"))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    // MARK: - Progress Ring Card (Hero card matching ModernHeartRateCard style)
    private var progressRingCard: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(accentGradient)
                .shadow(color: accentColor.opacity(0.2), radius: 12, x: 0, y: 6)
            
            // Glow effect
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .offset(x: 60, y: -60)
            
            // Border
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
            
            HStack {
                // Left: text content
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 6) {
                        Image(systemName: phaseIcon)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                        Text(pregnancyRawText("Current Phase"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(pregnancyFormat(
                        .dayOfCycleFormat,
                        Calendar.current.dateComponents([.day], from: lastPeriodDate, to: Date()).day ?? 0,
                        Int(cycleLength)
                    ))
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.75))
                        .padding(.top, 2)
                    
                    Spacer()
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(max(0, daysUntilNextPeriod))")
                            .font(.system(size: 48, weight: .black))
                            .foregroundColor(.white)
                        Text(pregnancyRawText("days"))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.75))
                    }
                    
                    // Phase badge
                    HStack(spacing: 4) {
                        Image(systemName: phaseIcon)
                            .font(.system(size: 10, weight: .medium))
                        Text(currentPhase.localizedTitle)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    )
                    .padding(.top, 4)
                }
                
                Spacer()
                
                // Right: progress ring
                ZStack {
                    // Pulsing glow
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 110, height: 110)
                        .blur(radius: 12)
                        .scaleEffect(isPulsing ? 1.08 : 0.92)
                    
                    // Track
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 10)
                        .frame(width: 100, height: 100)
                    
                    // Progress
                    Circle()
                        .trim(from: 0, to: cycleProgress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6), value: cycleProgress)
                    
                    // Center percentage
                    Text("\(Int(cycleProgress * 100))%")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(24)
        }
        .frame(height: 190)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Quick Stats Row
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            quickStatItem(
                icon: "calendar.badge.clock",
                label: pregnancyRawText("Next Period"),
                value: shortDate(nextPeriodDate),
                color: accentColor
            )
            
            quickStatItem(
                icon: "star.fill",
                label: pregnancyRawText("Ovulation"),
                value: shortDate(ovulationDate),
                color: ovulationColor
            )
            
            quickStatItem(
                icon: "heart.fill",
                label: pregnancyRawText("Fertile"),
                value: shortDate(fertileStart),
                color: fertileColor
            )
        }
        .padding(.horizontal, 20)
    }
    
    private func quickStatItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                .lineLimit(1)
            
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Settings Card
    private var settingsCard: some View {
        VStack(spacing: 20) {
            // Title
            HStack {
                Text(pregnancyRawText("Cycle Settings"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                Spacer()
            }
            
            // Last Period Date
            HStack {
                settingIcon("calendar", color: accentColor)
                Text(pregnancyRawText("Last Period"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                Spacer()
                DatePicker("", selection: $lastPeriodDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(accentColor)
            }
            
            Divider().foregroundColor(Color.black.opacity(0.06))
            
            // Cycle Length
            VStack(spacing: 10) {
                HStack {
                    settingIcon("arrow.triangle.2.circlepath", color: ovulationColor)
                    Text(pregnancyRawText("Cycle Length"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                    Spacer()
                    Text("\(Int(cycleLength)) \(pregnancyRawText("days"))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(accentColor)
                }
                Slider(value: $cycleLength, in: 21...35, step: 1)
                    .tint(accentColor)
            }
            
            Divider().foregroundColor(Color.black.opacity(0.06))
            
            // Period Length
            VStack(spacing: 10) {
                HStack {
                    settingIcon("drop.fill", color: fertileColor)
                    Text(pregnancyRawText("Period Length"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                    Spacer()
                    Text("\(Int(periodLength)) \(pregnancyRawText("days"))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(accentColor)
                }
                Slider(value: $periodLength, in: 3...7, step: 1)
                    .tint(accentColor)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
    
    private func settingIcon(_ name: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.12))
                .frame(width: 38, height: 38)
            Image(systemName: name)
                .font(.system(size: 16))
                .foregroundColor(color)
        }
    }
    
    // MARK: - Predictions Card
    private var predictionsCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text(pregnancyRawText("Predictions"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                Spacer()
            }
            
            CyclePredictionCard(
                icon: "calendar.badge.clock",
                iconColor: accentColor,
                title: pregnancyRawText("Next Period"),
                date: nextPeriodDate,
                subtitle: pregnancyFormat(.predictionDaysAwayFormat, max(0, daysUntilNextPeriod))
            )
            
            CyclePredictionCard(
                icon: "star.fill",
                iconColor: ovulationColor,
                title: pregnancyRawText("Ovulation"),
                date: ovulationDate,
                subtitle: pregnancyRawText("Estimated")
            )
            
            CyclePredictionCard(
                icon: "heart.fill",
                iconColor: fertileColor,
                title: pregnancyRawText("Fertile Window"),
                date: fertileStart,
                subtitle: formattedRange(fertileStart, fertileEnd)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Disclaimer
    private var disclaimerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(accentColor)
                .font(.system(size: 16))
            
            Text(pregnancyRawText("This is a basic tracker for reference only. For accurate fertility tracking, consult a healthcare provider."))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                .lineSpacing(3)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helpers
    private func shortDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        fmt.locale = effectiveLanguage(for: .pregnancy) == .chinese ? Locale(identifier: "zh-Hans") : Locale(identifier: "en_US")
        return fmt.string(from: date)
    }
    
    private func formattedRange(_ start: Date, _ end: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        fmt.locale = effectiveLanguage(for: .pregnancy) == .chinese ? Locale(identifier: "zh-Hans") : Locale(identifier: "en_US")
        return "\(fmt.string(from: start)) - \(fmt.string(from: end))"
    }
}

// MARK: - Prediction Card (Dashboard style)
struct CyclePredictionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let date: Date
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
            }
            
            Spacer()
            
            Text(date, style: .date)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(iconColor)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(iconColor.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(iconColor.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        CycleTrackerView()
    }
}
