//
//  OxygenInputView.swift
//  HeartRateSenior
//
//  Blood Oxygen Input View - Redesigned to match BP template
//

import SwiftUI
import SwiftData

struct OxygenInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var spo2Value: Double = 98
    @State private var notes: String = ""
    @State private var showingSaveAlert = false
    
    // Theme color — matches Dashboard Blood Oxygen card icon color
    private let themeColor = Color(hex: "2DCEB4")
    
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
    
    private var spo2Int: Int { Int(spo2Value) }
    
    private var category: OxygenCategory {
        OxygenRecord(spo2: spo2Int).category
    }
    
    private var categoryColor: Color {
        switch spo2Int {
        case 95...100: return Color(hex: "00C9A7")
        case 91...94:  return Color(hex: "F2C94C")
        case 86...90:  return Color(hex: "F2994A")
        default:       return Color(hex: "EB5757")
        }
    }
    
    private var categoryIcon: String {
        category.icon
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
                    
                    sliderSection
                    
                    analysisCard
                    
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
        .alert("SpO₂ Saved", isPresented: $showingSaveAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your blood oxygen reading has been recorded successfully.")
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
            
            Button("Save") { saveOxygen() }
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
                Text("\(spo2Int)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(textBody)
                    .minimumScaleFactor(0.7)
                
                Text("%")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundColor(textMuted)
            }
            
            Text("SpO₂")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(textMuted)
                .tracking(0.5)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Status Capsule
    private var statusCapsule: some View {
        HStack(spacing: 6) {
            Image(systemName: categoryIcon)
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
    
    // MARK: - Slider Section
    private var sliderSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("SpO₂")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(textLabel)
                
                Text("%")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(textMuted)
                
                Spacer()
                
                Text("\(spo2Int)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(themeColor)
                    .monospacedDigit()
                    .frame(minWidth: 40, alignment: .trailing)
            }
            
            HStack(spacing: 10) {
                Button {
                    if spo2Value > 70 {
                        spo2Value -= 1
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
                    value: $spo2Value,
                    in: 70...100,
                    step: 1
                )
                .tint(themeColor)
                
                Button {
                    if spo2Value < 100 {
                        spo2Value += 1
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
    
    // MARK: - Analysis Card
    private var analysisCard: some View {
        VStack(spacing: 10) {
            HStack {
                Text("SpO₂ Analysis")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(textLabel)
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 12))
                    Text(category.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundColor(categoryColor)
            }
            
            // SpO2 gradient bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "EB5757"))  // Severe
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "F2994A"))  // Moderate
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "F2C94C"))  // Mild
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "00C9A7"))  // Normal
                    }
                    .frame(height: 8)
                    
                    let position = spo2IndicatorPosition(spo2: spo2Int, width: geo.size.width)
                    Rectangle()
                        .fill(categoryColor)
                        .frame(width: 3, height: 18)
                        .cornerRadius(1.5)
                        .offset(x: position - 1.5, y: -5)
                }
            }
            .frame(height: 18)
            
            HStack {
                Text("SEVERE")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "EB5757"))
                    .tracking(0.5)
                Spacer()
                Text("NORMAL")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "00C9A7"))
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
        Button(action: saveOxygen) {
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
            Text("Not a medical device. Consult a healthcare provider for advice.")
        }
        .font(.system(size: 11, weight: .regular, design: .rounded))
        .foregroundColor(textMuted.opacity(0.6))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.top, 4)
    }
    
    // MARK: - Helpers
    
    private func spo2IndicatorPosition(spo2: Int, width: CGFloat) -> CGFloat {
        // Bar goes from severe (left, ~70%) to normal (right, 100%)
        let minSpo2: Double = 70
        let maxSpo2: Double = 100
        let clamped = min(max(Double(spo2), minSpo2), maxSpo2)
        let ratio = (clamped - minSpo2) / (maxSpo2 - minSpo2)
        return CGFloat(ratio) * width
    }
    
    private func saveOxygen() {
        HapticManager.shared.mediumImpact()
        
        let record = OxygenRecord(
            spo2: spo2Int,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(record)
        
        Task { @MainActor in
            AppsFlyerManager.shared.trackOxygenInput(value: spo2Int)
        }
        
        HapticManager.shared.success()
        showingSaveAlert = true
    }
}

#Preview {
    OxygenInputView()
        .modelContainer(for: OxygenRecord.self, inMemory: true)
}
