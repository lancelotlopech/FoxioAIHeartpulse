//
//  WelcomeView.swift
//  HeartRateSenior
//
//  Welcome screen with heart icon and animated feature icons
//

import SwiftUI

// MARK: - Feature Icon Model
struct FeatureIcon {
    let icon: String
    let position: CGPoint
    let delay: Double
}

struct WelcomeView: View {
    @Binding var currentPage: Int
    
    // Animation states
    @State private var visibleIcons: Set<Int> = []
    @State private var heartScale: CGFloat = 1.0
    @State private var glowRadius: CGFloat = 20
    private let accentRed = Color(hex: "F4403A")
    
    // Feature icons only (no text)
    private let features: [FeatureIcon] = [
        FeatureIcon(icon: "heart.fill", position: CGPoint(x: 0.82, y: 0.12), delay: 0.3),
        FeatureIcon(icon: "waveform.path.ecg", position: CGPoint(x: 0.18, y: 0.18), delay: 0.5),
        FeatureIcon(icon: "chart.xyaxis.line", position: CGPoint(x: 0.85, y: 0.5), delay: 0.7),
        FeatureIcon(icon: "drop.fill", position: CGPoint(x: 0.15, y: 0.52), delay: 0.9),
        FeatureIcon(icon: "scalemass.fill", position: CGPoint(x: 0.82, y: 0.88), delay: 1.1),
        FeatureIcon(icon: "lungs.fill", position: CGPoint(x: 0.18, y: 0.82), delay: 1.3),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let heartSize = min(size.width * 0.45, size.height * 0.32)
            let iconAreaHeight = heartSize * 1.4
            let bottomInset = geometry.safeAreaInsets.bottom
            
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                Spacer()
                .frame(height: size.height * 0.12)
                    
                    // Heart icon area with floating feature icons
                    ZStack {
                        // Main heart SF Symbol icon
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: heartSize, height: heartSize)
                            .foregroundColor(accentRed)
                            .shadow(color: accentRed.opacity(0.5), radius: glowRadius, x: 0, y: 0)
                            .shadow(color: accentRed.opacity(0.3), radius: glowRadius * 1.5, x: 0, y: 0)
                .scaleEffect(heartScale)
                            .position(x: size.width / 2, y: iconAreaHeight / 2)
                        
                        // Feature icons around the heart
                        ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                FeatureIconView(icon: feature.icon, accentColor: accentRed)
                                .scaleEffect(visibleIcons.contains(index) ? 1.0 : 0.3)
                                .opacity(visibleIcons.contains(index) ? 1.0 : 0)
                                .position(x: size.width * feature.position.x, y: iconAreaHeight * feature.position.y)
                        }
                    }
                    .frame(height: iconAreaHeight)
                Spacer()
                
                    // Title and subtitle
                    VStack(spacing: 16) {
                        Text("FoxioAI")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(accentRed)
                
                        VStack(spacing: 6) {
                            Text("Estimated heart rate")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.primary)
                            Text("For reference only")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                            Text("Not a medical device")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Get Started button
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
        visibleIcons.removeAll()
        heartScale = 1.0
        glowRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            startIconAnimations()
            startHeartbeatAnimation()
        }
    }
    
    private func startIconAnimations() {
        for (index, feature) in features.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + feature.delay) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    _ = visibleIcons.insert(index)
                }
            }
        }
    }
    
    private func startHeartbeatAnimation() {
        withAnimation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true)
        ) {
            heartScale = 1.08
glowRadius = 35
        }
    }
}

// MARK: - Feature Icon View (icon only, no text)
struct FeatureIconView: View {
    let icon: String
    let accentColor: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(accentColor)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
            )
            .overlay(
                Circle()
                    .stroke(accentColor.opacity(0.15), lineWidth: 1)
            )
    }
}

#Preview {
    WelcomeView(currentPage: .constant(0))
}
