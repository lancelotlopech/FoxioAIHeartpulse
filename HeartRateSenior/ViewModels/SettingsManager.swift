//
//  SettingsManager.swift
//  HeartRateSenior
//
//  User settings and preferences manager
//

import Foundation
import SwiftUI

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
    
    @Published var useImperialUnits: Bool {
        didSet {
            UserDefaults.standard.set(useImperialUnits, forKey: Keys.imperialUnits)
        }
    }
    
    @Published var measurementDuration: Int {
        didSet {
            UserDefaults.standard.set(measurementDuration, forKey: Keys.measurementDuration)
        }
    }
    
    // MARK: - Keys
    private enum Keys {
        static let syncToHealth = "syncToHealth"
        static let hapticFeedback = "hapticFeedback"
        static let imperialUnits = "imperialUnits"
        static let measurementDuration = "measurementDuration"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    // MARK: - Initialization
    init() {
        // Load saved settings or use defaults
        self.syncToHealth = UserDefaults.standard.object(forKey: Keys.syncToHealth) as? Bool ?? true
        self.hapticFeedbackEnabled = UserDefaults.standard.object(forKey: Keys.hapticFeedback) as? Bool ?? true
        self.useImperialUnits = UserDefaults.standard.object(forKey: Keys.imperialUnits) as? Bool ?? true // Default to Imperial for US market
        self.measurementDuration = UserDefaults.standard.object(forKey: Keys.measurementDuration) as? Int ?? 15
    }
    
    // MARK: - Methods
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        syncToHealth = true
        hapticFeedbackEnabled = true
        useImperialUnits = true
        measurementDuration = 15
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
