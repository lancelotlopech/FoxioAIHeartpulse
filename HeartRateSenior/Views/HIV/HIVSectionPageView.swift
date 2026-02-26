//
//  HIVSectionPageView.swift
//  HeartRateSenior
//
//  Individual Section Page for HIV Awareness
//

import SwiftUI

struct HIVSectionPageView: View {
    let section: HIVSection
    let pageNumber: Int
    let totalPages: Int
    let onNext: () -> Void
    let onBack: () -> Void
    let onStartAssessment: () -> Void
    let onShowMethodDetail: (HIVTestingMethod) -> Void
    
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Icon Area
                iconView
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                // Title
                Text(section.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                
                // Content Area
                contentView
                    .padding(.horizontal, 24)
                
                Spacer(minLength: 20)
                
                // Navigation Buttons
                navigationButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
            ) {
                iconScale = 1.1
            }
        }
    }
    
    // MARK: - Icon View
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.primaryRed.opacity(0.15),
                            AppColors.primaryRed.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Image(systemName: iconForSection)
                .font(.system(size: 44, weight: .medium))
                .foregroundColor(AppColors.primaryRed)
                .scaleEffect(iconScale)
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch pageNumber {
        case 1:
            page1Content
        case 2:
            page2Content
        case 3:
            page3Content
        case 4:
            page4Content
        case 5:
            page5Content
        case 6:
            page6Content
        case 7:
            page7Content
        case 8:
            page8Content
        default:
            EmptyView()
        }
    }
    
    // MARK: - Page 1: What is HIV?
    private var page1Content: some View {
        VStack(spacing: 16) {
            Text(section.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            if let keyPoints = section.keyPoints {
                VStack(spacing: 12) {
                    ForEach(keyPoints) { point in
                        HStack(spacing: 12) {
                            Image(systemName: point.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppColors.primaryRed)
                                .frame(width: 32)
                            
                            Text(point.text)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Page 2: Transmission
    private var page2Content: some View {
        VStack(spacing: 20) {
            Text(section.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            if let transmission = section.transmissionInfo {
                VStack(spacing: 16) {
                    // Can be transmitted
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(hivRawText("Can be transmitted:"))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        ForEach(transmission.transmittedThrough, id: \.self) { item in
                            HStack(spacing: 8) {
                                Text("•")
                                    .foregroundColor(AppColors.primaryRed)
                                Text(item)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    
                    // NOT transmitted
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                            Text(hivRawText("NOT transmitted:"))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        ForEach(transmission.notTransmittedThrough, id: \.self) { item in
                            HStack(spacing: 8) {
                                Text("•")
                                    .foregroundColor(.green)
                                Text(item)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                }
            }
        }
    }
    
    // MARK: - Page 3: Symptoms
    private var page3Content: some View {
        VStack(spacing: 16) {
            Text(section.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            if let symptoms = section.symptoms {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(symptoms, id: \.self) { symptom in
                        Text(symptom)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.95))
                                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                            )
                    }
                }
                .padding(.top, 8)
            }
            
            if let note = section.importantNote {
                Text(note)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.primaryRed)
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.primaryRed.opacity(0.1))
                    )
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Page 4: How Testing Works
    private var page4Content: some View {
        VStack(spacing: 16) {
            Text(section.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            if let testingInfo = section.testingInfo {
                VStack(alignment: .leading, spacing: 12) {
                    Text(hivRawText("Tests detect:"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    ForEach(testingInfo.detects, id: \.self) { item in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(item)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Page 5: Window Period
    private var page5Content: some View {
        VStack(spacing: 16) {
            Text(section.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            if let windowPeriod = section.windowPeriod {
                VStack(spacing: 12) {
                    ForEach(windowPeriod.testTypes) { testType in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(testType.name)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                Text(testType.detectableAfter)
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "clock.fill")
                                .foregroundColor(AppColors.primaryRed.opacity(0.6))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                        )
                    }
                }
                .padding(.top, 8)
                
                Text(windowPeriod.tip)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.primaryRed)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.primaryRed.opacity(0.1))
                    )
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Page 6: When to Test
    private var page6Content: some View {
        VStack(spacing: 16) {
            Text(section.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            if let whenToTest = section.whenToTest {
                VStack(spacing: 12) {
                    ForEach(whenToTest, id: \.self) { item in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                            
                            Text(item)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Page 7: Testing Methods
    private var page7Content: some View {
        VStack(spacing: 16) {
            Text(section.content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            if let methods = section.testingMethods {
                VStack(spacing: 12) {
                    ForEach(methods) { method in
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            onShowMethodDetail(method)
                        }) {
                            HStack(spacing: 14) {
                                Image(systemName: method.icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(AppColors.primaryRed)
                                    .frame(width: 44, height: 44)
                                    .background(AppColors.primaryRed.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(method.title)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    Text(method.description)
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.95))
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Page 8: Final CTA
    private var page8Content: some View {
        VStack(spacing: 20) {
            Text(hivRawText("Now you understand HIV basics.\nReady to check your potential risk?"))
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            if let expectations = section.testExpectations {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(expectations.reminders.prefix(3), id: \.self) { reminder in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(reminder)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
            }
            
            Button(action: onStartAssessment) {
                HStack(spacing: 10) {
                    Image(systemName: "checklist.checked")
                        .font(.system(size: 20, weight: .semibold))
                    Text(hivRawText("Start Risk Assessment"))
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
            }.padding(.top, 8)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if pageNumber > 1 {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text(hivText(.back))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1.5)
                    )
                }}
            
            if pageNumber < totalPages {
                Button(action: onNext) {
                    HStack(spacing: 6) {
                        Text(hivText(.next))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppColors.primaryRed)
                    .cornerRadius(14)
                }
            }
        }
    }
    
    // MARK: - Icon for Section
    private var iconForSection: String {
        switch pageNumber {
        case 1: return "cross.case.fill"
        case 2: return "arrow.triangle.2.circlepath"
        case 3: return "thermometer"
        case 4: return "microscope"
        case 5: return "clock.fill"
        case 6: return "calendar.badge.checkmark"
        case 7: return "building.2.fill"
        case 8: return "checkmark.seal.fill"
        default: return "questionmark.circle"
        }
    }
}

#Preview {
    HIVSectionPageView(
        section: HIVEducationData.localizedSections[0],
        pageNumber: 1,
        totalPages: 8,
        onNext: {},
        onBack: {},
        onStartAssessment: {},
        onShowMethodDetail: { _ in }
    )
}
