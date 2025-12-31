//
//  BloodGlucoseInputView.swift
//  HeartRateSenior
//
//  Blood Glucose Input View
//

import SwiftUI
import SwiftData

struct BloodGlucoseInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var glucoseValue: Double = 100
    @State private var selectedContext: MealContext = .fasting
    @State private var note: String = ""
    @State private var showingSaveConfirmation = false
    
    // Use mg/dL as default (US standard)
    @State private var unit: GlucoseUnit = .mgdL
    
    // Ranges for picker
    private var glucoseRange: [Double] {
        switch unit {
        case .mgdL:
            return Array(stride(from: 20.0, through: 500.0, by: 1.0))
        case .mmolL:
            return Array(stride(from: 1.0, through: 28.0, by: 0.1))
        }
    }
    
    var category: BloodGlucoseCategory {
        let mgdLValue = unit == .mgdL ? glucoseValue : GlucoseUnit.toMgdL(glucoseValue)
        return BloodGlucoseCategory.category(value: mgdLValue, context: selectedContext)
    }
    
    var categoryColor: Color {
        switch category {
        case .low: return .blue
        case .normal: return .green
        case .prediabetes: return .yellow
        case .diabetes: return .orange
        case .veryHigh: return .red
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppDimensions.paddingLarge) {
                    // Glucose Display
                    VStack(spacing: AppDimensions.paddingSmall) {
                        HStack(alignment: .bottom, spacing: 4) {
                            Text(displayValue)
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(categoryColor)
                            
                            Text(unit.rawValue)
                                .font(AppTypography.title)
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.bottom, 12)
                        }
                    }
                    .padding(.top, AppDimensions.paddingLarge)
                    
                    // Status Badge
                    HStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .foregroundColor(categoryColor)
                        
                        Text(category.rawValue)
                            .font(AppTypography.button)
                            .foregroundColor(categoryColor)
                    }
                    .padding(.horizontal, AppDimensions.paddingMedium)
                    .padding(.vertical, AppDimensions.paddingSmall)
                    .background(categoryColor.opacity(0.15))
                    .cornerRadius(AppDimensions.cornerRadius)
                    
                    // Description
                    Text(category.description)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    // Unit Toggle
                    Picker("Unit", selection: $unit) {
                        ForEach(GlucoseUnit.allCases, id: \.self) { u in
                            Text(u.rawValue).tag(u)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, AppDimensions.paddingLarge)
                    .onChange(of: unit) { oldUnit, newUnit in
                        // Convert value when switching units
                        if oldUnit == .mgdL && newUnit == .mmolL {
                            glucoseValue = GlucoseUnit.toMmolL(glucoseValue)
                        } else if oldUnit == .mmolL && newUnit == .mgdL {
                            glucoseValue = GlucoseUnit.toMgdL(glucoseValue)
                        }
                    }
                    
                    // Value Picker
                    VStack(spacing: 4) {
                        Text("Glucose Value")
                            .font(AppTypography.small)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Picker("Glucose", selection: $glucoseValue) {
                            ForEach(glucoseRange, id: \.self) { value in
                                Text(formatValue(value))
                                    .tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                    }
                    .padding(AppDimensions.paddingMedium)
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppDimensions.cornerRadiusLarge)
                    .padding(.horizontal, AppDimensions.paddingMedium)
                    
                    // Meal Context Selection
                    VStack(alignment: .leading, spacing: AppDimensions.paddingMedium) {
                        Text("When was this taken?")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: AppDimensions.paddingSmall) {
                            ForEach(MealContext.allCases) { context in
                                MealContextChip(
                                    context: context,
                                    isSelected: selectedContext == context,
                                    action: {
                                        HapticManager.shared.selectionChanged()
                                        selectedContext = context
                                    }
                                )
                            }
                        }
                    }
                    .padding(AppDimensions.paddingMedium)
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppDimensions.cornerRadiusLarge)
                    .padding(.horizontal, AppDimensions.paddingMedium)
                    
                    // Note Field
                    VStack(alignment: .leading, spacing: AppDimensions.paddingSmall) {
                        Text("Note (Optional)")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TextField("Add a note...", text: $note, axis: .vertical)
                            .font(AppTypography.body)
                            .padding(AppDimensions.paddingMedium)
                            .background(AppColors.cardBackground)
                            .cornerRadius(AppDimensions.cornerRadius)
                            .lineLimit(3...5)
                    }
                    .padding(.horizontal, AppDimensions.paddingMedium)
                    
                    // Save Button
                    Button(action: saveRecord) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Record")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SeniorButtonStyle())
                    .padding(.horizontal, AppDimensions.paddingLarge)
                    .padding(.top, AppDimensions.paddingMedium)
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Blood Glucose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Record Saved!", isPresented: $showingSaveConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your blood glucose has been recorded.")
            }
        }
    }
    
    private var displayValue: String {
        switch unit {
        case .mgdL:
            return String(format: "%.0f", glucoseValue)
        case .mmolL:
            return String(format: "%.1f", glucoseValue)
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        switch unit {
        case .mgdL:
            return String(format: "%.0f", value)
        case .mmolL:
            return String(format: "%.1f", value)
        }
    }
    
    private func saveRecord() {
        HapticManager.shared.mediumImpact()
        
        let record = BloodGlucoseRecord(
            value: glucoseValue,
            unit: unit,
            mealContext: selectedContext,
            timestamp: Date(),
            note: note.isEmpty ? nil : note
        )
        
        modelContext.insert(record)
        HapticManager.shared.success()
        showingSaveConfirmation = true
    }
}

// MARK: - Meal Context Chip
struct MealContextChip: View {
    let context: MealContext
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppDimensions.paddingSmall) {
                Image(systemName: context.icon)
                    .font(.system(size: 16))
                
                Text(context.rawValue)
                    .font(AppTypography.small)
            }
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isSelected ? AppColors.primaryRed : AppColors.background)
            .cornerRadius(AppDimensions.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                    .stroke(isSelected ? AppColors.primaryRed : AppColors.textSecondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BloodGlucoseInputView()
        .environmentObject(SettingsManager())
}
