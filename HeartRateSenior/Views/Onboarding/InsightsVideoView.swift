//
//  InsightsVideoView.swift
//  HeartRateSenior
//
//  Insights video page with onboarding video
//

import SwiftUI
import AVKit

struct InsightsVideoView: View {
    @Binding var currentPage: Int
    
    private let accentRed = Color(hex: "F4403A")
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let screenWidth = size.width
            let bottomInset = geometry.safeAreaInsets.bottom
            
            ZStack(alignment: .top) {
                // 背景色
                Color.white
                    .ignoresSafeArea()
                
                // 视频背景层
                OnboardingInsightsVideoPlayer(videoName: "onboardingvideo", videoExtension: "mp4")
                    .frame(width: screenWidth, height: screenWidth * 1.0)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
                
                // 内容层
                VStack(spacing: 0) {
                    // 视频占位空间（减小以避免与文字重叠）
                    Spacer()
                        .frame(height: screenWidth * 0.85)
                    
                    // Title (使用富文本，"Insights" 标红，文字连贯，增加顶部间距)
                    (Text("Insights ")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(accentRed)
                    + Text("based on your heart rate data.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.top, 132)
                    
                    Spacer()
                    
                    // Continue button (跳过第4页，直接到第5页)
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        withAnimation {
                            currentPage = 4  // 直接跳到第5页（PrivacyPermissionView）
                        }
                    }) {
                        Text("Continue")
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
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Onboarding Insights Video Player (参考订阅页实现)
struct OnboardingInsightsVideoPlayer: UIViewControllerRepresentable {
    let videoName: String
    let videoExtension: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        controller.view.backgroundColor = .white
        
        if let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) {
            let playerItem = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: playerItem)
            player.isMuted = true
            controller.player = player
            context.coordinator.player = player
            
            // 监听视频准备状态
            context.coordinator.statusObserver = playerItem.observe(\.status, options: [.new]) { [weak player] item, _ in
                DispatchQueue.main.async {
                    if item.status == .readyToPlay {
                        context.coordinator.setupLooping(for: player!)
                        context.coordinator.setupAppLifecycleObservers()
                        player?.play()
                    }
                }
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if let player = context.coordinator.player {
            if player.currentItem?.status == .readyToPlay && player.timeControlStatus != .playing {
                player.play()
            }
        }
    }
    
    class Coordinator {
        var player: AVPlayer?
        var statusObserver: NSKeyValueObservation?
        var loopObserver: Any?
        var resignObserver: Any?
        var activeObserver: Any?
        
        func setupLooping(for player: AVPlayer) {
            loopObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }
        
        func setupAppLifecycleObservers() {
            resignObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.player?.pause()
            }
            
            activeObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self?.player?.currentItem?.status == .readyToPlay {
                        self?.player?.seek(to: .zero)
                        self?.player?.play()
                    }
                }
            }
        }
        
        deinit {
            statusObserver?.invalidate()
            if let observer = loopObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            if let observer = resignObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            if let observer = activeObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            player?.pause()
            player = nil
        }
    }
}

#Preview {
    InsightsVideoView(currentPage: .constant(2))
}
