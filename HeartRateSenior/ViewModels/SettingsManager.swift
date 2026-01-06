//
//  SettingsManager.swift
//  HeartRateSenior
//
//  User settings and preferences manager
//

import Foundation
import SwiftUI
import UserNotifications

@MainActor
class SettingsManager: ObservableObject {
    
    // MARK: - Published Settings
    @Published var syncToHealth: Bool {
        didSet {
            UserDefaults.standard.set(syncToHealth, forKey: Keys.syncToHealth)
        }
    }
    
    @Published var hapticFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedbackEnabled, forKey: Keys.hapticFeedback)
        }
    }
    
    @Published var voiceAnnouncementEnabled: Bool {
        didSet {
            UserDefaults.standard.set(voiceAnnouncementEnabled, forKey: Keys.voiceAnnouncement)
        }
    }
    
    @Published var weightUnit: String {
        didSet {
            UserDefaults.standard.set(weightUnit, forKey: Keys.weightUnit)
        }
    }
    
    @Published var glucoseUnit: String {
        didSet {
            UserDefaults.standard.set(glucoseUnit, forKey: Keys.glucoseUnit)
        }
    }
    
    // Alert Settings
    @Published var alertEnabled: Bool {
        didSet {
            UserDefaults.standard.set(alertEnabled, forKey: Keys.alertEnabled)
        }
    }
    
    @Published var alertHeartRateLow: Int {
        didSet {
            UserDefaults.standard.set(alertHeartRateLow, forKey: Keys.alertHeartRateLow)
        }
    }
    
    @Published var alertHeartRateHigh: Int {
        didSet {
            UserDefaults.standard.set(alertHeartRateHigh, forKey: Keys.alertHeartRateHigh)
        }
    }
    
    // User Profile
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: Keys.userName)
        }
    }
    
    @Published var userAge: Int {
        didSet {
            UserDefaults.standard.set(userAge, forKey: Keys.userAge)
        }
    }
    
    @Published var userGender: String {
        didSet {
            UserDefaults.standard.set(userGender, forKey: Keys.userGender)
        }
    }
    
    @Published var userHeightCm: Double {
        didSet {
            UserDefaults.standard.set(userHeightCm, forKey: Keys.userHeight)
        }
    }
    
    // Notification status (read-only, refreshed on appear)
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Keys
    private enum Keys {
        static let syncToHealth = "syncToHealth"
        static let hapticFeedback = "hapticFeedback"
        static let voiceAnnouncement = "voiceAnnouncement"
        static let weightUnit = "weightUnit"
        static let glucoseUnit = "glucoseUnit"
        static let userName = "userName"
        static let userAge = "userAge"
        static let userGender = "userGender"
        static let userHeight = "userHeight"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let alertEnabled = "alertEnabled"
        static let alertHeartRateLow = "alertHeartRateLow"
        static let alertHeartRateHigh = "alertHeartRateHigh"
    }
    
    // MARK: - Initialization
    init() {
        // Load saved settings or use defaults
        self.syncToHealth = UserDefaults.standard.object(forKey: Keys.syncToHealth) as? Bool ?? true
        self.hapticFeedbackEnabled = UserDefaults.standard.object(forKey: Keys.hapticFeedback) as? Bool ?? true
        self.voiceAnnouncementEnabled = UserDefaults.standard.object(forKey: Keys.voiceAnnouncement) as? Bool ?? true
        self.weightUnit = UserDefaults.standard.string(forKey: Keys.weightUnit) ?? "lb" // US default
        self.glucoseUnit = UserDefaults.standard.string(forKey: Keys.glucoseUnit) ?? "mg/dL" // US default
        
        // Alert Settings
        self.alertEnabled = UserDefaults.standard.object(forKey: Keys.alertEnabled) as? Bool ?? false
        self.alertHeartRateLow = UserDefaults.standard.object(forKey: Keys.alertHeartRateLow) as? Int ?? 50
        self.alertHeartRateHigh = UserDefaults.standard.object(forKey: Keys.alertHeartRateHigh) as? Int ?? 120
        
        // User Profile
        self.userName = UserDefaults.standard.string(forKey: Keys.userName) ?? ""
        self.userAge = UserDefaults.standard.object(forKey: Keys.userAge) as? Int ?? 0
        self.userGender = UserDefaults.standard.string(forKey: Keys.userGender) ?? "Not Set"
        self.userHeightCm = UserDefaults.standard.object(forKey: Keys.userHeight) as? Double ?? 170.0
        
        // Check notification status
        refreshNotificationStatus()
    }
    
    // MARK: - Methods
    
    /// Refresh notification authorization status
    func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }
    
    /// Open system settings for notifications
    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    /// Open App Store for rating
    func openAppStoreForRating() {
        // Replace with actual App ID when published
        let appID = "YOUR_APP_ID"
        if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    /// Send feedback email
    func sendFeedbackEmail() {
        let email = "developer@moonspace.work"
        let subject = "Heart Pulse App Feedback"
        let body = "App Version: \(appVersion) (\(buildNumber))\n\n"
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        syncToHealth = true
        hapticFeedbackEnabled = true
        voiceAnnouncementEnabled = true
        weightUnit = "lb"
        glucoseUnit = "mg/dL"
    }
    
    /// Trigger haptic feedback if enabled
    func triggerHaptic(_ type: HapticType) {
        guard hapticFeedbackEnabled else { return }
        
        switch type {
        case .light:
            HapticManager.shared.lightImpact()
        case .medium:
            HapticManager.shared.mediumImpact()
        case .heavy:
            HapticManager.shared.heavyImpact()
        case .success:
            HapticManager.shared.success()
        case .warning:
            HapticManager.shared.warning()
        case .error:
            HapticManager.shared.error()
        case .selection:
            HapticManager.shared.selectionChanged()
        case .heartbeat:
            HapticManager.shared.heartbeat()
        }
    }
    
    // MARK: - Computed Properties
    
    /// User height in feet and inches for display
    var userHeightDisplay: String {
        if weightUnit == "lb" {
            // Imperial: feet and inches
            let totalInches = userHeightCm / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(inches)\""
        } else {
            // Metric: cm
            return "\(Int(userHeightCm)) cm"
        }
    }
    
    /// Profile summary
    var profileSummary: String {
        var parts: [String] = []
        if userAge > 0 { parts.append("\(userAge) yrs") }
        if userGender != "Not Set" { parts.append(userGender) }
        parts.append(userHeightDisplay)
        return parts.joined(separator: " • ")
    }
    
    // MARK: - App Info
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Haptic Types
enum HapticType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
    case heartbeat
}

// MARK: - Gender Options
enum GenderOption: String, CaseIterable {
    case notSet = "Not Set"
    case male = "Male"
    case female = "Female"
    case other = "Other"
}
