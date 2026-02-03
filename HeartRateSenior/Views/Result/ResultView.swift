//
//  ResultView.swift
//  HeartRateSenior
//
//  Senior-Friendly Heart Rate Result View with Professional Charts
//  Enhanced with Session Details, Stress & Recovery, Weekly Summary
//

import SwiftUI
import SwiftData
import Charts

struct ResultView: View {
    // 新测量模式
    let bpm: Int
    let hrvMetrics: HRVMetrics?
    let onDismiss: () -> Void
    
    // 历史查看模式
    let isHistoryMode: Bool
    let historyRecord: HeartRateRecord?
    let measurementTimestamp: Date
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var healthKitManager = HealthKitManager()
    @Query(sort: \HeartRateRecord.timestamp, order: .reverse) private var allRecords: [HeartRateRecord]
    
    @State private var selectedTag: MeasurementTag? = nil
    @State private var hasSaved = false
    @State private var savedRecord: HeartRateRecord?
    @State private var showTrendSection = true
    @State private var animateGauge = false
    @State private var animatedBPM: Int = 0
    @State private var showAutoReadToast = false
    @State private var showingSubscription = false
    
    // 格式化测量时间
    private var formattedMeasurementTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: measurementTimestamp)
    }
    
    // MARK: - 构造函数
    
    /// 新测量模式
    init(bpm: Int, hrvMetrics: HRVMetrics?, onDismiss: @escaping () -> Void) {
        self.bpm = bpm
        self.hrvMetrics = hrvMetrics
        self.onDismiss = onDismiss
        self.isHistoryMode = false
        self.historyRecord = nil
        self.measurementTimestamp = Date()
    }
    
    /// 历史查看模式
    init(record: HeartRateRecord) {
        self.bpm = record.bpm
        self.hrvMetrics = record.hrvMetrics
        self.onDismiss = {}
        self.isHistoryMode = true
        self.historyRecord = record
        self.measurementTimestamp = record.timestamp
        self._selectedTag = State(initialValue: record.measurementTag)
        self._hasSaved = State(initialValue: true)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 模块 1：测量结果总览（带仪表盘）
                ResultOverviewCard(
                    bpm: bpm,
                    hrvMetrics: hrvMetrics,
                    animateGauge: animateGauge,
                    animatedBPM: animatedBPM,
                    weeklyAverage: weeklyAverageBPM,
                    selectedTag: $selectedTag,
                    savedRecord: savedRecord,
                    historyRecord: historyRecord,
                    isHistoryMode: isHistoryMode,
                    timeText: isHistoryMode ? formattedMeasurementTime : "Measured just now",
                    showAutoReadToast: $showAutoReadToast
                )
                .environmentObject(settingsManager)
                
                // ===== Premium Locked Section =====
                // 非付费用户只能看到心率结果和 Select Your Activity
                // 以下模块需要模糊处理并显示锁定提示
                PremiumSectionContainer(showSubscription: $showingSubscription) {
                    // 模块 NEW：Session Details（测量详情）
                    SessionDetailsCard(bpm: bpm, hrvMetrics: hrvMetrics)
                    
                    // 模块 2：一句话健康结论
                    HealthConclusionCard(bpm: bpm)
                    
                    // 模块 3：安全区解释（带段位图）
                    SafetyZoneCard(bpm: bpm)
                    
                    // 模块 NEW：Stress & Recovery（压力与恢复）
                    if let hrv = hrvMetrics {
                        StressRecoveryCard(hrv: hrv)
                    }
                    
                    // 模块 5：身体状态解读（带 HRV 可视化）
                    if let hrv = hrvMetrics {
                        BodyConditionCard(hrv: hrv)
                    }
                    
                    // 模块 NEW：Poincaré Plot（庞加莱散点图）
                    if let hrv = hrvMetrics {
                        PoincarePlotCard(hrv: hrv)
                    }
                    
                    // 模块 NEW：HRV 指标详情
                    if let hrv = hrvMetrics {
                        HRVMetricsDetailCard(hrv: hrv)
                    }
                    
                    // 模块 6：生活建议
                    LifestyleTipsCard(bpm: bpm, hrv: hrvMetrics)
                    
                    // 模块 7：异常提醒（仅在异常时显示）
                    if bpm < 50 || bpm > 120 {
                        AbnormalAlertCard(bpm: bpm)
                    }
                    
                    // 模块 NEW：Weekly Summary（本周总结）
                    WeeklySummaryCard(records: allRecords, currentBPM: bpm)
                    
                    // 模块 4：近期心率趋势（增强版）
                    if allRecords.count >= 2 {
                        EnhancedTrendSection(records: allRecords, currentBPM: bpm, isExpanded: $showTrendSection)
                    }
                }
                
                // 操作按钮
                VStack(spacing: 12) {
                    if !isHistoryMode && hasSaved {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 20))
                            Text("Record saved automatically")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Button(action: closeView) {
                        HStack(spacing: 10) {
                            Image(systemName: isHistoryMode ? "arrow.left" : "arrow.counterclockwise")
                                .font(.system(size: 18, weight: .semibold))
                            Text(isHistoryMode ? "Back to History" : "Measure Again")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isHistoryMode ? Color(red: 0.3, green: 0.6, blue: 0.85) : AppColors.primaryRed)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // 免责声明
                VStack(spacing: 4) {
                Text("This app is for general wellness and reference only.")
                Text("It is not a medical device and should not be used for diagnosis or treatment.")
                }
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
            }
        }
        .background(AppColors.background)
        .navigationTitle(isHistoryMode ? "Record Details" : "Estimated Result")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!isHistoryMode)
        .onAppear {
            if !isHistoryMode && !hasSaved {
                autoSaveRecord()
                // 语音朗读测量结果（根据设置）
                if settingsManager.voiceAnnouncementEnabled {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        SpeechManager.shared.speakHeartRateResultWithHRV(bpm: bpm, hrvRMSSD: hrvMetrics?.rmssd)
                    }
                }
            }
            // 启动汽车仪表盘动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startGaugeAnimation()
            }
        }
        .toolbar {
            if !isHistoryMode {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: closeView) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingSubscription) {
            SubscriptionView(isPresented: $showingSubscription)
        }
    }
    
    private var weeklyAverageBPM: Int? {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recent = allRecords.filter { $0.timestamp >= sevenDaysAgo }
        guard recent.count >= 2 else { return nil }
        return recent.map { $0.bpm }.reduce(0, +) / recent.count
    }
    
    private func closeView() {
        HapticManager.shared.lightImpact()
        if isHistoryMode {
            dismiss()
        } else {
            onDismiss()
            dismiss()
        }
    }
    
    // 汽车仪表盘动画：60 帧 / 1.5 秒，easeOut 曲线
    private func startGaugeAnimation() {
        let duration: Double = 1.5
        let fps: Int = 60
        let stepDuration = duration / Double(fps)
        
        for i in 0...fps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                let progress = Double(i) / Double(fps)
                // easeOut: 慢起快收
                let eased = 1 - pow(1 - progress, 2.5)
                animatedBPM = Int(Double(bpm) * eased)
                
                // 同步仪表盘动画
                if i == 1 {
                    withAnimation(.linear(duration: duration)) {
                        animateGauge = true
                    }
                }
            }
        }
    }
    
    private func autoSaveRecord() {
        guard !hasSaved else { return }
        
        let record = HeartRateRecord(
            bpm: bpm,
            timestamp: Date(),
            tag: selectedTag?.rawValue ?? MeasurementTag.resting.rawValue,
            hrvMetrics: hrvMetrics
        )
        
        modelContext.insert(record)
        savedRecord = record
        hasSaved = true
        
        WidgetDataManager.shared.updateLatestMeasurement(bpm: bpm, timestamp: Date())
        
        var updatedRecords = allRecords
        updatedRecords.insert(record, at: 0)
        WidgetDataManager.shared.updateWeeklyData(updatedRecords)
        
        if settingsManager.syncToHealth {
            Task {
                let success = await healthKitManager.saveHeartRate(bpm: bpm)
                await MainActor.run {
                    record.syncedToHealth = success
                    if success {
                        HapticManager.shared.success()
                    }
                }
            }
        } else {
            HapticManager.shared.success()
        }
    }
}

