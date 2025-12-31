//
//  BloodGlucoseHistoryView.swift
//  HeartRateSenior
//
//  Blood Glucose History List View
//

import SwiftUI
import SwiftData

struct BloodGlucoseHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BloodGlucoseRecord.timestamp, order: .reverse) private var records: [BloodGlucoseRecord]
    
    @State private var showingAddSheet = false
    @State private var displayUnit: GlucoseUnit = .mgdL
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(records) { record in
                            BloodGlucoseRecordRow(record: record, displayUnit: displayUnit)
                        }
                        .onDelete(perform: deleteRecords)
                    }
                    .listStyle(.plain)
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
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                BloodGlucoseInputView()
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
            
            Image(systemName: "drop.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            
            Text("No Records Yet")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Tap the + button to add your first blood glucose reading")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppDimensions.paddingXLarge)
            
            Spacer()
        }
    }
}

// MARK: - Record Row
struct BloodGlucoseRecordRow: View {
    let record: BloodGlucoseRecord
    let displayUnit: GlucoseUnit
    
    var categoryColor: Color {
        switch record.category {
        case .low: return .blue
        case .normal: return .green
        case .prediabetes: return .yellow
        case .diabetes: return .orange
        case .veryHigh: return .red
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
                    Text(record.displayString(unit: displayUnit))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(displayUnit.rawValue)
                        .font(AppTypography.small)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.bottom, 4)
                }
                
                HStack(spacing: 8) {
                    // Meal context
                    HStack(spacing: 4) {
                        Image(systemName: record.context.icon)
                            .font(.system(size: 12))
                        Text(record.context.rawValue)
                            .font(AppTypography.small)
                    }
                    .foregroundColor(AppColors.textSecondary)
                    
                    Text("•")
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(record.category.rawValue)
                        .font(AppTypography.small)
                        .foregroundColor(categoryColor)
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
    BloodGlucoseHistoryView()
}
