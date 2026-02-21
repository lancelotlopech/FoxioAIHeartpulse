//
//  HIVOverviewView.swift
//  HeartRateSenior
//
//  HIV Education Overview - Multi-section scrollable view
//

import SwiftUI

struct HIVOverviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingRiskAssessment = false
    
    let sections = HIVEducationData.sections
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text("HIV Awareness")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Learn about prevention & testing")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 20)
                
                // Section Cards
                ForEach(sections) { section in
                    HIVSectionCard(section: section, isFirst: section.id == 1)
                }
                
                // CTA Section
                HIVCTASection(showingRiskAssessment: $showingRiskAssessment)
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
        .sheet(isPresented: $showingRiskAssessment) {
            HIVRiskAssessmentView()
        }
    }
}

// MARK: - HIV Section Card
struct HIVSectionCard: View {
    let section: HIVSection
    let isFirst: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader
            sectionContent
            sectionDetails
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private var sectionHeader: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(AppColors.primaryRed.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(
                    Text("\(section.id)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryRed)
                )
            
            Text(section.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
    }
    
    private var sectionContent: some View {
        Text(section.content)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundColor(AppColors.textSecondary)
            .lineSpacing(4)
    }
    
    @ViewBuilder
    private var sectionDetails: some View {
        if let keyPoints = section.keyPoints {
            HIVKeyPointsListView(keyPoints: keyPoints)
        }
        if let transmission = section.transmissionInfo {
            HIVTransmissionView(info: transmission)
        }
        if let symptoms = section.symptoms {
            HIVSymptomsView(symptoms: symptoms)
        }
        if let note = section.importantNote {
            HIVImportantNoteView(note: note)
        }
        if let testing = section.testingInfo {
            HIVTestingInfoView(info: testing)
        }
        if let methods = section.testingMethods {
            HIVTestingMethodsView(methods: methods)
        }
        if let windowPeriod = section.windowPeriod {
            HIVWindowPeriodView(info: windowPeriod)
        }
        if let timingGuidance = section.timingGuidance {
            HIVTimingTimelineView(guidance: timingGuidance)
        }
        if let whenToTest = section.whenToTest {
            HIVWhenToTestView(items: whenToTest)
        }
        if let expectations = section.testExpectations {
            HIVTestExpectationsView(expectations: expectations)
        }
        if isFirst {
            Text(HIVEducationData.disclaimer)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.gray)
                .lineSpacing(2)
                .padding(.top, 8)
        }
    }
}

// MARK: - Key Points List (Section 1)
private struct HIVKeyPointsListView: View {
    let keyPoints: [HIVKeyPoint]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(keyPoints) { point in
                HStack(spacing: 12) {
                    Image(systemName: point.icon)
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.primaryRed)
                        .frame(width: 36, height: 36)
                        .background(AppColors.primaryRed.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text(point.text)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Window Period View
struct HIVWindowPeriodView: View {
    let info: HIVWindowPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(info.description)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            windowPeriodTable
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
                Text(info.tip)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(2)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.yellow.opacity(0.08))
            )
        }
    }
    
    private var windowPeriodTable: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Test Type")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Detectable After")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 120, alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AppColors.primaryRed.opacity(0.85))
            
            ForEach(Array(info.testTypes.enumerated()), id: \.element.id) { index, testType in
                HStack {
                    Text(testType.name)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(testType.detectableAfter)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.primaryRed)
                        .frame(width: 120, alignment: .trailing)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(index % 2 == 0 ? Color.gray.opacity(0.04) : Color.white)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - When to Test View
struct HIVWhenToTestView: View {
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text(item)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Text("Regular testing is a responsible step for anyone who is sexually active.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, 4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.primaryRed.opacity(0.04))
        )
    }
}

// MARK: - Timing Timeline View (Section 5)
struct HIVTimingTimelineView: View {
    let guidance: [HIVTimingGuidance]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Testing Timeline After Exposure")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                ForEach(Array(guidance.enumerated()), id: \.element.id) { index, item in
                    timelineRow(item: item, index: index)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.04))
            )
        }
    }
    
    private func timelineRow(item: HIVTimingGuidance, index: Int) -> some View {
        HStack(spacing: 16) {
            VStack(spacing: 0) {
                Circle()
                    .fill(colorForStatus(item.status))
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(systemName: item.icon)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                if index < guidance.count - 1 {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .frame(height: 40)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.daysRange)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text(statusText(item.status))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(colorForStatus(item.status))
                        )
                }
                
                Text(item.guidance)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(2)
            }
            .padding(.vertical, 8)
        }
        .padding(.bottom, index < guidance.count - 1 ? 8 : 0)
    }
    
    private func colorForStatus(_ status: TimingStatus) -> Color {
        switch status {
        case .tooEarly: return .red
        case .earlyTest: return .orange
        case .reliable: return .green
        }
    }
    
    private func statusText(_ status: TimingStatus) -> String {
        switch status {
        case .tooEarly: return "Too Early"
        case .earlyTest: return "Early Test"
        case .reliable: return "Reliable"
        }
    }
}

// MARK: - CTA Section
struct HIVCTASection: View {
    @Binding var showingRiskAssessment: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text(HIVEducationData.ctaText)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Button(action: {
                HapticManager.shared.mediumImpact()
                showingRiskAssessment = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "checklist.checked")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Check Your Risk Level")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: AppColors.primaryRed.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        HIVOverviewView()
    }
}
