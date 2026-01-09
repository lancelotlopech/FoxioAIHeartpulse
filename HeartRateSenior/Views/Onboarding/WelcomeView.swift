//
//  WelcomeView.swift
//  HeartRateSenior
//
//  Welcome screen with heart image and animated feature labels
//

import SwiftUI

// MARK: - Feature Label Model (using index for animation tracking)
struct FeatureLabel {
    let text: String
    let icon: String
    let position: CGPoint // relative position (0-1) around center
    let delay: Double
}

struct WelcomeView: View {
    @Binding var currentPage: Int
    
    // Animation states - use Int index like PrivacyPermissionView
    @State private var visibleLabels: Set<Int> = []
    @State private var heartScale: CGFloat = 1.0
    @State private var glowRadius: CGFloat = 20
    
    private let accentRed = Color(hex: "F4403A")
    
    // Feature labels positioned around the heart (indexed 0-5)
    private let features: [FeatureLabel] = [
        FeatureLabel(text: "Heart Rate", icon: "heart.fill", position: CGPoint(x: 0.82, y: 0.12), delay: 0.3),
        FeatureLabel(text: "Blood Pressure", icon: "waveform.path.ecg", position: CGPoint(x: 0.18, y: 0.18), delay: 0.5),
        FeatureLabel(text: "HRV Analysis", icon: "chart.xyaxis.line", position: CGPoint(x: 0.85, y: 0.5), delay: 0.7),
        FeatureLabel(text: "Blood Glucose", icon: "drop.fill", position: CGPoint(x: 0.15, y: 0.52), delay: 0.9),
        FeatureLabel(text: "Weight", icon: "scalemass.fill", position: CGPoint(x: 0.82, y: 0.88), delay: 1.1),
        FeatureLabel(text: "SpO₂", icon: "lungs.fill", position: CGPoint(x: 0.18, y: 0.82), delay: 1.3),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let heartSize = min(size.width * 0.55, size.height * 0.38)
            let labelAreaHeight = heartSize * 1.3
            let bottomInset = geometry.safeAreaInsets.bottom
            
            ZStack {
                // White background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top spacing
                    Spacer()
                        .frame(height: size.height * 0.15)
                    
                    // Heart with floating labels
                    ZStack {
                        // [审核版本] 跳动心形动画 - 上架后换回 Image("heartpic")
                        // Image("heartpic")
                        //     .resizable()
                        //     .scaledToFit()
                        //     .frame(width: heartSize, height: heartSize)
                        //     .shadow(color: accentRed.opacity(0.5), radius: glowRadius, x: 0, y: 0)
                        //     .shadow(color: accentRed.opacity(0.3), radius: glowRadius * 1.5, x: 0, y: 0)
                        //     .scaleEffect(heartScale)
                        //     .position(x: size.width / 2, y: labelAreaHeight / 2)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: heartSize * 0.85))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [accentRed, Color(hex: "F65D58")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: accentRed.opacity(0.5), radius: glowRadius, x: 0, y: 0)
                            .shadow(color: accentRed.opacity(0.3), radius: glowRadius * 1.5, x: 0, y: 0)
                            .scaleEffect(heartScale)
                            .position(x: size.width / 2, y: labelAreaHeight / 2)
                        
                        // Floating feature labels - using index
                        ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                            FeatureLabelView(
                                feature: feature,
                                accentColor: accentRed
                            )
                            .scaleEffect(visibleLabels.contains(index) ? 1.0 : 0.3)
                            .opacity(visibleLabels.contains(index) ? 1.0 : 0)
                            .position(
                                x: size.width * feature.position.x,
                                y: labelAreaHeight * feature.position.y
                            )
                        }
                    }
                    .frame(height: labelAreaHeight)
                    
                    Spacer()
                    
                    // Title section
                    VStack(spacing: 16) {
                        (Text("Take care of your")
                            .font(.system(size: 32, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        +
                        Text(" heart")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(accentRed))
                        
                        Text("All-in-one health companion for\nheart rate, blood pressure & more")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Get Started button - aligned with safe area
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        withAnimation {
                            currentPage = 1
                        }
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(accentRed)
                            .cornerRadius(27)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(20, bottomInset) + 20)
                }
            }
        }
        .onAppear {
            resetAndStartAnimations()
        }
        .onChange(of: currentPage) { newPage in
            if newPage == 0 {
                resetAndStartAnimations()
            }
        }
    }
    
    private func resetAndStartAnimations() {
        // Reset all animation states
        visibleLabels.removeAll()
        heartScale = 1.0
        glowRadius = 20
        
        // Start animations after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            startLabelAnimations()
            startHeartbeatAnimation()
        }
    }
    
    private func startLabelAnimations() {
        // Labels pop in with delays - using fixed index
        for (index, feature) in features.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + feature.delay) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    _ = visibleLabels.insert(index)
                }
            }
        }
    }
    
    private func startHeartbeatAnimation() {
        // Continuous heartbeat animation
        withAnimation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true)
        ) {
            heartScale = 1.06
            glowRadius = 30
        }
    }
}

// MARK: - Feature Label View
struct FeatureLabelView: View {
    let feature: FeatureLabel
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: feature.icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(accentColor)
            
            Text(feature.text)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .overlay(
            Capsule()
                .stroke(accentColor.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    WelcomeView(currentPage: .constant(0))
}
