//
//  HeartRateSeniorApp.swift
//  HeartRateSenior
//
//  A senior-friendly heart rate monitoring app for iOS
//

import SwiftUI
import SwiftData
import AppTrackingTransparency
import AppsFlyerLib

@main
struct HeartRateSeniorApp: App {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSplash = true
    @State private var appIsReady = false  // 加载完成标志
    @State private var showPaywall = false // 启动后显示订阅页
    @StateObject private var appsFlyerManager = AppsFlyerManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HeartRateRecord.self,
            BloodPressureRecord.self,
            BloodGlucoseRecord.self,
            WeightRecord.self,
            OxygenRecord.self,
            Reminder.self,
            EmergencyContact.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // 主内容
                Group {
                    if hasCompletedOnboarding {
                        MainTabView()
                            .environmentObject(settingsManager)
                    } else {
                        OnboardingContainerView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .environmentObject(settingsManager)
                            .onChange(of: hasCompletedOnboarding) { _, newValue in
                                // Onboarding 完成后弹订阅页
                                if newValue && !subscriptionManager.isPremium {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        showPaywall = true
                                    }
                                }
                            }
                    }
                }
                .opacity(showSplash ? 0 : 1)
                .fullScreenCover(isPresented: $showPaywall) {
                    SubscriptionView()
                }
                
                // 启动动画（带保底机制）
                if showSplash {
                    SplashView(isReady: $appIsReady) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSplash = false
                        }
                        // Splash 结束后：已完成 Onboarding 的非 Premium 用户弹订阅页
                        if hasCompletedOnboarding && !subscriptionManager.isPremium {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showPaywall = true
                            }
                        }
                        // 请求 ATT 权限
                        requestATTPermission()
                    }
                    .transition(.opacity)
                    .onAppear {
                        // 配置 AppsFlyer SDK
                        appsFlyerManager.configure()
                        
                        // 模拟加载完成（实际项目可在数据加载完成后设置）
                        // 立即设置 ready，让保底机制生效
                        appIsReady = true
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - ATT Permission Request
    private func requestATTPermission() {
        // 延迟 1 秒后请求 ATT，避免与其他弹窗冲突
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // 记录用户选择（可用于分析或调试）
                switch status {
                case .authorized:
                    print("✅ ATT: User authorized tracking")
                case .denied:
                    print("❌ ATT: User denied tracking")
                case .notDetermined:
                    print("⏳ ATT: Not determined")
                case .restricted:
                    print("🔒 ATT: Restricted")
                @unknown default:
                    print("❓ ATT: Unknown status")
                }
                
                // 通知 AppsFlyer ATT 授权结果并启动 SDK
                Task { @MainActor in
                    AppsFlyerManager.shared.handleATTAuthorization(status: status)
                }
            }
        }
    }
}
