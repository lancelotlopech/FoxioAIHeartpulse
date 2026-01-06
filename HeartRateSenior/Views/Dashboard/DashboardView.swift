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
    @Query(sort: \WeightRecord.timestamp, order: .reverse) private var weightRecords: [WeightRecord]
    @Query(sort: \OxygenRecord.timestamp, order: .reverse) private var oxygenRecords: [OxygenRecord]
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var showingBloodPressureInput = false
    @State private var showingBloodGlucoseInput = false
    @State private var showingWeightInput = false
    @State private var showingOxygenInput = false
    @State private var showingEmergencyContacts = false
    @State private var selectedDate: Date? = nil
    @State private var showingDayDetail = false
    @State private var selectedTabForMeasure = 1
    @State private var showingSubscription = false
    @State private var showUpgradeBanner = PaywallConfiguration.showUpgradeBanner
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 1. Header with Emergency Button & Pro Badge
                    HeaderView(
                        onEmergencyTap: {
                            HapticManager.shared.heavyImpact()
                            showingEmergencyContacts = true
                        },
                        onProTap: {
                            HapticManager.shared.mediumImpact()
                            showingSubscription = true
                        },
                        isPremium: subscriptionManager.isPremium
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // 2. Upgrade Banner (非订阅用户可见)
                    if !subscriptionManager.isPremium && showUpgradeBanner {
                        UpgradeBannerView(
                            onTap: {
                                HapticManager.shared.mediumImpact()
                                showingSubscription = true
                            },
                            onClose: {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showUpgradeBanner = false
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    }
                    
                    // 2. Big Heart Rate Measure Button (核心功能)
                    BigMeasureButtonCard(
                        lastRecord: heartRateRecords.first,
                        onMeasureTap: {
                            HapticManager.shared.mediumImpact()
                            // Navigate to Measure tab
                            NotificationCenter.default.post(name: NSNotification.Name("SwitchToMeasureTab"), object: nil)
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, -4) // 减少与 Health Score 间距
                    
                    // 3. Health Score Ring
                    HealthScoreRingView(
                        heartRateRecords: heartRateRecords,
                        bloodPressureRecords: bloodPressureRecords,
                        bloodGlucoseRecords: bloodGlucoseRecords
                    )
                    .padding(.horizontal, 20)
                    
                    // 4. Monthly Calendar (Heatmap Style)
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
                    
                    // 5. Quick Record Cards (Horizontal List)
                    VStack(spacing: 12) {
                        Text("Quick Record")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // Blood Pressure
                            NavigationLink(destination: BloodPressureHistoryView()) {
                                HorizontalRecordCardView(
                                    icon: "heart.text.square.fill",
                                    title: "Blood Pressure",
                                    lastValue: bloodPressureRecords.first?.displayString,
                                    color: .blue,
                                    onAddTap: {
                                        HapticManager.shared.mediumImpact()
                                        showingBloodPressureInput = true
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Blood Glucose
                            NavigationLink(destination: BloodGlucoseHistoryView()) {
                                HorizontalRecordCardView(
                                    icon: "drop.fill",
                                    title: "Blood Glucose",
                                    lastValue: bloodGlucoseRecords.first.map { "\(Int($0.value)) mg/dL" },
                                    color: .purple,
                                    onAddTap: {
                                        HapticManager.shared.mediumImpact()
                                        showingBloodGlucoseInput = true
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Weight
                            NavigationLink(destination: WeightHistoryView()) {
                                HorizontalRecordCardView(
                                    icon: "scalemass.fill",
                                    title: "Weight",
                                    lastValue: weightRecords.first.map { String(format: "%.1f kg", $0.weight) },
                                    color: .orange,
                                    onAddTap: {
                                        HapticManager.shared.mediumImpact()
                                        showingWeightInput = true
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Blood Oxygen
                            NavigationLink(destination: OxygenHistoryView()) {
                                HorizontalRecordCardView(
                                    icon: "lungs.fill",
                                    title: "Blood Oxygen",
                                    lastValue: oxygenRecords.first.map { "\($0.spo2)%" },
                                    color: .cyan,
                                    onAddTap: {
                                        HapticManager.shared.mediumImpact()
                                        showingOxygenInput = true
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
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
            .sheet(isPresented: $showingWeightInput) {
                WeightInputView()
            }
            .sheet(isPresented: $showingOxygenInput) {
                OxygenInputView()
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
            .fullScreenCover(isPresented: $showingSubscription) {
                SubscriptionView()
            }
        }
    }
}

// MARK: - Shimmer Overlay (流光效果)
struct ShimmerOverlay: View {
    @State private var phase: CGFloat = -1
    
    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [
                    Color.white.opacity(0),
                    Color.white.opacity(0.4),
                    Color.white.opacity(0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 0.5)
            .offset(x: phase * geo.size.width * 1.5)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 2.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
        }
    }
}

// MARK: - Upgrade Banner View (升级横幅 + 流光效果)
struct UpgradeBannerView: View {
    let onTap: () -> Void
    let onClose: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 底层：渐变背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.3),
                                Color(red: 1.0, green: 0.55, blue: 0.25)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // 中层：流光效果
                ShimmerOverlay()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // 上层：内容
                HStack(spacing: 12) {
                    // 左侧：皇冠图标
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                    }
                    
                    // 中间：文字
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Unlock Premium")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("\(PaywallConfiguration.freeTrialDays) Days Free Trial")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // 右侧：箭头
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // 关闭按钮
                    Button(action: {
                        onClose()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(6)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 64)
            .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Header View with Emergency Button & Pro Badge
struct HeaderView: View {
    let onEmergencyTap: () -> Void
    let onProTap: () -> Void
    let isPremium: Bool
    
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
            
            // Pro Badge (非订阅用户显示)
            if !isPremium && PaywallConfiguration.showProBadgeInDashboard {
                Button(action: onProTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12, weight: .semibold))
                        Text("PRO")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.2),
                                Color(red: 1.0, green: 0.4, blue: 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            
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

// MARK: - Futuristic Circular Pulse Button (科技感圆形脉动按钮)
struct BigMeasureButtonCard: View {
    let lastRecord: HeartRateRecord?
    let onMeasureTap: () -> Void
    
    @State private var isAnimating = false
    @State private var ringRotation: Double = 0
    @State private var glowOpacity: Double = 0.4
    @State private var buttonScale: CGFloat = 1.0
    @State private var isPressed = false
    
    // 配色（调深）
    private let gradientRed = Color(red: 1.0, green: 0.29, blue: 0.43) // #FF4B6E 主红
    private let gradientPink = Color(red: 1.0, green: 0.35, blue: 0.35) // #FF5A5A 稍深粉红
    private let glowColor = Color(red: 1.0, green: 0.40, blue: 0.45) // 更明显的光晕红
    
    var body: some View {
        VStack(spacing: 24) {
            // 圆形主按钮
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                    onMeasureTap()
                }
            }) {
                ZStack {
                    // Layer 1: 最外层旋转光环
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    glowColor.opacity(0.0),
                                    glowColor.opacity(0.5),
                                    gradientPink.opacity(0.8),
                                    glowColor.opacity(0.5),
                                    glowColor.opacity(0.0)
                                ],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(ringRotation))
                    
                    // Layer 2: 半透明呼吸光晕
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    gradientRed.opacity(0.25),
                                    gradientRed.opacity(0.10),
                                    glowColor.opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 85
                            )
                        )
                        .frame(width: 180, height: 180)
                        .opacity(glowOpacity + 0.3)
                    
                    // Layer 3: 玻璃质感外圈
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.4),
                                            Color.white.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    // Layer 4: 主按钮背景
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [gradientRed, gradientPink.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: gradientRed.opacity(0.5), radius: 20, x: 0, y: 10)
                        .shadow(color: gradientRed.opacity(0.3), radius: 40, x: 0, y: 20)
                    
                    // Layer 5: 内部高光
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.35, y: 0.25),
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    // Layer 6: 心形图标
                    VStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundColor(.white)
                            .scaleEffect(isAnimating ? 1.12 : 1.0)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                        
                        Text("TAP")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(2)
                    }
                }
                .scaleEffect(isPressed ? 0.92 : buttonScale)
            }
            .onAppear {
                startAnimations()
            }
            
            // 提示文字
            Text("Tap to Measure")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            // 底部信息胶囊
            if let record = lastRecord {
                LastMeasurementCapsule(bpm: record.bpm, timestamp: record.timestamp)
            } else {
                Text("No measurements yet")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
            }
        }
        .padding(.vertical, 20)
    }
    
    private func startAnimations() {
        // 统一脉动周期 1.5s - 心形、按钮、光晕同步
        let pulseDuration: Double = 1.5
        
        // 心跳动画 (同步)
        withAnimation(
            Animation.easeInOut(duration: pulseDuration)
                .repeatForever(autoreverses: true)
        ) {
            isAnimating = true
        }
        
        // 外圈旋转动画 (独立，慢速旋转)
        withAnimation(
            Animation.linear(duration: 8)
                .repeatForever(autoreverses: false)
        ) {
            ringRotation = 360
        }
        
        // 光晕呼吸动画 (同步)
        withAnimation(
            Animation.easeInOut(duration: pulseDuration)
                .repeatForever(autoreverses: true)
        ) {
            glowOpacity = 0.6
        }
        
        // 整体按钮呼吸缩放 (同步)
        withAnimation(
            Animation.easeInOut(duration: pulseDuration)
                .repeatForever(autoreverses: true)
        ) {
            buttonScale = 1.04
        }
    }
}

// MARK: - Last Measurement Capsule (精致胶囊信息卡)
struct LastMeasurementCapsule: View {
    let bpm: Int
    let timestamp: Date
    
    @State private var isGlowing = false
    
    private let capsuleGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.97, blue: 0.97), // 浅粉白
            Color.white
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        HStack(spacing: 12) {
            // 左侧：心形徽章
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.primaryRed.opacity(0.15),
                                AppColors.primaryRed.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 18
                        )
                    )
                    .frame(width: 36, height: 36)
                    .scaleEffect(isGlowing ? 1.1 : 1.0)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryRed)
            }
            
            // 中间：BPM 数值
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(bpm)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("BPM")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.primaryRed)
                }
                
                Text("Last measured")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // 右侧：时间
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeAgo(from: timestamp))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Normal")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color.green)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(capsuleGradient)
                .shadow(color: AppColors.primaryRed.opacity(0.08), radius: 12, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppColors.primaryRed.opacity(0.15),
                                    AppColors.primaryRed.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                isGlowing = true
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60)) min ago" }
        else if interval < 86400 { return "\(Int(interval / 3600)) hr ago" }
        else { return "\(Int(interval / 86400)) days ago" }
    }
}

