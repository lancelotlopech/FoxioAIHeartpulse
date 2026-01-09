//
//  BloodPressureInputView.swift
//  HeartRateSenior
//
//  Blood Pressure Input View with Wheel Pickers
//

import SwiftUI
import SwiftData

struct BloodPressureInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var systolic: Int = 120
    @State private var diastolic: Int = 80
    @State private var pulse: Int = 72
    @State private var includePulse: Bool = false
    @State private var note: String = ""
    @State private var showingSaveConfirmation = false
    
    // Ranges for pickers
    private let systolicRange = Array(60...250)
    private let diastolicRange = Array(40...150)
    private let pulseRange = Array(40...200)
    
    var category: BloodPressureCategory {
        BloodPressureCategory.category(systolic: systolic, diastolic: diastolic)
    }
    
    var categoryColor: Color {
        switch category {
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .yellow
        case .hypertensionStage1: return .orange
        case .hypertensionStage2: return .red
        case .crisis: return .purple
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppDimensions.paddingLarge) {
                    // Blood Pressure Display
                    VStack(spacing: AppDimensions.paddingSmall) {
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("\(systolic)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(categoryColor)
                            
                            Text("/")
                                .font(.system(size: 48, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("\(diastolic)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(categoryColor)
                        }
                        
                        Text("mmHg")
                            .font(AppTypography.title)
                            .foregroundColor(AppColors.textSecondary)
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
                    
                    // Wheel Pickers
                    HStack(spacing: 0) {
                        // Systolic Picker
                        VStack(spacing: 4) {
                            Text("Systolic")
                                .font(AppTypography.small)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Picker("Systolic", selection: $systolic) {
                                ForEach(systolicRange, id: \.self) { value in
                                    Text("\(value)")
                                        .tag(value)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100, height: 150)
                            .clipped()
                        }
                        
                        Text("/")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.top, 20)
                        
                        // Diastolic Picker
                        VStack(spacing: 4) {
                            Text("Diastolic")
                                .font(AppTypography.small)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Picker("Diastolic", selection: $diastolic) {
                                ForEach(diastolicRange, id: \.self) { value in
                                    Text("\(value)")
                                        .tag(value)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100, height: 150)
                            .clipped()
                        }
                    }
                    .padding(.vertical, AppDimensions.paddingMedium)
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppDimensions.cornerRadiusLarge)
                    .padding(.horizontal, AppDimensions.paddingMedium)
                    
                    // Optional Pulse
                    VStack(spacing: AppDimensions.paddingMedium) {
                        Toggle(isOn: $includePulse) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(AppColors.primaryRed)
                                Text("Include Pulse")
                                    .font(AppTypography.body)
                            }
                        }
                        .tint(AppColors.primaryRed)
                        
                        if includePulse {
                            HStack {
                                Text("Pulse:")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Picker("Pulse", selection: $pulse) {
                                    ForEach(pulseRange, id: \.self) { value in
                                        Text("\(value) BPM")
                                            .tag(value)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
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
            .navigationTitle("Blood Pressure")
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
                Text("Your blood pressure has been recorded.")
            }
        }
    }
    
    private func saveRecord() {
        HapticManager.shared.mediumImpact()
        
        let record = BloodPressureRecord(
            systolic: systolic,
            diastolic: diastolic,
            pulse: includePulse ? pulse : nil,
            timestamp: Date(),
            note: note.isEmpty ? nil : note
        )
        
        modelContext.insert(record)
        
        // Track blood pressure input event
        Task { @MainActor in
            AppsFlyerManager.shared.trackBloodPressureInput(systolic: systolic, diastolic: diastolic)
        }
        
        HapticManager.shared.success()
        showingSaveConfirmation = true
    }
}

#Preview {
    BloodPressureInputView()
}
