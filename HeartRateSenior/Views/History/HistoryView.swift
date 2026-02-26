//
//  HistoryView.swift
//  HeartRateSenior
//
//  Enhanced history view with calendar heatmap, health score, and advanced analytics
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Time Range Enum
enum TimeRange: String, CaseIterable {
    case week = "7 Days"
    case month = "30 Days"
    case quarter = "90 Days"
    case all = "All"
    
    var days: Int? {
        switch self {
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        case .all: return nil
        }
    }
}

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HeartRateRecord.timestamp, order: .reverse) private var allRecords: [HeartRateRecord]
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedTag: MeasurementTag? = nil
    @State private var showingExportSheet = false
    @State private var showingSubscription = false
    @State private var showingDeleteConfirmation = false
    @State private var recordToDelete: HeartRateRecord?
    @State private var selectedRecord: HeartRateRecord?
    @State private var selectedCalendarDate: Date?
    
    // Filtered records based on time range and tag
    private var filteredRecords: [HeartRateRecord] {
        var records = allRecords
        
        if let days = selectedTimeRange.days {
            let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            records = records.filter { $0.timestamp >= startDate }
        }
        
        if let tag = selectedTag {
            records = records.filter { $0.measurementTag == tag }
        }
        
        return records
    }
    
    // Statistics
    private var statistics: (avg: Int, min: Int, max: Int, count: Int, trend: Int?) {
        guard !filteredRecords.isEmpty else { return (0, 0, 0, 0, nil) }
        
        let bpms = filteredRecords.map { $0.bpm }
        let avg = bpms.reduce(0, +) / bpms.count
        let min = bpms.min() ?? 0
        let max = bpms.max() ?? 0
        
        var trend: Int? = nil
        if let days = selectedTimeRange.days {
            let previousStart = Calendar.current.date(byAdding: .day, value: -days * 2, to: Date()) ?? Date()
            let previousEnd = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            let previousRecords = allRecords.filter { $0.timestamp >= previousStart && $0.timestamp < previousEnd }
            
            if !previousRecords.isEmpty {
                let previousAvg = previousRecords.map { $0.bpm }.reduce(0, +) / previousRecords.count
                trend = avg - previousAvg
            }
        }
        
        return (avg, min, max, filteredRecords.count, trend)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                PremiumSectionContainer(showSubscription: $showingSubscription) {
                    VStack(spacing: 16) {
                        // Time Range Selector
                        TimeRangeSelector(selectedRange: $selectedTimeRange)
                        
                        // 1. Health Score Card (NEW)
                        if filteredRecords.count >= 3 {
                            HealthScoreCard(records: filteredRecords)
                        }
                        
                        // 2. Calendar Heatmap (NEW)
                        CalendarHeatmapCard(
                            records: allRecords,
                            selectedDate: $selectedCalendarDate
                        )
                        
                        // 3. Period Conclusion Card (NEW)
                        if filteredRecords.count >= 3 {
                            PeriodConclusionCard(
                                records: filteredRecords,
                                timeRange: selectedTimeRange
                            )
                        }
                        
                        // 4. Daily Overview Chart (折线图+面积图)
                        DailyOverviewChartCard(records: filteredRecords, timeRange: selectedTimeRange)
                        
                        // 5. Week Comparison (NEW)
                        if selectedTimeRange == .week {
                            WeekComparisonCard(allRecords: allRecords)
                        }
                        
                        // 6. Heart Rate Zone Distribution (NEW)
                        if filteredRecords.count >= 3 {
                            HeartRateZoneCard(records: filteredRecords)
                        }
                        
                        // 7. Time of Day Analysis (NEW)
                        if filteredRecords.count >= 3 {
                            TimeOfDayAnalysisCard(records: filteredRecords)
                        }
                        
                        // 8. Activity Distribution (NEW)
                        if filteredRecords.count >= 3 {
                            ActivityDistributionCard(records: filteredRecords)
                        }
                        
                        // 9. Measurement Consistency (NEW)
                        MeasurementConsistencyCard(records: allRecords)
                        
                        // Records Section (含筛选器)
                        RecordsSectionView(
                            allRecords: allRecords,
                            selectedTag: $selectedTag,
                            onDelete: { record in
                                recordToDelete = record
                                showingDeleteConfirmation = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(AppColors.background)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !allRecords.isEmpty && subscriptionManager.isPremium {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            showingExportSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportView(records: Array(filteredRecords))
            }
            .fullScreenCover(isPresented: $showingSubscription) {
                SubscriptionView(isPresented: $showingSubscription)
            }
            .alert("Delete Record?", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let record = recordToDelete {
                        deleteRecord(record)
                    }
                }
                Button("Cancel", role: .cancel) {
                    recordToDelete = nil
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private func deleteRecord(_ record: HeartRateRecord) {
        HapticManager.shared.mediumImpact()
        modelContext.delete(record)
        recordToDelete = nil
    }
}

// MARK: - Health Score Card (NEW)
struct HealthScoreCard: View {
    let records: [HeartRateRecord]
    
    private var healthScore: Int {
        var score = 100
        let bpms = records.map { $0.bpm }
        let avg = bpms.reduce(0, +) / max(bpms.count, 1)
        
        // 心率范围评分
        if avg < 60 {
            score -= min(30, (60 - avg) * 2)
        } else if avg > 100 {
            score -= min(30, (avg - 100) * 2)
        }
        
        // 异常次数扣分
        let abnormalCount = bpms.filter { $0 < 50 || $0 > 120 }.count
        score -= abnormalCount * 5
        
        // 规律性加分
        let uniqueDays = Set(records.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
        if uniqueDays >= 5 { score += 5 }
        
        return max(0, min(100, score))
    }
    
    private var scoreInfo: (grade: String, color: Color, icon: String, message: String) {
        switch healthScore {
        case 90...100:
            return ("Excellent", Color(red: 0.2, green: 0.75, blue: 0.4), "star.fill", "Your heart health is excellent!")
        case 75..<90:
            return ("Good", Color(red: 0.3, green: 0.6, blue: 0.85), "hand.thumbsup.fill", "Your heart rate is generally healthy.")
        case 60..<75:
            return ("Fair", Color(red: 0.95, green: 0.6, blue: 0.2), "exclamationmark.circle.fill", "Consider monitoring more closely.")
        default:
            return ("Attention", AppColors.primaryRed, "heart.text.square.fill", "Please consult a healthcare provider.")
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Health Score")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: scoreInfo.icon)
                        .font(.system(size: 12))
                    Text(scoreInfo.grade)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(scoreInfo.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(scoreInfo.color.opacity(0.12))
                .cornerRadius(12)
            }
            
            HStack(spacing: 20) {
                // Score Ring
                ZStack {
                    Circle()
                        .stroke(scoreInfo.color.opacity(0.2), lineWidth: 12)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(healthScore) / 100)
                        .stroke(scoreInfo.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(healthScore)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(scoreInfo.color)
                        
                        Text("/ 100")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(scoreInfo.message)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Based on \(records.count) measurements")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                    
                    // Mini stats
                    HStack(spacing: 16) {
                        MiniStatItem(label: "Avg", value: "\(records.map { $0.bpm }.reduce(0, +) / max(records.count, 1))")
                        MiniStatItem(label: "Min", value: "\(records.map { $0.bpm }.min() ?? 0)")
                        MiniStatItem(label: "Max", value: "\(records.map { $0.bpm }.max() ?? 0)")
                    }
                }
                
                Spacer()
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

struct MiniStatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Calendar Heatmap Card (优化版)
struct CalendarHeatmapCard: View {
    let records: [HeartRateRecord]
    @Binding var selectedDate: Date?
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // 计算当月日历范围
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private var last35Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<35).compactMap { calendar.date(byAdding: .day, value: -34 + $0, to: today) }
    }
    
    private func recordsForDate(_ date: Date) -> [HeartRateRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        return records.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return AppColors.cardBackground
        case 1: return AppColors.primaryRed.opacity(0.3)
        case 2: return AppColors.primaryRed.opacity(0.5)
        case 3: return AppColors.primaryRed.opacity(0.7)
        default: return AppColors.primaryRed
        }
    }
    
    // 统计：总天数、有数据天数、总测量次数
    private var stats: (daysWithData: Int, totalMeasurements: Int) {
        var daysWithData = 0
        var totalMeasurements = 0
        for date in last35Days {
            let count = recordsForDate(date).count
            if count > 0 {
                daysWithData += 1
                totalMeasurements += count
            }
        }
        return (daysWithData, totalMeasurements)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题 + 月份
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Activity Calendar")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(monthTitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // 统计徽章
                HStack(spacing: 12) {
                    VStack(spacing: 0) {
                        Text("\(stats.daysWithData)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryRed)
                        Text("days")
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    VStack(spacing: 0) {
                        Text("\(stats.totalMeasurements)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.75, blue: 0.4))
                        Text("total")
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            // Weekday headers
            HStack(spacing: 4) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(last35Days, id: \.self) { date in
                    let dayRecords = recordsForDate(date)
                    let isToday = Calendar.current.isDateInToday(date)
                    let isSelected = selectedDate == date
                    
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        selectedDate = isSelected ? nil : date
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(colorForCount(dayRecords.count))
                                .frame(height: 36)
                            
                            if isToday {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(AppColors.primaryRed, lineWidth: 2)
                            }
                            
                            if isSelected {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.black.opacity(0.4), lineWidth: 2)
                            }
                            
                            VStack(spacing: 1) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 11, weight: isToday ? .bold : .medium, design: .rounded))
                                    .foregroundColor(dayRecords.count > 2 ? .white : AppColors.textPrimary)
                                
                                if dayRecords.count > 0 {
                                    Text("\(dayRecords.count)")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(dayRecords.count > 2 ? .white.opacity(0.8) : AppColors.primaryRed)
                                }
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // 图例说明
            HStack(spacing: 16) {
                LegendItem(color: AppColors.cardBackground, label: "No data")
                LegendItem(color: AppColors.primaryRed.opacity(0.3), label: "1 time")
                LegendItem(color: AppColors.primaryRed.opacity(0.6), label: "2-3 times")
                LegendItem(color: AppColors.primaryRed, label: "4+ times")
            }
            .padding(.top, 4)
            
            // Selected date detail
            if let date = selectedDate {
                let dayRecords = recordsForDate(date)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryRed)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatFullDate(date))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            if dayRecords.isEmpty {
                                Text("No measurements on this day")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                            } else {
                                let avg = dayRecords.map { $0.bpm }.reduce(0, +) / dayRecords.count
                                let min = dayRecords.map { $0.bpm }.min() ?? 0
                                let max = dayRecords.map { $0.bpm }.max() ?? 0
                                Text("\(dayRecords.count) measurement\(dayRecords.count > 1 ? "s" : "") • Avg: \(avg) BPM • Range: \(min)-\(max)")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(14)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

// 图例项
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
            
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Period Conclusion Card (NEW)
struct PeriodConclusionCard: View {
    let records: [HeartRateRecord]
    let timeRange: TimeRange
    
    private var analysis: (icon: String, title: String, message: String, color: Color) {
        let bpms = records.map { $0.bpm }
        let avg = bpms.reduce(0, +) / max(bpms.count, 1)
        let normalCount = bpms.filter { $0 >= 60 && $0 < 100 }.count
        let normalRate = Double(normalCount) / Double(bpms.count) * 100
        
        if normalRate >= 90 && avg >= 60 && avg < 100 {
            return ("checkmark.seal.fill", "Excellent Period", 
                    "Your average heart rate of \(avg) BPM is within the healthy range. \(Int(normalRate))% of your readings were normal.",
                    Color(red: 0.2, green: 0.75, blue: 0.4))
        } else if normalRate >= 70 {
            return ("hand.thumbsup.fill", "Good Period",
                    "Your average heart rate is \(avg) BPM. Most readings (\(Int(normalRate))%) are within normal range.",
                    Color(red: 0.3, green: 0.6, blue: 0.85))
        } else {
            return ("exclamationmark.circle.fill", "Needs Attention",
                    "Your average heart rate is \(avg) BPM. Only \(Int(normalRate))% of readings were in normal range.",
                    Color(red: 0.95, green: 0.6, blue: 0.2))
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(analysis.color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: analysis.icon)
                    .font(.system(size: 26))
                    .foregroundColor(analysis.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(timeRange.rawValue) Summary")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(analysis.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(analysis.color)
                
                Text(analysis.message)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Daily Overview Chart Card (折线图，无面积图避免底边红线)
struct DailyOverviewChartCard: View {
    let records: [HeartRateRecord]
    let timeRange: TimeRange
    
    private struct DayData: Identifiable {
        let id: Int
        let date: Date
        let avgBPM: Int?  // nil 表示无数据
        let count: Int
        let dayLabel: String
    }
    
    // 根据 timeRange 生成固定天数的数据
    private var dailyData: [DayData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = timeRange.days ?? 7  // All 模式也显示7天
        let displayDays = min(days, 30)  // 最多显示30天
        
        // 按日期分组记录
        let grouped = Dictionary(grouping: records) { calendar.startOfDay(for: $0.timestamp) }
        
        let formatter = DateFormatter()
        formatter.dateFormat = displayDays > 7 ? "d" : "EEE"  // 超过7天显示日期数字
        
        return (0..<displayDays).map { offset in
            let date = calendar.date(byAdding: .day, value: -(displayDays - 1 - offset), to: today)!
            let dayRecords = grouped[date] ?? []
            let avgBPM: Int? = dayRecords.isEmpty ? nil : dayRecords.map { $0.bpm }.reduce(0, +) / dayRecords.count
            
            return DayData(
                id: offset,
                date: date,
                avgBPM: avgBPM,
                count: dayRecords.count,
                dayLabel: formatter.string(from: date)
            )
        }
    }
    
    // 有数据的天
    private var dataWithValues: [DayData] {
        dailyData.filter { $0.avgBPM != nil }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Overview")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // 图例
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppColors.primaryRed)
                        .frame(width: 8, height: 8)
                    Text("Avg BPM")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            if dataWithValues.isEmpty {
                // 无数据时显示占位
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textSecondary.opacity(0.3))
                    
                    Text("No data for this period")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
            } else {
                Chart {
                    // 正常区域背景 (60-100 BPM)
                    RectangleMark(
                        yStart: .value("Low", 60),
                        yEnd: .value("High", 100)
                    )
                    .foregroundStyle(Color.green.opacity(0.08))
                    
                    // 只用折线 + 点，不用 AreaMark 避免底边红线
                    ForEach(dataWithValues) { data in
                        LineMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("BPM", data.avgBPM!)
                        )
                        .foregroundStyle(AppColors.primaryRed)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                    }
                    
                    // 数据点 (大小表示测量次数)
                    ForEach(dataWithValues) { data in
                        PointMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("BPM", data.avgBPM!)
                        )
                        .foregroundStyle(Color.white)
                        .symbolSize(CGFloat(min(100, 40 + data.count * 15)))
                        
                        PointMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("BPM", data.avgBPM!)
                        )
                        .foregroundStyle(AppColors.primaryRed)
                        .symbolSize(CGFloat(min(60, 25 + data.count * 10)))
                    }
                }
                .chartYScale(domain: 40...140)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            let index = dailyData.firstIndex { Calendar.current.isDate($0.date, inSameDayAs: date) }
                            // 根据天数决定显示间隔
                            let interval = dailyData.count > 14 ? 5 : (dailyData.count > 7 ? 2 : 1)
                            if let idx = index, idx % interval == 0 || idx == dailyData.count - 1 {
                                AxisValueLabel {
                                    Text(dailyData[idx].dayLabel)
                                        .font(.system(size: 9))
                                }
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [60, 80, 100, 120]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("\(v)")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }
                .frame(height: 180)
            }
            
            // 底部汇总
            if !dataWithValues.isEmpty {
                HStack(spacing: 20) {
                    SummaryItem(
                        icon: "calendar",
                        value: "\(dataWithValues.count)/\(dailyData.count)",
                        label: "Days with data"
                    )
                    
                    SummaryItem(
                        icon: "number",
                        value: "\(records.count)",
                        label: "Total measurements"
                    )
                    
                    let avgOfAvg = dataWithValues.compactMap { $0.avgBPM }.reduce(0, +) / max(dataWithValues.count, 1)
                    SummaryItem(
                        icon: "heart.fill",
                        value: "\(avgOfAvg)",
                        label: "Average BPM"
                    )
                }
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

struct SummaryItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.primaryRed)
                
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Week Comparison Card (NEW)
struct WeekComparisonCard: View {
    let allRecords: [HeartRateRecord]
    
    private var thisWeekStats: (avg: Int, count: Int, abnormal: Int) {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(byAdding: .day, value: -7, to: Date())!
        let weekRecords = allRecords.filter { $0.timestamp >= startOfWeek }
        guard !weekRecords.isEmpty else { return (0, 0, 0) }
        
        let avg = weekRecords.map { $0.bpm }.reduce(0, +) / weekRecords.count
        let abnormal = weekRecords.filter { $0.bpm < 50 || $0.bpm > 120 }.count
        return (avg, weekRecords.count, abnormal)
    }
    
    private var lastWeekStats: (avg: Int, count: Int, abnormal: Int) {
        let calendar = Calendar.current
        let startOfLastWeek = calendar.date(byAdding: .day, value: -14, to: Date())!
        let endOfLastWeek = calendar.date(byAdding: .day, value: -7, to: Date())!
        let weekRecords = allRecords.filter { $0.timestamp >= startOfLastWeek && $0.timestamp < endOfLastWeek }
        guard !weekRecords.isEmpty else { return (0, 0, 0) }
        
        let avg = weekRecords.map { $0.bpm }.reduce(0, +) / weekRecords.count
        let abnormal = weekRecords.filter { $0.bpm < 50 || $0.bpm > 120 }.count
        return (avg, weekRecords.count, abnormal)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Week Comparison")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("vs Last Week")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            if thisWeekStats.count == 0 && lastWeekStats.count == 0 {
                Text("No data for comparison")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                HStack(spacing: 16) {
                    // Avg BPM
                    ComparisonMetric(
                        icon: "heart.fill",
                        title: "Avg BPM",
                        thisWeek: thisWeekStats.avg,
                        lastWeek: lastWeekStats.avg,
                        lowerIsBetter: true
                    )
                    
                    // Measurements
                    ComparisonMetric(
                        icon: "number",
                        title: "Measurements",
                        thisWeek: thisWeekStats.count,
                        lastWeek: lastWeekStats.count,
                        lowerIsBetter: false
                    )
                    
                    // Abnormal
                    ComparisonMetric(
                        icon: "exclamationmark.triangle.fill",
                        title: "Abnormal",
                        thisWeek: thisWeekStats.abnormal,
                        lastWeek: lastWeekStats.abnormal,
                        lowerIsBetter: true
                    )
                }
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

struct ComparisonMetric: View {
    let icon: String
    let title: String
    let thisWeek: Int
    let lastWeek: Int
    let lowerIsBetter: Bool
    
    private var diff: Int { thisWeek - lastWeek }
    private var improved: Bool {
        if lastWeek == 0 { return thisWeek > 0 }
        return lowerIsBetter ? diff < 0 : diff > 0
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primaryRed)
            
            Text("\(thisWeek)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            if lastWeek > 0 {
                HStack(spacing: 2) {
                    Image(systemName: diff > 0 ? "arrow.up" : (diff < 0 ? "arrow.down" : "minus"))
                        .font(.system(size: 9, weight: .bold))
                    Text("\(abs(diff))")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(improved ? Color(red: 0.2, green: 0.75, blue: 0.4) : (diff == 0 ? AppColors.textSecondary : Color(red: 0.95, green: 0.6, blue: 0.2)))
            } else {
                Text("N/A")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
        )
    }
}

// MARK: - Time of Day Analysis Card (NEW)
struct TimeOfDayAnalysisCard: View {
    let records: [HeartRateRecord]
    
    private struct TimeSlot: Identifiable {
        let id: Int
        let name: String
        let icon: String
        var avgBPM: Int
        var count: Int
        let color: Color
    }
    
    private var timeSlots: [TimeSlot] {
        let calendar = Calendar.current
        var slots = [
            TimeSlot(id: 0, name: "Morning", icon: "sunrise.fill", avgBPM: 0, count: 0, color: Color(red: 1, green: 0.7, blue: 0.3)),
            TimeSlot(id: 1, name: "Afternoon", icon: "sun.max.fill", avgBPM: 0, count: 0, color: Color(red: 1, green: 0.5, blue: 0.2)),
            TimeSlot(id: 2, name: "Evening", icon: "sunset.fill", avgBPM: 0, count: 0, color: Color(red: 0.6, green: 0.4, blue: 0.8)),
            TimeSlot(id: 3, name: "Night", icon: "moon.fill", avgBPM: 0, count: 0, color: Color(red: 0.3, green: 0.4, blue: 0.6))
        ]
        
        for record in records {
            let hour = calendar.component(.hour, from: record.timestamp)
            if hour >= 5 && hour <= 11 {
                slots[0].count += 1
                slots[0].avgBPM += record.bpm
            } else if hour >= 12 && hour <= 17 {
                slots[1].count += 1
                slots[1].avgBPM += record.bpm
            } else if hour >= 18 && hour <= 22 {
                slots[2].count += 1
                slots[2].avgBPM += record.bpm
            } else {
                slots[3].count += 1
                slots[3].avgBPM += record.bpm
            }
        }
        
        for i in 0..<4 {
            if slots[i].count > 0 {
                slots[i].avgBPM = slots[i].avgBPM / slots[i].count
            }
        }
        
        return slots
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Time of Day")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("When you measure")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            HStack(spacing: 10) {
                ForEach(timeSlots) { slot in
                    VStack(spacing: 8) {
                        Image(systemName: slot.icon)
                            .font(.system(size: 20))
                            .foregroundColor(slot.color)
                        
                        Text(slot.name)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        
                        if slot.count > 0 {
                            Text("\(slot.avgBPM)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("\(slot.count) times")
                                .font(.system(size: 9))
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            Text("--")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textSecondary.opacity(0.4))
                            
                            Text("No data")
                                .font(.system(size: 9))
                                .foregroundColor(AppColors.textSecondary.opacity(0.4))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(slot.count > 0 ? slot.color.opacity(0.1) : AppColors.cardBackground)
                    )
                }
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

// MARK: - Activity Distribution Card (NEW)
struct ActivityDistributionCard: View {
    let records: [HeartRateRecord]
    
    private var tagDistribution: [(tag: MeasurementTag, count: Int, percentage: Int)] {
        var counts: [MeasurementTag: Int] = [:]
        for record in records {
            counts[record.measurementTag, default: 0] += 1
        }
        
        return MeasurementTag.allCases.map { tag in
            let count = counts[tag] ?? 0
            let percentage = records.count > 0 ? Int(Double(count) / Double(records.count) * 100) : 0
            return (tag, count, percentage)
        }.sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activity Distribution")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(records.count) total")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(spacing: 10) {
                ForEach(tagDistribution, id: \.tag) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.tag.icon)
                            .font(.system(size: 18))
                            .foregroundColor(item.tag.color)
                            .frame(width: 30)
                        
                        Text(item.tag.rawValue)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 70, alignment: .leading)
                        
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppColors.cardBackground)
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(item.tag.color)
                                    .frame(width: geo.size.width * CGFloat(item.percentage) / 100, height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        Text("\(item.count)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 30, alignment: .trailing)
                        
                        Text("\(item.percentage)%")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 35, alignment: .trailing)
                    }
                }
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

// MARK: - Heart Rate Zone Card (NEW)
struct HeartRateZoneCard: View {
    let records: [HeartRateRecord]
    
    private var zones: [(name: String, range: String, count: Int, color: Color)] {
        let bpms = records.map { $0.bpm }
        let low = bpms.filter { $0 < 60 }.count
        let normal = bpms.filter { $0 >= 60 && $0 < 100 }.count
        let elevated = bpms.filter { $0 >= 100 && $0 < 120 }.count
        let high = bpms.filter { $0 >= 120 }.count
        
        return [
            ("Low", "<60", low, Color(red: 0.3, green: 0.5, blue: 0.9)),
            ("Normal", "60-99", normal, Color(red: 0.2, green: 0.75, blue: 0.4)),
            ("Elevated", "100-119", elevated, Color(red: 0.95, green: 0.6, blue: 0.2)),
            ("High", "120+", high, AppColors.primaryRed)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Heart Rate Zones")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                // Pie chart
                ZStack {
                    ForEach(0..<zones.count, id: \.self) { index in
                        let startAngle = angleForIndex(index)
                        let endAngle = angleForIndex(index + 1)
                        
                        if zones[index].count > 0 {
                            PieSlice(startAngle: startAngle, endAngle: endAngle)
                                .fill(zones[index].color)
                        }
                    }
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 0) {
                        Text("\(records.count)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Total")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .frame(width: 120, height: 120)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(zones, id: \.name) { zone in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(zone.color)
                                .frame(width: 10, height: 10)
                            
                            Text(zone.name)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Text("\(zone.count)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(zone.color)
                            
                            let percentage = records.count > 0 ? Int(Double(zone.count) / Double(records.count) * 100) : 0
                            Text("(\(percentage)%)")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private func angleForIndex(_ index: Int) -> Angle {
        let total = Double(records.count)
        var sum: Double = 0
        for i in 0..<min(index, zones.count) {
            sum += Double(zones[i].count)
        }
        return .degrees(sum / total * 360 - 90)
    }
}

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Measurement Consistency Card (NEW)
struct MeasurementConsistencyCard: View {
    let records: [HeartRateRecord]
    
    private var consistencyInfo: (streak: Int, daysWithMeasurement: Int, message: String, color: Color) {
        let calendar = Calendar.current
        let last7Days = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }
        
        var daysWithMeasurement = 0
        var currentStreak = 0
        var streakBroken = false
        
        for day in last7Days {
            let startOfDay = calendar.startOfDay(for: day)
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { continue }
            let hasMeasurement = records.contains { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
            
            if hasMeasurement {
                daysWithMeasurement += 1
                if !streakBroken { currentStreak += 1 }
            } else {
                streakBroken = true
            }
        }
        
        let message: String
        let color: Color
        
        if daysWithMeasurement >= 6 {
            message = "Excellent consistency! Keep it up!"
            color = Color(red: 0.2, green: 0.75, blue: 0.4)
        } else if daysWithMeasurement >= 4 {
            message = "Good progress! Try measuring daily."
            color = Color(red: 0.3, green: 0.6, blue: 0.85)
        } else {
            message = "Measure more often for better insights."
            color = Color(red: 0.95, green: 0.6, blue: 0.2)
        }
        
        return (currentStreak, daysWithMeasurement, message, color)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Streak badge
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(consistencyInfo.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 0) {
                        Text("\(consistencyInfo.streak)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(consistencyInfo.color)
                        
                        Text("day")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Text("Streak")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Measurement Consistency")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                // Week dots
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: -(6 - dayOffset), to: Date()) ?? Date()
                        let hasMeasurement = hasRecordOnDate(date)
                        
                        Circle()
                            .fill(hasMeasurement ? consistencyInfo.color : AppColors.cardBackground)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(hasMeasurement ? Color.clear : AppColors.textSecondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                Text(consistencyInfo.message)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    private func hasRecordOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return false }
        return records.contains { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
    }
}

// MARK: - Time Range Selector
struct TimeRangeSelector: View {
    @Binding var selectedRange: TimeRange
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    HapticManager.shared.lightImpact()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedRange = range
                    }
                }) {
                    Text(range.rawValue)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(selectedRange == range ? .white : AppColors.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedRange == range ? AppColors.primaryRed : AppColors.cardBackground)
                        )
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Tag Filter View
struct TagFilterView: View {
    @Binding var selectedTag: MeasurementTag?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    title: "All",
                    icon: "list.bullet",
                    isSelected: selectedTag == nil,
                    color: AppColors.primaryRed
                ) {
                    HapticManager.shared.lightImpact()
                    withAnimation { selectedTag = nil }
                }
                
                ForEach(MeasurementTag.allCases, id: \.self) { tag in
                    FilterChip(
                        title: tag.rawValue,
                        icon: tag.icon,
                        isSelected: selectedTag == tag,
                        color: tag.color
                    ) {
                        HapticManager.shared.lightImpact()
                        withAnimation { selectedTag = tag }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color : color.opacity(0.15))
            )
        }
    }
}

// MARK: - Records Day Range Enum
enum RecordsDayRange: Int, CaseIterable {
    case week = 7
    case month = 30
    case quarter = 90
    case year = 365
    
    var label: String {
        switch self {
        case .week: return "7 Days"
        case .month: return "30 Days"
        case .quarter: return "90 Days"
        case .year: return "1 Year"
        }
    }
    
    var nextLevel: RecordsDayRange? {
        switch self {
        case .week: return .month
        case .month: return .quarter
        case .quarter: return .year
        case .year: return nil
        }
    }
}

// MARK: - Records Section View (优化版：自定义筛选器 + 多级加载)
struct RecordsSectionView: View {
    let allRecords: [HeartRateRecord]
    @Binding var selectedTag: MeasurementTag?
    let onDelete: (HeartRateRecord) -> Void
    
    @State private var expandedDates: Set<String> = []  // 展开的日期
    @State private var dayRange: RecordsDayRange = .week  // 当前显示范围
    @State private var showFilterPicker: Bool = false  // 显示自定义筛选弹窗
    
    private let calendar = Calendar.current
    
    // 按 Activity 筛选后的记录
    private var filteredRecords: [HeartRateRecord] {
        guard let tag = selectedTag else { return allRecords }
        return allRecords.filter { $0.measurementTag == tag }
    }
    
    // 获取日期范围
    private var recentDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<dayRange.rawValue).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }
    
    // 某天的记录
    private func recordsForDay(_ date: Date) -> [HeartRateRecord] {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        return filteredRecords.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    // 日期格式化
    private func formatDayHeader(_ date: Date) -> String {
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题 + 筛选器
            HStack {
                Text("All Records")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // 自定义 Activity 筛选器按钮
                Button(action: {
                    HapticManager.shared.lightImpact()
                    showFilterPicker.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: selectedTag?.icon ?? "line.3.horizontal.decrease.circle")
                            .font(.system(size: 14))
                        Text(selectedTag?.rawValue ?? "All")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                        Image(systemName: showFilterPicker ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTag != nil ? .white : AppColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedTag?.color ?? AppColors.cardBackground)
                    )
                }
            }
            
            // 自定义筛选器弹窗
            if showFilterPicker {
                VStack(spacing: 4) {
                    // All 选项
                    FilterOptionRow(
                        icon: "list.bullet",
                        title: "All Activities",
                        color: AppColors.primaryRed,
                        isSelected: selectedTag == nil
                    ) {
                        selectedTag = nil
                        showFilterPicker = false
                    }
                    
                    Divider().padding(.horizontal, 8)
                    
                    // 各个 Tag 选项
                    ForEach(MeasurementTag.allCases, id: \.self) { tag in
                        FilterOptionRow(
                            icon: tag.icon,
                            title: tag.rawValue,
                            color: tag.color,
                            isSelected: selectedTag == tag
                        ) {
                            selectedTag = tag
                            showFilterPicker = false
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
            }
            
            // 日期列表（折叠/展开）- 使用 VStack 避免 LazyVStack 的动画问题
            VStack(spacing: 8) {
                ForEach(recentDays, id: \.self) { date in
                    DayRecordSection(
                        date: date,
                        records: recordsForDay(date),
                        isExpanded: expandedDates.contains(dateKey(date)),
                        formatDayHeader: formatDayHeader,
                        onToggle: {
                            let key = dateKey(date)
                            if expandedDates.contains(key) {
                                expandedDates.remove(key)
                            } else {
                                expandedDates.insert(key)
                            }
                        },
                        onDelete: onDelete
                    )
                }
            }
            
            // 加载更多天数
            if let nextRange = dayRange.nextLevel {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    dayRange = nextRange
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                        Text("Show Last \(nextRange.label)")
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.primaryRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColors.primaryRed.opacity(0.08))
                    )
                }
            } else {
                // 已显示全部（1年）
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 0.2, green: 0.75, blue: 0.4))
                    Text("Showing last year of records")
                }
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .onAppear {
            // 默认展开今天
            expandedDates.insert(dateKey(Date()))
        }
        .animation(.easeInOut(duration: 0.2), value: showFilterPicker)
    }
}

// 筛选器选项行
struct FilterOptionRow: View {
    let icon: String
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? AppColors.primaryRed.opacity(0.08) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 单日记录区块（避免动画抖动）
struct DayRecordSection: View {
    let date: Date
    let records: [HeartRateRecord]
    let isExpanded: Bool
    let formatDayHeader: (Date) -> String
    let onToggle: () -> Void
    let onDelete: (HeartRateRecord) -> Void
    
    private var hasRecords: Bool { !records.isEmpty }
    
    var body: some View {
        VStack(spacing: 0) {
            // 日期头部（可点击展开）
            Button(action: {
                HapticManager.shared.lightImpact()
                onToggle()
            }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(hasRecords ? AppColors.primaryRed : AppColors.textSecondary.opacity(0.4))
                        .frame(width: 20)
                    
                    Text(formatDayHeader(date))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(hasRecords ? AppColors.textPrimary : AppColors.textSecondary.opacity(0.5))
                    
                    Spacer()
                    
                    if hasRecords {
                        Text("\(records.count) record\(records.count > 1 ? "s" : "")")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        
                        // 当天平均BPM
                        let avg = records.map { $0.bpm }.reduce(0, +) / records.count
                        Text("Avg: \(avg)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryRed)
                    } else {
                        Text("No data")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary.opacity(0.4))
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isExpanded ? AppColors.primaryRed.opacity(0.05) : (hasRecords ? Color.white : AppColors.cardBackground.opacity(0.5)))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!hasRecords)
            
            // 展开的记录列表 - 不使用 transition 避免抖动
            if isExpanded && hasRecords {
                VStack(spacing: 6) {
                    ForEach(records) { record in
                        CompactRecordRow(record: record, onDelete: { onDelete(record) })
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isExpanded)
    }
}

// 紧凑型记录行
struct CompactRecordRow: View {
    let record: HeartRateRecord
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink(destination: ResultView(record: record)) {
            HStack(spacing: 10) {
                // 时间
                Text(record.formattedTime)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 70, alignment: .leading)
                
                // Activity 图标
                Image(systemName: record.measurementTag.icon)
                    .font(.system(size: 14))
                    .foregroundColor(record.measurementTag.color)
                    .frame(width: 24)
                
                // Activity 名称
                Text(record.measurementTag.shortName)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // BPM
                HStack(spacing: 2) {
                    Text("\(record.bpm)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(bpmColor)
                    Text("BPM")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary.opacity(0.4))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColors.cardBackground)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var bpmColor: Color {
        if record.bpm < 60 { return Color(red: 0.3, green: 0.5, blue: 0.9) }
        else if record.bpm > 100 { return Color(red: 0.95, green: 0.6, blue: 0.2) }
        else { return AppColors.primaryRed }
    }
}

// MARK: - Empty History View
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)
            
            Image(systemName: "heart.text.square")
                .font(.system(size: 70))
                .foregroundColor(AppColors.textSecondary.opacity(0.4))
            
            Text("No Records Found")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Try adjusting your filters or\nmeasure your heart rate")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Records List View (分页加载)
struct RecordsListView: View {
    let records: [HeartRateRecord]
    let onDelete: (HeartRateRecord) -> Void
    
    @State private var displayLimit: Int = 15  // 初始显示15条
    private let loadMoreCount: Int = 15  // 每次加载15条
    
    // 当前显示的记录
    private var displayedRecords: [HeartRateRecord] {
        Array(records.prefix(displayLimit))
    }
    
    // 是否还有更多
    private var hasMore: Bool {
        displayLimit < records.count
    }
    
    var groupedRecords: [(String, [HeartRateRecord])] {
        let grouped = Dictionary(grouping: displayedRecords) { record in
            formatDateHeader(record.timestamp)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        LazyVStack(spacing: 12) {
            // 记录总数提示
            HStack {
                Image(systemName: "list.bullet")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                
                Text("Showing \(displayedRecords.count) of \(records.count) records")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
            
            ForEach(groupedRecords, id: \.0) { dateString, dayRecords in
                Section {
                    ForEach(dayRecords) { record in
                        RecordCard(record: record)
                            .contextMenu {
                                Button(role: .destructive) {
                                    onDelete(record)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    HStack {
                        Text(dateString)
                            .font(AppTypography.button)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text("\(dayRecords.count) records")
                            .font(AppTypography.small)
                            .foregroundColor(AppColors.textSecondary.opacity(0.7))
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
                }
            }
            
            // Load More 按钮
            if hasMore {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        displayLimit += loadMoreCount
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 16))
                        Text("Load More (\(records.count - displayLimit) remaining)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(AppColors.primaryRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.primaryRed.opacity(0.08))
                    )
                }
                .padding(.top, 8)
            } else if records.count > 15 {
                // 已全部加载提示
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.2, green: 0.75, blue: 0.4))
                    Text("All \(records.count) records loaded")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.vertical, 12)
            }
        }
    }
    
    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Record Card
struct RecordCard: View {
    let record: HeartRateRecord
    
    var body: some View {
        NavigationLink(destination: ResultView(record: record)) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(record.measurementTag.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: record.measurementTag.icon)
                        .font(.system(size: 20))
                        .foregroundColor(record.measurementTag.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.measurementTag.rawValue)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(record.formattedTime)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(record.bpm)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(bpmColor)
                    
                    Text("BPM")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                if record.syncedToHealth {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var bpmColor: Color {
        if record.bpm < 60 { return .blue }
        else if record.bpm > 100 { return .orange }
        else { return AppColors.primaryRed }
    }
}

// MARK: - Export View
struct ExportView: View {
    let records: [HeartRateRecord]
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 70))
                    .foregroundColor(AppColors.primaryRed)
                
                Text("Export for Doctor")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Create a PDF report of your\nheart rate history")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text("\(records.count) records")
                    .font(AppTypography.button)
                    .foregroundColor(AppColors.primaryRed)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppColors.primaryRed.opacity(0.1))
                    .cornerRadius(10)
                
                Spacer()
                
                Button(action: exportPDF) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isExporting ? "Creating PDF..." : "Export PDF")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppColors.primaryRed)
                    )
                }
                .disabled(isExporting)
                .padding(.horizontal, 24)
                
                Button("Cancel") {
                    dismiss()
                }
                .font(AppTypography.button)
                .foregroundColor(AppColors.textSecondary)
                .padding(.bottom, 32)
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func exportPDF() {
        isExporting = true
        HapticManager.shared.mediumImpact()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let pdfData = PDFExporter.generatePDF(from: records)
            isExporting = false
            
            if let pdfData = pdfData {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("HeartRate_Report.pdf")
                try? pdfData.write(to: tempURL)
                
                let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(activityVC, animated: true)
                }
                
                HapticManager.shared.success()
            }
            
            dismiss()
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: HeartRateRecord.self, inMemory: true)
}
