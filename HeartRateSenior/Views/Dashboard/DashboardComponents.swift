//
//  DashboardComponents.swift
//  HeartRateSenior
//
//  Dashboard components - 1:1 matching HTML design
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

// MARK: - Limited Time Offer Manager
class LimitedTimeOfferManager: ObservableObject {
    static let shared = LimitedTimeOfferManager()
    
    @Published var remainingTime: TimeInterval = 0
    @Published var isOfferExpired: Bool = false
    
    private var timer: Timer?
    private let offerDuration: TimeInterval = 2 * 60 * 60
    
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
            let newEndTime = Date().addingTimeInterval(offerDuration)
            UserDefaults.standard.set(Date(), forKey: lastOpenDateKey)
            UserDefaults.standard.set(newEndTime.timeIntervalSince1970, forKey: offerEndTimeKey)
            remainingTime = offerDuration
            isOfferExpired = false
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
    }
    
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

// MARK: - Upgrade Banner View
struct UpgradeBannerView: View {
    let onTap: () -> Void
    let onClose: () -> Void
    
    @State private var giftScale: CGFloat = 1.0
    @StateObject private var offerManager = LimitedTimeOfferManager.shared
    
    private let lightRedColor = AppColors.primaryRed.opacity(0.6)
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primaryRed, lightRedColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                ShimmerOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Limited Time Offer")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Unlock premium features")
                            .font(.system(size: 8, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text(offerManager.isOfferExpired ? "00:00:00.00" : offerManager.formattedTime())
                            .font(.system(size: 18, weight: .regular, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(lightRedColor.opacity(0.9))
                            )
                    }
                    
                    Spacer()
                    
                    Image("gift")
                        .resizable()
                        .interpolation(.medium)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 75)
                        .rotationEffect(.degrees(-15))
                        .scaleEffect(giftScale)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .frame(height: 110)
            .shadow(color: AppColors.primaryRed.opacity(0.35), radius: 12, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                giftScale = 1.08
            }
        }
    }
}

// MARK: - Modern Header View (匹配HTML: Home + Welcome back + PRO + SOS)
struct ModernHeaderView: View {
    let userName: String
    var showProBadge: Bool = false
    var onProTap: (() -> Void)? = nil
    let onEmergencyTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Home")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                    .tracking(-0.5)
                
                if !userName.isEmpty {
                    Text("Welcome back, \(userName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                }
            }
            
            Spacer()
            
            if showProBadge, let proAction = onProTap {
                Button(action: proAction) {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("PRO")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.4, blue: 0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.25).opacity(0.3), radius: 6, x: 0, y: 3)
                }
            }
            
            Button(action: onEmergencyTap) {
                Text("SOS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(0.5)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(AppColors.primaryRed)
                            .shadow(color: AppColors.primaryRed.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
        }
    }
}

// MARK: - Header View (旧版兼容)
struct HeaderView: View {
    let onEmergencyTap: () -> Void
    let onProTap: () -> Void
    let isPremium: Bool
    