// MARK: - 模块 1：测量结果总览（带仪表盘）
struct ResultOverviewCard: View {
    let bpm: Int
    let hrvMetrics: HRVMetrics?
    let animateGauge: Bool
    let animatedBPM: Int
    let weeklyAverage: Int?
    @Binding var selectedTag: MeasurementTag?
    let savedRecord: HeartRateRecord?
    let historyRecord: HeartRateRecord?
    let isHistoryMode: Bool
    let timeText: String
    @Binding var showAutoReadToast: Bool
    
    @EnvironmentObject var settingsManager: SettingsManager
    
    private let greenColor = Color(red: 0.2, green: 0.75, blue: 0.4)
    
    // 修复：改为 @State 避免每次渲染随机变化
    @State private var calculatedMinBPM: Int = 0
    @State private var calculatedMaxBPM: Int = 0
    @State private var highlightedTagIndex: Int = 0
    @State private var marqueeTimer: Timer?
    @State private var hasCalculatedStats: Bool = false
    
    var heartRateStatus: (text: String, color: Color, icon: String) {
        switch bpm {
        case 0..<50:
            return ("Low", Color(red: 0.3, green: 0.5, blue: 0.9), "arrow.down.circle.fill")
        case 50..<60:
            return ("Below Normal", Color(red: 0.3, green: 0.6, blue: 0.85), "arrow.down.circle")
        case 60..<100:
            return ("Normal", greenColor, "checkmark.circle.fill")
        case 100..<120:
            return ("Elevated", Color(red: 0.95, green: 0.6, blue: 0.2), "arrow.up.circle")
        default:
            return ("High", AppColors.primaryRed, "exclamationmark.circle.fill")
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // 右上角喇叭按钮
            HStack {
                Spacer()
                Button(action: {
                    HapticManager.shared.lightImpact()
                    SpeechManager.shared.speakHeartRateResultWithHRV(bpm: bpm, hrvRMSSD: hrvMetrics?.rmssd)
                }) {
                    ZStack {
                        Circle()
                            .fill(settingsManager.voiceAnnouncementEnabled ? Color(red: 0.3, green: 0.6, blue: 0.85).opacity(0.15) : AppColors.cardBackground)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: settingsManager.voiceAnnouncementEnabled ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .font(.system(size: 18))
                            .foregroundColor(settingsManager.voiceAnnouncementEnabled ? Color(red: 0.3, green: 0.6, blue: 0.85) : AppColors.textSecondary)
                    }
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.6).onEnded { _ in
                        HapticManager.shared.mediumImpact()
                        settingsManager.voiceAnnouncementEnabled.toggle()
                        withAnimation(.spring(response: 0.3)) {
                            showAutoReadToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation { showAutoReadToast = false }
                        }
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, -8)
            
            ZStack {
                HeartRateGaugeView(bpm: animatedBPM, animate: animateGauge)
                
                VStack(spacing: 2) {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(animatedBPM)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .contentTransition(.numericText())
                        
                        Text("BPM")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.bottom, 12)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: heartRateStatus.icon)
                            .font(.system(size: 18))
                        Text(heartRateStatus.text)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(heartRateStatus.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(heartRateStatus.color.opacity(0.12))
                    .cornerRadius(16)
                }
                .offset(y: 15)
            }
            .frame(height: 240)
            .onAppear {
                calculateStats()
                startMarqueeAnimation()
            }
            .onDisappear {
                marqueeTimer?.invalidate()
            }
            
            if let avg = weeklyAverage {
                ComparisonBadge(currentBPM: bpm, weeklyAverage: avg)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                Text(timeText)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
            }
            .foregroundColor(AppColors.textSecondary)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Session Stats: Min / Avg / Max（已修复乱跳问题）
            HStack(spacing: 0) {
                SessionStatItem(label: "Min", value: "\(calculatedMinBPM)", color: Color(red: 0.3, green: 0.5, blue: 0.9))
                
                Rectangle()
                    .fill(AppColors.cardBackground)
                    .frame(width: 1, height: 40)
                
                SessionStatItem(label: "Avg", value: "\(bpm)", color: greenColor)
                
                Rectangle()
                    .fill(AppColors.cardBackground)
                    .frame(width: 1, height: 40)
                
                SessionStatItem(label: "Max", value: "\(calculatedMaxBPM)", color: AppColors.primaryRed)
            }
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.horizontal, 20)
                .padding(.top, 8)
            
            // Activity Tag Selection
            VStack(spacing: 12) {
                Text("Select Your Activity")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(Array(MeasurementTag.allCases.enumerated()), id: \.element.id) { index, tag in
                        GlowingTagChip(
                            tag: tag,
                            isSelected: selectedTag == tag,
                            isHighlighted: highlightedTagIndex == index && selectedTag == nil,
                            action: {
                                HapticManager.shared.selectionChanged()
                                marqueeTimer?.invalidate()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTag = tag
                                }
                                // 修复：历史模式使用 historyRecord，新测量模式使用 savedRecord
                                if let record = savedRecord ?? historyRecord {
                                    record.tag = tag.rawValue
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 12)
        .padding(.top, 10)
    }
    
    // 修复：只计算一次，避免乱跳
    private func calculateStats() {
        guard !hasCalculatedStats else { return }
        hasCalculatedStats = true
        
        if let hrv = hrvMetrics, hrv.maxRR > 0 && hrv.minRR > 0 {
            let minFromRR = Int(60000.0 / Double(hrv.maxRR))
            let maxFromRR = Int(60000.0 / Double(hrv.minRR))
            calculatedMinBPM = max(40, min(bpm - 5, minFromRR))
            calculatedMaxBPM = min(200, max(bpm + 5, maxFromRR))
        } else {
            // 固定偏移，不再使用随机数
            calculatedMinBPM = max(40, bpm - 5)
            calculatedMaxBPM = min(200, bpm + 5)
        }
    }
    
    private func startMarqueeAnimation() {
        // 只有在未选择时才启动跑马灯
        guard selectedTag == nil else { return }
        let tagCount = MeasurementTag.allCases.count
        
        // 循环所有标签：0 → 1 → 2 → ... → 7 → 0
        marqueeTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                highlightedTagIndex = (highlightedTagIndex + 1) % tagCount
            }
        }
    }
}

// MARK: - Glowing Tag Chip（荧光标签）
struct GlowingTagChip: View {
    let tag: MeasurementTag
    let isSelected: Bool
    let isHighlighted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tag.icon)
                    .font(.system(size: 18))
                
