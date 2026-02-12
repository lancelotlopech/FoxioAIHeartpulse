//
//  HIVAwarenessView.swift
//  HeartRateSenior
//
//  HIV Awareness - Card-based Swipeable Pages
//

import SwiftUI

struct HIVAwarenessView: View {
    @State private var currentPage = 0
    @State private var showingRiskAssessment = false
    @State private var showingMethodDetail: HIVTestingMethod?
    @Environment(\.dismiss) private var dismiss
    
    private let sections = HIVEducationData.sections
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.96, blue: 0.96),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Text("\(currentPage + 1)/8")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // TabView
                TabView(selection: $currentPage) {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        HIVSectionPageView(
                            section: section,
                            pageNumber: index + 1,
                            totalPages: 8,
                            onNext: { moveToNext() },
                            onBack: { moveToBack() },
                            onStartAssessment: { showRiskAssessment() },
                            onShowMethodDetail: { method in
                                showingMethodDetail = method
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .fullScreenCover(isPresented: $showingRiskAssessment) {
            HIVRiskAssessmentView()
        }
        .sheet(item: $showingMethodDetail) { method in
            HIVTestingMethodDetailView(method: method)
        }
        .onChange(of: currentPage) { _ in
            HapticManager.shared.selectionChanged()
        }
    }
    
    private func moveToNext() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentPage < 7 {
                currentPage += 1
            }
        }
        HapticManager.shared.lightImpact()
    }
    
    private func moveToBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
        HapticManager.shared.lightImpact()
    }
    
    private func showRiskAssessment() {
        HapticManager.shared.mediumImpact()
        showingRiskAssessment = true
    }
}

#Preview {
    HIVAwarenessView()
}
