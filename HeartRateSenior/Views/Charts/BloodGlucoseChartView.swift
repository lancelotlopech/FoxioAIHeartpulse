//
//  BloodGlucoseChartView.swift
//  HeartRateSenior
//
//  Blood glucose trend chart view
//

import SwiftUI
import SwiftData
import Charts

struct BloodGlucoseChartView: View {
    @Query(sort: \BloodGlucoseRecord.timestamp, order: .reverse) private var allRecords: [BloodGlucoseRecord]
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedUnit: GlucoseUnit = .mgdL
    
    enum TimePeriod: String, CaseIterable {
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
    
    private var filteredRecords: [BloodGlucoseRecord] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedPeriod.days, to: Date()) ?? Date()
        return allRecords.filter { $0.timestamp >= cutoffDate }
    }
    
    private var fastingRecords: [BloodGlucoseRecord] {
        filteredRecords.filter { $0.context == .fasting }
    }
    
    private var afterMealRecords: [BloodGlucoseRecord] {
        filteredRecords.filter { $0.context == .afterMeal }
    }
    
    private var statistics: (avg: Double, min: Double, max: Double) {
        guard !filteredRecords.isEmpty else { return (0, 0, 0) }
        let values = filteredRecords.map { $0.value }
        let sum = values.reduce(0, +)
        let avg = sum / Double(values.count)
        let minVal = values.min() ?? 0
        let maxVal = values.max() ?? 0
        return (avg, minVal, maxVal)
    }
    
    private var fastingStats: (avg: Double, min: Double, max: Double) {
        guard !fastingRecords.isEmpty else { return (0, 0, 0) }
        let values = fastingRecords.map { $0.value }
        let avg = values.reduce(0, +) / Double(values.count)
        return (avg, values.min() ?? 0, values.max() ?? 0)
    }
    
    private var afterMealStats: (avg: Double, min: Double, max: Double) {
        guard !afterMealRecords.isEmpty else { return (0, 0, 0) }
        let values = afterMealRecords.map { $0.value }
        let avg = values.reduce(0, +) / Double(values.count)
        return (avg, values.min() ?? 0, values.max() ?? 0)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedPeriod) { _, _ in
                    HapticManager.shared.lightImpact()
                }
                
                // Unit Toggle
                HStack {
                    Text("Unit:")
                        .font(.system(size: 16, design: .rounded))
                    
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(GlucoseUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
                .padding(.horizontal)
                
                // Chart
                if !filteredRecords.isEmpty {
                    chartView
                        .frame(height: 250)
                        .padding()
                        .background(DesignSystem.Colors.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                } else {
                    emptyChartView
                }
                
                // Statistics Cards
                statisticsSection
                
                // Fasting vs After Meal Comparison
                if !fastingRecords.isEmpty || !afterMealRecords.isEmpty {
                    comparisonSection
                }
                
                // Target Ranges Info
                targetRangesSection
            }
            .padding(.vertical)
        }
        .navigationTitle("Glucose Trends")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        Chart {
            // Normal range area
            RectangleMark(
                xStart: nil,
                xEnd: nil,
                yStart: .value("Low", convertValue(70)),
                yEnd: .value("High", convertValue(140))
            )
            .foregroundStyle(.green.opacity(0.1))
            
            // Data points
            ForEach(filteredRecords.sorted(by: { $0.timestamp < $1.timestamp })) { record in
                LineMark(
                    x: .value("Date", record.timestamp),
                    y: .value("Glucose", convertValue(record.value))
                )
                .foregroundStyle(colorForContext(record.context))
                .symbol {
                    Circle()
                        .fill(colorForContext(record.context))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYScale(domain: yAxisDomain)
    }
    
    private var yAxisDomain: ClosedRange<Double> {
        let minVal = max(0, (filteredRecords.map { $0.value }.min() ?? 50) - 20)
        let maxVal = (filteredRecords.map { $0.value }.max() ?? 200) + 20
        return convertValue(minVal)...convertValue(maxVal)
    }
    
    private func convertValue(_ mgdL: Double) -> Double {
        switch selectedUnit {
        case .mgdL:
            return mgdL
        case .mmolL:
            return GlucoseUnit.toMmolL(mgdL)
        }
    }
    
    private func colorForContext(_ context: MealContext) -> Color {
        switch context {
        case .fasting:
            return .blue
        case .afterMeal:
            return .orange
        case .beforeMeal:
            return .purple
        case .bedtime:
            return .indigo
        case .random:
            return .gray
        }
    }
    
    // MARK: - Empty Chart View
    
    private var emptyChartView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Data Available")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
            
            Text("Record your blood glucose to see trends")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                GlucoseStatCard(
                    title: "Average",
                    value: formatValue(statistics.avg),
                    unit: selectedUnit.rawValue,
                    color: .blue
                )
                
                GlucoseStatCard(
                    title: "Lowest",
                    value: formatValue(statistics.min),
                    unit: selectedUnit.rawValue,
                    color: .green
                )
                
                GlucoseStatCard(
                    title: "Highest",
                    value: formatValue(statistics.max),
                    unit: selectedUnit.rawValue,
                    color: .red
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func formatValue(_ mgdL: Double) -> String {
        let value = convertValue(mgdL)
        switch selectedUnit {
        case .mgdL:
            return String(format: "%.0f", value)
        case .mmolL:
            return String(format: "%.1f", value)
        }
    }
    
    // MARK: - Comparison Section
    
    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fasting vs After Meal")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                ComparisonCard(
                    title: "Fasting",
                    icon: "sunrise.fill",
                    avg: formatValue(fastingStats.avg),
                    count: fastingRecords.count,
                    unit: selectedUnit.rawValue,
                    color: .blue
                )
                
                ComparisonCard(
                    title: "After Meal",
                    icon: "takeoutbag.and.cup.and.straw.fill",
                    avg: formatValue(afterMealStats.avg),
                    count: afterMealRecords.count,
                    unit: selectedUnit.rawValue,
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Target Ranges Section
    
    private var targetRangesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target Ranges")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                TargetRangeRow(
                    context: "Fasting",
                    range: selectedUnit == .mgdL ? "70-100 mg/dL" : "3.9-5.6 mmol/L",
                    color: .blue
                )
                
                TargetRangeRow(
                    context: "Before Meal",
                    range: selectedUnit == .mgdL ? "70-130 mg/dL" : "3.9-7.2 mmol/L",
                    color: .purple
                )
                
                TargetRangeRow(
                    context: "After Meal (2h)",
                    range: selectedUnit == .mgdL ? "<140 mg/dL" : "<7.8 mmol/L",
                    color: .orange
                )
                
                TargetRangeRow(
                    context: "Bedtime",
                    range: selectedUnit == .mgdL ? "100-140 mg/dL" : "5.6-7.8 mmol/L",
                    color: .indigo
                )
            }
            .padding()
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}

// MARK: - Supporting Views

struct GlucoseStatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(unit)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(12)
    }
}

struct ComparisonCard: View {
    let title: String
    let icon: String
    let avg: String
    let count: Int
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            
            Text(avg)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text("\(unit) avg")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("\(count) readings")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(12)
    }
}

struct TargetRangeRow: View {
    let context: String
    let range: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(context)
                .font(.system(size: 14, design: .rounded))
            
            Spacer()
            
            Text(range)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        BloodGlucoseChartView()
            .modelContainer(for: BloodGlucoseRecord.self, inMemory: true)
    }
}
