//
//  PaywallConfiguration.swift
//  HeartRateSenior
//
//  Paywall configuration for subscription products
//

import SwiftUI

struct PaywallConfiguration {
    // MARK: - Product IDs
    static let weeklyProductID = "heartrate9.99"
    static let yearlyProductID = "39.99"
    
    // MARK: - Colors
    static let primaryColor = AppColors.primaryRed
    static let gradientColors: [Color] = [
        Color(red: 0.957, green: 0.251, blue: 0.227),  // #F4403A
        Color(red: 1.0, green: 0.4, blue: 0.5)         // Pink accent
    ]
    
    // MARK: - App Title
    static let appTitle = "Heart Rate Pro"
    static let subtitle = "Unlock Premium Features"
    
    // MARK: - Premium Features
    static let features: [PremiumFeature] = [
        PremiumFeature(
            icon: "heart.fill",
            title: "Unlimited Measurements",
            description: "Measure your heart rate anytime"
        ),
        PremiumFeature(
            icon: "waveform.path.ecg",
            title: "Advanced HRV Analysis",
            description: "Deep insights into heart health"
        ),
        PremiumFeature(
            icon: "doc.text.fill",
            title: "Health Reports",
            description: "Export PDF reports for doctors"
        ),
        PremiumFeature(
            icon: "chart.line.uptrend.xyaxis",
            title: "All Health Tracking",
            description: "Blood pressure, glucose & more"
        ),
        PremiumFeature(
            icon: "xmark.circle.fill",
            title: "No Ads",
            description: "Enjoy ad-free experience"
        )
    ]
    
    // MARK: - Carousel Items
    static let carouselItems: [CarouselItem] = [
        CarouselItem(
            systemIcon: "heart.text.square.fill",
            title: "Accurate Heart Rate",
            subtitle: "Medical-grade PPG technology"
        ),
        CarouselItem(
            systemIcon: "chart.xyaxis.line",
            title: "HRV Insights",
            subtitle: "Understand your stress & recovery"
        ),
        CarouselItem(
            systemIcon: "doc.richtext.fill",
            title: "Health Reports",
            subtitle: "Share with your doctor"
        )
    ]
    
    // MARK: - URLs
    static let termsURL = URL(string: "https://termsheartpulse.moonspace.workers.dev/terms_of_use.html")!
    static let privacyURL = URL(string: "https://termsheartpulse.moonspace.workers.dev/privacy_policy.html")!
    
    // MARK: - Free Trial
    static let freeTrialDays = 3
    static let hasFreeTrial = true
    
    // MARK: - Mock Prices (显示用，真实价格从 StoreKit 获取)
    static let mockWeeklyPrice = "$9.99"
    static let mockYearlyPrice = "$39.99"
    static let mockYearlyPerWeekPrice = "$0.76"
    static let savingsPercent = "92%"
    
    // MARK: - Display Rules
    static let showProBadgeInDashboard = true
    static let showUpgradeBanner = true
    static let bannerDismissable = true // 可关闭，但下次启动仍会显示
    
    // MARK: - Feature Gating (Free User Limits)
    static let freeDailyMeasurements = 3      // 免费用户每日测量次数
    static let freeHistoryDays = 7            // 免费用户只能看最近7天历史
    static let showPaywallAfterMeasurements = 3 // 测量N次后显示升级提示
    
    // MARK: - Premium Features Lock
    static let lockAdvancedHRV = true         // 锁定高级HRV分析
    static let lockPDFExport = true           // 锁定PDF导出
    static let lockUnlimitedHistory = true    // 锁定无限历史
}

// MARK: - Premium Feature Model
struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Carousel Item Model
struct CarouselItem: Identifiable {
    let id = UUID()
    let systemIcon: String  // Using SF Symbols instead of images
    let title: String
    let subtitle: String
}
