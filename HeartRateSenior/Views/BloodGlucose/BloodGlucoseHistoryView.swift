//
//  BloodGlucoseHistoryView.swift
//  HeartRateSenior
//
//  Blood Glucose History View with statistics and date grouping
//

import SwiftUI
import SwiftData

struct BloodGlucoseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BloodGlucoseRecord.timestamp, order: .reverse) private var records: [BloodGlucoseRecord]
    
    @State private var showingAddSheet = false
    @State private var displayUnit: GlucoseUnit = .mgdL
    @State private var recordToDelete: BloodGlucoseRecord?
    @State private var showDeleteAlert = false
    
    // Convert value based on display unit
    private func convertValue(_ mgdL: Double) -> Double {
        switch displayUnit {
        case .mgdL: return mgdL
        case .mmolL: return mgdL / 18.0182
        }
    }
    
    private func formatValue(_ mgdL: Double) -> String {
        let converted = convertValue(mgdL)
        switch displayUnit {
        case .mgdL: return String(format: "%.0f", converted)
        case .mmolL: return String(format: "%.1f", converted)
        }
    }
    
    // Statistics with unit conversion
    private var stats: (avg: String, min: String, max: String) {
        guard !records.isEmpty else { return ("0", "0", "0") }
        let values = records.map { $0.value }
        let avg = values.reduce(0, +) / Double(values.count)
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        return (formatValue(avg), formatValue(min), formatValue(max))
    }
    
    // Category distribution
    private var categoryCounts: [BloodGlucoseCategory: Int] {
        var counts: [BloodGlucoseCategory: Int] = [:]
        for record in records {
            counts[record.category, default: 0] += 1
        }
        return counts
    }
    
    private var categoryDistribution: [(name: String, count: Int, color: Color)] {
        let counts = categoryCounts
        let normalCount = counts[.normal] ?? 0
        let lowCount = counts[.low] ?? 0
        let prediabetesCount = counts[.prediabetes] ?? 0
        let diabetesCount = counts[.diabetes] ?? 0
        let veryHighCount = counts[.veryHigh] ?? 0
        
        var result: [(name: String, count: Int, color: Color)] = []
        if normalCount > 0 { result.append(("Normal", normalCount, .green)) }
        if lowCount > 0 { result.append(("Low", lowCount, .blue)) }
        if prediabetesCount > 0 { result.append(("Pre-diabetes", prediabetesCount, .yellow)) }
        if diabetesCount > 0 { result.append(("Diabetes", diabetesCount, .orange)) }
        if veryHighCount > 0 { result.append(("Very High", veryHighCount, .red)) }
        return result
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    GenericEmptyStateView(
                        icon: "drop.fill",
                        title: "No Records Yet",
                        message: "Tap the + button to add your first blood glucose reading",
                        color: .purple
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // 1. Statistics Summary
                            GenericStatsSummaryCard(
                                title: "Blood Glucose",
                                icon: "drop.fill",
                                color: .purple,
                                avgValue: stats.avg,
                                minValue: stats.min,
                                maxValue: stats.max,
                                totalCount: records.count,
                                unit: displayUnit.rawValue
                            )
                            
                            // 2. Category Distribution
                            if !categoryDistribution.isEmpty {
                                GenericCategoryCard(
                                    title: "Category Distribution",
                                    categories: categoryDistribution,
                                    total: records.count
                                )
                            }
                            
                            // 3. Consistency Card
                            GenericConsistencyCard(
                                title: "Measurement Consistency",
                                icon: "drop.fill",
                                color: .purple,
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
            .navigationTitle("Blood Glucose")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("Unit", selection: $displayUnit) {
                        Text("mg/dL").tag(GlucoseUnit.mgdL)
                        Text("mmol/L").tag(GlucoseUnit.mmolL)
                    }
                    .pickerStyle(.menu)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                BloodGlucoseInputView()
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
                BGCompactRecordRow(record: record, displayUnit: displayUnit)
            },
            onDelete: { record in
                recordToDelete = record
                showDeleteAlert = true
            },
            avgValueForDay: { dayRecords in
                let totalMgdL = dayRecords.map { $0.value }.reduce(0, +)
                let avgMgdL = totalMgdL / Double(max(dayRecords.count, 1))
                return "Avg: \(formatValue(avgMgdL)) \(displayUnit.rawValue)"
            }
        )
    }
}

// MARK: - BG Compact Record Row
struct BGCompactRecordRow: View {
    let record: BloodGlucoseRecord
    let displayUnit: GlucoseUnit
    
    private var categoryColor: Color {
        switch record.category {
        case .low: return .blue
        case .normal: return .green
        case .prediabetes: return .yellow
        case .diabetes: return .orange
        case .veryHigh: return .red
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: record.timestamp)
    }
    
    var body: some View {
        GenericCompactRecordRow(
            time: timeString,
            icon: record.context.icon,
            iconColor: .purple,
            primaryValue: record.displayString(unit: displayUnit),
            secondaryValue: displayUnit.rawValue,
            statusText: record.category.rawValue,
            statusColor: categoryColor
        )
    }
}

#Preview {
    BloodGlucoseHistoryView()
        .modelContainer(for: BloodGlucoseRecord.self, inMemory: true)
}
