//
//  HIVTestingGuideView.swift
//  HeartRateSenior
//
//  HIV Testing Guide - Methods, expectations (Section 4+7+8)
//

import SwiftUI

struct HIVTestingGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingMethodDetail: HIVTestingMethod?
    
    private var testingSection: HIVSection? {
        HIVEducationData.localizedSections.first { $0.id == 4 }
    }
    
    private var methodsSection: HIVSection? {
        HIVEducationData.localizedSections.first { $0.id == 7 }
    }
    
    private var expectationsSection: HIVSection? {
        HIVEducationData.localizedSections.first { $0.id == 8 }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                heroSection
                testingBasicsCard
                testingMethodsCard
                expectationsCard
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(HIVMeshBackground())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }
    
    private var backButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "arrow.left")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryRed.opacity(0.1))
                    .frame(width: 72, height: 72)
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.primaryRed)
            }
            
            Text(hivRawText("Testing Guide"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            
            Text(hivRawText("Methods, process & what to expect"))
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var testingBasicsCard: some View {
        if let section = testingSection {
            sectionCard(
                section: section,
                icon: "magnifyingglass"
            ) {
                if let testing = section.testingInfo {
                    HIVTestingInfoView(info: testing)
                }
            }
        }
    }
    
    @ViewBuilder
    private var testingMethodsCard: some View {
        if let section = methodsSection {
            sectionCard(
                section: section,
                icon: "list.clipboard.fill"
            ) {
                if let methods = section.testingMethods {
                    HIVTestingMethodsView(methods: methods)
                }
            }
        }
    }
    
    @ViewBuilder
    private var expectationsCard: some View {
        if let section = expectationsSection {
            sectionCard(
                section: section,
                icon: "person.fill.checkmark"
            ) {
                if let expectations = section.testExpectations {
                    HIVTestExpectationsView(expectations: expectations)
                }
            }
        }
    }
    
    private func sectionCard<Content: View>(
        section: HIVSection,
        icon: String,
        @ViewBuilder extra: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Circle()
                    .fill(AppColors.primaryRed.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.primaryRed)
                    )
                
                Text(section.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            }
            
            Text(section.content)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .lineSpacing(4)
            
            extra()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    NavigationStack {
        HIVTestingGuideView()
    }
}
