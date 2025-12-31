//
//  TutorialView.swift
//  HeartRateSenior
//
//  Visual tutorial showing finger placement on camera
//

import SwiftUI

struct TutorialView: View {
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Scrollable Content
                ScrollView {
                    VStack(spacing: AppDimensions.paddingLarge) {
                        Spacer(minLength: 20)
                        
                        // Title
                        Text("How to Measure")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.bottom, 10)
                        
                        // Tutorial Image
                        Image("heart1")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300)
                            .frame(maxHeight: geometry.size.height * 0.5) // Increased size slightly since text is gone
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.vertical, 20)
                        
                        // Simplified Text
                        Text("Place finger gently over the back camera and flash")
                            .font(AppTypography.title)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        Spacer(minLength: 40)
                    }
                    .frame(minHeight: geometry.size.height - 120) // Reserve space for button
                }
                
                // Fixed Bottom Button
                VStack {
                    Button(action: {
                        HapticManager.shared.success()
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Start Measuring")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SeniorButtonStyle())
                }
                .padding(.horizontal, AppDimensions.paddingLarge)
                .padding(.bottom, AppDimensions.paddingXLarge)
                .background(AppColors.background)
            }
            .background(AppColors.background)
        }
    }
}

#Preview {
    TutorialView(hasCompletedOnboarding: .constant(false))
}
