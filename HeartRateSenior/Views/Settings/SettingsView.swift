//
//  SettingsView.swift
//  HeartRateSenior
//
//  Settings and preferences view (优化布局：6个Section + 大字体)
//

import SwiftUI
import SwiftData

// MARK: - 横向流光效果 (带停顿间隔)
struct ShimmerTimelineOverlay: View {
    let sweepDuration: Double   // 扫动时间
    let pauseDuration: Double   // 停顿时间
    
    private var totalCycle: Double { sweepDuration + pauseDuration }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016, paused: false)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let cycleTime = t.truncatingRemainder(dividingBy: totalCycle)
            
            GeometryReader { geo in
                if cycleTime < sweepDuration {
                    // 扫动阶段：显示光晕
                    let sweepPhase = cycleTime / sweepDuration
                    
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.10),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.3)
                    .offset(x: (sweepPhase - 0.15) * geo.size.width * 1.5)
                }
                // 停顿阶段：不显示任何内容
            }
        }
    }
}

// MARK: - 箭头脉冲动画
struct ArrowPulseView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016, paused: false)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let phase = sin(t * 4)
            let offset = phase * 3
            let scale = 1.0 + phase * 0.1
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .offset(x: offset)
                .scaleEffect(scale)
        }
    }
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var showingProfileSheet = false
    @State private var showingGenerateAlert = false
    @State private var showingDeleteAlert = false
    @State private var generatedCount = 0
    
    private let privacyPolicyURL = "https://termsheartpulse.moonspace.workers.dev/privacy_policy.html"
    private let termsOfUseURL = "https://termsheartpulse.moonspace.workers.dev/terms_of_use.html"
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                // SECTION 1: Premium Banner
                if !subscriptionManager.isPremium {
                    Section {
                        Button(action: { 
                            NotificationCenter.default.post(name: NSNotification.Name("ShowSubscription"), object: nil)
                        }) {
                            HStack(spacing: 14) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Improve Your Heart Health")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("Monitor anytime, unlock all reports")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                Spacer()
                                
                                ArrowPulseView()
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(
                            ZStack {
                                LinearGradient(
                                    colors: [
                                        Color(hex: "F5A623"),
                                        Color(hex: "FF6B8A"),
                                        Color(hex: "6366F1")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                ShimmerTimelineOverlay(sweepDuration: 1.75, pauseDuration: 1.25)
                            }
                        )
                    }
                }
                
                // SECTION 2: Profile
                Section {
                    Button(action: { showingProfileSheet = true }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E8E")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(settingsManager.userName.isEmpty ? "Set Up Profile" : settingsManager.userName)
                                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                if settingsManager.userAge > 0 || settingsManager.userGender != "Not Set" {
                                    Text(settingsManager.profileSummary)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Tap to add your profile info")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
                
                // SECTION 3: General (合并 Health + Preferences + Units + Notifications)
                Section {
                    // Apple Health - NavigationLink to dedicated page
                    NavigationLink {
                        HealthIntegrationView(settingsManager: settingsManager)
                    } label: {
                        SettingsRow(
                            icon: "heart.circle.fill",
                            title: "Apple Health",
                            subtitle: "Save heart rate data to Apple Health",
                            color: .red
                        )
                    }
                    
                    // Voice
                    Toggle(isOn: $settingsManager.voiceAnnouncementEnabled) {
                        SettingsRow(
                            icon: "speaker.wave.3.fill",
                            title: "Voice Announcement",
                            subtitle: "Read results aloud",
                            color: .indigo
                        )
                    }
                    .tint(Color(hex: "FF6B6B"))
                    
                    // Haptic
                    Toggle(isOn: $settingsManager.hapticFeedbackEnabled) {
                        SettingsRow(
                            icon: "hand.tap.fill",
                            title: "Haptic Feedback",
                            subtitle: "Vibration on interactions",
                            color: .blue
                        )
                    }
                    .tint(Color(hex: "FF6B6B"))
                    
                    // Weight Unit
                    Picker(selection: $settingsManager.weightUnit) {
                        Text("kg").tag("kg")
                        Text("lb").tag("lb")
                    } label: {
                        SettingsRow(
                            icon: "scalemass.fill",
                            title: "Weight Unit",
                            subtitle: settingsManager.weightUnit == "kg" ? "Kilograms" : "Pounds",
                            color: .orange
                        )
                    }
                    
                    // Glucose Unit
                    Picker(selection: $settingsManager.glucoseUnit) {
                        Text("mg/dL").tag("mg/dL")
                        Text("mmol/L").tag("mmol/L")
                    } label: {
                        SettingsRow(
                            icon: "drop.fill",
                            title: "Glucose Unit",
                            subtitle: settingsManager.glucoseUnit,
                            color: .purple
                        )
                    }
                    
                    // Notifications
                    Button(action: { settingsManager.openNotificationSettings() }) {
                        HStack {
                            SettingsRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: notificationStatusText,
                                color: .orange
                            )
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("General")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // SECTION 4: Tools (合并 Features + Data)
                Section {
                    NavigationLink {
                        RemindersView()
                    } label: {
                        SettingsRow(
                            icon: "alarm.fill",
                            title: "Reminders",
                            subtitle: "Measurement & medication alerts",
                            color: .cyan
                        )
                    }
                    
                    NavigationLink {
                        EmergencyContactsView()
                    } label: {
                        SettingsRow(
                            icon: "person.2.fill",
                            title: "Emergency Contacts",
                            subtitle: "Quick call & abnormal alerts",
                            color: .green
                        )
                    }
                    
                    NavigationLink {
                        HealthReportView()
                    } label: {
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Health Reports",
                            subtitle: "View & export health summaries",
                            color: .purple
                        )
                    }
                    
                    NavigationLink {
                        BackupRestoreView()
                    } label: {
                        SettingsRow(
                            icon: "icloud.fill",
                            title: "Backup & Restore",
                            subtitle: "Export and import your data",
                            color: .blue
                        )
                    }
                } header: {
                    Text("Tools")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // SECTION 5: About (合并 Support + About)
                Section {
                    Button(action: { settingsManager.openAppStoreForRating() }) {
                        HStack {
                            SettingsRow(
                                icon: "star.fill",
                                title: "Rate This App",
                                subtitle: "Share your feedback",
                                color: .yellow
                            )
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { settingsManager.sendFeedbackEmail() }) {
                        HStack {
                            SettingsRow(
                                icon: "envelope.fill",
                                title: "Send Feedback",
                                subtitle: "developer@moonspace.work",
                                color: .teal
                            )
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    HStack {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "Version",
                            subtitle: "\(settingsManager.appVersion) (\(settingsManager.buildNumber))",
                            color: .gray
                        )
                    }
                    
                    Link(destination: URL(string: privacyPolicyURL)!) {
                        HStack {
                            SettingsRow(
                                icon: "hand.raised.fill",
                                title: "Privacy Policy",
                                subtitle: "How we handle your data",
                                color: .gray
                            )
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Link(destination: URL(string: termsOfUseURL)!) {
                        HStack {
                            SettingsRow(
                                icon: "doc.plaintext.fill",
                                title: "Terms of Use",
                                subtitle: "Usage terms and conditions",
                                color: .gray
                            )
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("About")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // SECTION 6: Disclaimer
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 17))
                                .foregroundColor(.orange)
                            
                            Text("Medical Disclaimer")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                        
                        Text("This app is for informational purposes only and is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician with any questions regarding a medical condition.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 6)
                }
                
                // DEBUG Section
                #if DEBUG
                Section {
                    Picker(selection: Binding(
                        get: { DebugSettings.shared.premiumOverride },
                        set: { DebugSettings.shared.premiumOverride = $0 }
                    )) {
                        ForEach(DebugSettings.PremiumOverride.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    } label: {
                        SettingsRow(
                            icon: "crown.fill",
                            title: "Premium Override",
                            subtitle: "Current: \(DebugSettings.shared.premiumOverride.rawValue)",
                            color: .orange
                        )
                    }
                    
                    Toggle(isOn: Binding(
                        get: { DebugSettings.shared.hasCompletedOnboarding },
                        set: { DebugSettings.shared.hasCompletedOnboarding = $0 }
                    )) {
                        SettingsRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Onboarding Completed",
                            subtitle: DebugSettings.shared.hasCompletedOnboarding ? "Shown" : "Hidden",
                            color: .green
                        )
                    }
                    .tint(Color(hex: "FF6B6B"))
                    
                    Button(action: { DebugSettings.shared.resetOnboarding() }) {
                        SettingsRow(
                            icon: "arrow.counterclockwise",
                            title: "Reset Onboarding",
                            subtitle: "Show onboarding on next launch",
                            color: .purple
                        )
                    }
                    
                    Button(action: { showingGenerateAlert = true }) {
                        SettingsRow(
                            icon: "chart.bar.doc.horizontal.fill",
                            title: "Generate 100 Days Data",
                            subtitle: "Inject sample data",
                            color: .cyan
                        )
                    }
                    
                    Button(action: { showingDeleteAlert = true }) {
                        SettingsRow(
                            icon: "trash.fill",
                            title: "Delete All Records",
                            subtitle: "Remove all health records",
                            color: .red
                        )
                    }
                } header: {
                    HStack {
                        Image(systemName: "hammer.fill")
                        Text("🧪 Debug")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                } footer: {
                    Text("Only visible in Debug builds.")
                        .font(.system(size: 12))
                }
                #endif
            }
            .listStyle(.insetGrouped)
            .contentMargins(.top, 8, for: .scrollContent)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                settingsManager.refreshNotificationStatus()
            }
            .sheet(isPresented: $showingProfileSheet) {
                ProfileEditView(settingsManager: settingsManager)
            }
            .alert("Generate Sample Data?", isPresented: $showingGenerateAlert) {
                Button("Generate 100 Days", role: .none) {
                    generatedCount = SampleDataGenerator.generateSeniorHeartRateData(modelContext: modelContext, days: 100)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will generate approximately 200-300 heart rate records.")
            }
            .alert("Delete All Records?", isPresented: $showingDeleteAlert) {
                Button("Delete All", role: .destructive) {
                    SampleDataGenerator.deleteAllRecords(modelContext: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all records.")
            }
            }
        }
    }
    
    private var notificationStatusText: String {
        switch settingsManager.notificationStatus {
        case .authorized: return "Enabled"
        case .denied: return "Disabled - Tap to enable"
        case .provisional: return "Provisional"
        case .notDetermined: return "Not configured"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Settings Row (放大字体：18pt title, 14pt subtitle, 36×36 icon)
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Profile Edit View
struct ProfileEditView: View {
    @ObservedObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var ageText: String = ""
    @State private var selectedGender: GenderOption = .notSet
    @State private var heightCm: Double = 170.0
    
    private let heightRange = 100.0...220.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E8E")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section("Personal Information") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your Name", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(GenderOption.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("", text: $ageText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .font(.system(size: 18, weight: .semibold))
                        Text("years")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Body Measurements") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Height")
                            Spacer()
                            Text(heightDisplay)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $heightCm, in: heightRange, step: 1)
                            .tint(Color(hex: "FF6B6B"))
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                            Text("Privacy Notice")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        Text("Your profile information is stored locally on this device and is never shared with third parties.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear { loadCurrentProfile() }
        }
    }
    
    private var heightDisplay: String {
        if settingsManager.weightUnit == "lb" {
            let totalInches = heightCm / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(inches)\" (\(Int(heightCm)) cm)"
        } else {
            return "\(Int(heightCm)) cm"
        }
    }
    
    private func loadCurrentProfile() {
        name = settingsManager.userName
        ageText = settingsManager.userAge > 0 ? "\(settingsManager.userAge)" : ""
        selectedGender = GenderOption(rawValue: settingsManager.userGender) ?? .notSet
        heightCm = settingsManager.userHeightCm
    }
    
    private func saveProfile() {
        settingsManager.userName = name
        settingsManager.userAge = Int(ageText) ?? 0
        settingsManager.userGender = selectedGender.rawValue
        settingsManager.userHeightCm = heightCm
    }
}

#Preview {
    SettingsView()
}
