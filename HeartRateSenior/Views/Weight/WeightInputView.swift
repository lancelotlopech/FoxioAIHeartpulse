//
//  WeightInputView.swift
//  HeartRateSenior
//
//  Weight Input View - Redesigned to match BP template
//

import SwiftUI
import SwiftData

struct WeightInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var weightValue: Double = 70.0
    @State private var useKg: Bool = true
    @State private var notes: String = ""
    @State private var showingSaveAlert = false
    
    // User height for BMI calculation
    @AppStorage("userHeightCm") private var userHeightCm: Double = 170
    @State private var showingHeightPicker = false
    
    // Theme color — matches Dashboard Weight card icon color
    private let themeColor = Color(hex: "9B51E0")
    private let themeBgLight = Color(hex: "E9DDFB")
    
    // Text colors (shared with BP template)
    private let textDark = Color(hex: "0F172A")
    private let textBody = Color(hex: "2D3748")
    private let textMuted = Color(hex: "94A3B8")
    private let textCancel = Color(hex: "64748B")
    private let textLabel = Color(hex: "334155")
    
    // Backgrounds
    private let bgPage = Color.white
    private let borderLight = Color(hex: "E2E8F0")
    private let bgControl = Color(hex: "F1F5F9")
    private let iconControl = Color(hex: "475569")
    
    // Ranges
    private var weightMin: Double { useKg ? 20.0 : 44.0 }
    private var weightMax: Double { useKg ? 250.0 : 551.0 }
    private var weightStep: Double { 0.1 }
    
    private var weightInKg: Double {
        useKg ? weightValue : weightValue / 2.20462
    }
    
    private var bmiValue: Double? {
        guard userHeightCm > 0 else { return nil }
        let heightM = userHeightCm / 100
        return weightInKg / (heightM * heightM)
    }
    
    private var bmiCategory: String {
        guard let bmi = bmiValue else { return "—" }
        return WeightRecord.bmiCategory(bmi: bmi)
    }
    
    private var bmiColor: Color {
        guard let bmi = bmiValue else { return textMuted }
        switch bmi {
        case ..<18.5: return Color(hex: "4A90E2")
        case 18.5..<25: return Color(hex: "00C9A7")
        case 25..<30: return Color(hex: "F2994A")
        default: return Color(hex: "EB5757")
        }
    }
    
    private var bmiIcon: String {
        guard let bmi = bmiValue else { return "scalemass" }
        switch bmi {
        case ..<18.5: return "arrow.down.circle.fill"
        case 18.5..<25: return "checkmark.circle.fill"
        case 25..<30: return "exclamationmark.triangle.fill"
        default: return "exclamationmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topNavBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    bigNumberDisplay
                        .padding(.top, 8)
                    
                    bmiCapsule
                    
                    dividerLine
                    
                    unitToggle
                    
                    sliderSection
                    
                    bmiCard
                    
                    heightCard
                    
                    notesCard
                    
                    saveButton
                        .padding(.horizontal, 24)
                    
                    disclaimer
                }
                .padding(.bottom, 40)
            }
        }
        .background(bgPage.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showingHeightPicker) {
            HeightPickerView(heightCm: $userHeightCm)
        }
        .alert("Weight Saved", isPresented: $showingSaveAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your weight has been recorded successfully.")
        }
    }
    
    // MARK: - Top Nav Bar
    private var topNavBar: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(textCancel)
            
            Spacer()
            
            Text("New Entry")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(textDark)
            
            Spacer()
            
            Button("Save") { saveWeight() }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(themeColor)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(Color.white)
    }
    
    // MARK: - Big Number Display
    private var bigNumberDisplay: some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", weightValue))
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(textBody)
                    .minimumScaleFactor(0.7)
                
                Text(useKg ? "kg" : "lbs")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(textMuted)
            }
            
            Text("WEIGHT")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(textMuted)
                .tracking(0.5)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - BMI Capsule
    private var bmiCapsule: some View {
        HStack(spacing: 6) {
            Image(systemName: bmiIcon)
                .font(.system(size: 16))
                .foregroundColor(bmiColor)
            
            if let bmi = bmiValue {
                Text("BMI \(String(format: "%.1f", bmi)) · \(bmiCategory)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(bmiColor)
            } else {
                Text("Set height for BMI")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(textMuted)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Capsule().fill(bmiColor.opacity(0.12)))
    }
    
    // MARK: - Divider
    private var dividerLine: some View {
        Rectangle()
            .fill(borderLight)
            .frame(height: 1)
            .padding(.horizontal, 24)
    }
    
    // MARK: - Unit Toggle
    private var unitToggle: some View {
        Picker("Unit", selection: $useKg) {
            Text("kg").tag(true)
            Text("lbs").tag(false)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 24)
        .onChange(of: useKg) { oldVal, newVal in
            if oldVal == true && newVal == false {
                // kg -> lbs
                weightValue = weightValue * 2.20462
            } else if oldVal == false && newVal == true {
                // lbs -> kg
                weightValue = weightValue / 2.20462
            }
        }
    }
    
    // MARK: - Slider Section
    private var sliderSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Weight")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(textLabel)
                
                Text(useKg ? "kg" : "lbs")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(textMuted)
                
                Spacer()
                
                Text(String(format: "%.1f", weightValue))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(themeColor)
                    .monospacedDigit()
                    .frame(minWidth: 60, alignment: .trailing)
            }
            
            HStack(spacing: 10) {
                Button {
                    if weightValue > weightMin {
                        weightValue -= weightStep
                        weightValue = max(weightValue, weightMin)
                        HapticManager.shared.lightImpact()
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(iconControl)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(bgControl))
                }
                
                Slider(
                    value: $weightValue,
                    in: weightMin...weightMax,
                    step: weightStep
                )
                .tint(themeColor)
                
                Button {
                    if weightValue < weightMax {
                        weightValue += weightStep
                        weightValue = min(weightValue, weightMax)
                        HapticManager.shared.lightImpact()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(iconControl)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(bgControl))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - BMI Card
    private var bmiCard: some View {
        VStack(spacing: 10) {
            HStack {
                Text("BMI Analysis")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(textLabel)
                Spacer()
                
                if let bmi = bmiValue {
                    HStack(spacing: 4) {
                        Image(systemName: bmiIcon)
                            .font(.system(size: 12))
                        Text("\(String(format: "%.1f", bmi)) — \(bmiCategory)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(bmiColor)
                }
            }
            
            // BMI gradient bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "4A90E2"))  // Underweight
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "00C9A7"))  // Normal
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "F2994A"))  // Overweight
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "EB5757"))  // Obese
                    }
                    .frame(height: 8)
                    
                    if let bmi = bmiValue {
                        let position = bmiIndicatorPosition(bmi: bmi, width: geo.size.width)
                        Rectangle()
                            .fill(bmiColor)
                            .frame(width: 3, height: 18)
                            .cornerRadius(1.5)
                            .offset(x: position - 1.5, y: -5)
                    }
                }
            }
            .frame(height: 18)
            
            HStack {
                Text("UNDERWEIGHT")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "4A90E2"))
                    .tracking(0.5)
                Spacer()
                Text("OBESE")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "EB5757"))
                    .tracking(0.5)
            }
            
            if let bmi = bmiValue {
                Text(bmiDescription(bmi))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Height Card
    private var heightCard: some View {
        Button(action: { showingHeightPicker = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Height")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(textLabel)
                    
                    Text("\(Int(userHeightCm)) cm")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(themeColor)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 24)
    }
    
    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(textLabel)
            
            TextField("Add notes about this reading...", text: $notes, axis: .vertical)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(textBody)
                .lineLimit(3...5)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveWeight) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Save Entry")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeColor)
                    .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    // MARK: - Disclaimer
    private var disclaimer: some View {
        VStack(spacing: 4) {
            Text("This is a manual record for your personal reference.")
            Text("BMI is for general guidance only. Consult a healthcare provider for advice.")
        }
        .font(.system(size: 11, weight: .regular, design: .rounded))
        .foregroundColor(textMuted.opacity(0.6))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.top, 4)
    }
    
    // MARK: - Helpers
    
    private func bmiIndicatorPosition(bmi: Double, width: CGFloat) -> CGFloat {
        let minBMI: Double = 14
        let maxBMI: Double = 40
        let clamped = min(max(bmi, minBMI), maxBMI)
        let ratio = (clamped - minBMI) / (maxBMI - minBMI)
        return CGFloat(ratio) * width
    }
    
    private func bmiDescription(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Below healthy range. Consider consulting a healthcare provider."
        case 18.5..<25: return "Healthy weight range. Keep up the good work!"
        case 25..<30: return "Above healthy range. Consider lifestyle adjustments."
        default: return "Well above healthy range. Please consult a healthcare provider."
        }
    }
    
    private func saveWeight() {
        HapticManager.shared.mediumImpact()
        
        let record = WeightRecord(
            weight: weightInKg,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(record)
        
        Task { @MainActor in
            AppsFlyerManager.shared.trackWeightInput(weight: weightInKg)
        }
        
        HapticManager.shared.success()
        showingSaveAlert = true
    }
}

// MARK: - Height Picker View
struct HeightPickerView: View {
    @Binding var heightCm: Double
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempHeight: Double = 170
    
    private let themeColor = Color(hex: "9B51E0")
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Select Your Height")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "0F172A"))
                
                VStack(spacing: 8) {
                    Text("\(Int(tempHeight))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "2D3748"))
                    Text("cm (\(feetInchesString))")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "94A3B8"))
                }
                
                VStack(spacing: 12) {
                    Slider(value: $tempHeight, in: 100...220, step: 1)
                        .tint(themeColor)
                    
                    HStack {
                        Text("100 cm")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "94A3B8"))
                        Spacer()
                        Text("220 cm")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "94A3B8"))
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
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        heightCm = tempHeight
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(themeColor)
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
