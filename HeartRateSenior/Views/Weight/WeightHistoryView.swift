//
//  WeightHistoryView.swift
//  HeartRateSenior
//
//  Weight History View with statistics and date grouping
//

import SwiftUI
import SwiftData

struct WeightHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeightRecord.timestamp, order: .reverse) private var records: [WeightRecord]
    
    @State private var showingAddSheet = false
    @State private var displayUnit: WeightUnit = .kg
    @State private var recordToDelete: WeightRecord?
    @State private var showDeleteAlert = false
    
    // Default height for BMI calculation (170 cm)
    private let defaultHeightCm: Double = 170
    
    // Convert weight based on display unit
    private func convertWeight(_ kg: Double) -> Double {
        switch displayUnit {
        case .kg: return kg
        case .lb: return kg * 2.20462
        }
    }
    
    private func formatWeight(_ kg: Double) -> String {
        let converted = convertWeight(kg)
        return String(format: "%.1f", converted)
    }
    
    // Statistics with unit conversion
    private var stats: (avg: String, min: String, max: String) {
        guard !records.isEmpty else { return ("0", "0", "0") }
        let values = records.map { $0.weight }
        let avg = values.reduce(0, +) / Double(values.count)
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        return (formatWeight(avg), formatWeight(min), formatWeight(max))
    }
    
    // BMI helper
    private func calculateBMI(weight: Double) -> Double? {
        guard defaultHeightCm > 0 else { return nil }
        let heightM = defaultHeightCm / 100
        return weight / (heightM * heightM)
    }
    
    private func bmiCategory(_ bmi: Double) -> String {
        if bmi < 18.5 { return "Underweight" }
        else if bmi < 25 { return "Normal" }
        else if bmi < 30 { return "Overweight" }
        else { return "Obese" }
    }
    
    // BMI distribution
    private var bmiDistribution: [(name: String, count: Int, color: Color)] {
        var counts: [String: Int] = [:]
        for record in records {
            if let bmi = calculateBMI(weight: record.weight) {
                let category = bmiCategory(bmi)
                counts[category, default: 0] += 1
            }
        }
        
        var result: [(name: String, count: Int, color: Color)] = []
        if let c = counts["Underweight"], c > 0 { result.append(("Underweight", c, .blue)) }
        if let c = counts["Normal"], c > 0 { result.append(("Normal", c, .green)) }
        if let c = counts["Overweight"], c > 0 { result.append(("Overweight", c, .yellow)) }
        if let c = counts["Obese"], c > 0 { result.append(("Obese", c, .orange)) }
        return result
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    GenericEmptyStateView(
                        icon: "scalemass.fill",
                        title: "No Records Yet",
                        message: "Tap the + button to add your first weight reading",
                        color: .orange
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // 1. Statistics Summary
                            GenericStatsSummaryCard(
                                title: "Weight",
                                icon: "scalemass.fill",
                                color: .orange,
                                avgValue: stats.avg,
                                minValue: stats.min,
                                maxValue: stats.max,
                                totalCount: records.count,
                                unit: displayUnit.rawValue
                            )
                            
                            // 2. BMI Distribution
                            if !bmiDistribution.isEmpty {
                                GenericCategoryCard(
                                    title: "BMI Distribution",
                                    categories: bmiDistribution,
                                    total: records.count
                                )
                            }
                            
                            // 3. Consistency Card
                            GenericConsistencyCard(
                                title: "Measurement Consistency",
                                icon: "scalemass.fill",
                                color: .orange,
                                recordDates: records.map { $0.timestamp }
                            )
                            
                            // 4. Date Grouped Records
                            dateGroupedRecordsView
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .background(AppColors.background)
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("Unit", selection: $displayUnit) {
                        Text("kg").tag(WeightUnit.kg)
                        Text("lb").tag(WeightUnit.lb)
                    }
                    .pickerStyle(.menu)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                WeightInputView()
            }
            .alert("Delete Record?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let record = recordToDelete {
                        modelContext.delete(record)
                        recordToDelete = nil
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
    
    private var dateGroupedRecordsView: some View {
        GenericDateGroupedSection(
            title: "All Records",
            records: records,
            dateKeyPath: \.timestamp,
            rowContent: { record in
                WeightCompactRecordRow(record: record, displayUnit: displayUnit, heightCm: defaultHeightCm)
            },
            onDelete: { record in
                recordToDelete = record
                showDeleteAlert = true
            },
            avgValueForDay: { dayRecords in
                let totalKg = dayRecords.map { $0.weight }.reduce(0, +)
                let avgKg = totalKg / Double(max(dayRecords.count, 1))
                return "Avg: \(formatWeight(avgKg)) \(displayUnit.rawValue)"
            }
        )
    }
}

// MARK: - Weight Compact Record Row
struct WeightCompactRecordRow: View {
    let record: WeightRecord
    let displayUnit: WeightUnit
    let heightCm: Double
    
    private var bmiValue: Double? {
        record.bmi(heightCm: heightCm)
    }
    
    private var bmiColor: Color {
        guard let bmi = bmiValue else { return .gray }
        if bmi < 18.5 { return .blue }
        else if bmi < 25 { return .green }
        else if bmi < 30 { return .yellow }
        else { return .orange }
    }
    
    private var bmiCategory: String {
        guard let bmi = bmiValue else { return "N/A" }
        if bmi < 18.5 { return "Under" }
        else if bmi < 25 { return "Normal" }
        else if bmi < 30 { return "Over" }
        else { return "Obese" }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: record.timestamp)
    }
    
    private var displayWeight: String {
        let value = displayUnit == .kg ? record.weight : record.weight * 2.20462
        return String(format: "%.1f", value)
    }
    
    var body: some View {
        GenericCompactRecordRow(
            time: timeString,
            icon: "scalemass.fill",
            iconColor: .orange,
            primaryValue: displayWeight,
            secondaryValue: displayUnit.rawValue,
            statusText: bmiCategory,
            statusColor: bmiColor
        )
    }
}

// MARK: - Weight Unit Enum
enum WeightUnit: String, CaseIterable {
    case kg = "kg"
    case lb = "lb"
}

#Preview {
    WeightHistoryView()
        .modelContainer(for: WeightRecord.self, inMemory: true)
}
