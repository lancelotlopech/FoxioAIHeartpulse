//
//  ProfileView.swift
//  HeartRateSenior
//
//  Profile page with health overview, charts, and settings
//

import SwiftUI
import SwiftData
import Charts

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HeartRateRecord.timestamp, order: .reverse) private var heartRateRecords: [HeartRateRecord]
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var bloodPressureRecords: [BloodPressureRecord]
    @Query(sort: \BloodGlucoseRecord.timestamp, order: .reverse) private var bloodGlucoseRecords: [BloodGlucoseRecord]
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // User Stats Header
                    UserStatsHeader(
                        heartRateCount: heartRateRecords.count,
                        bloodPressureCount: bloodPressureRecords.count,
                        bloodGlucoseCount: bloodGlucoseRecords.count
                    )
                    
                    // Heart Rate Trend Chart
                    HeartRateTrendCard(records: heartRateRecords)
                    
                    // Health Overview Grid
                    HealthOverviewGrid(
                        bloodPressureRecords: bloodPressureRecords,
                        bloodGlucoseRecords: bloodGlucoseRecords
                    )
                    
                    // Quick Actions
                    QuickActionsSection(showingExportSheet: $showingExportSheet, records: heartRateRecords)
                    
                    // Settings Section
                    SettingsSection(settingsManager: settingsManager)
                    
                    // Information Section
                    InformationSection()
                    
                    // Version
                    Text("Version 1.0.0")
                        .font(AppTypography.small)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(AppColors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingExportSheet) {
                ExportPDFSheet(records: Array(heartRateRecords.prefix(30)))
            }
        }
    }
}

// MARK: - User Stats Header
struct UserStatsHeader: View {
    let heartRateCount: Int
    let bloodPressureCount: Int
    let bloodGlucoseCount: Int
    
