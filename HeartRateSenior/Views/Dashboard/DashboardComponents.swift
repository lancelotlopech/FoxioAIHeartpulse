//
//  DashboardComponents.swift
//  HeartRateSenior
//
//  Various smaller components for Dashboard
//

import SwiftUI
import Charts

// MARK: - Shimmer Overlay (流光效果)
struct ShimmerOverlay: View {
    @State private var phase: CGFloat = -1
    
    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [
                    Color.white.opacity(0),
                    Color.white.opacity(0.4),
                    Color.white.opacity(0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 0.5)
            .offset(x: phase * geo.size.width * 1.5)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 2.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
        }
    }
}

// MARK: - Limited Time Offer Manager (倒计时管理器 - 精确到毫秒)
class LimitedTimeOfferManager: ObservableObject {
    static let shared = LimitedTimeOfferManager()
    
    @Published var remainingTime: TimeInterval = 0
    @Published var isOfferExpired: Bool = false
    
    private var timer: Timer?
    private let offerDuration: TimeInterval = 2 * 60 * 60 // 2小时
    
    // UserDefaults keys
    private let lastOpenDateKey = "limitedOfferLastOpenDate"
    private let offerEndTimeKey = "limitedOfferEndTime"
    
    init() {
        checkAndResetOffer()
        startTimer()
    }
    
    private func checkAndResetOffer() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastOpenDate = UserDefaults.standard.object(forKey: lastOpenDateKey) as? Date
        let lastOpenDay = lastOpenDate.map { Calendar.current.startOfDay(for: $0) }
        
        // 如果是新的一天，重置倒计时
        if lastOpenDay != today {
            let newEndTime = Date().addingTimeInterval(offerDuration)
            UserDefaults.standard.set(today, forKey: lastOpenDateKey)
            UserDefaults.standard.set(newEndTime.timeIntervalSince1970, forKey: offerEndTimeKey)
        }
        
