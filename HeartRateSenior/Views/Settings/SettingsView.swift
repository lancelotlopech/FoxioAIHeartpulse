//
//  SettingsView.swift
//  HeartRateSenior
//
//  Settings and preferences view
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var healthKitManager = HealthKitManager()
    
    // Cloudflare Pages URLs
    private let privacyPolicyURL = "https://termsheartpulse.moonspace.workers.dev/privacy_policy.html"
    private let termsOfUseURL = "https://termsheartpulse.moonspace.workers.dev/terms_of_use.html"
    
    var body: some View {
        NavigationStack {
            List {
                // Health Integration Section
                Section {
                    Toggle(isOn: $settingsManager.syncToHealth) {
                        HStack(spacing: 12) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                                .frame(width: 28)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sync to Apple Health")
                                    .font(.system(size: 18, design: .rounded))
                                Text("Save measurements to Health app")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tint(Color(hex: "FF3B30"))
                } header: {
                    Text("Health Integration")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Preferences Section
                Section {
                    Toggle(isOn: $settingsManager.hapticFeedbackEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 28)
                            
                            Text("Haptic Feedback")
                                .font(.system(size: 18, design: .rounded))
                        }
                    }
                    .tint(Color(hex: "FF3B30"))
                } header: {
                    Text("Preferences")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Features Section
                Section {
                    NavigationLink {
                        RemindersView()
                    } label: {
                        SettingsRow(
                            icon: "bell.fill",
                            title: "Reminders",
                            subtitle: "Measurement & medication alerts",
                            color: .orange
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
                } header: {
                    Text("Features")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Data Section
                Section {
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
                    Text("Data")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                            .font(.system(size: 18, design: .rounded))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    Link(destination: URL(string: privacyPolicyURL)!) {
                        HStack {
                            Text("Privacy Policy")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Link(destination: URL(string: termsOfUseURL)!) {
                        HStack {
                            Text("Terms of Use")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("About")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Disclaimer Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Medical Disclaimer", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                        
                        Text("This app is for informational purposes only and is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
}