    var body: some View {
        HStack {
            Text("Home")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            Spacer()
            if !isPremium && PaywallConfiguration.showProBadgeInDashboard {
                Button(action: onProTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill").font(.system(size: 12, weight: .semibold))
                        Text("PRO").font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(LinearGradient(colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.4, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(12)
                }
            }
            Button(action: onEmergencyTap) {
                ZStack {
                    Circle().fill(AppColors.primaryRed).frame(width: 50, height: 50)
                    Image(systemName: "sos").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Week Calendar Strip (逐日滑动, 自动吸附, 机械表震动反馈)
struct WeekCalendarStripView: View {
    let heartRateRecords: [HeartRateRecord]
    let bloodPressureRecords: [BloodPressureRecord]
    let bloodGlucoseRecords: [BloodGlucoseRecord]
    let onDateTapped: (Date) -> Void
    var onViewMoreHistory: (() -> Void)? = nil
    
    private let calendar = Calendar.current
    private let itemWidth: CGFloat = 42
    private let itemSpacing: CGFloat = 6
    
    // 生成日期范围: 过去60天 + 今天 + 未来30天 (共91天)
    private var allDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (-60...30).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }
    
    // 今天的索引
    private var todayIndex: Int { 60 }
    
    @State private var currentCenterIndex: Int = 60
    
    private func hasRecords(on date: Date) -> Bool {
        heartRateRecords.contains { calendar.isDate($0.timestamp, inSameDayAs: date) } ||
        bloodPressureRecords.contains { calendar.isDate($0.timestamp, inSameDayAs: date) } ||
        bloodGlucoseRecords.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }
    
    private func weekdayLabel(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let labels = ["S", "M", "T", "W", "T", "F", "S"]
        return labels[weekday - 1]
    }
    
    private enum DateCategory {
        case past, today, future
    }
    
    private func dateCategory(_ date: Date) -> DateCategory {
        let today = calendar.startOfDay(for: Date())
        let dateStart = calendar.startOfDay(for: date)
        if dateStart == today { return .today }
        if dateStart < today { return .past }
        return .future
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: itemSpacing) {
                    ForEach(Array(allDates.enumerated()), id: \.offset) { index, date in
                        let category = dateCategory(date)
                        let isToday = category == .today
                        let dayNumber = calendar.component(.day, from: date)
                        let hasData = hasRecords(on: date)
                        
                        Button(action: {
                            HapticManager.shared.selectionChanged()
                            onDateTapped(date)
                        }) {
                            VStack(spacing: 4) {
                                Text(weekdayLabel(for: date))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(
                                        isToday ? .white.opacity(0.9) :
                                        category == .future ? Color(red: 0.75, green: 0.78, blue: 0.82) :
                                        Color(red: 0.392, green: 0.455, blue: 0.545)
                                    )
                                
                                Text("\(dayNumber)")
                                    .font(.system(size: isToday ? 18 : 15, weight: .bold))
                                    .foregroundColor(
                                        isToday ? .white :
                                        category == .future ? Color(red: 0.75, green: 0.78, blue: 0.82) :
                                        Color(red: 0.118, green: 0.161, blue: 0.231)
                                    )
                                
                                // 指示点
                                if isToday {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 5, height: 5)
                                } else if hasData {
                                    Circle()
                                        .fill(Color(red: 0.2, green: 0.78, blue: 0.35))
                                        .frame(width: 6, height: 6)
                                        .shadow(color: Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.5), radius: 2)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 5, height: 5)
                                }
                            }
                            .frame(width: itemWidth, height: 62)
                            .background(
                                Group {
                                    if isToday {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(AppColors.primaryRed)
                                            .shadow(color: AppColors.primaryRed.opacity(0.25), radius: 8, x: 0, y: 4)
                                    }
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .id(index)
                        .scrollTransition { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                                .opacity(phase.isIdentity ? 1.0 : 0.7)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                currentCenterIndex
            }, set: { newValue in
                if let newIndex = newValue as? Int, newIndex != currentCenterIndex {
                    currentCenterIndex = newIndex
                    HapticManager.shared.selectionChanged()
                }
            }))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo(todayIndex, anchor: .center)
                }
            }
        }
        .frame(height: 76)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// 辅助: 滚动偏移量 PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Modern Heart Rate Card (匹配HTML: 渐变 + 大心形SVG)
struct ModernHeartRateCard: View {
    let lastRecord: HeartRateRecord?
    let onMeasureTap: () -> Void
    
    @State private var isPulsing = false
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60)) min ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
    
    var body: some View {
        Button(action: onMeasureTap) {
            ZStack {
                // 背景渐变
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.937, green: 0.267, blue: 0.267), // red-500
                                AppColors.primaryRed,
                                Color(red: 0.98, green: 0.55, blue: 0.24)  // orange-400
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppColors.primaryRed.opacity(0.2), radius: 12, x: 0, y: 6)
                
                // 右上角白色光晕
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 160, height: 160)
                    .blur(radius: 40)
                    .offset(x: 60, y: -60)
                
                // 白色边框
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                
                HStack {
                    // 左侧内容
                    VStack(alignment: .leading, spacing: 0) {
                        // Heart Rate 标题
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Heart Rate")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // Last checked
                        if let record = lastRecord {
                            Text("Last checked \(timeAgo(from: record.timestamp))")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.85))
                                .padding(.top, 2)
                        } else {
                            Text("No readings yet")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.85))
                                .padding(.top, 2)
                        }
                        
                        Spacer()
                        
                        // BPM 大数字
                        if let record = lastRecord {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(record.bpm)")
                                    .font(.system(size: 48, weight: .black))
                                    .foregroundColor(.white)
                                
                                Text("BPM")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.85))
                            }
                            
                            // Stable Trend 标签
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10, weight: .medium))
                                Text("Stable Trend")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.top, 4)
                        } else {
                            Text("Tap to measure")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                    
                    // 右侧: 大心形图标 (匹配HTML的SVG心形+十字)
                    ZStack {
                        // 脉动光晕
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 88, height: 88)
                            .blur(radius: 16)
                            .scaleEffect(isPulsing ? 1.1 : 0.9)
                        
                        // 心形 + 十字
                        ZStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            
                            // 十字标记
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppColors.primaryRed)
                        }
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                    }
                    .frame(width: 100, height: 100)
                }
                .padding(24)
            }
            .frame(height: 180)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Quick Record Section Title
struct QuickRecordTitleView: View {
    var body: some View {
        HStack {
            Text("Quick Record")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
            
            Spacer()
        }
    }
}

// MARK: - Compact Health Card (匹配HTML: 圆形图标+状态标签+数值+单位, 整个卡片可点击)
struct CompactHealthCard: View {
    let icon: String
    let title: String
    let lastValue: String?
    let unit: String
    let color: Color
    let iconBgColor: Color
    var iconCircleBgColor: Color? = nil
    let statusText: String?
    let statusColor: Color
    let onAddTap: () -> Void
    
