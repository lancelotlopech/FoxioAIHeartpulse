//
//  HealthIntegrationView.swift
//  HeartRateSenior
//
//  Apple Health integration settings and information
//

import SwiftUI

struct HealthIntegrationView: View {
    @ObservedObject var settingsManager: SettingsManager
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some View {
        List {
            // SECTION 1: How It Works
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Camera-Based Estimation")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Text("Heart rate is estimated using your iPhone's camera and flashlight by detecting subtle color changes in your fingertip (PPG technology).")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Storage Only")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Text("Apple Health is used only to store your estimated readings — we do not read or import data from Apple Health.")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("How It Works")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            
            // SECTION 2: Auto-Sync Toggle
            Section {
                Toggle(isOn: $settingsManager.syncToHealth) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.15))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 18))
                                .foregroundColor(.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Auto-Sync to Apple Health")
                                .font(.system(size: 17, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Save estimated readings to Apple Health")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(Color(hex: "FF6B6B"))
            } footer: {
                Text("Apple Health integration is optional. The app works normally without it.")
                    .font(.system(size: 13, design: .rounded))
            }
            
            // SECTION 3: Permission Status
            Section {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(permissionStatusColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: permissionStatusIcon)
                            .font(.system(size: 18))
                            .foregroundColor(permissionStatusColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Permission Status")
                            .font(.system(size: 17, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(permissionStatusText)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
                
                if !healthKitManager.isAuthorized {
                    Button(action: requestHealthAccess) {
                        HStack {
                            Spacer()
                            Text("Grant Access")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(Color(hex: "FF6B6B"))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Permission Status")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            
            // SECTION 4: Your Privacy
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    PrivacyRow(icon: "iphone", text: "Data is stored locally in Apple Health on your device")
                    PrivacyRow(icon: "xmark.icloud", text: "We never upload your health data to any server")
                    PrivacyRow(icon: "hand.raised.fill", text: "You can revoke access anytime in Settings → Privacy → Health")
                }
                .padding(.vertical, 8)
            } header: {
                Text("Your Privacy")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            
            // SECTION 5: View Your Data
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("To view your saved heart rate data:")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                    
                    StepRow(number: 1, text: "Open the Health app")
                    StepRow(number: 2, text: "Tap \"Browse\" → \"Heart\"")
                    StepRow(number: 3, text: "View your heart rate history")
                }
                .padding(.vertical, 8)
                
                Button(action: openHealthApp) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Open Health App")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            } header: {
                Text("View Your Data in Apple Health")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Apple Health")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            healthKitManager.checkAuthorizationStatus()
        }
    }
    
    // MARK: - Permission Status Helpers
    
    private var permissionStatusColor: Color {
        healthKitManager.isAuthorized ? .green : .orange
    }
    
    private var permissionStatusIcon: String {
        healthKitManager.isAuthorized ? "checkmark.shield.fill" : "exclamationmark.shield.fill"
    }
    
    private var permissionStatusText: String {
        if healthKitManager.isAuthorized {
            return "Authorized to save estimated heart rate data"
        } else {
            return "Permission needed to save estimated data"
        }
    }
    
    // MARK: - Actions
    
    private func requestHealthAccess() {
        Task {
            await healthKitManager.requestAuthorization()
        }
    }
    
    private func openHealthApp() {
        if let url = URL(string: "x-apple-health://") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Supporting Views

private struct PrivacyRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.green)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

private struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "FF6B6B").opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "FF6B6B"))
            }
            
            Text(text)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        HealthIntegrationView(settingsManager: SettingsManager())
    }
}
