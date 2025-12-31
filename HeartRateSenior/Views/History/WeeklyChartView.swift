//
//  WeeklyChartView.swift
//  HeartRateSenior
//
//  Weekly heart rate trend chart using SwiftCharts
//

import SwiftUI
import Charts

struct WeeklyChartView: View {
    let records: [HeartRateRecord]
    
    var weeklyData: [DailyAverage] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get last 7 days
        var dailyAverages: [DailyAverage] = []
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let dayRecords = records.filter { record in
                calendar.isDate(record.timestamp, inSameDayAs: date)
            }
            
            let avgBPM: Int?
            if !dayRecords.isEmpty {
                avgBPM = dayRecords.map { $0.bpm }.reduce(0, +) / dayRecords.count
            } else {
                avgBPM = nil
            }
            
            // Use date for X-axis to allow automatic spacing
            dailyAverages.append(DailyAverage(day: "", date: date, averageBPM: avgBPM))
        }
        
        return dailyAverages
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.paddingMedium) {
            // Header
            HStack {
                Text("Weekly Trend")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // Average BPM
                if let avgBPM = calculateWeeklyAverage() {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Avg")
                            .font(AppTypography.small)
                            .foregroundColor(AppColors.textSecondary)
                        Text("\(avgBPM) BPM")
                            .font(AppTypography.button)
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            
            // Chart
            Chart {
                ForEach(weeklyData) { data in
                    if let bpm = data.averageBPM {
                        LineMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("BPM", bpm)
                        )
                        .foregroundStyle(AppColors.primaryRed)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("BPM", bpm)
                        )
                        .foregroundStyle(AppColors.primaryRed)
                        .symbolSize(100)
                        
                        AreaMark(
                            x: .value("Date", data.date, unit: .day),
                            y: .value("BPM", bpm)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primaryRed.opacity(0.3), AppColors.primaryRed.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                
                // Normal range reference lines
                RuleMark(y: .value("Low Normal", 60))
                    .foregroundStyle(Color.green.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                
                RuleMark(y: .value("High Normal", 100))
                    .foregroundStyle(Color.green.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
            .chartYScale(domain: 40...140)
            .chartYAxis {
                AxisMarks(position: .leading, values: [40, 60, 80, 100, 120, 140]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .font(AppTypography.small)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.weekday(.abbreviated))
                                .font(AppTypography.small)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            .frame(height: 150)
            
            // Legend
            HStack(spacing: AppDimensions.paddingMedium) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text("Normal Range (60-100)")
                        .font(AppTypography.small)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
        }
        .padding(AppDimensions.paddingMedium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppDimensions.cornerRadius)
    }
    
    private func calculateWeeklyAverage() -> Int? {
        let validData = weeklyData.compactMap { $0.averageBPM }
        guard !validData.isEmpty else { return nil }
        return validData.reduce(0, +) / validData.count
    }
}

// MARK: - Daily Average Model
struct DailyAverage: Identifiable {
    let id = UUID()
    let day: String
    let date: Date
    let averageBPM: Int?
}

#Preview {
    let sampleRecords = [
        HeartRateRecord(bpm: 72, timestamp: Date()),
        HeartRateRecord(bpm: 78, timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        HeartRateRecord(bpm: 65, timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
        HeartRateRecord(bpm: 82, timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
        HeartRateRecord(bpm: 70, timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!)
    ]
    
    return WeeklyChartView(records: sampleRecords)
        .frame(height: 250)
        .padding()
}