// MARK: - Horizontal Record Card View (支持历史入口 + 添加按钮)
struct HorizontalRecordCardView: View {
    let icon: String
    let title: String
    let lastValue: String?
    let color: Color
    let onAddTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧：大图标
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.12))
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(color)
            }
            
            // 中间：标题和上次值
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                if let value = lastValue {
                    Text("Last: \(value)")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(color)
                } else {
                    Text("Tap to view history")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // 右侧：添加按钮
            Button(action: onAddTap) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                }
            }
            
            // 箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Horizontal Record Card (横向卡片 - 旧版)
struct HorizontalRecordCard: View {
    let icon: String
    let title: String
    let lastValue: String?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 左侧：大图标
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.12))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(color)
                }
                
                // 中间：标题和上次值
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let value = lastValue {
                        Text("Last: \(value)")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(color)
                    } else {
                        Text("Tap to record")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // 右侧：添加按钮
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Quick Heart Rate Measure Card (旧版，保留兼容)
struct QuickHeartRateMeasureCard: View {
    let lastRecord: HeartRateRecord?
    let onMeasureTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Heart Icon
                ZStack {
                    Circle()
                        .fill(AppColors.primaryRed.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.primaryRed)
                }
                
                // Title & Last Value
                VStack(alignment: .leading, spacing: 4) {
                    Text("Heart Rate")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let record = lastRecord {
                        HStack(spacing: 6) {
                            Text("\(record.bpm) BPM")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.primaryRed)
                            
                            Text("· \(timeAgo(from: record.timestamp))")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    } else {
                        Text("No measurements yet")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
            }
            
            // Big Measure Button
            Button(action: onMeasureTap) {
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .semibold))
                    
                    Text("Start Measuring")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: AppColors.primaryRed.opacity(0.15), radius: 12, x: 0, y: 6)
        )
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
}

// MARK: - Compact Record Card (for 2x2 Grid)
struct CompactRecordCard: View {
    let icon: String
    let title: String
    let lastValue: String?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                // Value or Tap to record
                if let value = lastValue {
                    Text(value)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(color)
                        .lineLimit(1)
                } else {
                    Text("Tap to add")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Add Icon
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(color.opacity(0.7))
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
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