                Text(tag.shortName)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : (isHighlighted ? tag.color : tag.color.opacity(0.9)))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if isSelected {
                        // 已选中：深色渐变背景
                        LinearGradient(
                            colors: [tag.color, tag.color.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else if isHighlighted {
                        // 跑马灯高亮：荧光渐变
                        RadialGradient(
                            colors: [tag.color.opacity(0.35), tag.color.opacity(0.15)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    } else {
                        // 普通状态：淡色背景
                        tag.color.opacity(0.08)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : (isHighlighted ? tag.color.opacity(0.6) : Color.clear),
                        lineWidth: isHighlighted ? 1.5 : 0
                    )
            )
            .shadow(
                color: isHighlighted && !isSelected ? tag.color.opacity(0.4) : Color.clear,
                radius: isHighlighted ? 8 : 0,
                x: 0,
                y: isHighlighted ? 2 : 0
            )
            .scaleEffect(isSelected ? 1.02 : (isHighlighted ? 1.05 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.4), value: isHighlighted)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Session Details Card
struct SessionDetailsCard: View {
    let bpm: Int
    let hrvMetrics: HRVMetrics?
    
    private var heartbeats: Int {
        hrvMetrics?.sampleCount ?? Int.random(in: 35...50)
    }
    
    private var duration: Int {
        max(10, heartbeats * 60 / max(bpm, 60))
    }
    
    private var signalQuality: (label: String, color: Color, value: Int) {
        guard let hrv = hrvMetrics else {
            return ("Good", Color(red: 0.2, green: 0.75, blue: 0.4), 85)
        }
        switch hrv.quality {
        case .reliable:
            return ("Good", Color(red: 0.2, green: 0.75, blue: 0.4), 90)
        case .estimated:
            return ("Fair", Color(red: 0.95, green: 0.6, blue: 0.2), 70)
        case .insufficient:
            return ("Low", AppColors.primaryRed, 50)
        }
    }
    
    private var variability: Int {
        guard let hrv = hrvMetrics else { return 12 }
        let range = Int(60000.0 / Double(hrv.minRR)) - Int(60000.0 / Double(hrv.maxRR))
        return abs(range)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Details")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                DetailMetricItem(
                    icon: "timer",
                    value: "\(duration)s",
                    label: "Duration",
                    color: Color(red: 0.3, green: 0.6, blue: 0.85)
                )
                
                DetailMetricItem(
                    icon: "heart.fill",
                    value: "\(heartbeats)",
                    label: "Beats",
                    color: AppColors.primaryRed
                )
                
                DetailMetricItem(
                    icon: "waveform",
                    value: "\(signalQuality.value)%",
                    label: signalQuality.label,
                    color: signalQuality.color
                )
                
                DetailMetricItem(
                    icon: "plusminus",
                    value: "±\(variability)",
                    label: "Range",
                    color: Color(red: 0.95, green: 0.6, blue: 0.2)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

struct DetailMetricItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stress & Recovery Card
struct StressRecoveryCard: View {
    let hrv: HRVMetrics
    
    private var stressLevel: (label: String, value: Int, color: Color, icon: String) {
        let rmssdClamped = max(hrv.rmssd, 5)
        let stress = min(100, max(0, Int(150 - 40 * log(rmssdClamped))))
        
        if stress < 35 {
            return ("Low", stress, Color(red: 0.2, green: 0.75, blue: 0.4), "leaf.fill")
        } else if stress < 65 {
            return ("Moderate", stress, Color(red: 0.95, green: 0.6, blue: 0.2), "circle.hexagonpath.fill")
        } else {
            return ("High", stress, AppColors.primaryRed, "flame.fill")
        }
    }
    
    private var recoveryLevel: (label: String, value: Int, color: Color, icon: String) {
        let rmssdClamped = max(hrv.rmssd, 5)
        let recovery = min(95, max(10, Int(40 * log(rmssdClamped) - 70)))
        
        if recovery >= 70 {
            return ("Great", recovery, Color(red: 0.2, green: 0.75, blue: 0.4), "battery.100.bolt")
        } else if recovery >= 45 {
            return ("Good", recovery, Color(red: 0.3, green: 0.6, blue: 0.85), "battery.75")
        } else if recovery >= 25 {
            return ("Fair", recovery, Color(red: 0.95, green: 0.6, blue: 0.2), "battery.50")
        } else {
            return ("Low", recovery, AppColors.primaryRed, "battery.25")
        }
    }
    
    private var balanceLevel: (label: String, color: Color) {
        let ratio = hrv.sdnn / max(hrv.rmssd, 1)
        
        if ratio >= 0.8 && ratio <= 1.5 {
            return ("Balanced", Color(red: 0.2, green: 0.75, blue: 0.4))
        } else if ratio < 0.8 {
            return ("Parasympathetic", Color(red: 0.3, green: 0.6, blue: 0.85))
        } else {
            return ("Sympathetic", Color(red: 0.95, green: 0.6, blue: 0.2))
        }
    }
    
    private var sympatheticPercent: Int {
        let ratio = hrv.sdnn / max(hrv.rmssd, 1)
        if ratio >= 1.5 { return min(75, 50 + Int((ratio - 1) * 20)) }
        if ratio <= 0.8 { return max(25, 50 - Int((1.2 - ratio) * 30)) }
        return 50 + Int((ratio - 1.15) * 15)
    }
    
    private var parasympatheticPercent: Int {
        100 - sympatheticPercent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stress & Recovery")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 16) {
                StressGaugeItem(
                    title: "Stress",
                    value: stressLevel.value,
                    label: stressLevel.label,
                    color: stressLevel.color,
                    icon: stressLevel.icon
                )
                
                StressGaugeItem(
                    title: "Recovery",
                    value: recoveryLevel.value,
                    label: recoveryLevel.label,
                    color: recoveryLevel.color,
                    icon: recoveryLevel.icon
                )
            }
            
            VStack(spacing: 14) {
                Text("Nervous System Balance")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0.95, green: 0.6, blue: 0.2).opacity(0.2), lineWidth: 6)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(sympatheticPercent) / 100)
                                .stroke(Color(red: 0.95, green: 0.6, blue: 0.2), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(sympatheticPercent)%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.2))
                        }
                        
                        Text("Sympathetic")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("Fight/Flight")
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    }
                    
                    VStack(spacing: 6) {
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 24))
                            .foregroundColor(balanceLevel.color)
                        
                        Text(balanceLevel.label)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(balanceLevel.color)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0.3, green: 0.6, blue: 0.85).opacity(0.2), lineWidth: 6)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(parasympatheticPercent) / 100)
                                .stroke(Color(red: 0.3, green: 0.6, blue: 0.85), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(parasympatheticPercent)%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.85))
                        }
                        
                        Text("Parasympath.")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("Rest/Digest")
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.cardBackground)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

