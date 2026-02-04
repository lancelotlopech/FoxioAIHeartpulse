//
//  SubscriptionView.swift
//  HeartRateSenior
//
//  Subscription paywall view - Single Screen Optimized
//

import SwiftUI
import StoreKit
import AVKit

// MARK: - Looping Video Player for Subscription
struct SubscriptionVideoPlayer: UIViewControllerRepresentable {
    let videoName: String
    let videoExtension: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = UIColor(Color(hex: "EFF0F3"))
        
        if let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) {
            let player = AVPlayer(url: url)
            player.isMuted = true
            controller.player = player
            context.coordinator.player = player
            
            // 设置循环播放
            context.coordinator.setupLooping(for: player)
            
            // 监听 App 生命周期 - 解决后台播放和切回卡死问题
            context.coordinator.setupAppLifecycleObservers()
            
            // Start playing
            player.play()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // 视图重新出现时恢复播放
        if let player = context.coordinator.player {
            if player.timeControlStatus != .playing {
                player.play()
            }
        }
    }
    
    class Coordinator {
        var player: AVPlayer?
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
            // 进入后台时暂停视频
            resignObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.player?.pause()
            }
            
            // 返回前台时恢复播放
            activeObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                // 延迟一点恢复播放，确保视图已经完全显示
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.player?.seek(to: .zero)
                    self?.player?.play()
                }
            }
        }
        
        deinit {
            // 清理所有观察者
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

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var subManager = SubscriptionManager.shared
    
    // 支持从 ZStack 叠加调用时传入 binding
    var isPresented: Binding<Bool>?
    
    @State private var selectedProductID: String = PaywallConfiguration.weeklyProductID  // 默认选中 $0.99
    @State private var isTrialEnabled: Bool = true  // 默认开启试用
    
    // 关闭方法：优先使用 binding，否则使用 dismiss（无动画，瞬间关闭）
    private func closeView() {
        if let binding = isPresented {
            binding.wrappedValue = false
        } else {
            dismiss()
        }
    }
    
    // Theme Gradient - 基于主页测量按钮颜色 F4403A
    private var brandGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "F4403A"),  // 主色
                Color(hex: "F65D58")   // 微微浅一点
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var brandColor: Color {
        Color(hex: "F4403A")  // 主页测量按钮颜色
    }
    
    // Price Display (从 StoreKit 获取或使用 mock)
    var weeklyPrice: String {
        subManager.weeklyProduct?.displayPrice ?? PaywallConfiguration.mockWeeklyPrice
    }
    
    var yearlyPrice: String {
        subManager.yearlyProduct?.displayPrice ?? PaywallConfiguration.mockYearlyPrice
    }
    
    var yearlyPerWeekPrice: String {
        if let product = subManager.yearlyProduct {
            let weeklyPrice = product.price / 52
            return weeklyPrice.formatted(product.priceFormatStyle)
        } else {
            return PaywallConfiguration.mockYearlyPerWeekPrice
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            ZStack(alignment: .top) {
                // 背景色 #EFF0F3
                Color(hex: "EFF0F3")
                    .ignoresSafeArea()
                
                // 视频背景 + 顶部淡红色遮罩
                ZStack(alignment: .top) {
                    // 视频播放器（静音循环播放）- 增大高度比例
                    SubscriptionVideoPlayer(videoName: "subvideo", videoExtension: "mp4")
                        .frame(width: screenWidth, height: screenWidth * 1.3)
                    
                    // 顶部淡红色渐变遮罩 - 只遮上面约1公分(40pt)
                    LinearGradient(
                        colors: [Color.pink.opacity(0.08), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: screenWidth, height: 40)
                    
                    // 下边缘渐变模糊遮罩 - 更平滑的过渡到背景色
                    VStack {
                        Spacer()
                        LinearGradient(
                            colors: [
                                .clear,
                                Color(hex: "EFF0F3").opacity(0.2),
                                Color(hex: "EFF0F3").opacity(0.5),
                                Color(hex: "EFF0F3").opacity(0.8),
                                Color(hex: "EFF0F3")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 80)
                    }
                }
                .frame(width: screenWidth, height: screenWidth * 1.3)
                .ignoresSafeArea(edges: .top)
                
                // 原本内容层 - 完全不变
                VStack(spacing: 0) {
                    // 1. Header
                    headerView
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    // 固定单屏布局 - 不允许滚动
                    fixedContentLayout
                    
                    // 7. Bottom Button (Always Sticky)
                    bottomSection
                }
            }
        }
        .onChange(of: isTrialEnabled) { oldValue, newValue in
            // 同步 Trial Toggle -> Product Selection
            if newValue {
                selectedProductID = PaywallConfiguration.weeklyProductID
            } else {
                selectedProductID = PaywallConfiguration.yearlyProductID
            }
        }
        .onChange(of: selectedProductID) { oldValue, newValue in
            // 同步 Product Selection -> Trial Toggle
            if newValue == PaywallConfiguration.yearlyProductID {
                isTrialEnabled = false
            } else if newValue == PaywallConfiguration.weeklyProductID {
                isTrialEnabled = true
            }
        }
        .task {
            await subManager.loadProducts()
        }
    }
    
    // MARK: - Layout Variants
    
    private var fixedContentLayout: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 4)
            heroSection
            Spacer(minLength: 10)
            pricingSection.padding(.horizontal, 20)
            Spacer(minLength: 6)
            assuranceSection
            Spacer(minLength: 6)
        }
    }
    
    private var scrollableContentLayout: some View {
        ScrollView {
            VStack(spacing: 4) {
                heroSection
                    .padding(.top, 4)
                pricingSection
                    .padding(.horizontal, 20)
                assuranceSection
                Spacer(minLength: 8)
            }
            .padding(.bottom, 12)
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack {
            Button {
                closeView()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.gray.opacity(0.5))
            }
            
            Spacer()
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 4) {
            // 视频已移到背景层，这里留空间让视频显示
            // 减小高度让内容整体往上移
            Spacer()
                .frame(height: screenWidth * 1.3 - 110)  // 减小 30pt 让内容往上移
        }
    }
    
    // 获取屏幕宽度的计算属性
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // 购买指定产品
    private func purchaseProduct(_ productID: String) {
        Task {
            selectedProductID = productID
            if let product = subManager.products.first(where: { $0.id == productID }) {
                let _ = try? await subManager.purchase(product)
                if subManager.isPremium {
                    closeView()
                }
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(spacing: 8) {
            // Weekly Option (7 Day Full Access) - 放在上面，带社交证明标签
            PricingCardNew(
                title: "7 DAY FULL ACCESS",
                price: "$0.99",
                subtitle: nil,
                badge: nil,
                socialProofBadge: true,  // 显示社交证明标签
                isSelected: selectedProductID == PaywallConfiguration.weeklyProductID,
                brandGradient: brandGradient,
                onTap: { purchaseProduct(PaywallConfiguration.weeklyProductID) }
            )
            
            // Yearly Option - 放在下面（去掉 Best Value 角标）
            PricingCardNew(
                title: "YEARLY ACCESS",
                price: yearlyPrice,
                subtitle: "Save 92%!",
                badge: nil,
                socialProofBadge: false,
                isSelected: selectedProductID == PaywallConfiguration.yearlyProductID,
                brandGradient: brandGradient,
                onTap: { purchaseProduct(PaywallConfiguration.yearlyProductID) }
            )
        }
    }
    
    // 根据选中状态动态显示的说明文字
    private var billingDescription: String {
        if selectedProductID == PaywallConfiguration.weeklyProductID {
            return "Billed $9.99/week auto-renewal after 7 days, Request a refund if you're not satisfied."
        } else {
            return "Billed annually at $39.99, Request a refund if you're not satisfied."
        }
    }
    
    private var assuranceSection: some View {
        VStack(spacing: 8) {
            // 动态计费说明 - 固定行高防止切换时跳动
            Text(billingDescription)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 28)  // 固定高度，防止切换时内容跳动
                .padding(.horizontal, 12)
                .animation(.easeInOut(duration: 0.2), value: selectedProductID)
        }
    }
    
    private var bottomSection: some View {
        VStack(spacing: 14) {
            // Continue 按钮 - 带呼吸动画效果
            Button {
                purchaseProduct(selectedProductID)
            } label: {
                AnimatedCTAButton(
                    text: buttonText,
                    gradient: brandGradient,
                    brandColor: brandColor
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            
            // 底部链接：Terms of Use • Privacy Policy • Restore - 全部在一行
            HStack(spacing: 8) {
                Link("Terms of Use", destination: PaywallConfiguration.termsURL)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary.opacity(0.5))
                
                Link("Privacy Policy", destination: PaywallConfiguration.privacyURL)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary.opacity(0.5))
                
                Button("Restore") {
                    Task {
                        await subManager.restorePurchases()
                        if subManager.isPremium {
                            closeView()
                        }
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 24)
    }
    
    private var buttonText: String {
        if isTrialEnabled {
            return "Continue"
        } else {
            return "Continue"
        }
    }
}

// MARK: - Animated CTA Button (只有微妙呼吸动画，无流光)
struct AnimatedCTAButton: View {
    let text: String
    let gradient: LinearGradient
    let brandColor: Color
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016, paused: false)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            
            // 跳动: sin 波形，周期约 1.5 秒
            let pulsePhase = sin(t * 4.2)
            // 缩放幅度减少 20%: 0.025 → 0.02
            let scale = 1.0 + pulsePhase * 0.02
            let shadowRadius = 8.0 + pulsePhase * 3.0
            let shadowOpacity = 0.35 + pulsePhase * 0.1
            
            // 按钮本体（无流光）
            Text(text)
                .font(.headline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(gradient)
                .clipShape(RoundedRectangle(cornerRadius: 27))
                .scaleEffect(scale)
                .shadow(color: brandColor.opacity(shadowOpacity), radius: shadowRadius, y: 4)
        }
        .frame(height: 54)
    }
}

// MARK: - Subscription Animated Heart (替代视频的跳动心形)
struct SubscriptionAnimatedHeart: View {
    let brandGradient: LinearGradient
    let brandColor: Color
    
    @State private var heartScale: CGFloat = 1.0
    @State private var glowRadius: CGFloat = 20
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // 居中的心形
                Image(systemName: "heart.fill")
                    .font(.system(size: size * 0.45))
                    .foregroundStyle(brandGradient)
                    .shadow(color: brandColor.opacity(0.5), radius: glowRadius, x: 0, y: 0)
                    .shadow(color: brandColor.opacity(0.3), radius: glowRadius * 1.5, x: 0, y: 0)
                    .scaleEffect(heartScale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startHeartbeatAnimation()
        }
    }
    
    private func startHeartbeatAnimation() {
        withAnimation(
            .easeInOut(duration: 0.8)
            .repeatForever(autoreverses: true)
        ) {
            heartScale = 1.1
            glowRadius = 35
        }
    }
}