    var body: some View {
        Button(action: onAddTap) {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部: 圆形图标 + 状态标签
                    HStack {
                        // 圆形图标背景
                        ZStack {
                            Circle()
                                .fill(iconCircleBgColor ?? iconBgColor.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: icon)
                                .font(.system(size: 18))
                                .foregroundColor(iconBgColor)
                        }
                        
                        Spacer()
                        
                        // 状态标签
                        if let status = statusText {
                            Text(status)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(statusColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(statusColor.opacity(0.12))
                                )
                        }
                    }
                    
                    Spacer().frame(height: 12)
                    
                    // 标题
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                        .lineLimit(1)
                    
                    Spacer().frame(height: 4)
                    
                    // 数值
                    Text(lastValue ?? "--")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
                    
                    Spacer().frame(height: 2)
                    
                    // 单位
                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                }
                
                // 右下角加号图标（装饰性，整个卡片都可点击）
                ZStack {
                    Circle()
                        .fill(Color(red: 0.973, green: 0.976, blue: 0.984))
                        .frame(width: 32, height: 32)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Self Check Section Title
struct SelfCheckTitleView: View {
    var body: some View {
        HStack {
            Text("Self Check")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
            Spacer()
        }
    }
}

// MARK: - Image Based Self Check Card (匹配HTML: 并排2列, 图片背景+渐变+图标+文字)
struct ImageBasedSelfCheckCard: View {
    let imageName: String
    let title: String
    let subtitle: String
    let iconName: String
    let gradientColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    // 背景图片
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: 176)
                        .clipped()
                    
                    // 渐变遮罩
                    LinearGradient(
                        colors: [
                            Color.clear,
                            gradientColor.opacity(0.4),
                            gradientColor.opacity(0.9)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // 内容
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        
                        // 圆形图标
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: iconName)
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 12)
                        
                        // 标题
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        // 副标题
                        Text(subtitle)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                    .padding(16)
                }
            }
            .frame(height: 176)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Health Articles Title
struct HealthArticlesTitleView: View {
    var onSeeAllTap: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text("Health Articles")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.118, green: 0.161, blue: 0.231))
            
            Spacer()
            
            if let action = onSeeAllTap {
                Button(action: action) {
                    Text("See All")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primaryRed)
                }
            } else {
                Text("See All")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryRed)
            }
        }
    }
}

// MARK: - Article Image Card (匹配HTML: 图片背景+渐变+标签+标题)
struct ArticleImageCard: View {
    let imageName: String
    let tag: String
    let tagColor: Color
    let title: String
    let height: CGFloat
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { onTap?() }) {
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    // 背景图片
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: height)
                        .clipped()
                    
                    // 渐变遮罩
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.6)
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    // 内容
                    VStack(alignment: .leading, spacing: 6) {
                        Spacer()
                        
                        // 标签
                        Text(tag.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .tracking(0.5)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(tagColor))
                        
                        // 标题
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(16)
                }
            }
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Disclaimer Footer (匹配HTML: 白色卡片 + info图标 + 文字 + 下箭头)
struct DashboardDisclaimerFooter: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text("References & Disclaimer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text("This app is for informational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.392, green: 0.455, blue: 0.545))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - 旧版组件保留兼容

struct SectionTitleView: View {
    let icon: String
    let title: String
    var showSeeMore: Bool = false
    var onSeeMoreTap: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }
            Spacer()
            if showSeeMore, let action = onSeeMoreTap {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text("See All").font(.system(size: 14, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
            }
        }
    }
}

struct WeeklyTrendCard: View {
    let records: [HeartRateRecord]
    private var recentRecords: [HeartRateRecord] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return records.filter { $0.timestamp >= sevenDaysAgo }.reversed()
    }
    private var averageBPM: Int? {
        guard !recentRecords.isEmpty else { return nil }
        return recentRecords.reduce(0) { $0 + $1.bpm } / recentRecords.count
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week").font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundColor(AppColors.textPrimary)
                Spacer()
                if let avg = averageBPM {
                    Text("Avg: \(avg) BPM").font(.system(size: 14, weight: .medium, design: .rounded)).foregroundColor(AppColors.textSecondary)
                }
            }
            if recentRecords.count >= 2 {
                Chart(Array(recentRecords)) { record in
                    LineMark(x: .value("Time", record.timestamp), y: .value("BPM", record.bpm))
                        .foregroundStyle(AppColors.primaryRed.gradient).interpolationMethod(.catmullRom)
                    AreaMark(x: .value("Time", record.timestamp), y: .value("BPM", record.bpm))
                        .foregroundStyle(LinearGradient(colors: [AppColors.primaryRed.opacity(0.3), AppColors.primaryRed.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)
                }
                .chartXAxis(.hidden).chartYAxis(.hidden).chartYScale(domain: .automatic(includesZero: false)).frame(height: 80)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4))
    }
}
