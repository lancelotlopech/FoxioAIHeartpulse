//
//  PregnancyTestGuideView.swift
//  HeartRateSenior
//
//  Pregnancy test usage guide — Minimalist redesign
//

import SwiftUI

struct PregnancyTestGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    private let pages = TestGuideData.allPages
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
                    
                    Text(pregnancyRawText("How to Use a Test"))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // Horizontal step bar
                GuideStepBar(
                    total: pages.count,
                    current: currentPage,
                    primaryColor: primaryColor
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        GuideMinimalPageView(page: page, primaryColor: primaryColor)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                // Bottom nav
                HStack(spacing: 12) {
                    if currentPage > 0 {
                        Button {
                            HapticManager.shared.lightImpact()
                            withAnimation { currentPage -= 1 }
                        } label: {
                            Text(pregnancyText(.back))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "1a1a1a"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color(hex: "e8e6e6"), lineWidth: 1)
                                )
                        }
                    }
                    
                    Button {
                        HapticManager.shared.mediumImpact()
                        if currentPage < pages.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? pregnancyText(.next) : pregnancyText(.done))
                            .font(.system(size: 15, weight: .bold))
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
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Step Bar
private struct GuideStepBar: View {
    let total: Int
    let current: Int
    let primaryColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<total, id: \.self) { index in
                // Circle
                ZStack {
                    if index <= current {
                        Circle()
                            .fill(primaryColor)
                            .frame(width: 28, height: 28)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .strokeBorder(Color(hex: "dddddd"), lineWidth: 1.5)
                            .frame(width: 28, height: 28)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "bbbbbb"))
                    }
                }
                
                // Connector line
                if index < total - 1 {
                    Rectangle()
                        .fill(index < current ? primaryColor : Color(hex: "e8e6e6"))
                        .frame(height: 2)
                }
            }
        }
    }
}

// MARK: - Page Content
private struct GuideMinimalPageView: View {
    let page: TestGuidePage
    let primaryColor: Color
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Step label
                Text("\(pregnancyRawText("STEP")) \(page.stepNumber)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(primaryColor)
                    .tracking(1)
                    .padding(.top, 28)
                
                // Title
                Text(pregnancyRawText(page.title))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "1a1a1a"))
                    .padding(.top, 8)
                
                // Description
                Text(pregnancyRawText(page.description))
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "999999"))
                    .lineSpacing(4)
                    .padding(.top, 8)
                
                // Details with red checkmarks
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(page.details, id: \.self) { detail in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(primaryColor)
                                .frame(width: 20, height: 20)
                                .background(
                                    Circle().fill(primaryColor.opacity(0.1))
                                )
                            
                            Text(pregnancyRawText(detail))
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "555555"))
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.top, 20)
                
                // Tips card (gray background)
                if !page.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(pregnancyText(.tips))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "1a1a1a"))
                        
                        ForEach(page.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "999999"))
                                
                                Text(pregnancyRawText(tip))
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "777777"))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "f8f6f6"))
                    )
                    .padding(.top, 24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
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
