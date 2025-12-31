//
//  MeasureButton.swift
//  HeartRateSenior
//
//  Large circular button with breathing animation for measurement
//

import SwiftUI

struct MeasureButton: View {
    let action: () -> Void
    
    @State private var isBreathing = false
    @State private var isPressing = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer breathing glow
                Circle()
                    .fill(AppColors.primaryRed.opacity(0.1))
                    .frame(
                        width: AppDimensions.largeButtonSize + 40,
                        height: AppDimensions.largeButtonSize + 40
                    )
                    .scaleEffect(isBreathing ? 1.1 : 1.0)
                
                // Main button circle
                Circle()
                    .fill(Color.white)
                    .frame(
                        width: AppDimensions.largeButtonSize,
                        height: AppDimensions.largeButtonSize
                    )
                    .overlay(
                        Circle()
                            .stroke(AppColors.primaryRed, lineWidth: 4)
                    )
                    .shadow(color: AppColors.primaryRed.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Heart icon
                Image(systemName: "heart.fill")
                    .font(.system(size: AppDimensions.iconXLarge))
                    .foregroundColor(AppColors.primaryRed)
                    .scaleEffect(isBreathing ? 1.1 : 1.0)
            }
            .scaleEffect(isPressing ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Start breathing animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressing = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressing = false
                    }
                }
        )
        .accessibilityLabel("Measure Heart Rate")
        .accessibilityHint("Double tap to start measuring your heart rate")
    }
}

#Preview {
    VStack {
        MeasureButton {
            print("Measure tapped")
        }
    }
    .padding()
    .background(AppColors.background)
}
