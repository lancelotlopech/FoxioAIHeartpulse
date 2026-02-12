//
//  VideoPreloader.swift
//  HeartRateSenior
//
//  Video preloader for subscription page - preloads video during onboarding
//

import AVKit
import Combine

/// 视频预加载管理器 - 单例模式
/// 在 Onboarding 期间预加载订阅页视频，避免首次打开时的白屏延迟
class VideoPreloader: ObservableObject {
    static let shared = VideoPreloader()
    
    /// 预加载好的播放器
    @Published private(set) var player: AVPlayer?
    
    /// 视频是否已准备好播放
    @Published private(set) var isReady = false
    
    /// 是否正在预加载
    @Published private(set) var isLoading = false
    
    private var statusObserver: NSKeyValueObservation?
    private var loopObserver: Any?
    private var resignObserver: Any?
    private var activeObserver: Any?
    
    private init() {}
    
    /// 预加载订阅页视频
    /// 建议在 Onboarding 流程开始时调用
    func preloadSubscriptionVideo() {
        // 避免重复加载
        guard !isLoading && !isReady else { return }
        
        isLoading = true
        
        guard let url = Bundle.main.url(forResource: "subvideo", withExtension: "mp4") else {
            print("⚠️ VideoPreloader: subvideo.mp4 not found")
            isLoading = false
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: playerItem)
        newPlayer.isMuted = true
        
        // 先保存播放器引用
        self.player = newPlayer
        
        // 监听视频准备状态
        statusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    self?.isReady = true
                    self?.isLoading = false
                    print("✅ VideoPreloader: Video ready to play")
                    // 视频准备好后设置循环播放和生命周期监听
                    if let player = self?.player {
                        self?.setupLooping(for: player)
                        self?.setupAppLifecycleObservers(for: player)
                    }
                case .failed:
                    self?.isLoading = false
                    print("❌ VideoPreloader: Failed to load video - \(item.error?.localizedDescription ?? "unknown")")
                default:
                    break
                }
            }
        }
        
        // 注意：不调用 preroll，让 AVPlayer 自动缓冲
        // preroll 只能在 status 为 readyToPlay 时调用，否则会崩溃
    }
    
    /// 开始播放（订阅页显示时调用）
    func play() {
        guard isReady else { return }
        player?.seek(to: .zero)
        player?.play()
    }
    
    /// 暂停播放
    func pause() {
        player?.pause()
    }
    
    /// 重置播放器（订阅页关闭时可选调用）
    func reset() {
        player?.seek(to: .zero)
        player?.pause()
    }
    
    // MARK: - Private Methods
    
    private func setupLooping(for player: AVPlayer) {
        // 先移除旧的观察者
        if let observer = loopObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    private func setupAppLifecycleObservers(for player: AVPlayer) {
        // 先移除旧的观察者
        if let observer = resignObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = activeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // 进入后台时暂停视频
        resignObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak player] _ in
            player?.pause()
        }
        
        // 返回前台时恢复播放（只有在订阅页显示时才恢复）
        activeObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak player] _ in
            // 不自动恢复播放，让 SubscriptionView 控制
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