    var totalCount: Int {
        heartRateCount + bloodPressureCount + bloodGlucoseCount
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppColors.primaryRed.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.primaryRed)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Heart Rate Senior")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(totalCount) total measurements")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                
                // Mini stats
                HStack(spacing: 12) {
                    MiniStatBadge(icon: "heart.fill", count: heartRateCount, color: AppColors.primaryRed)
                    MiniStatBadge(icon: "heart.text.square.fill", count: bloodPressureCount, color: .blue)
                    MiniStatBadge(icon: "drop.fill", count: bloodGlucoseCount, color: .purple)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct MiniStatBadge: View {
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text("\(count)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Heart Rate Trend Card
struct HeartRateTrendCard: View {
    let records: [HeartRateRecord]
    
    private var recentRecords: [HeartRateRecord] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return records.filter { $0.timestamp >= sevenDaysAgo }.suffix(30).reversed()
    }
    
    private var stats: (avg: Int, min: Int, max: Int) {
        guard !recentRecords.isEmpty else { return (0, 0, 0) }
        let bpms = recentRecords.map { $0.bpm }
        let avg = bpms.reduce(0, +) / bpms.count
        return (avg, bpms.min() ?? 0, bpms.max() ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryRed)
                
                Text("Heart Rate Trend")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("Last 7 Days")
                    .font(AppTypography.small)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Chart
            if recentRecords.count >= 2 {
                ProfileHeartRateChart(records: Array(recentRecords))
                    .frame(height: 180)
                
                // Stats Row
                HStack(spacing: 0) {
                    StatItem(label: "Average", value: "\(stats.avg)", unit: "BPM", color: AppColors.primaryRed)
                    
                    Divider()
                        .frame(height: 40)
                    
                    StatItem(label: "Lowest", value: "\(stats.min)", unit: "BPM", color: .blue)
                    
                    Divider()
                        .frame(height: 40)
                    
                    StatItem(label: "Highest", value: "\(stats.max)", unit: "BPM", color: .orange)
                }
                .padding(.top, 8)
            } else {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textSecondary.opacity(0.3))
                    
                    Text("Not enough data")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Measure your heart rate to see trends")
                        .font(AppTypography.small)
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
            }
            
            // View History Button
            NavigationLink(destination: HistoryView()) {
                HStack {
                    Text("View Full History")
                        .font(AppTypography.button)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(AppColors.primaryRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.primaryRed.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, 4)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Heart Rate Chart
struct ProfileHeartRateChart: View {
    let records: [HeartRateRecord]
    
    var body: some View {
        Chart {
            // Normal range area (60-100 BPM)
            RectangleMark(
                xStart: .value("Start", records.first?.timestamp ?? Date()),
                xEnd: .value("End", records.last?.timestamp ?? Date()),
                yStart: .value("Low", 60),
                yEnd: .value("High", 100)
            )
            .foregroundStyle(Color.green.opacity(0.1))
            
            // Data line
            ForEach(records) { record in
                LineMark(
                    x: .value("Time", record.timestamp),
                    y: .value("BPM", record.bpm)
                )
                .foregroundStyle(AppColors.primaryRed.gradient)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                
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
                
                PointMark(
                    x: .value("Time", record.timestamp),
                    y: .value("BPM", record.bpm)
                )
                .foregroundStyle(AppColors.primaryRed)
                .symbolSize(30)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [60, 80, 100, 120]) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYScale(domain: 40...140)
    }
}

// MARK: - Health Overview Grid
struct HealthOverviewGrid: View {
    let bloodPressureRecords: [BloodPressureRecord]
    let bloodGlucoseRecords: [BloodGlucoseRecord]
    
    var body: some View {
        HStack(spacing: 12) {
            // Blood Pressure Card
            NavigationLink(destination: BloodPressureHistoryView()) {
                HealthOverviewMiniCard(
                    icon: "heart.text.square.fill",
                    title: "Blood Pressure",
                    value: bloodPressureRecords.first?.displayString ?? "--/--",
                    unit: "mmHg",
                    status: bloodPressureRecords.first?.category.rawValue ?? "No data",
                    statusColor: bpStatusColor,
                    iconColor: .blue
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Blood Glucose Card
            NavigationLink(destination: BloodGlucoseHistoryView()) {
                HealthOverviewMiniCard(
                    icon: "drop.fill",
                    title: "Blood Glucose",
                    value: bloodGlucoseRecords.first?.displayString(unit: .mgdL) ?? "--",
                    unit: "mg/dL",
                    status: bloodGlucoseRecords.first?.category.rawValue ?? "No data",
                    statusColor: bgStatusColor,
                    iconColor: .purple
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var bpStatusColor: Color {
        guard let record = bloodPressureRecords.first else { return AppColors.textSecondary }
        switch record.category {
        case .low: return .blue
        case .normal: return .green
        case .elevated: return .yellow
        case .hypertensionStage1: return .orange
        case .hypertensionStage2: return .red
        case .crisis: return .purple
        }
    }
    
    private var bgStatusColor: Color {
        guard let record = bloodGlucoseRecords.first else { return AppColors.textSecondary }
        switch record.category {
        case .low: return .blue
        case .normal: return .green
        case .prediabetes: return .yellow
        case .diabetes: return .orange
        case .veryHigh: return .red
        }
    }
}

struct HealthOverviewMiniCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let status: String
    let statusColor: Color
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(title)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(unit)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                Text(status)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(statusColor)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Quick Actions Section
struct QuickActionsSection: View {
    @Binding var showingExportSheet: Bool
    let records: [HeartRateRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                NavigationLink(destination: HealthReportView()) {
                    QuickActionRow(icon: "doc.text.fill", title: "Health Report", color: .blue)
                }
                
                Divider().padding(.leading, 52)
                
                Button(action: {
                    HapticManager.shared.lightImpact()
                    showingExportSheet = true
                }) {
                    QuickActionRow(icon: "square.and.arrow.up", title: "Export PDF", color: .green)
                }
                
                Divider().padding(.leading, 52)
                
                NavigationLink(destination: RemindersView()) {
                    QuickActionRow(icon: "bell.fill", title: "Reminders", color: .orange)
                }
                
                Divider().padding(.leading, 52)
                
                NavigationLink(destination: EmergencyContactsView()) {
                    QuickActionRow(icon: "phone.fill", title: "Emergency Contacts", color: .red)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
}

struct QuickActionRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Settings Section
struct SettingsSection: View {
    @ObservedObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                // Apple Health Sync
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.pink.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.pink)
                    }
                    
                    Text("Sync to Apple Health")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $settingsManager.syncToHealth)
                        .tint(AppColors.primaryRed)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider().padding(.leading, 52)
                
                // Haptic Feedback
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 16))
                            .foregroundColor(.purple)
                    }
                    
                    Text("Haptic Feedback")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $settingsManager.hapticFeedbackEnabled)
                        .tint(AppColors.primaryRed)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider().padding(.leading, 52)
                
                // Backup & Restore
                NavigationLink(destination: BackupRestoreView()) {
                    QuickActionRow(icon: "icloud.fill", title: "Backup & Restore", color: .cyan)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Information Section
struct InformationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Information")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                NavigationLink(destination: AboutView()) {
                    QuickActionRow(icon: "info.circle.fill", title: "About", color: .blue)
                }
                
                Divider().padding(.leading, 52)
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    QuickActionRow(icon: "lock.shield.fill", title: "Privacy Policy", color: .green)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Export PDF Sheet
struct ExportPDFSheet: View {
    let records: [HeartRateRecord]
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppColors.primaryRed.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 44))
                        .foregroundColor(AppColors.primaryRed)
                }
                .padding(.top, 40)
                
                // Title
                Text("Export Health Report")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                // Description
                Text("Generate a PDF report with your last \(records.count) heart rate measurements to share with your doctor.")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
                
                // Export Button
                Button(action: {
                    exportPDF()
                }) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isExporting ? "Generating..." : "Generate & Share PDF")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(records.isEmpty ? AppColors.textSecondary : AppColors.primaryRed)
                    )
                }
                .disabled(records.isEmpty || isExporting)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func exportPDF() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            var url: URL? = nil
            if let pdfData = PDFExporter.generatePDF(from: records) {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("HeartRateReport.pdf")
                try? pdfData.write(to: tempURL)
                url = tempURL
            }
            
            DispatchQueue.main.async {
                isExporting = false
                exportURL = url
                if url != nil {
                    showShareSheet = true
                }
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppColors.primaryRed)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                // App Name
                Text("Heart Rate Senior")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Version 1.0.0")
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                
                // Description
                VStack(alignment: .leading, spacing: 16) {
                    Text("About This App")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Heart Rate Senior is designed specifically for seniors to easily measure and track their heart rate using their iPhone's camera.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Features:")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "camera.fill", text: "PPG-based heart rate measurement")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track your heart rate history")
                        FeatureRow(icon: "doc.fill", text: "Export PDF reports for your doctor")
                        FeatureRow(icon: "heart.text.square.fill", text: "Sync with Apple Health")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    Text("Disclaimer")
                        .font(AppTypography.title)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("This app is for informational purposes only and is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician with any questions you may have regarding a medical condition.")
                        .font(AppTypography.small)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer(minLength: 50)
            }
        }
        .background(AppColors.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryRed)
                .frame(width: 24)
            
            Text(text)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 20)
                
                PolicySection(
                    title: "Data Collection",
                    content: "Heart Rate Senior collects heart rate measurements that you choose to record. All data is stored locally on your device and is never transmitted to external servers."
                )
                
                PolicySection(
                    title: "Camera Usage",
                    content: "The app uses your device's camera and flashlight to detect blood flow changes in your fingertip. Camera data is processed in real-time and is not stored or transmitted."
                )
                
                PolicySection(
                    title: "Apple Health Integration",
                    content: "If you choose to enable Apple Health sync, your heart rate measurements will be shared with the Health app. This is optional and can be disabled at any time."
                )
                
                PolicySection(
                    title: "Data Storage",
                    content: "All measurement data is stored locally on your device using Apple's secure data storage. Your data is protected by your device's security features."
                )
                
                PolicySection(
                    title: "Third-Party Services",
                    content: "This app does not use any third-party analytics, advertising, or tracking services. Your privacy is our priority."
                )
                
                PolicySection(
                    title: "Contact",
                    content: "If you have any questions about this privacy policy, please contact us through the App Store."
                )
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 24)
        }
        .background(AppColors.background)
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text(content)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(SettingsManager())
        .modelContainer(for: [HeartRateRecord.self, BloodPressureRecord.self, BloodGlucoseRecord.self], inMemory: true)
}
