//
//  HistoryView.swift
//  HeartRateSenior
//
//  Enhanced history view with filters, statistics, and improved charts
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
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedTag: MeasurementTag? = nil
    @State private var showingExportSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var recordToDelete: HeartRateRecord?
    @State private var selectedRecord: HeartRateRecord?
    
    // Filtered records based on time range and tag
    private var filteredRecords: [HeartRateRecord] {
        var records = allRecords
        
        // Filter by time range
        if let days = selectedTimeRange.days {
            let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            records = records.filter { $0.timestamp >= startDate }
        }
        
        // Filter by tag
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
        
        // Calculate trend (compare to previous period)
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
                VStack(spacing: 16) {
                    // Time Range Selector
                    TimeRangeSelector(selectedRange: $selectedTimeRange)
                    
                    // Statistics Card
                    if !filteredRecords.isEmpty {
                        if filteredRecords.count >= 3 {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Summary (\(selectedTimeRange.rawValue))")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 4)
                                
                                StatisticsCard(stats: statistics)
                            }
                        } else {
                            // Insufficient data card to avoid misleading stats
                            InsufficientDataCard(count: filteredRecords.count)
                        }
                    }
                    
                    // Tag Filter
                    TagFilterView(selectedTag: $selectedTag)
                    
                    // Chart
                    if !filteredRecords.isEmpty {
                        EnhancedChartView(
                            records: filteredRecords,
                            selectedRecord: $selectedRecord
                        )
                        .frame(height: 220)
                    }
                    
                    // Records List
                    if filteredRecords.isEmpty {
                        EmptyHistoryView()
                    } else {
                        RecordsListView(
                            records: filteredRecords,
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
                if !allRecords.isEmpty {
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

// MARK: - Statistics Card
struct StatisticsCard: View {
    let stats: (avg: Int, min: Int, max: Int, count: Int, trend: Int?)
    
    var body: some View {
        VStack(spacing: 16) {
            // Main stats row
            HStack(spacing: 0) {
                StatBox(title: "Average", value: "\(stats.avg)", unit: "BPM", color: AppColors.primaryRed)
                
                Divider()
                    .frame(height: 50)
                
                StatBox(title: "Lowest", value: "\(stats.min)", unit: "BPM", color: .blue)
                
                Divider()
                    .frame(height: 50)
                
                StatBox(title: "Highest", value: "\(stats.max)", unit: "BPM", color: .orange)
            }
            
            Divider()
            
            // Secondary stats row
            HStack {
                // Total measurements
                HStack(spacing: 6) {
                    Image(systemName: "number.circle.fill")
                        .foregroundColor(AppColors.primaryRed)
                    Text("\(stats.count) measurements")
                        .font(AppTypography.small)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Trend indicator
                if let trend = stats.trend {
                    HStack(spacing: 4) {
                        Image(systemName: trend > 0 ? "arrow.up.right" : (trend < 0 ? "arrow.down.right" : "arrow.right"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(trendColor(trend))
                        
                        Text("\(abs(trend)) BPM vs last period")
                            .font(AppTypography.small)
                            .foregroundColor(trendColor(trend))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(trendColor(trend).opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private func trendColor(_ trend: Int) -> Color {
        if trend > 5 { return .orange }
        else if trend < -5 { return .blue }
        else { return .green }
    }
}

// MARK: - Insufficient Data Card
struct InsufficientDataCard: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryRed.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryRed)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Trend Analysis")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Measure \(3 - count) more times to see your average, highest, and lowest heart rates.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, 5)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tag Filter View
struct TagFilterView: View {
    @Binding var selectedTag: MeasurementTag?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All tags button
                FilterChip(
                    title: "All",
                    icon: "list.bullet",
                    isSelected: selectedTag == nil,
                    color: AppColors.primaryRed
                ) {
                    HapticManager.shared.lightImpact()
                    withAnimation { selectedTag = nil }
                }
                
                // Individual tag buttons
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

// MARK: - Enhanced Chart View
struct EnhancedChartView: View {
    let records: [HeartRateRecord]
    @Binding var selectedRecord: HeartRateRecord?
    
    private var chartRecords: [HeartRateRecord] {
        Array(records.suffix(50).reversed())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Heart Rate Trend")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if let selected = selectedRecord {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(selected.bpm) BPM")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryRed)
                        Text(selected.formattedTime)
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            Chart {
                // Normal range area
                RectangleMark(
                    xStart: .value("Start", chartRecords.first?.timestamp ?? Date()),
                    xEnd: .value("End", chartRecords.last?.timestamp ?? Date()),
                    yStart: .value("Low", 60),
                    yEnd: .value("High", 100)
                )
                .foregroundStyle(Color.green.opacity(0.1))
                
                ForEach(chartRecords) { record in
                    LineMark(
                        x: .value("Time", record.timestamp),
                        y: .value("BPM", record.bpm)
                    )
                    .foregroundStyle(AppColors.primaryRed.gradient)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    
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
                    
                    if selectedRecord?.id == record.id {
                        PointMark(
                            x: .value("Time", record.timestamp),
                            y: .value("BPM", record.bpm)
                        )
                        .foregroundStyle(AppColors.primaryRed)
                        .symbolSize(100)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [60, 80, 100, 120]) { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartYScale(domain: 40...140)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let x = value.location.x
                                    if let date: Date = proxy.value(atX: x) {
                                        // Find closest record
                                        let closest = chartRecords.min(by: {
                                            abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date))
                                        })
                                        selectedRecord = closest
                                    }
                                }
                                .onEnded { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation { selectedRecord = nil }
                                    }
                                }
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Empty History View
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 40)
            
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

// MARK: - Records List View
struct RecordsListView: View {
    let records: [HeartRateRecord]
    let onDelete: (HeartRateRecord) -> Void
    
    var groupedRecords: [(String, [HeartRateRecord])] {
        let grouped = Dictionary(grouping: records) { record in
            formatDateHeader(record.timestamp)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        LazyVStack(spacing: 12) {
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
                // Tag icon
                ZStack {
                    Circle()
                        .fill(record.measurementTag.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: record.measurementTag.icon)
                        .font(.system(size: 20))
                        .foregroundColor(record.measurementTag.color)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.measurementTag.rawValue)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(record.formattedTime)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // BPM
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(record.bpm)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(bpmColor)
                    
                    Text("BPM")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Health sync indicator
                if record.syncedToHealth {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                }
                
                // 右箭头指示可点击
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
