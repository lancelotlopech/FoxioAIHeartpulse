//
//  HapticManager.swift
//  HeartRateSenior
//
//  Centralized haptic feedback management with realistic heartbeat pattern
//

import UIKit
import CoreHaptics

@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    // Generators
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        heavyGenerator.prepare()
        mediumGenerator.prepare()
        lightGenerator.prepare()
    }
    
    // MARK: - Realistic Heartbeat Pattern "咚-咚"
    
    /// Play a realistic heartbeat pattern: strong beat followed by weaker beat
    /// Mimics the "lub-dub" sound of a real heart
    /// Real heart timing: S1-S2 interval is about 0.25-0.35 seconds
    func playHeartbeatPattern() {
        // First beat: Strong (S1 - "lub")
        heavyGenerator.impactOccurred(intensity: 1.0)
        heavyGenerator.prepare()
        
        // Second beat: Weaker (S2 - "dub") after 0.3 seconds (realistic timing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.mediumGenerator.impactOccurred(intensity: 0.5)
            self?.mediumGenerator.prepare()
        }
    }
    
    // MARK: - Legacy Methods
    
    func playPattern(intensity: Float) {
        heavyGenerator.impactOccurred(intensity: CGFloat(intensity))
        heavyGenerator.prepare()
    }
    
    func heartbeat() {
        playHeartbeatPattern()
    }
    
    func lightImpact() {
        lightGenerator.impactOccurred()
    }
    
    func mediumImpact() {
        mediumGenerator.impactOccurred()
    }
    
    func heavyImpact() {
        heavyGenerator.impactOccurred()
    }
    
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    func selectionChanged() {
        selectionGenerator.selectionChanged()
    }
}
