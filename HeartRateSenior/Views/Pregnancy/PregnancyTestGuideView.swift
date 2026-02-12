//
//  PregnancyTestGuideView.swift
//  HeartRateSenior
//
//  Pregnancy test usage guide (4-page carousel)
//

import SwiftUI

struct PregnancyTestGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    private let pages = TestGuideData.allPages
    private let primaryColor = Color(red: 1.0, green: 0.7, blue: 0.75)
    
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
                    
                    Text("How to Use a Test")
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
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        GuidePageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
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
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Previous")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
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
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentPage < pages.count - 1 ? "Next" : "Done")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            if currentPage < pages.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
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
        .navigationBarHidden(true)
    }
}

// MARK: - Guide Page View
struct GuidePageView: View {
    let page: TestGuidePage
    
    private let primaryColor = Color(red: 1.0, green: 0.7, blue: 0.75)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(primaryColor)
                }
                .padding(.top, 20)
                
                // Step Number
                Text("Step \(page.stepNumber)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(primaryColor)
                
                // Title
                Text(page.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Description
                Text(page.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                
                // Details
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(page.details, id: \.self) { detail in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(primaryColor)
                            
                            Text(detail)
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
                
                // Tips (if available)
                if !page.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.orange)
                            
                            Text("Pro Tips")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        ForEach(page.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.orange)
                                
                                Text(tip)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.08))
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Test Guide Data
struct TestGuideData {
    static let allPages: [TestGuidePage] = [
        TestGuidePage(
            stepNumber: 1,
            icon: "calendar.badge.clock",
            title: "Choose the Right Time",
            description: "Timing is crucial for accurate results. Test at the right moment for best accuracy.",
            details: [
                "Wait until the first day of your missed period for most accurate results",
                "Use first morning urine - it has the highest concentration of hCG",
                "If testing early, use a sensitive test (10-25 mIU/mL)",
                "Avoid drinking too much liquid before testing"
            ],
            tips: [
                "Set a reminder for the best testing day",
                "Keep the test at room temperature before use",
                "Check the expiration date on the package"
            ]
        ),
        TestGuidePage(
            stepNumber: 2,
            icon: "drop.fill",
            title: "Collect Your Sample",
            description: "Proper sample collection ensures reliable test results.",
            details: [
                "Use a clean, dry container if collecting urine",
                "Collect midstream urine for best results",
                "Use the sample within 10 minutes of collection",
                "Make sure the test stick doesn't touch anything else"
            ],
            tips: [
                "Wash hands before handling the test",
                "Read all instructions before starting",
                "Have a timer ready to track waiting time"
            ]
        ),
        TestGuidePage(
            stepNumber: 3,
            icon: "timer",
            title: "Perform the Test",
            description: "Follow the test instructions carefully for accurate results.",
            details: [
                "Remove the test from its wrapper just before use",
                "Hold the absorbent tip in urine stream for 5-10 seconds",
                "Or dip the tip in collected urine for the time specified",
                "Lay the test flat on a clean, dry surface"
            ],
            tips: [
                "Don't shake excess urine off the test",
                "Keep the test horizontal while waiting",
                "Set a timer for the exact waiting time"
            ]
        ),
        TestGuidePage(
            stepNumber: 4,
            icon: "doc.text.magnifyingglass",
            title: "Read Your Results",
            description: "Understanding your results correctly is important.",
            details: [
                "Wait the exact time specified (usually 3-5 minutes)",
                "Two lines = Positive (even if one is faint)",
                "One line = Negative",
                "No lines or unclear = Invalid test, repeat with new test"
            ],
            tips: [
                "Read results within the time window specified",
                "A faint line is still a positive result",
                "If unsure, take another test in 2-3 days",
                "Consult a healthcare provider to confirm"
            ]
        )
    ]
}

// MARK: - Test Guide Page Model
struct TestGuidePage {
    let stepNumber: Int
    let icon: String
    let title: String
    let description: String
    let details: [String]
    let tips: [String]
}

#Preview {
    PregnancyTestGuideView()
}
