//
//  PremiumLockedOverlay.swift
//  HeartRateSenior
//
//  Premium feature lock overlay with blur effect
//

import SwiftUI

// MARK: - Premium Locked Overlay View (Three Full Lock Views)
struct PremiumLockedOverlay: View {
    @Binding var showSubscription: Bool
    var title: String = "Unlock Full Report"
    var subtitle: String = "Get detailed health insights"
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        triggerSubscription()
                    }
                
                if height < 280 {
                    FullLockView(
                        title: title,
                        subtitle: subtitle,
                        onUnlock: triggerSubscription,
                        isCompact: false
                    )
                    .position(x: width / 2, y: height * 0.5)
                } else {
                    // 上部完整锁定视图
                    FullLockView(
                        title: title,
                        subtitle: subtitle,
                        onUnlock: triggerSubscription,
                        isCompact: true
                    )
                    .position(x: width / 2, y: height * 0.18)
                    
                    // 中部完整锁定视图（主）
                    FullLockView(
                        title: title,
                        subtitle: subtitle,
                        onUnlock: triggerSubscription,
                        isCompact: false
                    )
                    .position(x: width / 2, y: height * 0.5)
                    
                    // 下部完整锁定视图
                    FullLockView(
                        title: title,
                        subtitle: subtitle,
                        onUnlock: triggerSubscription,
                        isCompact: true
                    )
                    .position(x: width / 2, y: height * 0.82)
                }
            }
        }
    }
    
    private func triggerSubscription() {
        HapticManager.shared.mediumImpact()
        showSubscription = true
    }
}

// MARK: - Full Lock View (完整锁定视图)
struct FullLockView: View {
    let title: String
    let subtitle: String
    let onUnlock: () -> Void
    var isCompact: Bool = false
    
    var body: some View {
        VStack(spacing: isCompact ? 10 : 16) {
            // Lock Icon with glow effect -可点击
            Button(action: onUnlock) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.primaryRed.opacity(0.3),
                                    AppColors.primaryRed.opacity(0.1),Color.clear
                                ],
                                center: .center,
                                startRadius: isCompact ? 15 : 20,
                                endRadius: isCompact ? 45 : 60
                            )
                        )
                        .frame(width: isCompact ? 80 : 100, height: isCompact ? 80 : 100)
                    Circle()
                        .fill(Color.white)
                        .frame(width: isCompact ? 52 : 64, height: isCompact ? 52 : 64)
                        .shadow(color: AppColors.primaryRed.opacity(0.2), radius: isCompact ? 8 : 10, x: 0, y: isCompact ? 3 : 4)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: isCompact ? 22 : 28, weight: .semibold))
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Title
            Text(title)
                .font(.system(size: isCompact ? 16 : 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            // Subtitle
            Text(subtitle)
                .font(.system(size: isCompact ? 12 : 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary).multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Unlock Button
            Button(action: onUnlock) {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: isCompact ? 14 : 16))
                    Text("Unlock Now")
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, isCompact ? 22 : 28)
                .padding(.vertical, isCompact ? 11 : 14)
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(isCompact ? 20 : 25)
                .shadow(color: AppColors.primaryRed.opacity(0.3), radius: isCompact ? 6 : 8, x: 0, y: isCompact ? 3 : 4)
            }
        }
        .padding(.vertical, isCompact ? 16 : 24).padding(.horizontal, isCompact ? 16 : 20)
    }
}

// MARK: - Premium Gated Section Modifier
struct PremiumGatedModifier: ViewModifier {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Binding var showSubscription: Bool
    var blurRadius: CGFloat = 8
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: subscriptionManager.isPremium ? 0 : blurRadius)
                .allowsHitTesting(subscriptionManager.isPremium)
            
            if !subscriptionManager.isPremium {
                // Semi-transparent overlay
                Color.white.opacity(0.4)
                
                // Lock overlay
                PremiumLockedOverlay(showSubscription: $showSubscription)}
        }}
}

// MARK: - View Extension
extension View {
    func premiumGated(showSubscription: Binding<Bool>, blurRadius: CGFloat = 8) -> some View {
        modifier(PremiumGatedModifier(showSubscription: showSubscription, blurRadius: blurRadius))
    }
}

// MARK: - Premium Section Container
/// A container that wraps multiple sections with a single premium lock overlay
struct PremiumSectionContainer<Content: View>: View {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Binding var showSubscription: Bool
    let title: String
    let subtitle: String
    let content: Content
    
    init(
        showSubscription: Binding<Bool>,
        title: String = "Unlock Full Report",
        subtitle: String = "Access detailed metrics, trends, and personalized insights",
        @ViewBuilder content: () -> Content
    ) {
        self._showSubscription = showSubscription
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                content}
            .blur(radius: subscriptionManager.isPremium ? 0 : 6)
            .allowsHitTesting(subscriptionManager.isPremium)
            if !subscriptionManager.isPremium {
                // Gradient overlay for better readability
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.5),
                        Color.white.opacity(0.5),
                        Color.white.opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
                
                // Lock overlay with three full views
                PremiumLockedOverlay(
                    showSubscription: $showSubscription,
                    title: title,
                    subtitle: subtitle
                )
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Sample Content")
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
    .padding()
    .premiumGated(showSubscription: .constant(false))
}
