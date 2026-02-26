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
import FacebookCore
import FirebaseCore

// MARK: - AppDelegate for Facebook SDK lifecycle
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
}

@main
struct HeartRateSeniorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var billingIdentityManager = BillingIdentityManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSplash = true
    @State private var appIsReady = false  // 加载完成标志
    @State private var showPaywall = false // 启动后显示订阅页
    @StateObject private var appsFlyerManager = AppsFlyerManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasRequestedATT = false  // 确保 ATT 只请求一次
    @State private var shouldRequestATT = false  // 标记是否应该请求 ATT

    init() {
        Self.configureFirebase()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HeartRateRecord.self,
            BloodPressureRecord.self,
            BloodGlucoseRecord.self,
            WeightRecord.self,
            OxygenRecord.self,
            Reminder.self,
            EmergencyContact.self,
            CycleProfile.self,
            PregnancyAssessmentRecord.self,
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
                            .environmentObject(settingsManager)} else {
                        OnboardingContainerView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .environmentObject(settingsManager)
                    }
                }
                .opacity(showSplash ? 0 : 1)
                
                // 订阅页叠加显示（瞬间出现，无动画）
                if showPaywall {
                    Color(hex: "EFF0F3")
                        .ignoresSafeArea()
                        .overlay(
                            SubscriptionView(isPresented: $showPaywall)
                )
                        .zIndex(100)
                }
                
                // 启动动画（带保底机制）
                if showSplash {
                    SplashView(isReady: $appIsReady) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSplash = false
                        }// Splash 结束后：已完成 Onboarding 的非 Premium 用户立即弹订阅页
                        if hasCompletedOnboarding && !subscriptionManager.isPremium {
                            showPaywall = true
                        }// 标记需要请求 ATT（等待 scenePhase 变为 active时请求）
                        shouldRequestATT = true
                    }.transition(.opacity)
                    .onAppear {
                        Task { @MainActor in
                            await billingIdentityManager.configureOnLaunch()
                        }

                        // 配置 AppsFlyer SDK
                        appsFlyerManager.configure()
                        
                        // 配置 Facebook SDK
                        FacebookSDKManager.shared.configure()
                        
                        // 模拟加载完成（实际项目可在数据加载完成后设置）
                        // 立即设置 ready，让保底机制生效
                        appIsReady = true}
                }
            }
            // onChange 必须在 ZStack 外部，否则会因为视图切换而失效
            .onChange(of: hasCompletedOnboarding) { _, newValue in
                // Onboarding 完成后立即弹订阅页（无动画）
                if newValue && !subscriptionManager.isPremium {
                    showPaywall = true
                }
            }
            // 监听 scenePhase 变化，确保在 App 完全进入 active 状态后请求 ATT
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active && shouldRequestATT && !hasRequestedATT {
                    requestATTPermission()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }

    // MARK: - Firebase
    private static func configureFirebase() {
        guard FirebaseApp.app() == nil else { return }
        guard let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: plistPath) else {
            print("🔥 Firebase: GoogleService-Info.plist missing, Firebase is not configured")
            return
        }
        FirebaseApp.configure(options: options)
        print("🔥 Firebase: Configured")
    }
    
    // MARK: - ATT Permission Request
    private func requestATTPermission() {
        // 确保只请求一次
        guard !hasRequestedATT else { return }
        hasRequestedATT = true
        
        // 延迟 0.5 秒后请求 ATT，确保 UI 完全稳定
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                    // 通知 Facebook SDK ATT 授权结果
                    FacebookSDKManager.shared.handleATTAuthorization(authorized: status == .authorized)
                }
            }
        }
    }
}
