//
//  WeightInputView.swift
//  HeartRateSenior
//
//  Weight recording input view with BMI calculation
//

import SwiftUI
import SwiftData

struct WeightInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var weightString: String = ""
    @State private var useKg: Bool = true
    @State private var notes: String = ""
    @State private var showingSaveAlert = false
    
    // User height for BMI calculation (can be stored in UserDefaults)
    @AppStorage("userHeightCm") private var userHeightCm: Double = 170
    @State private var showingHeightPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Weight Input Card
                    VStack(spacing: 20) {
                        // Unit Toggle
                        Picker("Unit", selection: $useKg) {
                            Text("kg").tag(true)
                            Text("lbs").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 40)
                        
                        // Weight Input
                        VStack(spacing: 8) {
                            TextField(useKg ? "70.0" : "154.0", text: $weightString)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                                .frame(height: 100)
                            
                            Text(useKg ? "kg" : "lbs")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.vertical, 20)
                        
                        // Quick Adjust Buttons
                        HStack(spacing: 16) {
                            QuickAdjustButton(label: "-1", action: { adjustWeight(-1) })
                            QuickAdjustButton(label: "-0.5", action: { adjustWeight(-0.5) })
                            QuickAdjustButton(label: "+0.5", action: { adjustWeight(0.5) })
                            QuickAdjustButton(label: "+1", action: { adjustWeight(1) })
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // BMI Card
                    if let weight = currentWeightInKg, weight > 0 {
                        VStack(spacing: 12) {
                            HStack {
                                Text("BMI Calculator")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Button(action: { showingHeightPicker = true }) {
                                    HStack(spacing: 4) {
                                        Text("Height: \(Int(userHeightCm)) cm")
                                            .font(.system(size: 14, weight: .medium))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(AppColors.primaryRed)
                                }
                            }
                            
                            if let bmi = calculateBMI() {
                                HStack(spacing: 20) {
                                    // BMI Value
                                    VStack(spacing: 4) {
                                        Text(String(format: "%.1f", bmi))
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundColor(bmiColor(bmi))
                                        Text("BMI")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Divider()
                                        .frame(height: 50)
                                    
                                    // BMI Category
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(WeightRecord.bmiCategory(bmi: bmi))
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            .foregroundColor(bmiColor(bmi))
                                        Text(bmiDescription(bmi))
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(bmiColor(bmi).opacity(0.1))
                                )
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes (Optional)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        TextField("Add any notes...", text: $notes, axis: .vertical)
                            .lineLimit(3...5)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppColors.cardBackground)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Manual Record Disclaimer
                    VStack(spacing: 4) {
                        Text("This is a manual record for your personal reference.")
                        Text("BMI is for general guidance only. Consult a healthcare provider for advice.")
                    }
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Record Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWeight()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(currentWeightInKg != nil ? AppColors.primaryRed : AppColors.textSecondary)
                    .disabled(currentWeightInKg == nil)
                }
            }
            .sheet(isPresented: $showingHeightPicker) {
                HeightPickerView(heightCm: $userHeightCm)
            }
            .alert("Weight Saved", isPresented: $showingSaveAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your weight has been recorded successfully.")
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private var currentWeightInKg: Double? {
        guard let value = Double(weightString), value > 0 else { return nil }
        return useKg ? value : value / 2.20462
    }
    
    private func adjustWeight(_ amount: Double) {
        let current = Double(weightString) ?? (useKg ? 70.0 : 154.0)
        let newValue = max(0, current + amount)
        weightString = String(format: "%.1f", newValue)
        HapticManager.shared.selectionChanged()
    }
    
    private func calculateBMI() -> Double? {
        guard let weightKg = currentWeightInKg, weightKg > 0, userHeightCm > 0 else { return nil }
        let heightM = userHeightCm / 100
        return weightKg / (heightM * heightM)
    }
    
    private func bmiColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return Color(red: 0.3, green: 0.6, blue: 0.9)  // Blue
        case 18.5..<25: return Color(red: 0.2, green: 0.75, blue: 0.4) // Green
        case 25..<30: return Color(red: 0.95, green: 0.6, blue: 0.2) // Orange
        default: return Color(red: 0.9, green: 0.3, blue: 0.3) // Red
        }
    }
    
    private func bmiDescription(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Below healthy range"
        case 18.5..<25: return "Healthy weight range"
        case 25..<30: return "Above healthy range"
        default: return "Well above healthy range"
        }
    }
    
    private func saveWeight() {
        guard let weightKg = currentWeightInKg else { return }
        
        let record = WeightRecord(
            weight: weightKg,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(record)
        
        do {
            try modelContext.save()
            
            // Track weight input event
            Task { @MainActor in
                AppsFlyerManager.shared.trackWeightInput(weight: weightKg)
            }
            
            HapticManager.shared.success()
            showingSaveAlert = true
        } catch {
            print("Failed to save weight: \(error)")
            HapticManager.shared.error()
        }
    }
}

// MARK: - Quick Adjust Button
struct QuickAdjustButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.primaryRed)
                .frame(width: 60, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.primaryRed.opacity(0.1))
                )
        }
    }
}

// MARK: - Height Picker View
struct HeightPickerView: View {
    @Binding var heightCm: Double
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempHeight: Double = 170
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Select Your Height")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                // Height Display
                VStack(spacing: 8) {
                    Text("\(Int(tempHeight))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Text("cm (\(feetInchesString))")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Slider
                VStack(spacing: 12) {
                    Slider(value: $tempHeight, in: 100...220, step: 1)
                        .tint(AppColors.primaryRed)
                    
                    HStack {
                        Text("100 cm")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text("220 cm")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Height")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        heightCm = tempHeight
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.primaryRed)
                }
            }
            .onAppear {
                tempHeight = heightCm
            }
        }
    }
    
    private var feetInchesString: String {
        let totalInches = tempHeight / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return "\(feet)'\(inches)\""
    }
}

#Preview {
    WeightInputView()
        .modelContainer(for: WeightRecord.self, inMemory: true)
}