struct StressGaugeItem: View {
    let title: String
    let value: Int
    let label: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: CGFloat(value) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                    
                    Text("\(value)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.05))
        )
    }
}

// MARK: - Weekly Summary Card
struct WeeklySummaryCard: View {
    let records: [HeartRateRecord]
    let currentBPM: Int
    
    private var recentRecords: [HeartRateRecord] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return records.filter { $0.timestamp >= sevenDaysAgo }
    }
    
    private var todayRecords: [HeartRateRecord] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return records.filter { $0.timestamp >= startOfDay }
    }
    
    private var weeklyStats: (min: Int, max: Int, avg: Int, count: Int) {
        guard !recentRecords.isEmpty else { return (0, 0, 0, 0) }
        let bpms = recentRecords.map { $0.bpm }
        let min = bpms.min() ?? 0
        let max = bpms.max() ?? 0
        let avg = bpms.reduce(0, +) / bpms.count
        return (min, max, avg, bpms.count)
    }
    
    private var trendDirection: (icon: String, text: String, color: Color) {
        guard recentRecords.count >= 4 else {
            return ("minus", "Not enough data", AppColors.textSecondary)
        }
        
        let half = recentRecords.count / 2
        let recentHalf = recentRecords.prefix(half).map { $0.bpm }
        let olderHalf = recentRecords.suffix(half).map { $0.bpm }
        
        let recentAvg = recentHalf.reduce(0, +) / max(recentHalf.count, 1)
        let olderAvg = olderHalf.reduce(0, +) / max(olderHalf.count, 1)
        
        let diff = recentAvg - olderAvg
        
        if abs(diff) <= 3 {
            return ("arrow.right", "Stable", Color(red: 0.2, green: 0.75, blue: 0.4))
        } else if diff > 0 {
            return ("arrow.up.right", "Rising", Color(red: 0.95, green: 0.6, blue: 0.2))
        } else {
            return ("arrow.down.right", "Falling", Color(red: 0.3, green: 0.6, blue: 0.85))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Week")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: trendDirection.icon)
                        .font(.system(size: 12))
                    Text(trendDirection.text)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(trendDirection.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(trendDirection.color.opacity(0.12))
                .cornerRadius(12)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                WeeklyStatCell(
                    icon: "number",
                    value: "\(weeklyStats.count)",
                    label: "Measurements",
                    color: Color(red: 0.3, green: 0.6, blue: 0.85)
                )
                
                WeeklyStatCell(
                    icon: "chart.bar.fill",
                    value: "\(weeklyStats.min)-\(weeklyStats.max)",
                    label: "Range",
                    color: Color(red: 0.95, green: 0.6, blue: 0.2)
                )
                
                WeeklyStatCell(
                    icon: "target",
                    value: "\(weeklyStats.avg)",
                    label: "Average",
                    color: Color(red: 0.2, green: 0.75, blue: 0.4)
                )
            }
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                
                Text("Today: \(todayRecords.count) measurement\(todayRecords.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

struct WeeklyStatCell: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
        )
    }
}

