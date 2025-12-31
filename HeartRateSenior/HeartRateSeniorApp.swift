//
//  HeartRateSeniorApp.swift
//  HeartRateSenior
//
//  A senior-friendly heart rate monitoring app for iOS
//

import SwiftUI
import SwiftData

@main
struct HeartRateSeniorApp: App {
    @StateObject private var settingsManager = SettingsManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HeartRateRecord.self,
            BloodPressureRecord.self,
            BloodGlucoseRecord.self,
            Reminder.self,
            EmergencyContact.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(settingsManager)
            } else {
                OnboardingContainerView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .environmentObject(settingsManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
