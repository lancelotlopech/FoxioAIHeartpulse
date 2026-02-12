//
//  CycleTrackerView.swift
//  HeartRateSenior
//
//  Enhanced cycle tracker with beautiful UI
//

import SwiftUI

struct CycleTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var lastPeriodDate = Date()
    @State private var cycleLength: Double = 28
    @State private var periodLength: Double = 5
    
    private let primaryColor = Color(red: 1.0, green: 0.6, blue: 0.7)
    private let secondaryColor = Color(red: 1.0, green: 0.75, blue: 0.8)
    private let ovulationColor = Color(red: 0.6, green: 0.8, blue: 1.0)
    
    private var nextPeriodDate: Date {
        Calendar.current.date(byAdding: .day, value: Int(cycleLength), to: lastPeriodDate) ?? Date()
    }
    
    private var ovulationDate: Date {
        Calendar.current.date(byAdding: .day, value: Int(cycleLength) - 14, to: lastPeriodDate) ?? Date()
    }
    
    private var fertileStart: Date {
        Calendar.current.date(byAdding: .day, value: Int(cycleLength) - 16, to: lastPeriodDate) ?? Date()
    }
    
    private var fertileEnd: Date {
        Calendar.current.date(byAdding: .day, value: Int(cycleLength) - 12, to: lastPeriodDate) ?? Date()
    }
    
    private var daysUntilNextPeriod: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextPeriodDate).day ?? 0
    }
    
    private var cycleProgress: Double {
        let days = Calendar.current.dateComponents([.day], from: lastPeriodDate, to: Date()).day ?? 0
        return min(Double(days) / cycleLength, 1.0)
    }
    
    private var currentPhase: String {
        let days = Calendar.current.dateComponents([.day], from: lastPeriodDate, to: Date()).day ?? 0
        if days < Int(periodLength) { return "Period" }
        if days < Int(cycleLength) - 16 { return "Follicular" }
        if days < Int(cycleLength) - 12 { return "Fertile Window" }
        return "Luteal"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [primaryColor.opacity(0.05), secondaryColor.opacity(0.08), AppColors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [primaryColor.opacity(0.2), secondaryColor.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)
                            
                            Image(systemName: "calendar.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                        }
                        .shadow(color: primaryColor.opacity(0.25), radius: 16, x: 0, y: 8)
                        
                        Text("Cycle Tracker")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.top, 16)
                    
                    // Progress Ring Card
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(primaryColor.opacity(0.12), lineWidth: 18)
                                .frame(width: 180, height: 180)
                            
                            Circle()
                                .trim(from: 0, to: cycleProgress)
                                .stroke(
                                    LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                                )
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.6), value: cycleProgress)
                            
                            VStack(spacing: 6) {
                                Text("\(max(0, daysUntilNextPeriod))")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(primaryColor)
                                
                                Text("days left")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        // Current Phase Badge
                        Text(currentPhase)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .leading, endPoint: .trailing)
                                    )
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: primaryColor.opacity(0.1), radius: 16, x: 0, y: 8)
                    )
                    .padding(.horizontal, 20)
                    
                    // Settings Card
                    VStack(spacing: 24) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(primaryColor)
                            Text("Cycle Settings")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                        
                        // Last Period Date
                        HStack {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(primaryColor.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "calendar")
                                        .foregroundColor(primaryColor)
                                }
                                Text("Last Period")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            Spacer()
                            DatePicker("", selection: $lastPeriodDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(primaryColor)
                        }
                        
                        Divider().opacity(0.5)
                        
                        // Cycle Length
                        VStack(spacing: 12) {
                            HStack {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(primaryColor.opacity(0.12))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .foregroundColor(primaryColor)
                                    }
                                    Text("Cycle Length")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                Spacer()
                                Text("\(Int(cycleLength)) days")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(primaryColor)
                            }
                            
                            Slider(value: $cycleLength, in: 21...35, step: 1)
                                .tint(primaryColor)
                        }
                        
                        Divider().opacity(0.5)
                        
                        // Period Length
                        VStack(spacing: 12) {
                            HStack {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(primaryColor.opacity(0.12))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "drop.fill")
                                            .foregroundColor(primaryColor)
                                    }
                                    Text("Period Length")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                Spacer()
                                Text("\(Int(periodLength)) days")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(primaryColor)
                            }
                            
                            Slider(value: $periodLength, in: 3...7, step: 1)
                                .tint(primaryColor)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: primaryColor.opacity(0.1), radius: 16, x: 0, y: 8)
                    )
                    .padding(.horizontal, 20)
                    
                    // Predictions Card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(primaryColor)
                            Text("Predictions")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                        
                        CyclePredictionCard(
                            icon: "calendar.badge.clock",
                            iconColor: primaryColor,
                            title: "Next Period",
                            date: nextPeriodDate,
                            subtitle: "\(max(0, daysUntilNextPeriod)) days away"
                        )
                        
                        CyclePredictionCard(
                            icon: "star.fill",
                            iconColor: ovulationColor,
                            title: "Ovulation",
                            date: ovulationDate,
                            subtitle: "Estimated"
                        )
                        
                        CyclePredictionCard(
                            icon: "heart.fill",
                            iconColor: Color.purple.opacity(0.7),
                            title: "Fertile Window",
                            date: fertileStart,
                            subtitle: formattedRange(fertileStart, fertileEnd)
                        )
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: primaryColor.opacity(0.1), radius: 16, x: 0, y: 8)
                    )
                    .padding(.horizontal, 20)
                    
                    // Disclaimer
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                        
                        Text("This is a basic tracker for reference only. For accurate fertility tracking, consult a healthcare provider.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.06))
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    private func formattedRange(_ start: Date, _ end: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: start)) - \(fmt.string(from: end))"
    }
}

// MARK: - Prediction Card
struct CyclePredictionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let date: Date
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(.label))
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(date, style: .date)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(iconColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(iconColor.opacity(0.04))
        )
    }
}

#Preview {
    NavigationStack {
        CycleTrackerView()
    }
}
