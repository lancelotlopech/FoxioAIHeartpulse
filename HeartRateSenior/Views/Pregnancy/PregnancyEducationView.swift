//
//  PregnancyEducationView.swift
//  HeartRateSenior
//
//  Pregnancy education carousel (4 pages)
//

import SwiftUI

struct PregnancyEducationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    private let sections = EducationPageSection.allSections
    private let primaryColor = Color(red: 1.0, green: 0.6, blue: 0.7)
    
    var body: some View {
        ZStack {
            // Background
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
                    
                    Text("Learn About Pregnancy")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<sections.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? primaryColor : Color.gray.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 16)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                // Icon & Title
                                VStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(primaryColor.opacity(0.15))
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: section.icon)
                                            .font(.system(size: 36, weight: .medium))
                                            .foregroundColor(primaryColor)
                                    }
                                    
                                    Text(section.title)
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 20)
                                
                                // Description
                                Text(section.description)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineSpacing(6)
                                    .padding(.horizontal, 20)
                                
                                // Key Points
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(section.keyPoints) { point in
                                        HStack(alignment: .top, spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(primaryColor.opacity(0.15))
                                                    .frame(width: 32, height: 32)
                                                
                                                Image(systemName: point.icon)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(primaryColor)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(point.title)
                                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                    .foregroundColor(AppColors.textPrimary)
                                                
                                                Text(point.description)
                                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                                    .foregroundColor(AppColors.textSecondary)
                                                    .lineSpacing(4)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                
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
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Previous")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(primaryColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(primaryColor.opacity(0.12))
                            )
                        }
                    }
                    
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        if currentPage < sections.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentPage < sections.count - 1 ? "Next" : "Done")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            if currentPage < sections.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
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
    }
}

#Preview {
    PregnancyEducationView()
}
