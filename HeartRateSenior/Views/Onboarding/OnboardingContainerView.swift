//
//  OnboardingContainerView.swift
//  HeartRateSenior
//
//  Container view for onboarding flow
//

import SwiftUI

struct OnboardingContainerView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var currentPage = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                WelcomeView(currentPage: $currentPage)
                    .tag(0)
                
                PrivacyPermissionView(currentPage: $currentPage)
                    .tag(1)
                
                TutorialView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Page indicator
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? AppColors.primaryRed : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        .animation(.spring(), value: currentPage)
                }
            }
            .padding(.bottom, AppDimensions.paddingXLarge)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingContainerView(hasCompletedOnboarding: .constant(false))
        .environmentObject(SettingsManager())
}
