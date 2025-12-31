//
//  DashboardView.swift
//  HeartRateSenior
//
//  Main dashboard with health overview - Health Score, Calendar, Quick Records
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HeartRateRecord.timestamp, order: .reverse) private var heartRateRecords: [HeartRateRecord]
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var bloodPressureRecords: [BloodPressureRecord]
    @Query(sort: \BloodGlucoseRecord.timestamp, order: .reverse) private var bloodGlucoseRecords: [BloodGlucoseRecord]
    
    @State private var showingBloodPressureInput = false
    @State private var showingBloodGlucoseInput = false
    @State private var showingEmergencyContacts = false
    @State private var selectedDate: Date? = nil
    @State private var showingDayDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Header with Emergency Button
                    HeaderView(onEmergencyTap: {
                        HapticManager.shared.heavyImpact()
                        showingEmergencyContacts = true
                    })
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // 2. Health Score Ring
                    HealthScoreRingView(
                        heartRateRecords: heartRateRecords,
                        bloodPressureRecords: bloodPressureRecords,
                        bloodGlucoseRecords: bloodGlucoseRecords
                    )
                    .padding(.horizontal, 20)
                    
                    // 3. Monthly Calendar (Heatmap Style)
                    MonthlyCalendarView(
                        heartRateRecords: heartRateRecords,
                        bloodPressureRecords: bloodPressureRecords,
                        bloodGlucoseRecords: bloodGlucoseRecords,
                        onDateTapped: { date in
                            HapticManager.shared.selectionChanged()
                            selectedDate = date
                            showingDayDetail = true
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    // 4. Quick Record Cards
                    VStack(spacing: 12) {
                        Text("Quick Record")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // Blood Pressure Card
                            QuickRecordCard(
                                icon: "heart.text.square.fill",
                                title: "Blood Pressure",
                                lastValue: bloodPressureRecords.first?.displayString,
                                color: .blue,
                                action: {
                                    HapticManager.shared.mediumImpact()
                                    showingBloodPressureInput = true
                                }
                            )
                            
                            // Blood Glucose Card
                            QuickRecordCard(
                                icon: "drop.fill",
                                title: "Blood Glucose",
                                lastValue: bloodGlucoseRecords.first.map { "\(Int($0.value)) mg/dL" },
                                color: .purple,
                                action: {
                                    HapticManager.shared.mediumImpact()
                                    showingBloodGlucoseInput = true
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // 5. Weekly Trend (Optional, compact)
                    if heartRateRecords.count >= 3 {
                        WeeklyTrendCard(records: heartRateRecords)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showingBloodPressureInput) {
                BloodPressureInputView()
            }
            .sheet(isPresented: $showingBloodGlucoseInput) {
                BloodGlucoseInputView()
            }
            .sheet(isPresented: $showingEmergencyContacts) {
                EmergencyContactsView()
            }
            .sheet(isPresented: $showingDayDetail) {
                if let date = selectedDate {
                    DayDetailView(
                        date: date,
                        heartRateRecords: heartRateRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) },
                        bloodPressureRecords: bloodPressureRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) },
                        bloodGlucoseRecords: bloodGlucoseRecords.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
                    )
                }
            }
        }
    }
}

// MARK: - Header View with Emergency Button
struct HeaderView: View {
    let onEmergencyTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(dateText)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Emergency Button
            Button(action: onEmergencyTap) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryRed.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "sos")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.primaryRed)
                }
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning!" }
        else if hour < 18 { return "Good Afternoon!" }
        else { return "Good Evening!" }
    }
    
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

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

