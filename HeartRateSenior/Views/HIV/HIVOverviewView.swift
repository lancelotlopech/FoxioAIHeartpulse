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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
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
            // Section Title
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
            
            // Content
            Text(section.content)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
            
            // Key Points (Section 1)
            if let keyPoints = section.keyPoints {
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
            
            // Transmission Info (Section 2)
            if let transmission = section.transmissionInfo {
                HIVTransmissionView(info: transmission)
            }
            
            // Symptoms (Section 3)
            if let symptoms = section.symptoms {
                HIVSymptomsView(symptoms: symptoms)
            }
            
            // Important Note (Section 3)
            if let note = section.importantNote {
                HIVImportantNoteView(note: note)
            }
            // Testing Info (Section 4)
            if let testing = section.testingInfo {
                HIVTestingInfoView(info: testing)
            }
            
            // Testing Methods (Section 4 & 7)
            if let methods = section.testingMethods {
                HIVTestingMethodsView(methods: methods)
            }
            
            // Window Period (Section 5)
            if let windowPeriod = section.windowPeriod {
                HIVWindowPeriodView(info: windowPeriod)
            }
            
            // Timing Guidance (Section 5 - Calendar Timeline)
            if let timingGuidance = section.timingGuidance {
                HIVTimingTimelineView(guidance: timingGuidance)
            }
            
            // When to Test (Section 6)
            if let whenToTest = section.whenToTest {
                HIVWhenToTestView(items: whenToTest)
            }
            
            // Test Expectations (Section 8)
            if let expectations = section.testExpectations {
                HIVTestExpectationsView(expectations: expectations)
            }
            
            // Disclaimer only on first section
            if isFirst {
                Text(HIVEducationData.disclaimer)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.gray)
                    .lineSpacing(2)
                    .padding(.top, 8)
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

// MARK: - Transmission View
struct HIVTransmissionView: View {
    let info: HIVTransmissionInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Transmitted through
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    Text("Can be transmitted through:")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                ForEach(info.transmittedThrough, id: \.self) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.orange.opacity(0.6))
                            .frame(width: 6, height: 6)
                        Text(item)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.06))
            )
            
            // NOT transmitted through
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                    Text("NOT transmitted through:")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                ForEach(info.notTransmittedThrough, id: \.self) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green.opacity(0.6))
                            .frame(width: 6, height: 6)
                        Text(item)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.06))
            )
        }
    }
}

// MARK: - Symptoms View
struct HIVSymptomsView: View {
    let symptoms: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Common early symptoms may include:")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(symptoms, id: \.self) { symptom in
                    HStack(spacing: 6) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .foregroundColor(AppColors.primaryRed)
                        Text(symptom)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.primaryRed.opacity(0.04))
        )
    }
}

// MARK: - Important Note View
struct HIVImportantNoteView: View {
    let note: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)
            
            Text(note)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(3)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Testing Info View
struct HIVTestingInfoView: View {
    let info: HIVTestingInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HIV testing detects:")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            ForEach(info.detects, id: \.self) { item in
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primaryRed)
                    Text(item)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.primaryRed.opacity(0.04))
        )
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
            
            // Table
            VStack(spacing: 0) {
                // Header
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
                
                // Rows
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
            .clipShape(RoundedRectangle(cornerRadius: 12)).overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            
            // Tip
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
        }}
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
            
            // Additional note
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

// MARK: - Testing Methods View (Section 7)
struct HIVTestingMethodsView: View {
    let methods: [HIVTestingMethod]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(methods) { method in
                VStack(alignment: .leading, spacing: 12) {
                    // Method Header
                    HStack(spacing: 12) {
                        Image(systemName: method.icon)
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryRed)
                            .frame(width: 48, height: 48)
                            .background(AppColors.primaryRed.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(method.title)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(method.description)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Pros
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("Advantages:")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        ForEach(method.pros, id: \.self) { pro in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .foregroundColor(.green)
                                Text(pro)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    
                    // Cons
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("Considerations:")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        ForEach(method.cons, id: \.self) { con in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .foregroundColor(.orange)
                                Text(con)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppColors.primaryRed.opacity(0.15), lineWidth: 1.5)
                        )
                )
            }
        }
    }
}

// MARK: - Timing Timeline View (Section 5 - Calendar Style)
struct HIVTimingTimelineView: View {
    let guidance: [HIVTimingGuidance]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Testing Timeline After Exposure")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                ForEach(Array(guidance.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 16) {
                        // Timeline indicator
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
                        
                        // Content
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
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.04))
            )
        }
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

// MARK: - Test Expectations View (Section 8)
struct HIVTestExpectationsView: View {
    let expectations: HIVTestExpectation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // What to Expect
            VStack(alignment: .leading, spacing: 10) {
                Text(expectations.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                ForEach(expectations.items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primaryRed)
                        
                        Text(item)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(2)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.primaryRed.opacity(0.04))
            )
            
            // Reminders
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    Text("Important Reminders")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                ForEach(expectations.reminders, id: \.self) { reminder in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.blue.opacity(0.6))
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(reminder)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(2)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.06))
            )
            
            // Tip Card
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
                
                Text(expectations.tipCard)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineSpacing(3)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
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
