//
//  TutorialView.swift
//  HeartRateSenior
//
//  Visual tutorial showing finger placement
//

import SwiftUI
import AVKit

// MARK: - Full Video Player - Shows complete video filling width
struct FullVideoPlayer: UIViewControllerRepresentable {
    let videoName: String
    let videoExtension: String
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect  // Complete video, no cropping
        controller.view.backgroundColor = .white
        
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
    
    private let accentRed = Color(hex: "F4403A")
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let bottomInset = geometry.safeAreaInsets.bottom
            
            // Video fills full width, height calculated to show complete video
            // Assuming video is roughly 4:3 or 16:9, we give generous height
            let videoWidth = size.width
            let videoHeight = size.height * 0.45  // Give generous height for complete video
            
            VStack(spacing: 0) {
                // Top spacing
                Spacer()
                    .frame(height: 20)
                
                // Full-width video - complete display
                FullVideoPlayer(videoName: "pulsemeasure", videoExtension: "mp4")
                    .frame(width: videoWidth, height: videoHeight)
                    .background(Color.white)
                
                Spacer()
                    .frame(height: 24)
                
                // Title
                VStack(spacing: 12) {
                    (Text("How to ")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                    +
                    Text("Measure")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(accentRed))
                    
                    Text("Place your finger gently over\nthe back camera and flash")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Two tips
                HStack(spacing: 40) {
                    TutorialTip(icon: "hand.raised.fill", text: "Stay still", accentColor: accentRed)
                    TutorialTip(icon: "heart.fill", text: "Check pulse", accentColor: accentRed)
                }
                
                Spacer()
                
                // Start button - aligned with page 1
                Button(action: {
                    HapticManager.shared.success()
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                }) {
                    Text("Start Measuring")
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
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Tutorial Tip
struct TutorialTip: View {
    let icon: String
    let text: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(accentColor)
            }
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    TutorialView(hasCompletedOnboarding: .constant(false))
}
