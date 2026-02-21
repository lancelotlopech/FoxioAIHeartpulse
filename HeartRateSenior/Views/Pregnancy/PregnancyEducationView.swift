//
//  PregnancyEducationView.swift
//  HeartRateSenior
//
//  Pregnancy education carousel — Minimalist redesign
//

import SwiftUI

struct PregnancyEducationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    private let sections = EducationPageSection.allSections
    private let primaryColor = Color(red: 0.93, green: 0.17, blue: 0.36)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1a1a1a"))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(hex: "f8f6f6")))
                    }
                    
                    Spacer()
                    
                    Text("Learn About Pregnancy")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // Linear step indicator: 1 — 2 — 3 — 4
                EducationStepIndicator(
                    currentStep: currentPage,
                    totalSteps: sections.count,
                    primaryColor: primaryColor
                )
                .padding(.top, 20)
                .padding(.horizontal, 40)
                
                // Content pages
                TabView(selection: $currentPage) {
                    ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                        EducationPageContent(
                            section: section,
                            primaryColor: primaryColor
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, _ in
                    HapticManager.shared.selectionChanged()
                }
                
                // Navigation buttons
                HStack(spacing: 12) {
                    if currentPage > 0 {
                        Button {
                            HapticManager.shared.lightImpact()
                            withAnimation(.easeInOut(duration: 0.25)) { currentPage -= 1 }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Previous")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(primaryColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(primaryColor, lineWidth: 1.5)
                            )
                        }
                    }
                    
                    Button {
                        HapticManager.shared.mediumImpact()
                        if currentPage < sections.count - 1 {
                            withAnimation(.easeInOut(duration: 0.25)) { currentPage += 1 }
                        } else {
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(currentPage < sections.count - 1 ? "Next" : "Done")
                                .font(.system(size: 15, weight: .bold))
                            if currentPage < sections.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(primaryColor)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Step Indicator
struct EducationStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    let primaryColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<totalSteps, id: \.self) { index in
                // Step circle
                ZStack {
                    Circle()
                        .fill(index <= currentStep ? primaryColor : Color(hex: "e8e6e6"))
                        .frame(width: 28, height: 28)
                    
                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(index <= currentStep ? .white : Color(hex: "aaaaaa"))
                }
                
                // Connector line (not after last)
                if index < totalSteps - 1 {
                    Rectangle()
                        .fill(index < currentStep ? primaryColor : Color(hex: "e8e6e6"))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentStep)
    }
}

// MARK: - Page Content
struct EducationPageContent: View {
    let section: EducationPageSection
    let primaryColor: Color
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Small inline icon + section label
                HStack(spacing: 8) {
                    Image(systemName: section.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(primaryColor)
                    
                    Text("STEP \(section.id)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(primaryColor)
                        .tracking(1.2)
                }
                .padding(.top, 28)
                
                // Title
                Text(section.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(hex: "1a1a1a"))
                    .lineSpacing(4)
                    .padding(.top, 12)
                
                // Description
                Text(section.description)
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "777777"))
                    .lineSpacing(6)
                    .padding(.top, 16)
                
                // Key points
                VStack(spacing: 0) {
                    ForEach(Array(section.keyPoints.enumerated()), id: \.offset) { index, point in
                        EducationKeyPointRow(
                            point: point,
                            primaryColor: primaryColor,
                            isLast: index == section.keyPoints.count - 1
                        )
                    }
                }
                .padding(.top, 24)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Key Point Row
struct EducationKeyPointRow: View {
    let point: EducationKeyPoint
    let primaryColor: Color
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                // Red checkmark icon
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(primaryColor)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle().fill(primaryColor.opacity(0.1))
                    )
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(point.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Text(point.description)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "888888"))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(.vertical, 14)
            
            if !isLast {
                Divider()
                    .background(Color(hex: "f0eeee"))
            }
        }
    }
}

#Preview {
    PregnancyEducationView()
}
