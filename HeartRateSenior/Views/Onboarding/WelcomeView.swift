//
//  WelcomeView.swift
//  HeartRateSenior
//
//  Welcome screen with large heart icon
//

import SwiftUI

struct WelcomeView: View {
    @Binding var currentPage: Int
    @State private var heartScale: CGFloat = 1.0
    @State private var heartOpacity: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Content Area (65% height)
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Animated heart icon
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(AppColors.primaryRed.opacity(0.1))
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                            .scaleEffect(heartScale * 1.2)
                        
                        // Heart icon
                        Image(systemName: "heart.fill")
                            .font(.system(size: geometry.size.width * 0.3))
                            .foregroundColor(AppColors.primaryRed)
                            .scaleEffect(heartScale)
                    }
                    .opacity(heartOpacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8)) {
                            heartOpacity = 1.0
                        }
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            heartScale = 1.1
                        }
                    }
                    
                    Spacer()
                }
                .frame(height: geometry.size.height * 0.55)
                
                // Text Area (25% height)
                VStack(spacing: 16) {
                    // Title
                    Text("HeartRate Senior")
                        .font(AppTypography.largeTitle)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                    
                    // Subtitle
                    Text("Simple & Easy\nHeart Rate Monitoring")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 20)
                .frame(height: geometry.size.height * 0.25)
                
                Spacer()
                
                // Bottom Button Area (10% height + safe area)
                Button(action: {
                    HapticManager.shared.mediumImpact()
                    withAnimation {
                        currentPage = 1
                    }
                }) {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SeniorButtonStyle())
                .padding(.horizontal, AppDimensions.paddingLarge)
                .padding(.bottom, AppDimensions.paddingXLarge)
            }
            .background(AppColors.background)
        }
    }
}

#Preview {
    WelcomeView(currentPage: .constant(0))
}
