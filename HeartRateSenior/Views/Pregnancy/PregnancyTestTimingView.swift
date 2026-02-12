//
//  PregnancyTestTimingView.swift
//  HeartRateSenior
//
//  Pregnancy test timing calculator
//

import SwiftUI

struct PregnancyTestTimingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOption: TestTimingOption?
    @State private var showResult = false
    
    private let primaryColor = Color(red: 0.9, green: 0.5, blue: 0.7)
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if showResult, let option = selectedOption {
                TimingResultView(option: option, onDismiss: {
                    dismiss()
                })
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(primaryColor.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(primaryColor)
                            }
                            
                            Text("When Should I Test?")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Choose your situation to get personalized timing advice")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 40)
                        
                        // Options
                        VStack(spacing: 16) {
                            ForEach(TestTimingOption.allCases) { option in
                                TimingOptionCard(
                                    option: option,
                                    isSelected: selectedOption == option,
                                    onTap: {
                                        HapticManager.shared.selectionChanged()
                                        selectedOption = option
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            showResult = true
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    HapticManager.shared.lightImpact()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Timing Option Card
struct TimingOptionCard: View {
    let option: TestTimingOption
    let isSelected: Bool
    let onTap: () -> Void
    
    private let primaryColor = Color(red: 0.9, green: 0.5, blue: 0.7)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: option.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(primaryColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(option.subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? primaryColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Timing Result View
struct TimingResultView: View {
    let option: TestTimingOption
    let onDismiss: () -> Void
    
    private let primaryColor = Color(red: 0.9, green: 0.5, blue: 0.7)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: option.resultIcon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(primaryColor)
                }
                .padding(.top, 40)
                
                // Title
                Text(option.resultTitle)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Timing Info
                VStack(spacing: 16) {
                    InfoRow(icon: "calendar", title: "Best Time", value: option.bestTime)
                    InfoRow(icon: "clock", title: "Time of Day", value: option.timeOfDay)
                    InfoRow(icon: "checkmark.circle", title: "Accuracy", value: option.accuracy)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
                .padding(.horizontal, 20)
                
                // Why This Timing
                VStack(alignment: .leading, spacing: 12) {
                    Text("Why This Timing?")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(option.explanation)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(primaryColor.opacity(0.08))
                )
                .padding(.horizontal, 20)
                
                // Tips
                VStack(alignment: .leading, spacing: 16) {
                    Text("Testing Tips")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    ForEach(option.tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.orange)
                            
                            Text(tip)
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
                
                // Done Button
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    onDismiss()
                }) {
                    Text("Got It")
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
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    private let primaryColor = Color(red: 0.9, green: 0.5, blue: 0.7)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(primaryColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

// MARK: - Test Timing Option Enum
enum TestTimingOption: String, CaseIterable, Identifiable {
    case missedPeriod = "Missed Period"
    case beforePeriod = "Before Period"
    case afterSex = "After Unprotected Sex"
    case irregular = "Irregular Cycle"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .missedPeriod: return "I missed my period"
        case .beforePeriod: return "Before my period is due"
        case .afterSex: return "After unprotected sex"
        case .irregular: return "I have irregular cycles"
        }
    }
    
    var subtitle: String {
        switch self {
        case .missedPeriod: return "My period is late"
        case .beforePeriod: return "Want to test early"
        case .afterSex: return "Recent exposure"
        case .irregular: return "Unpredictable timing"
        }
    }
    
    var icon: String {
        switch self {
        case .missedPeriod: return "calendar.badge.exclamationmark"
        case .beforePeriod: return "calendar.badge.clock"
        case .afterSex: return "clock.arrow.circlepath"
        case .irregular: return "waveform.path.ecg"
        }
    }
    
    var resultIcon: String {
        switch self {
        case .missedPeriod: return "checkmark.circle.fill"
        case .beforePeriod: return "clock.badge.checkmark"
        case .afterSex: return "hourglass"
        case .irregular: return "calendar.badge.plus"
        }
    }
    
    var resultTitle: String {
        switch self {
        case .missedPeriod: return "Test Now"
        case .beforePeriod: return "Wait a Few Days"
        case .afterSex: return "Wait 2-3 Weeks"
        case .irregular: return "Test Regularly"
        }
    }
    
    var bestTime: String {
        switch self {
        case .missedPeriod: return "Anytime now"
        case .beforePeriod: return "1-2 days before period"
        case .afterSex: return "2-3 weeks after"
        case .irregular: return "Every 2-3 weeks"
        }
    }
    
    var timeOfDay: String {
        switch self {
        case .missedPeriod: return "First morning urine"
        case .beforePeriod: return "First morning urine"
        case .afterSex: return "First morning urine"
        case .irregular: return "First morning urine"
        }
    }
    
    var accuracy: String {
        switch self {
        case .missedPeriod: return "99% accurate"
        case .beforePeriod: return "Variable (60-90%)"
        case .afterSex: return "99% after 3 weeks"
        case .irregular: return "99% when positive"
        }
    }
    
    var explanation: String {
        switch self {
        case .missedPeriod:
            return "If your period is late, pregnancy hormone (hCG) levels should be high enough to detect. Testing with first morning urine provides the most concentrated sample for best results."
        case .beforePeriod:
            return "Early testing is possible but less reliable. hCG levels may not be high enough yet. For best accuracy, wait until the day your period is expected or after."
        case .afterSex:
            return "It takes about 2-3 weeks after conception for hCG levels to be detectable. Testing too early may give a false negative. Wait at least 2 weeks, ideally 3 weeks for most accurate results."
        case .irregular:
            return "With irregular cycles, it's hard to know when to test. Test every 2-3 weeks if you've had unprotected sex, or wait for pregnancy symptoms before testing."
        }
    }
    
    var tips: [String] {
        switch self {
        case .missedPeriod:
            return [
                "Use first morning urine for most concentrated hCG",
                "Read results within the time frame specified",
                "If negative but still no period, retest in 3-5 days"
            ]
        case .beforePeriod:
            return [
                "Early tests are less reliable - be prepared for false negatives",
                "Use a sensitive test (10-25 mIU/mL)",
                "Retest on the day your period is due if negative"
            ]
        case .afterSex:
            return [
                "Mark your calendar for 2-3 weeks after exposure",
                "Don't test too early to avoid false negatives",
                "Consider emergency contraception if within 72 hours"
            ]
        case .irregular:
            return [
                "Keep track of when you have unprotected sex",
                "Test regularly if trying to conceive",
                "Consider tracking ovulation with other methods"
            ]
        }
    }
}

#Preview {
    NavigationStack {
        PregnancyTestTimingView()
    }
}
