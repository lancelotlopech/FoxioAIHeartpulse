//
//  DayDetailView.swift
//  HeartRateSenior
//
//  Day Detail Sheet component for Dashboard
//

import SwiftUI

// MARK: - Day Detail View (Sheet)
struct DayDetailView: View {
    let date: Date
    let heartRateRecords: [HeartRateRecord]
    let bloodPressureRecords: [BloodPressureRecord]
    let bloodGlucoseRecords: [BloodGlucoseRecord]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if heartRateRecords.isEmpty && bloodPressureRecords.isEmpty && bloodGlucoseRecords.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("No records on this day")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, 60)
                    } else {
                        // Heart Rate Records
                        if !heartRateRecords.isEmpty {
                            DaySectionView(title: "Heart Rate", icon: "heart.fill", color: AppColors.primaryRed) {
                                ForEach(heartRateRecords) { record in
                                    DayRecordRow(
                                        value: "\(record.bpm) BPM",
                                        time: timeString(from: record.timestamp),
                                        tag: record.tag
                                    )
                                }
                            }
                        }
                        
                        // Blood Pressure Records
                        if !bloodPressureRecords.isEmpty {
                            DaySectionView(title: "Blood Pressure", icon: "heart.text.square.fill", color: .blue) {
                                ForEach(bloodPressureRecords) { record in
                                    let categoryText = record.category.rawValue
                                    DayRecordRow(
                                        value: record.displayString,
                                        time: timeString(from: record.timestamp),
                                        tag: categoryText
                                    )
                                }
                            }
                        }
                        
                        // Blood Glucose Records
                        if !bloodGlucoseRecords.isEmpty {
                            DaySectionView(title: "Blood Glucose", icon: "drop.fill", color: .purple) {
                                ForEach(bloodGlucoseRecords) { record in
                                    let categoryText = record.category.rawValue
                                    DayRecordRow(
                                        value: "\(Int(record.value)) mg/dL",
                                        time: timeString(from: record.timestamp),
                                        tag: categoryText
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(dateString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Day Section View
struct DaySectionView<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: 8) {
                content()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Day Record Row
struct DayRecordRow: View {
    let value: String
    let time: String
    let tag: String?
    
    var body: some View {
        HStack {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(time)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                if let tag = tag {
                    Text(tag)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.cardBackground)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
