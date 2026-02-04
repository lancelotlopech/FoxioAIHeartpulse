//
//  HealthScoreRingView.swift
//  HeartRateSenior
//
//  Health Score Ring component for Dashboard
//

import SwiftUI

// MARK: - Health Score Ring View (Senior-Friendly Horizontal Layout)
struct HealthScoreRingView: View {
    let heartRateRecords: [HeartRateRecord]
    let bloodPressureRecords: [BloodPressureRecord]
    let bloodGlucoseRecords: [BloodGlucoseRecord]
    
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Main Content: Horizontal Layout
            HStack(spacing: 20) {
                // Left: Score Ring (smaller)
                ZStack {
                    // Background Ring
                    Circle()
                        .stroke(scoreBackgroundColor, lineWidth: 14)
                        .frame(width: 120, height: 120)
                    
                    // Progress Ring with gradient
                    Circle()
                        .trim(from: 0, to: CGFloat(healthScore) / 100)
                        .stroke(
                            AngularGradient(
                                colors: [scoreColor, scoreColor.opacity(0.6), scoreColor],
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.2), value: healthScore)
                    
                    // Center Score Number
                    Text("\(healthScore)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor)
                }
                
                // Right: Label & Description
                VStack(alignment: .leading, spacing: 8) {
                    // Status Badge
                    HStack(spacing: 6) {
                        Text(scoreEmoji)
                            .font(.system(size: 24))
                        Text(scoreLabel)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(scoreColor)
                    }
                    
                    // Description
                    Text(scoreDescription)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // View Details Button
            Button(action: {
                HapticManager.shared.selectionChanged()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showDetails.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: showDetails ? "chevron.up.circle.fill" : "info.circle.fill")
                        .font(.system(size: 20))
                    Text(showDetails ? "Hide Details" : "How is this calculated?")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .foregroundColor(AppColors.primaryRed.opacity(0.8))
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.primaryRed.opacity(0.08))
                )
            }
            
            // Expandable Details with smooth animation
            if showDetails {
                VStack(spacing: 14) {
                    // Heart Rate Score
                    ScoreDetailRow(
                        icon: "heart.fill",
                        title: "Heart Rate",
                        score: heartRateScore,
                        maxScore: 30,
                        detail: heartRateDetail,
                        color: AppColors.primaryRed,
                        isOptional: false
                    )
                    
                    // Consistency Score
                    ScoreDetailRow(
                        icon: "calendar.badge.checkmark",
                        title: "Consistency",
                        score: consistencyScore,
                        maxScore: 30,
                        detail: consistencyDetail,
                        color: Color(red: 0.2, green: 0.7, blue: 0.4),
                        isOptional: false
                    )
                    
                    // Blood Pressure Score (Optional)
                    ScoreDetailRow(
                        icon: "heart.text.square.fill",
                        title: "Blood Pressure",
                        score: bloodPressureScore,
                        maxScore: 20,
                        detail: bloodPressureRecords.isEmpty ? "Optional" : bloodPressureDetail,
                        color: Color(red: 0.3, green: 0.5, blue: 0.9),
                        isOptional: bloodPressureRecords.isEmpty
                    )
                    
                    // Blood Glucose Score (Optional)
                    ScoreDetailRow(
                        icon: "drop.fill",
                        title: "Blood Glucose",
                        score: bloodGlucoseScore,
                        maxScore: 20,
                        detail: bloodGlucoseRecords.isEmpty ? "Optional" : bloodGlucoseDetail,
                        color: Color(red: 0.6, green: 0.4, blue: 0.8),
                        isOptional: bloodGlucoseRecords.isEmpty
                    )
                }
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                ))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Score Calculations
    
    private var healthScore: Int {
        var score = 0
        
        // 1. Consistency (30 points) - 7天内测量天数
        score += consistencyScore
        
        // 2. Heart Rate (30 points)
        score += heartRateScore
        
        // 3. Blood Pressure (20 points) - Optional
        score += bloodPressureScore
        
        // 4. Blood Glucose (20 points) - Optional
        score += bloodGlucoseScore
        
        return min(100, score)
    }
    
