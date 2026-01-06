//
//  HealthRecordHistoryComponents.swift
//  HeartRateSenior
//
//  Reusable components for health record history views
//

import SwiftUI
import Charts

// MARK: - Generic Statistics Summary Card

struct GenericStatsSummaryCard: View {
    let title: String
    let icon: String
    let color: Color
    let avgValue: String
    let minValue: String
    let maxValue: String
    let totalCount: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(totalCount) records")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.cardBackground)
                    .cornerRadius(8)
            }
            
            // Stats Grid
            HStack(spacing: 0) {
                HistoryStatItem(label: "Average", value: avgValue, unit: unit, color: color)
                
                Divider()
                    .frame(height: 40)
                
                HistoryStatItem(label: "Lowest", value: minValue, unit: unit, color: .blue)
                
                Divider()
                    .frame(height: 40)
                
                HistoryStatItem(label: "Highest", value: maxValue, unit: unit, color: .orange)
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

private struct HistoryStatItem: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(unit)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Generic Trend Chart Card

struct GenericTrendChartCard<DataPoint: Identifiable>: View {
    let title: String
    let data: [DataPoint]
    let valueKeyPath: KeyPath<DataPoint, Double>
    let dateKeyPath: KeyPath<DataPoint, Date>
    let color: Color
    let unit: String
    let normalRange: ClosedRange<Double>?
    
    @State private var selectedRange: ChartTimeRange = .week
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with range picker
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Picker("Range", selection: $selectedRange) {
                    Text("7D").tag(ChartTimeRange.week)
                    Text("30D").tag(ChartTimeRange.month)
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }
            
            // Chart
            if filteredData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textSecondary.opacity(0.3))
                    Text("No data for this period")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
            } else {
                Chart {
                    // Normal range background
                    if let range = normalRange {
                        RectangleMark(
                            yStart: .value("Low", range.lowerBound),
                            yEnd: .value("High", range.upperBound)
                        )
                        .foregroundStyle(Color.green.opacity(0.08))
                    }
                    
                    // Line
                    ForEach(filteredData) { point in
                        LineMark(
                            x: .value("Date", point[keyPath: dateKeyPath]),
                            y: .value("Value", point[keyPath: valueKeyPath])
                        )
                        .foregroundStyle(color)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .interpolationMethod(.catmullRom)
                    }
                    
                    // Points
                    ForEach(filteredData) { point in
                        PointMark(
                            x: .value("Date", point[keyPath: dateKeyPath]),
                            y: .value("Value", point[keyPath: valueKeyPath])
                        )
                        .foregroundStyle(Color.white)
                        .symbolSize(60)
                        
                        PointMark(
                            x: .value("Date", point[keyPath: dateKeyPath]),
                            y: .value("Value", point[keyPath: valueKeyPath])
                        )
                        .foregroundStyle(color)
                        .symbolSize(35)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(String(format: "%.0f", v))
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }
                .frame(height: 160)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private var filteredData: [DataPoint] {
        let calendar = Calendar.current
        let days = selectedRange == .week ? 7 : 30
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return data.filter { $0[keyPath: dateKeyPath] >= startDate }
    }
}

enum ChartTimeRange: CaseIterable {
    case week, month
}

// MARK: - Generic Category Distribution Card

struct GenericCategoryCard: View {
    let title: String
    let categories: [(name: String, count: Int, color: Color)]
    let total: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(total) total")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            HStack(spacing: 12) {
                // Pie chart
                ZStack {
                    ForEach(0..<categories.count, id: \.self) { index in
                        let startAngle = angleForIndex(index)
                        let endAngle = angleForIndex(index + 1)
                        
                        if categories[index].count > 0 {
                            GenericPieSlice(startAngle: startAngle, endAngle: endAngle)
                                .fill(categories[index].color)
                        }
                    }
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                    
                    VStack(spacing: 0) {
                        Text("\(total)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
                .frame(width: 100, height: 100)
                
                // Legend
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(categories, id: \.name) { category in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 10, height: 10)
                            
                            Text(category.name)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Text("\(category.count)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(category.color)
                            
                            let percentage = total > 0 ? Int(Double(category.count) / Double(total) * 100) : 0
                            Text("(\(percentage)%)")
                                .font(.system(size: 10))
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
        guard total > 0 else { return .degrees(-90) }
        var sum: Double = 0
        for i in 0..<min(index, categories.count) {
            sum += Double(categories[i].count)
        }
        return .degrees(sum / Double(total) * 360 - 90)
    }
}

struct GenericPieSlice: Shape {
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

// MARK: - Generic Date Grouped Records Section

struct GenericDateGroupedSection<Record: Identifiable, RowContent: View>: View {
    let title: String
    let records: [Record]
    let dateKeyPath: KeyPath<Record, Date>
    let rowContent: (Record) -> RowContent
    let onDelete: ((Record) -> Void)?
    let avgValueForDay: (([Record]) -> String)?
    
    @State private var expandedDates: Set<String> = []
    @State private var dayRange: Int = 7
    
    private let calendar = Calendar.current
    
    init(
        title: String,
        records: [Record],
        dateKeyPath: KeyPath<Record, Date>,
        @ViewBuilder rowContent: @escaping (Record) -> RowContent,
        onDelete: ((Record) -> Void)? = nil,
        avgValueForDay: (([Record]) -> String)? = nil
    ) {
        self.title = title
        self.records = records
        self.dateKeyPath = dateKeyPath
        self.rowContent = rowContent
        self.onDelete = onDelete
        self.avgValueForDay = avgValueForDay
    }
    
    private var recentDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<dayRange).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }
    
    private func recordsForDay(_ date: Date) -> [Record] {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        return records.filter { 
            let recordDate = $0[keyPath: dateKeyPath]
            return recordDate >= startOfDay && recordDate < endOfDay 
        }.sorted { $0[keyPath: dateKeyPath] > $1[keyPath: dateKeyPath] }
    }
    
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
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 8) {
                ForEach(recentDays, id: \.self) { date in
                    let dayRecords = recordsForDay(date)
                    let key = dateKey(date)
                    let isExpanded = expandedDates.contains(key)
                    
                    VStack(spacing: 0) {
                        // Day Header
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            if isExpanded {
                                expandedDates.remove(key)
                            } else {
                                expandedDates.insert(key)
                            }
                        }) {
                            HStack {
                                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(dayRecords.isEmpty ? AppColors.textSecondary.opacity(0.4) : AppColors.primaryRed)
                                    .frame(width: 20)
                                
                                Text(formatDayHeader(date))
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(dayRecords.isEmpty ? AppColors.textSecondary.opacity(0.5) : AppColors.textPrimary)
                                
                                Spacer()
                                
                                if !dayRecords.isEmpty {
                                    Text("\(dayRecords.count) record\(dayRecords.count > 1 ? "s" : "")")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    if let avgFunc = avgValueForDay {
                                        Text(avgFunc(dayRecords))
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(AppColors.primaryRed)
                                    }
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
                                    .fill(isExpanded ? AppColors.primaryRed.opacity(0.05) : (dayRecords.isEmpty ? AppColors.cardBackground.opacity(0.5) : Color.white))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(dayRecords.isEmpty)
                        
                        // Expanded Records
                        if isExpanded && !dayRecords.isEmpty {
                            VStack(spacing: 6) {
                                ForEach(dayRecords) { record in
                                    rowContent(record)
                                        .contextMenu {
                                            if let deleteAction = onDelete {
                                                Button(role: .destructive) {
                                                    deleteAction(record)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                        }
                    }
                    .animation(.easeInOut(duration: 0.15), value: isExpanded)
                }
            }
            
            // Load More
            if dayRange < 365 {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    dayRange = min(dayRange + 23, 365)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                        Text("Load More Days")
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
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .onAppear {
            expandedDates.insert(dateKey(Date()))
        }
    }
}

// MARK: - Generic Consistency Card

struct GenericConsistencyCard: View {
    let title: String
    let icon: String
    let color: Color
    let recordDates: [Date]
    
    private var consistencyInfo: (streak: Int, daysWithData: Int, message: String) {
        let calendar = Calendar.current
        let last7Days = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: Date()) }
        
        var daysWithData = 0
        var currentStreak = 0
        var streakBroken = false
        
        for day in last7Days {
            let startOfDay = calendar.startOfDay(for: day)
            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { continue }
            let hasData = recordDates.contains { $0 >= startOfDay && $0 < endOfDay }
            
            if hasData {
                daysWithData += 1
                if !streakBroken { currentStreak += 1 }
            } else {
                streakBroken = true
            }
        }
        
        let message: String
        if daysWithData >= 6 {
            message = "Excellent consistency!"
        } else if daysWithData >= 4 {
            message = "Good progress!"
        } else {
            message = "Measure more often"
        }
        
        return (currentStreak, daysWithData, message)
    }
    
    private func hasDataOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return false }
        return recordDates.contains { $0 >= startOfDay && $0 < endOfDay }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Streak badge
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 0) {
                        Text("\(consistencyInfo.streak)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(color)
                        
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
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                // Week dots
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: -(6 - dayOffset), to: Date()) ?? Date()
                        let hasData = hasDataOnDate(date)
                        
                        Circle()
                            .fill(hasData ? color : AppColors.cardBackground)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(hasData ? Color.clear : AppColors.textSecondary.opacity(0.3), lineWidth: 1)
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
}

// MARK: - Generic Empty State

struct GenericEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(color.opacity(0.6))
            }
            
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Generic Compact Record Row

struct GenericCompactRecordRow: View {
    let time: String
    let icon: String
    let iconColor: Color
    let primaryValue: String
    let secondaryValue: String?
    let statusText: String
    let statusColor: Color
    
    var body: some View {
        HStack(spacing: 10) {
            // Time
            Text(time)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 55, alignment: .leading)
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            // Values
            HStack(spacing: 2) {
                Text(primaryValue)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                if let secondary = secondaryValue {
                    Text(secondary)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Status
            Text(statusText)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.12))
                .cornerRadius(6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColors.cardBackground)
        )
    }
}