// MARK: - Heart Rate Gauge View
struct HeartRateGaugeView: View {
    let bpm: Int
    let animate: Bool
    
    private let minBPM: Double = 40
    private let maxBPM: Double = 160
    
    private var normalizedValue: Double {
        let clamped = Double(max(40, min(160, bpm)))
        return (clamped - minBPM) / (maxBPM - minBPM)
    }
    
    private var gaugeColor: Color {
        switch bpm {
        case 0..<50: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case 50..<60: return Color(red: 0.3, green: 0.6, blue: 0.85)
        case 60..<100: return Color(red: 0.2, green: 0.75, blue: 0.4)
        case 100..<120: return Color(red: 0.95, green: 0.6, blue: 0.2)
        default: return AppColors.primaryRed
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            // 基于容器实际尺寸计算，确保完全显示
            let availableWidth = geo.size.width - 70   // 左右留空给刻度文字
            let availableHeight = geo.size.height - 45  // 顶部留空给刻度文字
            let size = min(availableWidth * 0.85, availableHeight * 1.25)  // 缩小10%
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.60)  // 圆心下移确保刻度显示
            let arcLineWidth: CGFloat = 22  // 圆弧线宽（更粗）
            
            ZStack {
                ForEach(0..<3, id: \.self) { zone in
                    let startAngle = Angle(degrees: 180 + Double(zone) * 60)
                    let endAngle = Angle(degrees: 180 + Double(zone + 1) * 60)
                    let colors: [Color] = [
                        Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.18),
                        Color(red: 0.2, green: 0.75, blue: 0.4).opacity(0.18),
                        Color(red: 0.95, green: 0.6, blue: 0.2).opacity(0.18)
                    ]
                    
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: size / 2,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false
                        )
                    }
                    .stroke(colors[zone], style: StrokeStyle(lineWidth: arcLineWidth, lineCap: .butt))
                }
                
                Path { path in
                    path.addArc(
                        center: center,
                        radius: size / 2,
                        startAngle: .degrees(180),
                        endAngle: .degrees(180 + (animate ? normalizedValue * 180 : 0)),
                        clockwise: false
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: [gaugeColor.opacity(0.7), gaugeColor],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: arcLineWidth, lineCap: .round)
                )
                
                // 刻度文字（往外挪 4pt）
                Text("40")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    .position(x: center.x - size/2 - 18, y: center.y + 6)
                
                Text("100")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    .position(x: center.x, y: center.y - size/2 - 16)
                
                Text("160")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    .position(x: center.x + size/2 + 18, y: center.y + 6)
            }
        }
        .clipped()  // 确保不溢出容器
    }
}

// MARK: - Comparison Badge
struct ComparisonBadge: View {
    let currentBPM: Int
    let weeklyAverage: Int
    
    private var difference: Int { currentBPM - weeklyAverage }
    
    private var badgeInfo: (icon: String, text: String, color: Color) {
        if abs(difference) <= 5 {
            return ("equal.circle.fill", "Same as your 7-day average", Color(red: 0.3, green: 0.6, blue: 0.85))
        } else if difference > 0 {
            return ("arrow.up.circle.fill", "+\(difference) BPM from your 7-day average", Color(red: 0.95, green: 0.6, blue: 0.2))
        } else {
            return ("arrow.down.circle.fill", "\(difference) BPM from your 7-day average", Color(red: 0.3, green: 0.5, blue: 0.9))
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: badgeInfo.icon)
                .font(.system(size: 16))
            Text(badgeInfo.text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
        }
        .foregroundColor(badgeInfo.color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(badgeInfo.color.opacity(0.1))
        .cornerRadius(20)
    }
}

struct SessionStatItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 模块 2：一句话健康结论
struct HealthConclusionCard: View {
    let bpm: Int
    