    private var consistencyScore: Int {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentHeartRate = heartRateRecords.filter { $0.timestamp >= sevenDaysAgo }
        let measureDays = Set(recentHeartRate.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
        return min(30, measureDays * 5) // 5 points per day, max 30
    }
    
    private var consistencyDetail: String {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentHeartRate = heartRateRecords.filter { $0.timestamp >= sevenDaysAgo }
        let measureDays = Set(recentHeartRate.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
        if measureDays == 0 {
            return "Start measuring!"
        } else if measureDays < 7 {
            return "\(measureDays)/7 days this week"
        } else {
            return "Perfect week! ✓"
        }
    }
    
    private var heartRateScore: Int {
        guard let lastHR = heartRateRecords.first else { return 0 }
        if lastHR.bpm >= 60 && lastHR.bpm <= 100 {
            return 30
        } else if lastHR.bpm >= 50 && lastHR.bpm <= 110 {
            return 20
        } else {
            return 10
        }
    }
    
    private var heartRateDetail: String {
        guard let lastHR = heartRateRecords.first else { return "No data yet" }
        if lastHR.bpm >= 60 && lastHR.bpm <= 100 {
            return "Normal (\(lastHR.bpm) BPM) ✓"
        } else if lastHR.bpm >= 50 && lastHR.bpm <= 110 {
            return "\(lastHR.bpm) BPM - Slightly off"
        } else {
            return "\(lastHR.bpm) BPM"
        }
    }
    
    private var bloodPressureScore: Int {
        guard let lastBP = bloodPressureRecords.first else { return 0 }
        switch lastBP.category {
        case .normal: return 20
        case .elevated, .low: return 15
        case .hypertensionStage1: return 10
        case .hypertensionStage2: return 5
        case .crisis: return 0
        }
    }
    
    private var bloodPressureDetail: String {
        guard let lastBP = bloodPressureRecords.first else { return "Not recorded" }
        return "\(lastBP.displayString) - \(lastBP.category.rawValue)"
    }
    
    private var bloodGlucoseScore: Int {
        guard let lastBG = bloodGlucoseRecords.first else { return 0 }
        switch lastBG.category {
        case .normal: return 20
        case .low: return 15
        case .prediabetes: return 10
        case .diabetes: return 5
        case .veryHigh: return 0
        }
    }
    
    private var bloodGlucoseDetail: String {
        guard let lastBG = bloodGlucoseRecords.first else { return "Not recorded" }
        return "\(Int(lastBG.value)) mg/dL - \(lastBG.category.rawValue)"
    }
    
    // MARK: - Score Display Properties
    
    private var scoreBackgroundColor: Color {
        return AppColors.cardBackground.opacity(0.8)
    }
    
    private var scoreColor: Color {
        // Beautiful gradient-like colors
        if healthScore >= 76 { return Color(red: 0.2, green: 0.75, blue: 0.4) } // Fresh green
        else if healthScore >= 51 { return Color(red: 0.3, green: 0.65, blue: 0.85) } // Sky blue
        else if healthScore >= 26 { return Color(red: 0.95, green: 0.6, blue: 0.2) } // Warm orange
        else if healthScore > 0 { return Color(red: 0.4, green: 0.6, blue: 0.9) } // Soft blue
        else { return AppColors.textSecondary }
    }
    
    private var scoreEmoji: String {
        if healthScore >= 76 { return "⭐" }
        else if healthScore >= 51 { return "👍" }
        else if healthScore >= 26 { return "📈" }
        else if healthScore > 0 { return "🌱" }
        else { return "💫" }
    }
    
    private var scoreLabel: String {
        if healthScore >= 76 { return "Excellent" }
        else if healthScore >= 51 { return "Good Progress" }
        else if healthScore >= 26 { return "Building Habits" }
        else if healthScore > 0 { return "Getting Started" }
        else { return "No Data" }
    }
    
    private var scoreDescription: String {
        if healthScore >= 76 { return "Amazing! Your health routine is excellent!" }
        else if healthScore >= 51 { return "You're making great progress!" }
        else if healthScore >= 26 { return "Keep building your healthy habits!" }
        else if healthScore > 0 { return "You're just getting started. Keep measuring to build your healthy routine!" }
        else { return "Start measuring to see your health score" }
    }
}

// MARK: - Score Detail Row
struct ScoreDetailRow: View {
    let icon: String
    let title: String
    let score: Int
    let maxScore: Int
    let detail: String
    let color: Color
    let isOptional: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                if isOptional {
                    Text("Optional")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.textSecondary.opacity(0.5))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text("\(score)/\(maxScore)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(score > 0 ? color : AppColors.textSecondary)
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.cardBackground)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isOptional && score == 0 ? AppColors.textSecondary.opacity(0.3) : color)
                        .frame(width: geo.size.width * CGFloat(score) / CGFloat(maxScore), height: 8)
                        .animation(.easeInOut(duration: 0.5), value: score)
                }
            }
            .frame(height: 8)
            
            // Detail Text
            Text(detail)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
        )
    }
}
