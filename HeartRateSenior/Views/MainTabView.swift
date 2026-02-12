//
//  MainTabView.swift
//  HeartRateSenior
//
//  Custom tab bar with large touch targets for seniors
//  Structure: Home (Dashboard) | ❤️ Measure | Settings
//

import SwiftUI

// MARK: - Tab Item Enum
enum TabItem: Int, CaseIterable {
    case home = 0
    case measure = 1
    case settings = 2
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .measure: return "Check"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .measure: return "heart.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @State private var showingMeasureFullScreen = false  // 全屏测量页面
    @State private var showingSubscription = false
    @State private var previousTab: TabItem = .home  // 记录之前的 Tab
    @State private var lastActiveTime: Date = Date()  // 记录最后活跃时间
    @State private var isReturningFromBackground = false  // 是否从后台返回
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Content
                Group {
                    switch selectedTab {
                    case .home:
                        DashboardView()
                    case .measure:
                        // 非自动启动模式下显示 HomeView（手动点击 Tab）
                        // 注意：当 fullScreenCover 显示时，这个 View 仍然存在
                        // 但不会干扰测量，因为 autoStart=false
                        if !showingMeasureFullScreen {
                            HomeView(
                                autoStart: false,
                                onDismiss: nil
                            )
                        } else {
                            // 全屏测量时显示占位视图，避免两个 HomeView 同时存在
                            Color.white
                        }
                        
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 13) // Space for tab bar
                
                // Custom Tab Bar - Fixed at bottom
                VStack(spacing: 0) {
                    Spacer()
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        onMeasureTapped: {
                            startMeasurement()
                        }
                    )
                }
                .ignoresSafeArea(.keyboard)
                .ignoresSafeArea(edges: .bottom) // 让 Tab Bar 延伸到屏幕底部
                
                // 订阅页 - 在最顶层，覆盖 Tab 栏
                // 使用背景色填充安全区域，SubscriptionView 自己处理内部布局
                if showingSubscription {
                    Color(hex: "EFF0F3")
                        .ignoresSafeArea()
                        .overlay(
                            SubscriptionView(isPresented: $showingSubscription)
                        )
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        // 全屏测量页面（沉浸式，隐藏 Tab Bar）
        .fullScreenCover(isPresented: $showingMeasureFullScreen) {
            HomeView(
                autoStart: true,
                onDismiss: {
                    showingMeasureFullScreen = false
                }
            )
            .environmentObject(settingsManager)
        }
        // 监听应用状态变化
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                // 从后台返回前台
                let timeSinceLastActive = Date().timeIntervalSince(lastActiveTime)
                if timeSinceLastActive > 1.0 {
                    // 超过 1 秒，标记为从后台返回
                    isReturningFromBackground = true
                    print("📱 App returned from background after \(timeSinceLastActive)s")
                    
                    // 1 秒后重置标记
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isReturningFromBackground = false
                    }
                }
                lastActiveTime = Date()
                
            case .inactive, .background:
                lastActiveTime = Date()
                
            @unknown default:
                break
            }
        }
        // Listen for navigation requests from Dashboard
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToMeasure"))) { _ in
            // 如果是从后台返回，忽略此通知
            guard !isReturningFromBackground else {
                print("📱 Ignoring NavigateToMeasure - returning from background")
                return
            }
            startMeasurement()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToMeasureTab"))) { _ in
            // 如果是从后台返回，忽略此通知
            guard !isReturningFromBackground else {
                print("📱 Ignoring SwitchToMeasureTab - returning from background")
                return
            }
            startMeasurement()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSubscription"))) { _ in
            showingSubscription = true
        }
    }
    
    private func startMeasurement() {
        // 防抖：如果已经在显示测量页面，不重复触发
        guard !showingMeasureFullScreen else {
            print("📱 Measurement already showing, ignoring")
            return
        }
        
        HapticManager.shared.mediumImpact()
        showingMeasureFullScreen = true
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var onMeasureTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Home Tab
            TabBarButton(
                tab: .home,
                isSelected: selectedTab == .home,
                action: { 
                    HapticManager.shared.selectionChanged()
                    selectedTab = .home 
                }
            )
            
            // Measure Tab (Center - Larger)
            CenterMeasureButton(
                action: onMeasureTapped
            )
            
            // Settings Tab
            TabBarButton(
                tab: .settings,
                isSelected: selectedTab == .settings,
                action: { 
                    HapticManager.shared.selectionChanged()
                    selectedTab = .settings 
                }
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, 5) // 距离屏幕底部 5 像素
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: -4)
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 28, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.textSecondary)
                
                Text(tab.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Center Measure Button
struct CenterMeasureButton: View {
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .shadow(color: AppColors.primaryRed.opacity(0.35), radius: 8, x: 0, y: 3)
                        .scaleEffect(scale)
                    
                    // Heart icon
                    Image(systemName: "heart.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                }
                .offset(y: -7)
                
                Text("Measure")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.primaryRed)
                    .offset(y: -3)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.08
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SettingsManager())
}