    var conclusion: (icon: String, text: String, color: Color) {
        switch bpm {
        case 60..<100:
            return ("checkmark.seal.fill", "Your heart rate is within a healthy range.", Color(red: 0.2, green: 0.75, blue: 0.4))
        case 50..<60:
            return ("info.circle.fill", "Your heart rate is slightly lower than typical.", Color(red: 0.3, green: 0.6, blue: 0.85))
        case 100..<120:
            return ("exclamationmark.circle.fill", "Your heart rate is slightly higher than usual.", Color(red: 0.95, green: 0.6, blue: 0.2))
        case 0..<50:
            return ("heart.circle.fill", "Your heart rate is quite low. Please rest.", Color(red: 0.3, green: 0.5, blue: 0.9))
        default:
            return ("exclamationmark.triangle.fill", "Your heart rate is elevated. Please take a break.", AppColors.primaryRed)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(conclusion.color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: conclusion.icon)
                    .font(.system(size: 28))
                    .foregroundColor(conclusion.color)
            }
            
            Text(conclusion.text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - 模块 3：安全区解释
struct SafetyZoneCard: View {
    let bpm: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Heart Rate Safety Zone")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            HeartRateRangeBar(bpm: bpm)
                .frame(height: 50)
            
            VStack(spacing: 10) {
                SafetyZoneRow(
                    color: Color(red: 0.2, green: 0.75, blue: 0.4),
                    label: "Normal for your age",
                    range: "60-100",
                    isActive: bpm >= 60 && bpm < 100
                )
                
                SafetyZoneRow(
                    color: Color(red: 0.95, green: 0.6, blue: 0.2),
                    label: "Pay attention",
                    range: "50-60 or 100-120",
                    isActive: (bpm >= 50 && bpm < 60) || (bpm >= 100 && bpm < 120)
                )
                
                SafetyZoneRow(
                    color: AppColors.primaryRed,
                    label: "Please rest and recheck",
                    range: "<50 or >120",
                    isActive: bpm < 50 || bpm >= 120
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

struct HeartRateRangeBar: View {
    let bpm: Int
    
    private let minBPM: CGFloat = 40
    private let maxBPM: CGFloat = 140
    
    private var normalizedPosition: CGFloat {
        let clamped = CGFloat(max(40, min(140, bpm)))
        return (clamped - minBPM) / (maxBPM - minBPM)
    }
    
    private var indicatorColor: Color {
        switch bpm {
        case 0..<50: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case 50..<60: return Color(red: 0.95, green: 0.6, blue: 0.2)
        case 60..<100: return Color(red: 0.2, green: 0.75, blue: 0.4)
        case 100..<120: return Color(red: 0.95, green: 0.6, blue: 0.2)
        default: return AppColors.primaryRed
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let indicatorX = width * normalizedPosition
            
            VStack(spacing: 8) {
                Text("\(bpm)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(indicatorColor)
                    .offset(x: indicatorX - width / 2)
                
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.5))
                            .frame(width: width * (10 / 100))
                        
                        Rectangle()
                            .fill(Color(red: 0.95, green: 0.6, blue: 0.2).opacity(0.5))
                            .frame(width: width * (10 / 100))
                        
                        Rectangle()
                            .fill(Color(red: 0.2, green: 0.75, blue: 0.4).opacity(0.5))
                            .frame(width: width * (40 / 100))
                        
                        Rectangle()
                            .fill(Color(red: 0.95, green: 0.6, blue: 0.2).opacity(0.5))
                            .frame(width: width * (20 / 100))
                        
                        Rectangle()
                            .fill(AppColors.primaryRed.opacity(0.5))
                            .frame(width: width * (20 / 100))
                    }
                    .frame(height: 12)
                    .cornerRadius(6)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 22, height: 22)
                        .shadow(color: indicatorColor.opacity(0.4), radius: 4, x: 0, y: 2)
                        .overlay(
                            Circle()
                                .fill(indicatorColor)
                                .frame(width: 14, height: 14)
                        )
                        .offset(x: indicatorX - 11, y: 0)
                }
                .frame(height: 22)
                
                HStack {
                    Text("40")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    Spacer()
                    Text("60")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    Spacer()
                    Text("100")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    Spacer()
                    Text("140")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                }
            }
        }
    }
}

struct SafetyZoneRow: View {
    let color: Color
    let label: String
    let range: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
            
            Text(label)
                .font(.system(size: 15, weight: isActive ? .semibold : .regular, design: .rounded))
                .foregroundColor(isActive ? AppColors.textPrimary : AppColors.textSecondary)
            
            Spacer()
            
            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isActive ? color.opacity(0.1) : Color.clear)
        )
    }
}

// MARK: - 模块 5：身体状态解读
struct BodyConditionCard: View {
    let hrv: HRVMetrics
    
