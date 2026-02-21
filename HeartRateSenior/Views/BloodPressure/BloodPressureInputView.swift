//
//  BloodPressureInputView.swift
//  HeartRateSenior
//
//  Blood Pressure Input View - Optimized Layout & Aligned Design
//

import SwiftUI
import SwiftData

struct BloodPressureInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var systolic: Int = 120
    @State private var diastolic: Int = 80
    @State private var pulse: Int = 72
    @State private var note: String = ""
    @State private var showingSaveConfirmation = false
    
    private let systolicMin = 60
    private let systolicMax = 250
    private let diastolicMin = 40
    private let diastolicMax = 150
    
    // Theme color — matches Dashboard BP card icon color
    private let themeColor = Color(hex: "F2994A")
    private let themeBgLight = Color(hex: "FFF7ED")
    
    // Text colors
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
    
    var category: BloodPressureCategory {
        BloodPressureCategory.category(systolic: systolic, diastolic: diastolic)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topNavBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    bigNumberDisplay
                        .padding(.top, 8)
                    
                    pulseCapsule
                    
                    dividerLine
                    
                    slidersSection
                    
                    notesCard
                    
                    analysisCard
                    
                    saveButton
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .background(bgPage.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Record Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your blood pressure has been recorded.")
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
    
    // MARK: - Big Number Display (aligned)
    private var bigNumberDisplay: some View {
        HStack(spacing: 0) {
            // Systolic column
            VStack(spacing: 6) {
                Text("\(systolic)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(textBody)
                    .minimumScaleFactor(0.7)
                
                Text("SYSTOLIC")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(textMuted)
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity)
            
            // Separator
            Text("/")
                .font(.system(size: 36, weight: .light, design: .rounded))
                .foregroundColor(textMuted.opacity(0.5))
                .frame(width: 24)
            
            // Diastolic column
            VStack(spacing: 6) {
                Text("\(diastolic)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(textBody)
                    .minimumScaleFactor(0.7)
                
                Text("DIASTOLIC")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(textMuted)
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Pulse Capsule
    private var pulseCapsule: some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .font(.system(size: 16))
                .foregroundColor(themeColor)
            
            Text("\(pulse)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(themeColor)
            
            Text("BPM")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(themeColor.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Capsule().fill(themeBgLight))
    }
    
    // MARK: - Divider
    private var dividerLine: some View {
        Rectangle()
            .fill(borderLight)
            .frame(height: 1)
            .padding(.horizontal, 24)
    }
    
    // MARK: - Sliders Section
    private var slidersSection: some View {
        VStack(spacing: 0) {
            sliderRow(label: "Systolic", unit: "mmHg", value: $systolic, range: systolicMin...systolicMax)
            
            Rectangle()
                .fill(borderLight.opacity(0.6))
                .frame(height: 1)
                .padding(.horizontal, 0)
                .padding(.vertical, 16)
            
            sliderRow(label: "Diastolic", unit: "mmHg", value: $diastolic, range: diastolicMin...diastolicMax)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Slider Row
    private func sliderRow(label: String, unit: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: 12) {
            // Label row
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(textLabel)
                
                Text(unit)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(textMuted)
                
                Spacer()
                
                Text("\(value.wrappedValue)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(themeColor)
                    .monospacedDigit()
                    .frame(minWidth: 40, alignment: .trailing)
            }
            
            // Slider row
            HStack(spacing: 10) {
                Button {
                    if value.wrappedValue > range.lowerBound {
                        value.wrappedValue -= 1
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
                    value: Binding<Double>(
                        get: { Double(value.wrappedValue) },
                        set: { value.wrappedValue = Int($0) }
                    ),
                    in: Double(range.lowerBound)...Double(range.upperBound),
                    step: 1
                )
                .tint(themeColor)
                
                Button {
                    if value.wrappedValue < range.upperBound {
                        value.wrappedValue += 1
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
        analysisBarContent
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 24)
    }
    
    // MARK: - Analysis Bar Content
    private var analysisBarContent: some View {
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
                            .fill(Color(hex: "00C9A7"))  // 翠绿
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "FFD966"))  // 浅黄
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "F2994A"))  // 深黄/橙
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "EB5757"))  // 大红
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
                Text("OPTIMAL")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "00C9A7"))
                    .tracking(0.5)
                Spacer()
                Text("HIGH")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "EB5757"))
                    .tracking(0.5)
            }
        }
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
    
    // MARK: - Helpers
    
    private var categoryColor: Color {
        switch category {
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .yellow
        case .hypertensionStage1: return .orange
        case .hypertensionStage2: return .red
        case .crisis: return .purple
        }
    }
    
    private func indicatorPosition(width: CGFloat) -> CGFloat {
        let minVal: Double = 90
        let maxVal: Double = 180
        let clamped = min(max(Double(systolic), minVal), maxVal)
        let ratio = (clamped - minVal) / (maxVal - minVal)
        return CGFloat(ratio) * width
    }
    
    private func saveRecord() {
        HapticManager.shared.mediumImpact()
        
        let record = BloodPressureRecord(
            systolic: systolic,
            diastolic: diastolic,
            pulse: pulse,
            timestamp: Date(),
            note: note.isEmpty ? nil : note
        )
        
        modelContext.insert(record)
        
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
