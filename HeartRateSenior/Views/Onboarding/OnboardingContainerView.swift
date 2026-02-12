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
            // Page content (移除第四页 DisclaimerOnboardingView)
            TabView(selection: $currentPage) {
                WelcomeView(currentPage: $currentPage)
                    .tag(0)
                
                TutorialView(currentPage: $currentPage, hasCompletedOnboarding: $hasCompletedOnboarding)
                    .tag(1)
                
                InsightsVideoView(currentPage: $currentPage)
                    .tag(2)
                
                PrivacyPermissionView(currentPage: $currentPage, hasCompletedOnboarding: $hasCompletedOnboarding)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            .highPriorityGesture(
                DragGesture()
                    .onChanged { _ in }
                    .onEnded { _ in }
            )  // 拦截滑动手势但保留按钮交互
            
            // Page indicator (改为4个点，对应4个页面)
            HStack(spacing: 12) {
                ForEach([0, 1, 2, 4], id: \.self) { index in
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
        .onAppear {
            // 在 Onboarding 开始时预加载订阅页视频
            VideoPreloader.shared.preloadSubscriptionVideo()
        }
    }
}

#Preview {
    OnboardingContainerView(hasCompletedOnboarding: .constant(false))
        .environmentObject(SettingsManager())
}
