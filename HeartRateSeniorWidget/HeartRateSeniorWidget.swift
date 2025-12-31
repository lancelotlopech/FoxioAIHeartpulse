//
//  HeartRateSeniorWidget.swift
//  HeartRateSeniorWidget
//
//  iOS Widget for displaying heart rate data on home screen
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct HeartRateEntry: TimelineEntry {
    let date: Date
    let bpm: Int?
    let lastMeasured: Date?
    let weeklyData: [Int]
    let averageBPM: Int?
    let measurementCount: Int
}

// MARK: - Timeline Provider
struct HeartRateProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> HeartRateEntry {
        HeartRateEntry(
            date: Date(),
            bpm: 72,
            lastMeasured: Date(),
            weeklyData: [68, 72, 75, 70, 73, 71, 72],
            averageBPM: 72,
            measurementCount: 15
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HeartRateEntry) -> Void) {
        let entry = loadData()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HeartRateEntry>) -> Void) {
        let entry = loadData()
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadData() -> HeartRateEntry {
        // Load data from App Group shared container
        let defaults = UserDefaults(suiteName: "group.com.heartrate.senior")
        
        let bpm = defaults?.integer(forKey: "lastBPM")
        let lastMeasuredTimestamp = defaults?.double(forKey: "lastMeasuredTimestamp")
        let weeklyDataString = defaults?.string(forKey: "weeklyData") ?? ""
        let averageBPM = defaults?.integer(forKey: "averageBPM")
        let measurementCount = defaults?.integer(forKey: "measurementCount") ?? 0
        
        let lastMeasured: Date? = lastMeasuredTimestamp != nil && lastMeasuredTimestamp! > 0 
            ? Date(timeIntervalSince1970: lastMeasuredTimestamp!) 
            : nil
        
        let weeklyData = weeklyDataString.split(separator: ",").compactMap { Int($0) }
        
        return HeartRateEntry(
            date: Date(),
            bpm: bpm != 0 ? bpm : nil,
            lastMeasured: lastMeasured,
            weeklyData: weeklyData.isEmpty ? [] : weeklyData,
            averageBPM: averageBPM != 0 ? averageBPM : nil,
            measurementCount: measurementCount
        )
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: HeartRateEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Heart icon
            Image(systemName: "heart.fill")
                .font(.system(size: 24))
                .foregroundColor(.red)
            
            // BPM Value
            if let bpm = entry.bpm {
                Text("\(bpm)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("BPM")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            } else {
                Text("--")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("Tap to measure")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            // Last measured time
            if let lastMeasured = entry.lastMeasured {
                Text(timeAgoString(from: lastMeasured))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: HeartRateEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Current BPM
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                    
                    Text("Heart Rate")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                if let bpm = entry.bpm {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(bpm)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("BPM")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                    }
                } else {
                    Text("--")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                if let lastMeasured = entry.lastMeasured {
                    Text(timeAgoString(from: lastMeasured))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Right side - Mini chart or stats
            VStack(alignment: .trailing, spacing: 8) {
                if !entry.weeklyData.isEmpty {
                    MiniChartView(data: entry.weeklyData)
                        .frame(width: 100, height: 50)
                }
                
                HStack(spacing: 12) {
                    if let avg = entry.averageBPM {
                        VStack(spacing: 2) {
                            Text("Avg")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Text("\(avg)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    VStack(spacing: 2) {
                        Text("Today")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("\(entry.measurementCount)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: HeartRateEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.red)
                
                Text("Heart Rate")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let lastMeasured = entry.lastMeasured {
                    Text(timeAgoString(from: lastMeasured))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            // Current BPM
            HStack(alignment: .bottom, spacing: 8) {
                if let bpm = entry.bpm {
                    Text("\(bpm)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("BPM")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)
                } else {
                    Text("--")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("BPM")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)
                }
                
                Spacer()
            }
            
            // Chart
            if !entry.weeklyData.isEmpty {
                LargeChartView(data: entry.weeklyData)
                    .frame(height: 80)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 80)
                    .overlay(
                        Text("No data yet")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    )
            }
            
            // Stats row
            HStack(spacing: 0) {
                StatWidget(title: "Average", value: entry.averageBPM != nil ? "\(entry.averageBPM!)" : "--", color: .red)
                
                Divider()
                    .frame(height: 40)
                
                StatWidget(title: "Min", value: entry.weeklyData.isEmpty ? "--" : "\(entry.weeklyData.min() ?? 0)", color: .blue)
                
                Divider()
                    .frame(height: 40)
                
                StatWidget(title: "Max", value: entry.weeklyData.isEmpty ? "--" : "\(entry.weeklyData.max() ?? 0)", color: .orange)
                
                Divider()
                    .frame(height: 40)
                
                StatWidget(title: "Count", value: "\(entry.measurementCount)", color: .green)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
}

struct StatWidget: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Mini Chart View
struct MiniChartView: View {
    let data: [Int]
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = CGFloat(data.max() ?? 100)
            let minValue = CGFloat(data.min() ?? 60)
            let range = max(maxValue - minValue, 20)
            
            Path { path in
                guard data.count > 1 else { return }
                
                let stepX = geometry.size.width / CGFloat(data.count - 1)
                
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedY = (CGFloat(value) - minValue) / range
                    let y = geometry.size.height * (1 - normalizedY)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.red, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Large Chart View
struct LargeChartView: View {
    let data: [Int]
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = CGFloat(data.max() ?? 100)
            let minValue = CGFloat(data.min() ?? 60)
            let range = max(maxValue - minValue, 20)
            
            ZStack {
                // Area fill
                Path { path in
                    guard data.count > 1 else { return }
                    
                    let stepX = geometry.size.width / CGFloat(data.count - 1)
                    
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedY = (CGFloat(value) - minValue) / range
                        let y = geometry.size.height * (1 - normalizedY)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.red.opacity(0.3), Color.red.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Line
                Path { path in
                    guard data.count > 1 else { return }
                    
                    let stepX = geometry.size.width / CGFloat(data.count - 1)
                    
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedY = (CGFloat(value) - minValue) / range
                        let y = geometry.size.height * (1 - normalizedY)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.red, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - Widget Entry View
struct HeartRateSeniorWidgetEntryView: View {
    var entry: HeartRateProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration
@main
struct HeartRateSeniorWidget: Widget {
    let kind: String = "HeartRateSeniorWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeartRateProvider()) { entry in
            HeartRateSeniorWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Heart Rate")
        .description("View your latest heart rate measurement and trends.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    HeartRateSeniorWidget()
} timeline: {
    HeartRateEntry(date: Date(), bpm: 72, lastMeasured: Date(), weeklyData: [68, 72, 75, 70, 73, 71, 72], averageBPM: 72, measurementCount: 15)
}

#Preview(as: .systemMedium) {
    HeartRateSeniorWidget()
} timeline: {
    HeartRateEntry(date: Date(), bpm: 72, lastMeasured: Date(), weeklyData: [68, 72, 75, 70, 73, 71, 72], averageBPM: 72, measurementCount: 15)
}

#Preview(as: .systemLarge) {
    HeartRateSeniorWidget()
} timeline: {
    HeartRateEntry(date: Date(), bpm: 72, lastMeasured: Date(), weeklyData: [68, 72, 75, 70, 73, 71, 72], averageBPM: 72, measurementCount: 15)
}
