//
//  BloodPressureHistoryView.swift
//  HeartRateSenior
//
//  Blood Pressure History List View
//

import SwiftUI
import SwiftData

struct BloodPressureHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var records: [BloodPressureRecord]
    
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(records) { record in
                            BloodPressureRecordRow(record: record)
                        }
                        .onDelete(perform: deleteRecords)
                    }
                    .listStyle(.plain)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Blood Pressure")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                BloodPressureInputView()
            }
        }
    }
    
    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
    }
}

// MARK: - Empty State View
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: AppDimensions.paddingLarge) {
            Spacer()
            
            Image(systemName: "heart.text.square")
                .font(.system(size: 80))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            
            Text("No Records Yet")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Tap the + button to add your first blood pressure reading")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppDimensions.paddingXLarge)
            
            Spacer()
        }
    }
}

// MARK: - Record Row
struct BloodPressureRecordRow: View {
    let record: BloodPressureRecord
    
    var categoryColor: Color {
        switch record.category {
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .yellow
        case .hypertensionStage1: return .orange
        case .hypertensionStage2: return .red
        case .crisis: return .purple
        }
    }
    
    var body: some View {
        HStack(spacing: AppDimensions.paddingMedium) {
            // Category indicator
            Circle()
                .fill(categoryColor)
                .frame(width: 12, height: 12)
            
            // Values
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 2) {
                    Text(record.displayString)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("mmHg")
                        .font(AppTypography.small)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.bottom, 4)
                }
                
                HStack(spacing: 8) {
                    Text(record.category.rawValue)
                        .font(AppTypography.small)
                        .foregroundColor(categoryColor)
                    
                    if let pulse = record.pulse {
                        Text("•")
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.primaryRed)
                            Text("\(pulse) BPM")
                                .font(AppTypography.small)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Timestamp
            VStack(alignment: .trailing, spacing: 4) {
                Text(record.timestamp, style: .date)
                    .font(AppTypography.small)
                    .foregroundColor(AppColors.textSecondary)
                
                Text(record.timestamp, style: .time)
                    .font(AppTypography.small)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, AppDimensions.paddingSmall)
    }
}

#Preview {
    BloodPressureHistoryView()
}
