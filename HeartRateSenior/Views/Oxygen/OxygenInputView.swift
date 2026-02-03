//
//  OxygenInputView.swift
//  HeartRateSenior
//
//  Blood oxygen saturation (SpO2) recording input view
//

import SwiftUI
import SwiftData

struct OxygenInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var spo2Value: Int = 98
    @State private var notes: String = ""
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // SpO2 Input Card
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.cyan.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "lungs.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.cyan)
                        }
                        
                        // SpO2 Value
                        VStack(spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(spo2Value)")
                                    .font(.system(size: 80, weight: .bold, design: .rounded))
                                    .foregroundColor(categoryColor)
                                
                                Text("%")
                                    .font(.system(size: 32, weight: .medium, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Text("Oxygen Saturation")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        // Stepper Controls
                        HStack(spacing: 20) {
                            // Decrease Button
                            Button(action: {
                                if spo2Value > 70 {
                                    spo2Value -= 1
                                    HapticManager.shared.selectionChanged()
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(AppColors.primaryRed.opacity(spo2Value > 70 ? 1 : 0.3))
                                    )
                            }
                            .disabled(spo2Value <= 70)
                            
                            // Slider
                            Slider(value: Binding(
                                get: { Double(spo2Value) },
                                set: { spo2Value = Int($0) }
                            ), in: 70...100, step: 1)
                            .tint(categoryColor)
                            .frame(width: 150)
                            .onChange(of: spo2Value) { _, _ in
                                HapticManager.shared.selectionChanged()
                            }
                            
                            // Increase Button
                            Button(action: {
                                if spo2Value < 100 {
                                    spo2Value += 1
                                    HapticManager.shared.selectionChanged()
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(AppColors.primaryRed.opacity(spo2Value < 100 ? 1 : 0.3))
                                    )
                            }
                            .disabled(spo2Value >= 100)
                        }
                        
                        // Quick Preset Buttons
                        HStack(spacing: 12) {
                            ForEach([95, 96, 97, 98, 99], id: \.self) { value in
                                Button(action: {
                                    spo2Value = value
                                    HapticManager.shared.selectionChanged()
                                }) {
                                    Text("\(value)%")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(spo2Value == value ? .white : AppColors.primaryRed)
                                        .frame(width: 54, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(spo2Value == value ? AppColors.primaryRed : AppColors.primaryRed.opacity(0.1))
                                        )
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Status Card
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: category.icon)
                                .font(.system(size: 24))
                                .foregroundColor(categoryColor)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.rawValue)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(categoryColor)
                                
                                Text(category.description)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(categoryColor.opacity(0.1))
                    )
                    .padding(.horizontal, 20)
                    
                    // Reference Guide
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reference Guide")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        VStack(spacing: 8) {
                            ReferenceRow(range: "95-100%", label: "Normal", color: Color(red: 0.2, green: 0.75, blue: 0.4))
                            ReferenceRow(range: "91-94%", label: "Mild Low", color: Color(red: 0.95, green: 0.7, blue: 0.2))
                            ReferenceRow(range: "86-90%", label: "Moderate Low", color: Color(red: 0.95, green: 0.5, blue: 0.2))
                            ReferenceRow(range: "<86%", label: "Severe Low", color: Color(red: 0.9, green: 0.3, blue: 0.3))
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
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
                        Text("Not a medical measurement. Consult a healthcare provider for diagnosis.")
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
            .navigationTitle("Blood Oxygen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveOxygen()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppColors.primaryRed)
                }
            }
            .alert("Saved", isPresented: $showingSaveAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your blood oxygen level has been recorded.")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var category: OxygenCategory {
        switch spo2Value {
        case 95...100: return .normal
        case 91...94: return .mild
        case 86...90: return .moderate
        default: return .severe
        }
    }
    
    private var categoryColor: Color {
        category.color
    }
    
    // MARK: - Save Function
    
    private func saveOxygen() {
        let record = OxygenRecord(
            spo2: spo2Value,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(record)
        
        do {
            try modelContext.save()
            
            // Track oxygen input event
            Task { @MainActor in
                AppsFlyerManager.shared.trackOxygenInput(value: spo2Value)
            }
            
            HapticManager.shared.success()
            showingSaveAlert = true
        } catch {
            print("Failed to save oxygen: \(error)")
            HapticManager.shared.error()
        }
    }
}

// MARK: - Reference Row
struct ReferenceRow: View {
    let range: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(range)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 80, alignment: .leading)
            
            Text(label)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OxygenInputView()
        .modelContainer(for: OxygenRecord.self, inMemory: true)
}
