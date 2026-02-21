//
//  BloodPressureHistoryView.swift
//  HeartRateSenior
//
//  Blood Pressure History View with statistics and date grouping
//

import SwiftUI
import SwiftData

struct BloodPressureHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var records: [BloodPressureRecord]
    
    @State private var showingAddSheet = false
    @State private var recordToDelete: BloodPressureRecord?
    @State private var showDeleteAlert = false
    
    // Statistics
    private var stats: (avgSys: Int, avgDia: Int, minSys: Int, maxSys: Int) {
        guard !records.isEmpty else { return (0, 0, 0, 0) }
        let systolics = records.map { $0.systolic }
        let diastolics = records.map { $0.diastolic }
        return (
            systolics.reduce(0, +) / systolics.count,
            diastolics.reduce(0, +) / diastolics.count,
            systolics.min() ?? 0,
            systolics.max() ?? 0
        )
    }
    
    // Category distribution
    private var categoryDistribution: [(name: String, count: Int, color: Color)] {
        var counts: [BloodPressureCategory: Int] = [:]
        for record in records {
            counts[record.category, default: 0] += 1
        }
        
        return [
            ("Normal", counts[.normal] ?? 0, .green),
            ("Elevated", counts[.elevated] ?? 0, .yellow),
            ("Stage 1", counts[.hypertensionStage1] ?? 0, .orange),
            ("Stage 2", counts[.hypertensionStage2] ?? 0, .red),
            ("Low", counts[.low] ?? 0, .blue),
            ("Crisis", counts[.crisis] ?? 0, .purple)
        ].filter { $0.count > 0 }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    GenericEmptyStateView(
                        icon: "heart.text.square.fill",
                        title: "No Records Yet",
                        message: "Tap the + button to add your first blood pressure reading",
                        color: .blue
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // 1. Statistics Summary
                            GenericStatsSummaryCard(
                                title: "Blood Pressure",
                                icon: "heart.text.square.fill",
                                color: .blue,
                                avgValue: "\(stats.avgSys)/\(stats.avgDia)",
                                minValue: "\(stats.minSys)",
                                maxValue: "\(stats.maxSys)",
                                totalCount: records.count,
                                unit: "mmHg"
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
                                icon: "heart.text.square.fill",
                                color: .blue,
                                recordDates: records.map { $0.timestamp }
                            )
                            
                            // 4. Date Grouped Records
                            GenericDateGroupedSection(
                                title: "All Records",
                                records: records,
                                dateKeyPath: \.timestamp,
                                rowContent: { record in
                                    BPCompactRecordRow(record: record)
                                },
                                onDelete: { record in
                                    recordToDelete = record
                                    showDeleteAlert = true
                                },
                                avgValueForDay: { dayRecords in
                                    let avgSys = dayRecords.map { $0.systolic }.reduce(0, +) / max(dayRecords.count, 1)
                                    let avgDia = dayRecords.map { $0.diastolic }.reduce(0, +) / max(dayRecords.count, 1)
                                    return "Avg: \(avgSys)/\(avgDia)"
                                }
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .background(AppColors.background)
            .navigationTitle("Blood Pressure")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingAddSheet) {
                BloodPressureInputView()
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

// MARK: - BP Compact Record Row
struct BPCompactRecordRow: View {
    let record: BloodPressureRecord
    
    private var categoryColor: Color {
        switch record.category {
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .yellow
        case .hypertensionStage1: return .orange
        case .hypertensionStage2: return .red
        case .crisis: return .purple
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
            icon: "heart.text.square.fill",
            iconColor: .blue,
            primaryValue: record.displayString,
            secondaryValue: "mmHg",
            statusText: record.category.rawValue,
            statusColor: categoryColor
        )
    }
}

#Preview {
    BloodPressureHistoryView()
        .modelContainer(for: BloodPressureRecord.self, inMemory: true)
}