// MARK: - Social Proof Manager (社交证明人数管理器)
class SocialProofManager: ObservableObject {
    static let shared = SocialProofManager()
    
    @Published var joinedCount: Int = 0
    
    private var timer: Timer?
    private let maxCount = 1675
    private let minInitial = 201
    private let maxInitial = 315
    
    // UserDefaults keys
    private let lastResetDateKey = "socialProofLastResetDate"
    private let currentCountKey = "socialProofCurrentCount"
    private let lastUpdateTimeKey = "socialProofLastUpdateTime"
    
    init() {
        checkAndResetCount()
        startTimer()
    }
    
    private func checkAndResetCount() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date
        let lastResetDay = lastResetDate.map { Calendar.current.startOfDay(for: $0) }
        
        // 如果是新的一天，重置计数
        if lastResetDay != today {
            let initialCount = Int.random(in: minInitial...maxInitial)
            UserDefaults.standard.set(today, forKey: lastResetDateKey)
            UserDefaults.standard.set(initialCount, forKey: currentCountKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastUpdateTimeKey)
            joinedCount = initialCount
        } else {
            // 读取已保存的计数
            joinedCount = UserDefaults.standard.integer(forKey: currentCountKey)
            if joinedCount == 0 {
                // 首次使用
                let initialCount = Int.random(in: minInitial...maxInitial)
                UserDefaults.standard.set(initialCount, forKey: currentCountKey)
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastUpdateTimeKey)
                joinedCount = initialCount
            }
            // 计算从上次更新到现在应该增加多少
            let lastUpdateTime = UserDefaults.standard.double(forKey: lastUpdateTimeKey)
            if lastUpdateTime > 0 {
                let minutesPassed = Int((Date().timeIntervalSince1970 - lastUpdateTime) / 60)
                if minutesPassed > 0 {
                    // 每分钟增加 1-5 人
                    for _ in 0..<minutesPassed {
                        if joinedCount < maxCount {
                            joinedCount += Int.random(in: 1...5)
                            joinedCount = min(joinedCount, maxCount)
                        }
                    }
                    UserDefaults.standard.set(joinedCount, forKey: currentCountKey)
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastUpdateTimeKey)
                }
            }
        }
    }
    
    private func startTimer() {
        // 每分钟更新一次
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.incrementCount()
        }
    }
    
    private func incrementCount() {
        guard joinedCount < maxCount else { return }
        
        let increment = Int.random(in: 1...5)
        joinedCount = min(joinedCount + increment, maxCount)
        UserDefaults.standard.set(joinedCount, forKey: currentCountKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastUpdateTimeKey)
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Social Proof Badge (社交证明徽章)
struct SocialProofBadge: View {
    let brandColor: Color
    @StateObject private var manager = SocialProofManager.shared
    
    var body: some View {
        HStack(spacing: 6) {
            Text("🔥")
                .font(.system(size: 14))
            Text("\(manager.joinedCount.formatted()) people joined today")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(Capsule())
    }
}

// MARK: - New Pricing Card (更大圆角，居中布局，支持社交证明标签)
struct PricingCardNew: View {
    let title: String
    let price: String
    let subtitle: String?
    let badge: String?
    let socialProofBadge: Bool  // 是否显示社交证明标签
    let isSelected: Bool
    let brandGradient: LinearGradient
    let onTap: () -> Void
    
    @StateObject private var socialProofManager = SocialProofManager.shared
    
    // Badge 渐变配色
    private var badgeGradient: LinearGradient {
        // Best Value: 金 → 橙 → 红
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.84, blue: 0.0),   // 金色
                Color(red: 1.0, green: 0.55, blue: 0.0),   // 橙色
                Color(red: 1.0, green: 0.25, blue: 0.2)    // 红色
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // 社交证明标签渐变 - 火焰橙红色
    private var socialProofGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.45, blue: 0.2),   // 橙红
                Color(red: 1.0, green: 0.3, blue: 0.25)    // 深红
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                // Radio Circle
                ZStack {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(brandGradient)
                    } else {
                        Image(systemName: "circle")
                            .font(.title3)
                            .foregroundStyle(.gray.opacity(0.5))
                    }
                }
                
                // 标题和副标题 - 垂直居中
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(brandGradient) // 始终使用红色渐变
                    }
                }
                
                Spacer()
                
                // 价格
                Text(price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(height: 70) // 固定高度
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 28)) // 更大圆角
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(isSelected ? brandGradient : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing), lineWidth: 2.5)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            // Badge (Best Value 等)
            if let badge = badge {
                Text(badge)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(badgeGradient)
                    .clipShape(Capsule())
                    .shadow(color: Color.orange.opacity(0.5), radius: 4, x: 0, y: 2)
                    .offset(x: 10, y: -10)
            }
            
            // 社交证明标签 (🔥 xxx people have joined this plan today)
            if socialProofBadge {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 10))
                    Text("\(socialProofManager.joinedCount) people have joined this plan today")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(socialProofGradient)
                .clipShape(Capsule())
                .shadow(color: Color.red.opacity(0.4), radius: 4, x: 0, y: 2)
                .offset(x: 10, y: -10)
            }
        }
        .padding(.top, 8)
        .padding(.trailing, 8)
    }
}

#Preview {
    SubscriptionView()
}
