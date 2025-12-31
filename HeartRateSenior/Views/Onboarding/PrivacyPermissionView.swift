//
//  PrivacyPermissionView.swift
//  HeartRateSenior
//
//  Privacy explanation and camera permission request
//

import SwiftUI
import AVFoundation

struct PrivacyPermissionView: View {
    @Binding var currentPage: Int
    @State private var cameraPermissionGranted = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Scrollable Content
                ScrollView {
                    VStack(spacing: AppDimensions.paddingLarge) {
                        Spacer(minLength: 20)
                        
                        // Privacy icon
                        ZStack {
                            Circle()
                                .fill(AppColors.cardBackground)
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 70))
                                .foregroundColor(AppColors.primaryRed)
                        }
                        
                        // Title
                        Text("Your Privacy Matters")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        
                        // Explanation
                        VStack(spacing: 16) {
                            PrivacyFeatureRow(
                                icon: "camera.fill",
                                title: "Camera Access",
                                description: "Used to detect blood flow changes in your fingertip."
                            )
                            
                            PrivacyFeatureRow(
                                icon: "iphone",
                                title: "Local Processing",
                                description: "Data is processed on device. No internet needed."
                            )
                            
                            PrivacyFeatureRow(
                                icon: "hand.raised.fill",
                                title: "Your Control",
                                description: "You can delete your data anytime."
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Legal Disclaimer
                        VStack(spacing: 6) {
                            Text("By using this app, you agree to our")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                Link("Terms of Use", destination: URL(string: "https://termsheartpulse.moonspace.workers.dev/terms_of_use.html")!)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColors.primaryRed)
                                
                                Text("&")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                
                                Link("Privacy Policy", destination: URL(string: "https://termsheartpulse.moonspace.workers.dev/privacy_policy.html")!)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppColors.primaryRed)
                            }
                        }
                        .padding(.top, 10)
                        
                        Spacer(minLength: 40)
                    }
                    .frame(minHeight: geometry.size.height - 180) // Reserve space for bottom buttons
                }
                
                // Fixed Bottom Buttons
                VStack(spacing: 16) {
                    // Permission button
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        requestCameraPermission()
                    }) {
                        HStack {
                            Image(systemName: cameraPermissionGranted ? "checkmark.circle.fill" : "camera.fill")
                            Text(cameraPermissionGranted ? "Permission Granted" : "Allow Camera Access")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SeniorButtonStyle(
                        backgroundColor: cameraPermissionGranted ? .green : AppColors.primaryRed
                    ))
                    .disabled(cameraPermissionGranted)
                    
                    // Continue/Skip Area
                    if cameraPermissionGranted {
                        Button(action: {
                            HapticManager.shared.mediumImpact()
                            withAnimation {
                                currentPage = 2
                            }
                        }) {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage = 2
                            }
                        }) {
                            Text("Skip for now")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, AppDimensions.paddingLarge)
                .padding(.bottom, AppDimensions.paddingXLarge)
                .background(AppColors.background) // Cover scroll content
            }
            .background(AppColors.background)
        }
        .onAppear {
            checkCameraPermission()
        }
        .alert("Camera Access Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable camera access in Settings to measure your heart rate.")
        }
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermissionGranted = status == .authorized
    }
    
    private func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                    if granted {
                        HapticManager.shared.success()
                    }
                }
            }
        case .denied, .restricted:
            showingPermissionAlert = true
        case .authorized:
            cameraPermissionGranted = true
        @unknown default:
            break
        }
    }
}

// MARK: - Privacy Feature Row
struct PrivacyFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: AppDimensions.paddingMedium) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(AppColors.primaryRed)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.button)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(AppDimensions.paddingMedium)
        .background(AppColors.cardBackground)
        .cornerRadius(AppDimensions.cornerRadius)
    }
}

#Preview {
    PrivacyPermissionView(currentPage: .constant(1))
}
