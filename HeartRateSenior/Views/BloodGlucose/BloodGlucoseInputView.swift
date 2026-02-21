//
//  BloodGlucoseInputView.swift
//  HeartRateSenior
//
//  Blood Glucose Input View - Redesigned to match BP template
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
    @State private var unit: GlucoseUnit = .mgdL
    
    // Theme color — matches Dashboard Blood Glucose card icon color
    private let themeColor = Color(hex: "4A90E2")
    private let themeBgLight = Color(hex: "EDF4FD")
    
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
    private var glucoseMin: Double { unit == .mgdL ? 20 : 1.0 }
    private var glucoseMax: Double { unit == .mgdL ? 500 : 28.0 }
    private var glucoseStep: Double { unit == .mgdL ? 1 : 0.1 }
    
    var category: BloodGlucoseCategory {
        let mgdLValue = unit == .mgdL ? glucoseValue : GlucoseUnit.toMgdL(glucoseValue)
        return BloodGlucoseCategory.category(value: mgdLValue, context: selectedContext)
    }
    
    var categoryColor: Color {
        switch category {
        case .low: return Color(hex: "4A90E2")
        case .normal: return Color(hex: "00C9A7")
        case .prediabetes: return Color(hex: "FFD966")
        case .diabetes: return Color(hex: "F2994A")
        case .veryHigh: return Color(hex: "EB5757")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topNavBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    bigNumberDisplay
                        .padding(.top, 8)
                    
                    statusCapsule
                    
                    dividerLine
                    
                    unitToggle
                    
                    sliderSection
                    
                    mealContextSection
                    
                    notesCard
                    
                    analysisCard
                    
                    saveButton
                        .padding(.horizontal, 24)
                    
                    disclaimer
                }
                .padding(.bottom, 40)
            }
        }
        .background(bgPage.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Record Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your blood glucose has been recorded.")
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
            
            Button("Save") { saveRecord() }
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
                Text(displayValue)
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(textBody)
                    .minimumScaleFactor(0.7)
                
                Text(unit.rawValue)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(textMuted)
            }
            
            Text("BLOOD GLUCOSE")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(textMuted)
                .tracking(0.5)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Status Capsule
    private var statusCapsule: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.system(size: 16))
                .foregroundColor(categoryColor)
            
            Text(category.rawValue)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(categoryColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Capsule().fill(categoryColor.opacity(0.12)))
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
        Picker("Unit", selection: $unit) {
            ForEach(GlucoseUnit.allCases, id: \.self) { u in
                Text(u.rawValue).tag(u)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 24)
        .onChange(of: unit) { oldUnit, newUnit in
            if oldUnit == .mgdL && newUnit == .mmolL {
                glucoseValue = GlucoseUnit.toMmolL(glucoseValue)
            } else if oldUnit == .mmolL && newUnit == .mgdL {
                glucoseValue = GlucoseUnit.toMgdL(glucoseValue)
            }
        }
    }
    
    // MARK: - Slider Section
    private var sliderSection: some View {
        VStack(spacing: 12) {
            // Label row
            HStack(alignment: .firstTextBaseline) {
                Text("Glucose Value")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(textLabel)
                
                Text(unit.rawValue)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(textMuted)
                
                Spacer()
                
                Text(displayValue)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(themeColor)
                    .monospacedDigit()
                    .frame(minWidth: 50, alignment: .trailing)
            }
            
            // Slider row
            HStack(spacing: 10) {
                Button {
                    if glucoseValue > glucoseMin {
                        glucoseValue -= glucoseStep
                        glucoseValue = max(glucoseValue, glucoseMin)
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
                    value: $glucoseValue,
                    in: glucoseMin...glucoseMax,
                    step: glucoseStep
                )
                .tint(themeColor)
                
                Button {
                    if glucoseValue < glucoseMax {
                        glucoseValue += glucoseStep
                        glucoseValue = min(glucoseValue, glucoseMax)
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
    
    // MARK: - Meal Context Section
    private var mealContextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When was this taken?")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(textLabel)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(MealContext.allCases) { context in
                    MealContextChip(
                        context: context,
                        isSelected: selectedContext == context,
                        themeColor: themeColor,
                        action: {
                            HapticManager.shared.selectionChanged()
                            selectedContext = context
                        }
                    )
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
    
    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(textLabel)
            
            TextField("Add notes about this reading...", text: $note, axis: .vertical)
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
    
    // MARK: - Analysis Card
    private var analysisCard: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Analysis")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(textLabel)
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: category.icon)
                        .font(.system(size: 12))
                    Text(category.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(categoryColor)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "4A90E2"))  // Low (blue)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "00C9A7"))  // Normal (green)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "FFD966"))  // Prediabetes (yellow)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "EB5757"))  // Diabetes/High (red)
                    }
                    .frame(height: 8)
                    
                    let position = indicatorPosition(width: geo.size.width)
                    Rectangle()
                        .fill(categoryColor)
                        .frame(width: 3, height: 18)
                        .cornerRadius(1.5)
                        .offset(x: position - 1.5, y: -5)
                }
            }
            .frame(height: 18)
            
            HStack {
                Text("LOW")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "4A90E2"))
                    .tracking(0.5)
                Spacer()
                Text("HIGH")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "EB5757"))
                    .tracking(0.5)
            }
            
            Text(category.description)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
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
        Button(action: saveRecord) {
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
            Text("Not a medical measurement. Consult a healthcare provider for diagnosis.")
        }
        .font(.system(size: 11, weight: .regular, design: .rounded))
        .foregroundColor(textMuted.opacity(0.6))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.top, 4)
    }
    
    // MARK: - Helpers
    
    private var displayValue: String {
        switch unit {
        case .mgdL: return String(format: "%.0f", glucoseValue)
        case .mmolL: return String(format: "%.1f", glucoseValue)
        }
    }
    
    private func indicatorPosition(width: CGFloat) -> CGFloat {
        let mgdLValue = unit == .mgdL ? glucoseValue : GlucoseUnit.toMgdL(glucoseValue)
        let minVal: Double = 40
        let maxVal: Double = 300
        let clamped = min(max(mgdLValue, minVal), maxVal)
        let ratio = (clamped - minVal) / (maxVal - minVal)
        return CGFloat(ratio) * width
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
        
        Task { @MainActor in
            AppsFlyerManager.shared.trackBloodGlucoseInput(value: glucoseValue)
        }
        
        HapticManager.shared.success()
        showingSaveConfirmation = true
    }
}

// MARK: - Meal Context Chip
struct MealContextChip: View {
    let context: MealContext
    let isSelected: Bool
    var themeColor: Color = Color(hex: "4A90E2")
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: context.icon)
                    .font(.system(size: 14))
                
                Text(context.rawValue)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : Color(hex: "334155"))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? themeColor : Color(hex: "F1F5F9"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? themeColor : Color(hex: "E2E8F0"), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BloodGlucoseInputView()
        .environmentObject(SettingsManager())
}
