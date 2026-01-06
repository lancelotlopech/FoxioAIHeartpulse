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
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = UIColor(Color(hex: "EFF0F3"))
        
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

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var subManager = SubscriptionManager.shared
    
    @State private var selectedProductID: String = PaywallConfiguration.yearlyProductID
    @State private var isTrialEnabled: Bool = false
    @State private var isAnimating = false
    
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
        ZStack {
            // 背景色 #EFF0F3 (与视频背景一致)
            Color(hex: "EFF0F3")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Header
                headerView
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                // Adaptive Content Area - 单屏优先
                ViewThatFits(in: .vertical) {
                    // Option A: 固定单屏布局
                    fixedContentLayout
                    
                    // Option B: 小屏幕回退到滚动
                    scrollableContentLayout
                }
                
                // 7. Bottom Button (Always Sticky)
                bottomSection
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
            Spacer(minLength: 8)
            heroSection
            Spacer(minLength: 12)
            trialToggleSection.padding(.horizontal, 20)
            Spacer(minLength: 8)
            pricingSection.padding(.horizontal, 20)
            Spacer(minLength: 8)
            assuranceSection
            Spacer(minLength: 12)
        }
    }
    
    private var scrollableContentLayout: some View {
        ScrollView {
            VStack(spacing: 12) {
                heroSection
                    .padding(.top, 10)
                trialToggleSection
                    .padding(.horizontal, 20)
                pricingSection
                    .padding(.horizontal, 20)
                assuranceSection
                Spacer(minLength: 20)
            }
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.gray.opacity(0.5))
            }
            
            Spacer()
            
            Button("Restore") {
                Task {
                    await subManager.restorePurchases()
                    if subManager.isPremium {
                        dismiss()
                    }
                }
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 12) {
            // Heartbeat Video - Looping, muted, auto-play
            SubscriptionVideoPlayer(videoName: "heartbeat", videoExtension: "mp4")
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "EFF0F3"))
            
            // Title
            VStack(spacing: 4) {
                Text(PaywallConfiguration.appTitle)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(brandGradient)
                
                Text(PaywallConfiguration.subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            // Feature List (Compact)
            VStack(alignment: .leading, spacing: 6) {
                FeatureRowCompact(text: "Unlimited Heart Rate Measurements", gradient: brandGradient)
                FeatureRowCompact(text: "Advanced HRV & Health Insights", gradient: brandGradient)
                FeatureRowCompact(text: "Export PDF Reports", gradient: brandGradient)
            }
            .padding(.top, 8)
        }
    }
    
    private var trialToggleSection: some View {
        HStack {
            Text(isTrialEnabled ? "Free Trial Enabled" : "Not sure yet? Enable free trial")
                .font(.subheadline.bold())
                .foregroundStyle(isTrialEnabled ? brandColor : .secondary)
            
            Spacer()
            
            Toggle("", isOn: $isTrialEnabled)
                .labelsHidden()
                .tint(brandColor)
        }
        .padding(12)
        .background(isTrialEnabled ? brandColor.opacity(0.1) : Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isTrialEnabled ? brandColor.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var pricingSection: some View {
        VStack(spacing: 8) {
            // Yearly Option
            PricingCard(
                title: "YEARLY ACCESS",
                price: "\(yearlyPrice)/year",
                subtitle: "Just \(yearlyPerWeekPrice) per week",
                badge: "Save \(PaywallConfiguration.savingsPercent)",
                isSelected: selectedProductID == PaywallConfiguration.yearlyProductID,
                brandGradient: brandGradient,
                onTap: { selectedProductID = PaywallConfiguration.yearlyProductID }
            )
            
            // Weekly Option
            PricingCard(
                title: "WEEKLY ACCESS",
                price: "\(weeklyPrice)/week",
                subtitle: isTrialEnabled ? "\(PaywallConfiguration.freeTrialDays) Days Free Trial" : nil,
                badge: isTrialEnabled ? "Popular" : nil,
                isSelected: selectedProductID == PaywallConfiguration.weeklyProductID,
                brandGradient: brandGradient,
                onTap: { selectedProductID = PaywallConfiguration.weeklyProductID }
            )
        }
    }
    
    private var assuranceSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundStyle(.green)
                .font(.caption)
            Text("You can cancel anytime.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    private var bottomSection: some View {
        VStack(spacing: 8) {
            Button {
                Task {
                    if let product = subManager.products.first(where: { $0.id == selectedProductID }) {
                        let _ = try? await subManager.purchase(product)
                        if subManager.isPremium {
                            dismiss()
                        }
                    }
                }
            } label: {
                if subManager.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(brandGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 27))
                } else {
                    // 使用 TimelineView 实现真正的循环动画
                    AnimatedCTAButton(text: buttonText, gradient: brandGradient, brandColor: brandColor)
                }
            }
            
            HStack(spacing: 20) {
                Link("Terms of Use", destination: PaywallConfiguration.termsURL)
                Link("Privacy Policy", destination: PaywallConfiguration.privacyURL)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    private var buttonText: String {
        if isTrialEnabled {
            return "Start Free Trial"
        } else {
            return "Continue"
        }
    }
}

// MARK: - Feature Row Compact
struct FeatureRowCompact: View {
    let text: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(gradient)
            
            Text(text)
                .font(.footnote)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Pricing Card
struct PricingCard: View {
    let title: String
    let price: String
    let subtitle: String?
    let badge: String?
    let isSelected: Bool
    let brandGradient: LinearGradient
    let onTap: () -> Void
    
    // Badge 渐变配色 - 火焰金方案
    private var badgeGradient: LinearGradient {
        if badge?.contains("Save") == true {
            // Save 80%: 金 → 橙 → 红
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.84, blue: 0.0),   // 金色
                    Color(red: 1.0, green: 0.55, blue: 0.0),   // 橙色
                    Color(red: 1.0, green: 0.25, blue: 0.2)    // 红色
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // Popular: 红 → 紫 → 蓝
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.25, blue: 0.35),  // 红色
                    Color(red: 0.7, green: 0.3, blue: 0.9),    // 紫色
                    Color(red: 0.3, green: 0.5, blue: 1.0)     // 蓝色
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var badgeShadowColor: Color {
        if badge?.contains("Save") == true {
            return Color.orange.opacity(0.5)
        } else {
            return Color.purple.opacity(0.5)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
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
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                        
                        // 固定占位：始终显示 subtitle 区域
                        Text(subtitle ?? " ")
                            .font(.caption2)
                            .foregroundStyle(subtitle != nil && isSelected ? brandGradient : LinearGradient(colors: [.secondary], startPoint: .leading, endPoint: .trailing))
                            .fontWeight(isSelected ? .medium : .regular)
                            .opacity(subtitle != nil ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    Text(price)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(height: 70) // 固定高度
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(isSelected ? brandGradient : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                )
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeGradient)
                        .clipShape(Capsule())
                        .shadow(color: badgeShadowColor, radius: 4, x: 0, y: 2)
                        .offset(x: 10, y: -10)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
        .padding(.trailing, 8)
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

#Preview {
    SubscriptionView()
}
