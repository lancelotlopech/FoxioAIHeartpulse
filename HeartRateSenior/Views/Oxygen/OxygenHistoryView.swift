//
//  OxygenHistoryView.swift
//  HeartRateSenior
//
//  Blood Oxygen History View with statistics and date grouping
//

import SwiftUI
import SwiftData

struct OxygenHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \OxygenRecord.timestamp, order: .reverse) private var records: [OxygenRecord]
    
    @State private var showingAddSheet = false
    @State private var recordToDelete: OxygenRecord?
    @State private var showDeleteAlert = false
    
    // Statistics
    private var stats: (avg: Int, min: Int, max: Int) {
        guard !records.isEmpty else { return (0, 0, 0) }
        let values = records.map { $0.spo2 }
        return (
            values.reduce(0, +) / values.count,
            values.min() ?? 0,
            values.max() ?? 0
        )
    }
    
    // Category distribution
    private var categoryDistribution: [(name: String, count: Int, color: Color)] {
        var counts: [OxygenCategory: Int] = [:]
        for record in records {
            counts[record.category, default: 0] += 1
        }
        
        var result: [(name: String, count: Int, color: Color)] = []
        if let c = counts[.normal], c > 0 { result.append(("Normal", c, .green)) }
        if let c = counts[.mild], c > 0 { result.append(("Mild", c, .yellow)) }
        if let c = counts[.moderate], c > 0 { result.append(("Moderate", c, .orange)) }
        if let c = counts[.severe], c > 0 { result.append(("Severe", c, .red)) }
        return result
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    GenericEmptyStateView(
                        icon: "lungs.fill",
                        title: "No Records Yet",
                        message: "Tap the + button to add your first blood oxygen reading",
                        color: .cyan
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // 1. Statistics Summary
                            GenericStatsSummaryCard(
                                title: "Blood Oxygen",
                                icon: "lungs.fill",
                                color: .cyan,
                                avgValue: "\(stats.avg)",
                                minValue: "\(stats.min)",
                                maxValue: "\(stats.max)",
                                totalCount: records.count,
                                unit: "%"
                            )
                            
                            // 2. Category Distribution
                            if !categoryDistribution.isEmpty {
                                GenericCategoryCard(
                                    title: "SpO2 Distribution",
                                    categories: categoryDistribution,
                                    total: records.count
                                )
                            }
                            
                            // 3. Consistency Card
                            GenericConsistencyCard(
                                title: "Measurement Consistency",
                                icon: "lungs.fill",
                                color: .cyan,
                                recordDates: records.map { $0.timestamp }
                            )
                            
                            // 4. Date Grouped Records
                            GenericDateGroupedSection(
                                title: "All Records",
                                records: records,
                                dateKeyPath: \.timestamp,
                                rowContent: { record in
                                    OxygenCompactRecordRow(record: record)
                                },
                                onDelete: { record in
                                    recordToDelete = record
                                    showDeleteAlert = true
                                },
                                avgValueForDay: { dayRecords in
                                    let avg = dayRecords.map { $0.spo2 }.reduce(0, +) / max(dayRecords.count, 1)
                                    return "Avg: \(avg)%"
                                }
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .background(AppColors.background)
            .navigationTitle("Blood Oxygen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.cyan)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                OxygenInputView()
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
}

// MARK: - Oxygen Compact Record Row
struct OxygenCompactRecordRow: View {
    let record: OxygenRecord
    
    private var categoryColor: Color {
        switch record.category {
        case .normal: return .green
        case .mild: return .yellow
        case .moderate: return .orange
        case .severe: return .red
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
            icon: "lungs.fill",
            iconColor: .cyan,
            primaryValue: "\(record.spo2)",
            secondaryValue: "%",
            statusText: record.category.rawValue,
            statusColor: categoryColor
        )
    }
}

#Preview {
    OxygenHistoryView()
        .modelContainer(for: OxygenRecord.self, inMemory: true)
}
