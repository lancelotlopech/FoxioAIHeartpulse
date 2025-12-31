//
//  BloodPressureChartView.swift
//  HeartRateSenior
//
//  Blood pressure trend chart view
//

import SwiftUI
import SwiftData
import Charts

struct BloodPressureChartView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var allRecords: [BloodPressureRecord]
    
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            }
        }
    }
    
    private var filteredRecords: [BloodPressureRecord] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
        return allRecords.filter { $0.timestamp >= cutoffDate }.reversed()
    }
    
    private var averageSystolic: Int {
        guard !filteredRecords.isEmpty else { return 0 }
        let sum = filteredRecords.reduce(0) { $0 + $1.systolic }
        return sum / filteredRecords.count
    }
    
    private var averageDiastolic: Int {
        guard !filteredRecords.isEmpty else { return 0 }
        let sum = filteredRecords.reduce(0) { $0 + $1.diastolic }
        return sum / filteredRecords.count
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Time Range Picker
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if filteredRecords.isEmpty {
                emptyStateView
            } else {
                // Summary Cards
                summaryCards
                
                // Chart
                chartView
                
                // Legend
                legendView
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No Data Available")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("Record your blood pressure\nto see trends here")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Summary Cards
    
    private var summaryCards: some View {
        HStack(spacing: 12) {
            // Average Systolic
            VStack(spacing: 4) {
                Text("Avg Systolic")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(averageSystolic)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                Text("mmHg")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            // Average Diastolic
            VStack(spacing: 4) {
                Text("Avg Diastolic")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(averageDiastolic)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text("mmHg")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            // Records Count
            VStack(spacing: 4) {
                Text("Records")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(filteredRecords.count)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                
                Text("total")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        Chart {
            // Normal range area
            RectangleMark(
                xStart: nil,
                xEnd: nil,
                yStart: .value("Low", 60),
                yEnd: .value("High", 80)
            )
            .foregroundStyle(.green.opacity(0.1))
            
            RectangleMark(
                xStart: nil,
                xEnd: nil,
                yStart: .value("Low", 90),
                yEnd: .value("High", 120)
            )
            .foregroundStyle(.green.opacity(0.1))
            
            // Systolic line
            ForEach(filteredRecords) { record in
                LineMark(
                    x: .value("Date", record.timestamp),
                    y: .value("Systolic", record.systolic)
                )
                .foregroundStyle(.blue)
                .symbol(.circle)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", record.timestamp),
                    y: .value("Systolic", record.systolic)
                )
                .foregroundStyle(.blue)
                .symbolSize(40)
            }
            
            // Diastolic line
            ForEach(filteredRecords) { record in
                LineMark(
                    x: .value("Date", record.timestamp),
                    y: .value("Diastolic", record.diastolic)
                )
                .foregroundStyle(.green)
                .symbol(.circle)
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", record.timestamp),
                    y: .value("Diastolic", record.diastolic)
                )
                .foregroundStyle(.green)
                .symbolSize(40)
            }
            
            // Reference lines
            RuleMark(y: .value("High BP", 140))
                .foregroundStyle(.red.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            
            RuleMark(y: .value("Normal Systolic", 120))
                .foregroundStyle(.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
        }
        .chartYScale(domain: 40...180)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [60, 80, 100, 120, 140, 160]) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 250)
        .padding(.horizontal)
    }
    
    // MARK: - Legend
    
    private var legendView: some View {
        HStack(spacing: 24) {
            HStack(spacing: 6) {
                Circle()
                    .fill(.blue)
                    .frame(width: 10, height: 10)
                Text("Systolic")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 6) {
                Circle()
                    .fill(.green)
                    .frame(width: 10, height: 10)
                Text("Diastolic")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 6) {
                Rectangle()
                    .fill(.green.opacity(0.3))
                    .frame(width: 16, height: 10)
                Text("Normal")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    BloodPressureChartView()
        .modelContainer(for: BloodPressureRecord.self, inMemory: true)
}