// MARK: - Monthly Calendar View (Heatmap Style)
struct MonthlyCalendarView: View {
    let heartRateRecords: [HeartRateRecord]
    let bloodPressureRecords: [BloodPressureRecord]
    let bloodGlucoseRecords: [BloodGlucoseRecord]
    let onDateTapped: (Date) -> Void
    
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Month Header
            HStack {
                Text(monthYearString)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: HistoryView()) {
                    HStack(spacing: 4) {
                        Text("Full History")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
            }
            
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            hasData: hasDataOnDate(date),
                            isToday: calendar.isDateInToday(date),
                            onTap: { onDateTapped(date) }
                        )
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var daysInMonth: [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasDataOnDate(_ date: Date) -> Bool {
        let hasHR = heartRateRecords.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }
        let hasBP = bloodPressureRecords.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }
        let hasBG = bloodGlucoseRecords.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }
        return hasHR || hasBP || hasBG
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let hasData: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .regular, design: .rounded))
                    .foregroundColor(isToday ? .white : AppColors.textPrimary)
                
                if hasData {
                    Circle()
                        .fill(isToday ? Color.white : AppColors.primaryRed)
                        .frame(width: 6, height: 6)
                } else {
                    Color.clear.frame(width: 6, height: 6)
                }
            }
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(isToday ? AppColors.primaryRed : Color.clear)
            )
        }
        .disabled(date > Date())
        .opacity(date > Date() ? 0.3 : 1)
    }
}

// MARK: - Quick Record Card (Senior-Friendly Large Design)
struct QuickRecordCard: View {
    let icon: String
    let title: String
    let lastValue: String?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Left: Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
                
                // Middle: Title & Value
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let value = lastValue {
                        Text("Last: \(value)")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        Text("Tap to record")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Right: Add Button
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(color)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Weekly Trend Card
struct WeeklyTrendCard: View {
    let records: [HeartRateRecord]
    
    private var recentRecords: [HeartRateRecord] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return records.filter { $0.timestamp >= sevenDaysAgo }.reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if let avg = averageBPM {
                    Text("Avg: \(avg) BPM")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            if recentRecords.count >= 2 {
                Chart(Array(recentRecords)) { record in
                    LineMark(
                        x: .value("Time", record.timestamp),
                        y: .value("BPM", record.bpm)
                    )
                    .foregroundStyle(AppColors.primaryRed.gradient)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Time", record.timestamp),
                        y: .value("BPM", record.bpm)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.primaryRed.opacity(0.3), AppColors.primaryRed.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 80)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private var averageBPM: Int? {
        guard !recentRecords.isEmpty else { return nil }
        let total = recentRecords.reduce(0) { $0 + $1.bpm }
        return total / recentRecords.count
    }
}

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
                            SectionView(title: "Heart Rate", icon: "heart.fill", color: AppColors.primaryRed) {
                                ForEach(heartRateRecords) { record in
                                    RecordRow(
                                        value: "\(record.bpm) BPM",
                                        time: timeString(from: record.timestamp),
                                        tag: record.tag
                                    )
                                }
                            }
                        }
                        
                        // Blood Pressure Records
                        if !bloodPressureRecords.isEmpty {
                            SectionView(title: "Blood Pressure", icon: "heart.text.square.fill", color: .blue) {
                                ForEach(bloodPressureRecords) { record in
                                    let categoryText = record.category.rawValue
                                    RecordRow(
                                        value: record.displayString,
                                        time: timeString(from: record.timestamp),
                                        tag: categoryText
                                    )
                                }
                            }
                        }
                        
                        // Blood Glucose Records
                        if !bloodGlucoseRecords.isEmpty {
                            SectionView(title: "Blood Glucose", icon: "drop.fill", color: .purple) {
                                ForEach(bloodGlucoseRecords) { record in
                                    let categoryText = record.category.rawValue
                                    RecordRow(
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

// MARK: - Section View
struct SectionView<Content: View>: View {
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

// MARK: - Record Row
struct RecordRow: View {
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

#Preview {
    DashboardView()
        .modelContainer(for: [HeartRateRecord.self, BloodPressureRecord.self, BloodGlucoseRecord.self], inMemory: true)
}
