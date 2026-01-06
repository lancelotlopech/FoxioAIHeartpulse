//
//  TutorialView.swift
//  HeartRateSenior
//
//  Visual tutorial showing finger placement on camera
//

import SwiftUI
import AVKit

// MARK: - Looping Video Player
struct LoopingVideoPlayer: UIViewControllerRepresentable {
    let videoName: String
    let videoExtension: String
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        
        if let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) {
            let player = AVPlayer(url: url)
            player.isMuted = true
            controller.player = player
            
            // Loop video
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
            
            // Start playing
            player.play()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

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
                        
                        // Tutorial Video - Looping, muted, auto-play
                        LoopingVideoPlayer(videoName: "pulsemeasure", videoExtension: "mp4")
                            .frame(maxWidth: 300)
                            .frame(height: geometry.size.height * 0.5)
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
