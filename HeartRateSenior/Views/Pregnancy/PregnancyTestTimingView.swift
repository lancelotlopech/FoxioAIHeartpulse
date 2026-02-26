//
//  PregnancyTestTimingView.swift
//  HeartRateSenior
//
//  Pregnancy test timing calculator — Minimalist redesign
//

import SwiftUI

struct PregnancyTestTimingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOption: TestTimingOption?
    @State private var showResult = false
    
    private let primaryColor = Color(red: 0.93, green: 0.17, blue: 0.36)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        HapticManager.shared.lightImpact()
                        if showResult {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showResult = false
                                selectedOption = nil
                            }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: showResult ? "chevron.left" : "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1a1a1a"))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(hex: "f8f6f6")))
                    }
                    
                    Spacer()
                    
                    Text(pregnancyRawText("When Should I Test?"))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                if showResult, let option = selectedOption {
                    TimingResultMinimalView(
                        option: option,
                        primaryColor: primaryColor,
                        onDismiss: { dismiss() }
                    )
                } else {
                    TimingSelectionView(
                        selectedOption: $selectedOption,
                        showResult: $showResult,
                        primaryColor: primaryColor
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Selection View
private struct TimingSelectionView: View {
    @Binding var selectedOption: TestTimingOption?
    @Binding var showResult: Bool
    let primaryColor: Color
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text(pregnancyRawText("Choose your situation"))
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "999999"))
                    .padding(.top, 24)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    ForEach(TestTimingOption.allCases) { option in
                        Button {
                            HapticManager.shared.selectionChanged()
                            selectedOption = option
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showResult = true
                                }
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: option.icon)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(primaryColor)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(option.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(hex: "1a1a1a"))
                                    
                                    Text(option.subtitle)
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "999999"))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "cccccc"))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color(hex: "e8e6e6"), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
    }
}

// MARK: - Result View
private struct TimingResultMinimalView: View {
    let option: TestTimingOption
    let primaryColor: Color
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Result badge
                HStack(spacing: 8) {
                    Image(systemName: option.resultIcon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(primaryColor)
                    
                    Text(option.resultTitle)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(primaryColor)
                        .tracking(0.5)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(primaryColor.opacity(0.1))
                )
                .padding(.top, 24)
                
                // Title
                Text(option.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(hex: "1a1a1a"))
                    .padding(.top, 16)
                
                // Table-style timing info
                VStack(spacing: 0) {
                    TimingInfoTableRow(label: pregnancyRawText("Best Time"), value: option.bestTime, primaryColor: primaryColor)
                    Divider().background(Color(hex: "f0eeee"))
                    TimingInfoTableRow(label: pregnancyRawText("Time of Day"), value: option.timeOfDay, primaryColor: primaryColor)
                    Divider().background(Color(hex: "f0eeee"))
                    TimingInfoTableRow(label: pregnancyRawText("Accuracy"), value: option.accuracy, primaryColor: primaryColor)
                }
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color(hex: "e8e6e6"), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.top, 20)
                
                // Explanation
                VStack(alignment: .leading, spacing: 10) {
                    Text(pregnancyRawText("Why This Timing?"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Text(option.explanation)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "777777"))
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 24)
                
                // Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text(pregnancyText(.tips))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    ForEach(Array(option.tips.enumerated()), id: \.offset) { index, tip in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(primaryColor))
                            
                            Text(tip)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "777777"))
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.top, 24)
                
                // Done button
                Button {
                    HapticManager.shared.mediumImpact()
                    onDismiss()
                } label: {
                    Text(pregnancyRawText("Got It"))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(primaryColor)
                        )
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Table Row
private struct TimingInfoTableRow: View {
    let label: String
    let value: String
    let primaryColor: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "999999"))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "1a1a1a"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
        case .missedPeriod: return pregnancyRawText("I missed my period")
        case .beforePeriod: return pregnancyRawText("Before my period is due")
        case .afterSex: return pregnancyRawText("After unprotected sex")
        case .irregular: return pregnancyRawText("I have irregular cycles")
        }
    }
    
    var subtitle: String {
        switch self {
        case .missedPeriod: return pregnancyRawText("My period is late")
        case .beforePeriod: return pregnancyRawText("Want to test early")
        case .afterSex: return pregnancyRawText("Recent exposure")
        case .irregular: return pregnancyRawText("Unpredictable timing")
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
        case .missedPeriod: return pregnancyRawText("Test Now")
        case .beforePeriod: return pregnancyRawText("Wait a Few Days")
        case .afterSex: return pregnancyRawText("Wait 2-3 Weeks")
        case .irregular: return pregnancyRawText("Test Regularly")
        }
    }
    
    var bestTime: String {
        switch self {
        case .missedPeriod: return pregnancyRawText("Anytime now")
        case .beforePeriod: return pregnancyRawText("1-2 days before period")
        case .afterSex: return pregnancyRawText("2-3 weeks after")
        case .irregular: return pregnancyRawText("Every 2-3 weeks")
        }
    }
    
    var timeOfDay: String {
        switch self {
        case .missedPeriod: return pregnancyRawText("First morning urine")
        case .beforePeriod: return pregnancyRawText("First morning urine")
        case .afterSex: return pregnancyRawText("First morning urine")
        case .irregular: return pregnancyRawText("First morning urine")
        }
    }
    
    var accuracy: String {
        switch self {
        case .missedPeriod: return pregnancyRawText("99% accurate")
        case .beforePeriod: return pregnancyRawText("Variable (60-90%)")
        case .afterSex: return pregnancyRawText("99% after 3 weeks")
        case .irregular: return pregnancyRawText("99% when positive")
        }
    }
    
    var explanation: String {
        switch self {
        case .missedPeriod:
            return pregnancyRawText("If your period is late, pregnancy hormone (hCG) levels should be high enough to detect. Testing with first morning urine provides the most concentrated sample for best results.")
        case .beforePeriod:
            return pregnancyRawText("Early testing is possible but less reliable. hCG levels may not be high enough yet. For best accuracy, wait until the day your period is expected or after.")
        case .afterSex:
            return pregnancyRawText("It takes about 2-3 weeks after conception for hCG levels to be detectable. Testing too early may give a false negative. Wait at least 2 weeks, ideally 3 weeks for most accurate results.")
        case .irregular:
            return pregnancyRawText("With irregular cycles, it's hard to know when to test. Test every 2-3 weeks if you've had unprotected sex, or wait for pregnancy symptoms before testing.")
        }
    }
    
    var tips: [String] {
        switch self {
        case .missedPeriod:
            return [
                pregnancyRawText("Use first morning urine for most concentrated hCG"),
                pregnancyRawText("Read results within the time frame specified"),
                pregnancyRawText("If negative but still no period, retest in 3-5 days")
            ]
        case .beforePeriod:
            return [
                pregnancyRawText("Early tests are less reliable - be prepared for false negatives"),
                pregnancyRawText("Use a sensitive test (10-25 mIU/mL)"),
                pregnancyRawText("Retest on the day your period is due if negative")
            ]
        case .afterSex:
            return [
                pregnancyRawText("Mark your calendar for 2-3 weeks after exposure"),
                pregnancyRawText("Don't test too early to avoid false negatives"),
                pregnancyRawText("Consider emergency contraception if within 72 hours")
            ]
        case .irregular:
            return [
                pregnancyRawText("Keep track of when you have unprotected sex"),
                pregnancyRawText("Test regularly if trying to conceive"),
                pregnancyRawText("Consider tracking ovulation with other methods")
            ]
        }
    }
}

#Preview {
    PregnancyTestTimingView()
}