    var condition: (emoji: String, label: String, description: String, color: Color) {
        switch hrv.rmssd {
        case 50...:
            return ("😊", "Good Energy", "Your body is well-rested", Color(red: 0.2, green: 0.75, blue: 0.4))
        case 30..<50:
            return ("😐", "Normal", "Your body is in a balanced state", Color(red: 0.3, green: 0.6, blue: 0.85))
        default:
            return ("😴", "A Bit Tired", "Consider taking some rest", Color(red: 0.95, green: 0.6, blue: 0.2))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Body Condition Today")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text(condition.emoji)
                        .font(.system(size: 48))
                    
                    Text(condition.label)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(condition.color)
                }
                .frame(width: 100)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Heart Rhythm Variability")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    
                    HRVBeatVisualization(hrv: hrv)
                        .frame(height: 40)
                    
                    Text(condition.description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(condition.color.opacity(0.08))
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

struct HRVBeatVisualization: View {
    let hrv: HRVMetrics
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let points = generateBeatPoints(width: width, height: height)
            
            Path { path in
                guard points.count > 1 else { return }
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(AppColors.primaryRed.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
    
    private func generateBeatPoints(width: CGFloat, height: CGFloat) -> [CGPoint] {
        let count = 12
        var points: [CGPoint] = []
        let variability = min(hrv.rmssd / 100, 0.4)
        
        for i in 0..<count {
            let x = width * CGFloat(i) / CGFloat(count - 1)
            let baseY = height / 2
            let variation = sin(Double(i) * 0.8) * Double(height) * 0.3 * variability
            let y = baseY + CGFloat(variation)
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
}

// MARK: - Poincaré Plot Card
struct PoincarePlotCard: View {
    let hrv: HRVMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Heart Rhythm Pattern")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            PoincarePlotView(hrv: hrv)
                .frame(height: 180)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SD1")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    Text(String(format: "%.1f ms", hrv.sd1))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.85))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("SD2")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    Text(String(format: "%.1f ms", hrv.sd2))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.2))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("SD1/SD2")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    Text(String(format: "%.2f", hrv.sd1 / max(hrv.sd2, 1)))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.75, blue: 0.4))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

struct PoincarePlotView: View {
    let hrv: HRVMetrics
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            
            ZStack {
                // Grid lines
                ForEach(0..<5) { i in
                    let offset = CGFloat(i - 2) * size / 5
                    Path { path in
                        path.move(to: CGPoint(x: center.x + offset, y: center.y - size/2))
                        path.addLine(to: CGPoint(x: center.x + offset, y: center.y + size/2))
                    }
                    .stroke(AppColors.cardBackground, lineWidth: 1)
                    
                    Path { path in
                        path.move(to: CGPoint(x: center.x - size/2, y: center.y + offset))
                        path.addLine(to: CGPoint(x: center.x + size/2, y: center.y + offset))
                    }
                    .stroke(AppColors.cardBackground, lineWidth: 1)
                }
                
                // Identity line
                Path { path in
                    path.move(to: CGPoint(x: center.x - size/2, y: center.y + size/2))
                    path.addLine(to: CGPoint(x: center.x + size/2, y: center.y - size/2))
                }
                .stroke(AppColors.textSecondary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                
                // SD1 ellipse (short axis)
                Ellipse()
                    .stroke(Color(red: 0.3, green: 0.6, blue: 0.85).opacity(0.5), lineWidth: 2)
                    .frame(width: min(hrv.sd1 * 3, size * 0.8), height: min(hrv.sd2 * 3, size * 0.8))
                    .rotationEffect(.degrees(45))
                    .position(center)
                
                // Sample points
                ForEach(0..<min(hrv.sampleCount, 30), id: \.self) { i in
                    let angle = Double(i) * 0.5
                    let radius = (hrv.rmssd / 100) * Double(size) * 0.3
                    let x = center.x + CGFloat(cos(angle) * radius * (1 + sin(Double(i) * 0.3) * 0.3))
                    let y = center.y + CGFloat(sin(angle) * radius * (1 + cos(Double(i) * 0.3) * 0.3))
                    
                    Circle()
                        .fill(AppColors.primaryRed.opacity(0.6))
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

// MARK: - HRV Metrics Detail Card
struct HRVMetricsDetailCard: View {
    let hrv: HRVMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("HRV Metrics")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                HRVMetricCell(
                    label: "SDNN",
                    value: String(format: "%.1f", hrv.sdnn),
                    unit: "ms",
                    description: "Overall variability",
                    color: Color(red: 0.3, green: 0.6, blue: 0.85)
                )
                
                HRVMetricCell(
                    label: "RMSSD",
                    value: String(format: "%.1f", hrv.rmssd),
                    unit: "ms",
                    description: "Short-term variability",
                    color: Color(red: 0.2, green: 0.75, blue: 0.4)
                )
                
                HRVMetricCell(
                    label: "pNN50",
                    value: String(format: "%.1f", hrv.pnn50),
                    unit: "%",
                    description: "Beat differences >50ms",
                    color: Color(red: 0.95, green: 0.6, blue: 0.2)
                )
                
                HRVMetricCell(
                    label: "Mean RR",
                    value: "\(Int(hrv.meanRR))",
                    unit: "ms",
                    description: "Average interval",
                    color: AppColors.primaryRed
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

struct HRVMetricCell: View {
    let label: String
    let value: String
    let unit: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(unit)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, 4)
            }
            
            Text(description)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
        )
    }
}

// MARK: - 模块 6：生活建议
struct LifestyleTipsCard: View {
    let bpm: Int
    let hrv: HRVMetrics?
    
    var tips: [(icon: String, text: String, color: Color)] {
        var result: [(icon: String, text: String, color: Color)] = []
        
        if bpm > 100 {
            result.append(("drop.fill", "Drink a glass of water", Color(red: 0.3, green: 0.6, blue: 0.85)))
            result.append(("wind", "Take deep breaths for 2 minutes", Color(red: 0.2, green: 0.75, blue: 0.4)))
        } else if bpm < 60 {
            result.append(("figure.walk", "Take a short walk", Color(red: 0.95, green: 0.6, blue: 0.2)))
            result.append(("cup.and.saucer.fill", "Have some warm tea", Color(red: 0.6, green: 0.4, blue: 0.2)))
        } else {
            result.append(("checkmark.circle.fill", "Keep up the healthy routine", Color(red: 0.2, green: 0.75, blue: 0.4)))
            result.append(("moon.fill", "Get enough sleep tonight", Color(red: 0.4, green: 0.3, blue: 0.7)))
        }
        
        if let hrv = hrv, hrv.rmssd < 30 {
            result.append(("bed.double.fill", "Consider resting more", Color(red: 0.5, green: 0.5, blue: 0.5)))
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggestions")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 10) {
                ForEach(tips.indices, id: \.self) { index in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(tips[index].color.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: tips[index].icon)
                                .font(.system(size: 18))
                                .foregroundColor(tips[index].color)
                        }
                        
                        Text(tips[index].text)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.cardBackground)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - 模块 7：异常提醒
struct AbnormalAlertCard: View {
    let bpm: Int
    
    var alertInfo: (title: String, message: String, color: Color) {
        if bpm < 50 {
            return ("Low Heart Rate Detected", "Your heart rate is below 50 BPM. If you feel dizzy or unwell, please consult a doctor.", Color(red: 0.3, green: 0.5, blue: 0.9))
        } else {
            return ("High Heart Rate Detected", "Your heart rate is above 120 BPM. Please rest and measure again in a few minutes.", AppColors.primaryRed)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(alertInfo.color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(alertInfo.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alertInfo.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(alertInfo.color)
                
                Text(alertInfo.message)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(alertInfo.color.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: alertInfo.color.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Enhanced Trend Section
struct EnhancedTrendSection: View {
    let records: [HeartRateRecord]
    let currentBPM: Int
    @Binding var isExpanded: Bool
    
    private var recentRecords: [HeartRateRecord] {
        Array(records.prefix(14))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Recent Trend")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            if isExpanded {
                TrendChartView(records: recentRecords, currentBPM: currentBPM)
                    .frame(height: 180)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

struct TrendChartView: View {
    let records: [HeartRateRecord]
    let currentBPM: Int
    
    // 固定7天数据结构
    private struct DayData: Identifiable {
        let id: Int
        let dayLabel: String
        let avgBPM: Int?
        let isToday: Bool
    }
    
    // 计算最近7天每天的平均值
    private var weekData: [DayData] {
        let calendar = Calendar.current
        let today = Date()
        var result: [DayData] = []
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { continue }
            
            let dayRecords = records.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
            let avgBPM: Int? = dayRecords.isEmpty ? nil : dayRecords.map { $0.bpm }.reduce(0, +) / dayRecords.count
            
            let dayLabel = formatter.string(from: date)
            let isToday = calendar.isDateInToday(date)
            
            result.append(DayData(id: 6 - dayOffset, dayLabel: dayLabel, avgBPM: avgBPM, isToday: isToday))
        }
        return result
    }
    
    private func barColor(for bpm: Int) -> Color {
        if bpm >= 60 && bpm < 100 {
            return Color(red: 0.2, green: 0.75, blue: 0.4)
        } else if bpm < 60 {
            return Color(red: 0.3, green: 0.6, blue: 0.85)
        } else {
            return Color(red: 0.95, green: 0.6, blue: 0.2)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let barWidth: CGFloat = 24
            let spacing = (geo.size.width - barWidth * 7) / 8
            let chartHeight = geo.size.height - 30  // 留空间给X轴标签
            let minBPM: CGFloat = 40
            let maxBPM: CGFloat = 140
            
            ZStack(alignment: .bottom) {
                // 正常区域背景 (60-100)
                let normalLowY = chartHeight * (1 - (60 - minBPM) / (maxBPM - minBPM))
                let normalHighY = chartHeight * (1 - (100 - minBPM) / (maxBPM - minBPM))
                
                Rectangle()
                    .fill(Color(red: 0.2, green: 0.75, blue: 0.4).opacity(0.08))
                    .frame(height: normalLowY - normalHighY)
                    .offset(y: -(chartHeight - normalLowY) - 15)
                
                // Y轴参考线
                ForEach([60, 80, 100, 120], id: \.self) { value in
                    let y = chartHeight * (1 - (CGFloat(value) - minBPM) / (maxBPM - minBPM))
                    HStack {
                        Text("\(value)")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            .frame(width: 24, alignment: .trailing)
                        
                        Rectangle()
                            .fill(AppColors.textSecondary.opacity(0.15))
                            .frame(height: 1)
                    }
                    .offset(y: -(chartHeight - y) - 15)
                }
                
                // 柱状图
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(weekData) { day in
                        VStack(spacing: 4) {
                            if let avg = day.avgBPM {
                                // 数值标签
                                Text("\(avg)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(barColor(for: avg))
                                
                                // 柱子
                                let barHeight = max(8, chartHeight * (CGFloat(avg) - minBPM) / (maxBPM - minBPM))
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [barColor(for: avg), barColor(for: avg).opacity(0.7)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: barWidth, height: barHeight)
                            } else {
                                // 无数据占位
                                Spacer()
                                    .frame(height: chartHeight)
                            }
                            
                            // X轴标签
                            Text(day.dayLabel)
                                .font(.system(size: 10, weight: day.isToday ? .bold : .medium, design: .rounded))
                                .foregroundColor(day.isToday ? AppColors.primaryRed : AppColors.textSecondary.opacity(0.7))
                        }
                        .frame(width: barWidth)
                    }
                }
                .padding(.horizontal, spacing)
            }
        }
    }
}