        updateRemainingTime()
    }
    
    private func updateRemainingTime() {
        let endTimeStamp = UserDefaults.standard.double(forKey: offerEndTimeKey)
        if endTimeStamp > 0 {
            let endTime = Date(timeIntervalSince1970: endTimeStamp)
            remainingTime = max(0, endTime.timeIntervalSince(Date()))
            isOfferExpired = remainingTime <= 0
        } else {
            // 首次使用，设置倒计时
            let newEndTime = Date().addingTimeInterval(offerDuration)
            UserDefaults.standard.set(Date(), forKey: lastOpenDateKey)
            UserDefaults.standard.set(newEndTime.timeIntervalSince1970, forKey: offerEndTimeKey)
            remainingTime = offerDuration
            isOfferExpired = false
        }
    }
    
    private func startTimer() {
        // 每 10 毫秒更新一次，实现毫秒级显示
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }
    
    // 格式化时间（精确到毫秒）
    func formattedTime() -> String {
        let hours = Int(remainingTime) / 3600
        let minutes = (Int(remainingTime) % 3600) / 60
        let seconds = Int(remainingTime) % 60
        let milliseconds = Int((remainingTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds)
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Upgrade Banner View (升级横幅 + 流光效果 + 倒计时)
struct UpgradeBannerView: View {
    let onTap: () -> Void
    let onClose: () -> Void
    
    @State private var isAnimating = false
    @State private var giftScale: CGFloat = 1.0
    @StateObject private var offerManager = LimitedTimeOfferManager.shared
    
    // 浅红色（渐变右边的颜色）
    private let lightRedColor = AppColors.primaryRed.opacity(0.6)
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 底层：渐变背景（红色→浅红色）
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.primaryRed,      // 主红色
                                lightRedColor              // 浅红色
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // 中层：流光效果
                ShimmerOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                // 上层：内容
                HStack(spacing: 12) {
                    // 左侧：文字 + 倒计时
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Limited Time Offer")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
                        
                        Text("Unlock premium features")
                            .font(.system(size: 8, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                        
                        // 倒计时（左下角）- 字体变细，背景改为浅红色
                        Text(offerManager.isOfferExpired ? "00:00:00.00" : offerManager.formattedTime())
                            .font(.system(size: 18, weight: .regular, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(lightRedColor.opacity(0.9))  // 浅红色背景
                            )
                            .shadow(color: AppColors.primaryRed.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    // 右侧：礼盒图片 + 星星装饰
                    ZStack {
                        // 礼盒图片（向左旋转15度 + 呼吸动效）
                        Image("gift")
                            .resizable()
                            .interpolation(.medium)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 75, height: 75)
                            .rotationEffect(.degrees(-15))  // 向左旋转15度
                            .scaleEffect(giftScale)
                    }
                    .frame(width: 90, height: 80)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .frame(height: 110)
            .shadow(color: AppColors.primaryRed.opacity(0.35), radius: 12, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // 礼盒呼吸动画
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                giftScale = 1.08
            }
        }
    }
}

// MARK: - Header View with Emergency Button & Pro Badge
struct HeaderView: View {
    let onEmergencyTap: () -> Void
    let onProTap: () -> Void
    let isPremium: Bool
    
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Home")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text(dateText)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.black.opacity(0.6))
            }
            
            Spacer()
            
            // Pro Badge (非订阅用户显示)
            if !isPremium && PaywallConfiguration.showProBadgeInDashboard {
                Button(action: onProTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("PRO")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.2),
                                Color(red: 1.0, green: 0.4, blue: 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            // Emergency Button - 红色背景 + 白色图标
            Button(action: onEmergencyTap) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryRed)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "sos")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Horizontal Record Card View (支持历史入口 + 添加按钮 + 封面图片)
struct HorizontalRecordCardView: View {
    let icon: String
    let title: String
    let lastValue: String?
    let color: Color
    let onAddTap: () -> Void
    var coverImage: String? = nil  // 可选的封面图片名称
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧：封面图片或图标
            if let imageName = coverImage {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.12))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(color)
                }
            }
            
            // 中间：标题和上次值
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                if let value = lastValue {
                    Text("Last: \(value)")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(color)
                } else {
                    Text("Tap to view history")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // 右侧：添加按钮
            Button(action: onAddTap) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                }
            }
            // 箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Weekly Trend Card
struct WeeklyTrendCard: View {
    let records: [HeartRateRecord]
    
    private var recentRecords: [HeartRateRecord] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return records.filter { $0.timestamp >= sevenDaysAgo }.reversed()
    }
    
    private var averageBPM: Int? {
        guard !recentRecords.isEmpty else { return nil }
        let total = recentRecords.reduce(0) { $0 + $1.bpm }
        return total / recentRecords.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                
                if let avg = averageBPM {
                    Text("Avg: \(avg) BPM")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            if recentRecords.count >= 2 {
                Chart(Array(recentRecords)) { record in
                    LineMark(
                        x: .value("Time", record.timestamp),
                        y: .value("BPM", record.bpm)
                    )
                    .foregroundStyle(AppColors.primaryRed.gradient)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Time", record.timestamp),
                        y: .value("BPM", record.bpm)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.primaryRed.opacity(0.3), AppColors.primaryRed.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 80)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Quick Record Card (Senior-Friendly Large Design)
struct QuickRecordCard: View {
    let icon: String
    let title: String
    let lastValue: String?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Left: Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
                
                // Middle: Title & Value
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let value = lastValue {
                        Text("Last: \(value)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        Text("Tap to record")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Right: Add Button
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(color)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Compact Record Card (for 2x2 Grid)
struct CompactRecordCard: View {
    let icon: String
    let title: String
    let lastValue: String?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary).lineLimit(1)
                
                // Value or Tap to record
                if let value = lastValue {
                    Text(value)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(color)
                        .lineLimit(1)
                } else {
                    Text("Tap to add")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Add Icon
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(color.opacity(0.7))
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Horizontal Record Card (横向卡片 - 旧版)
struct HorizontalRecordCard: View {
    let icon: String
    let title: String
    let lastValue: String?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 左侧：大图标
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.12))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(color)
                }
                
                // 中间：标题和上次值
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let value = lastValue {
                        Text("Last: \(value)")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(color)
                    } else {
                        Text("Tap to record")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // 右侧：添加按钮
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Quick Heart Rate Measure Card (旧版，保留兼容)
struct QuickHeartRateMeasureCard: View {
    let lastRecord: HeartRateRecord?
    let onMeasureTap: () -> Void
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Heart Icon
                ZStack {
                    Circle()
                        .fill(AppColors.primaryRed.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.primaryRed)
                }
                
                // Title & Last Value
                VStack(alignment: .leading, spacing: 4) {
                    Text("Heart Rate")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let record = lastRecord {
                        HStack(spacing: 6) {
                            Text("\(record.bpm) BPM")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.primaryRed)
                            
                            Text("· \(timeAgo(from: record.timestamp))")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    } else {
                        Text("No readings yet")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
            }
            
            // Big Measure Button
            Button(action: onMeasureTap) {
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .semibold))
                    
                    Text("Start Measuring")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: AppColors.primaryRed.opacity(0.15), radius: 12, x: 0, y: 6)
        )
    }
}
