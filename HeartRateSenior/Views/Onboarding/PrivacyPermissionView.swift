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
    @Binding var hasCompletedOnboarding: Bool
    @State private var cameraPermissionGranted = false
    @State private var showingPermissionAlert = false
    
    // Animation states
    @State private var visibleItems: Set<Int> = []
    @State private var iconScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    
    private let accentRed = Color(hex: "F4403A")
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let isSmallScreen = size.height < 700
            let iconSize: CGFloat = isSmallScreen ? 44 : 54
            let bottomInset = geometry.safeAreaInsets.bottom
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top spacing
                    Spacer()
                        .frame(height: isSmallScreen ? 16 : 24)
                    
                    // Privacy shield icon with glow
                    ZStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: iconSize))
                            .foregroundColor(accentRed)
                            .shadow(color: accentRed.opacity(glowOpacity), radius: 15, x: 0, y: 0)
                            .shadow(color: accentRed.opacity(glowOpacity * 0.6), radius: 25, x: 0, y: 0)
                            .scaleEffect(iconScale)
                    }
                    .frame(height: iconSize + 12)
                    
                    Spacer()
                        .frame(height: isSmallScreen ? 10 : 14)
                    
                    // Title (字号改为24，确保三行显示，"data safe" 标红)
                    (Text("We keep your health ")
                        .font(.system(size: isSmallScreen ? 16 : 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    + Text("data safe")
                        .font(.system(size: isSmallScreen ? 16 : 20, weight: .bold, design: .rounded))
                        .foregroundColor(accentRed)
                    + Text("\nand always under your control")
                        .font(.system(size: isSmallScreen ? 16 : 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: isSmallScreen ? 14 : 18)
                    
                    // Feature items
                    VStack(spacing: isSmallScreen ? 6 : 8) {
                        PrivacyFeatureRowCompact(
                            icon: "camera.fill",
                            iconColor: .blue,
                            title: "Camera Access",
                            description: "Detect blood flow in your fingertip",
                            isVisible: visibleItems.contains(0),
                            isSmallScreen: isSmallScreen
                        )
                        
                        PrivacyFeatureRowCompact(
                            icon: "iphone.gen3",
                            iconColor: .green,
                            title: "Local Processing",
                            description: "All data stays on your device",
                            isVisible: visibleItems.contains(1),
                            isSmallScreen: isSmallScreen
                        )
                        
                        PrivacyFeatureRowCompact(
                            icon: "hand.raised.fill",
                            iconColor: .orange,
                            title: "Your Control",
                            description: "Delete your data anytime",
                            isVisible: visibleItems.contains(2),
                            isSmallScreen: isSmallScreen
                        )
                        
                        PrivacyFeatureRowCompact(
                            icon: "heart.text.square.fill",
                            iconColor: accentRed,
                            title: "Apple Health",
                            description: "Sync heart rate data with Health app",
                            isVisible: visibleItems.contains(3),
                            isSmallScreen: isSmallScreen
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: isSmallScreen ? 10 : 14)
                    
                    // Apple Health Detail Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16))
                                .foregroundColor(accentRed)
                            Text("Apple Health Integration")
                                .font(.system(size: isSmallScreen ? 13 : 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("Foxio-HeartRate Senior uses Apple Health to track your heart rate and provide personalized insights.")
                            .font(.system(size: isSmallScreen ? 11 : 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                        
                        Text("You will be asked to grant permission to access your heart data.")
                            .font(.system(size: isSmallScreen ? 11 : 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentRed.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(accentRed.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .opacity(visibleItems.contains(4) ? 1 : 0)
                    .offset(y: visibleItems.contains(4) ? 0 : 10)
                    
                    Spacer()
                        .frame(height: isSmallScreen ? 16 : 20)
                    
                    // Continue button
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        requestCameraPermission()
                    }) {
                        HStack(spacing: 6) {
                            if cameraPermissionGranted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                            }
                            Text(cameraPermissionGranted ? "Continue" : "Allow Camera Access")
                                .font(.system(size: isSmallScreen ? 15 : 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: isSmallScreen ? 48 : 52)
                        .background(cameraPermissionGranted ? Color.green : accentRed)
                        .cornerRadius(isSmallScreen ? 24 : 26)
                    }
                    .padding(.horizontal, 20)
                    
                    // Bottom spacing
                    Spacer()
                        .frame(height: max(16, bottomInset) + 12)
                }
                .frame(minHeight: size.height)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            checkCameraPermission()
            resetAndStartAnimations()
        }
        .onChange(of: currentPage) { newPage in
            if newPage == 4 {
                resetAndStartAnimations()
            }
        }
        .alert("Camera Access Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable camera access in Settings to check your heart rate.")
        }
    }
    
    private func resetAndStartAnimations() {
        visibleItems.removeAll()
        iconScale = 1.0
        glowOpacity = 0.3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Icon pulse animation
        withAnimation(
            .easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        ) {
            iconScale = 1.08
            glowOpacity = 0.5
        }
        
        // Feature rows appear with delays (now 5 items: 4 rows + 1 card)
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    _ = visibleItems.insert(i)
                }
            }
        }
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermissionGranted = status == .authorized
    }
    
    private func requestCameraPermission() {
        if cameraPermissionGranted {
            HapticManager.shared.success()
            withAnimation {
                hasCompletedOnboarding = true
            }
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                    if granted {
                        HapticManager.shared.success()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                hasCompletedOnboarding = true
                            }
                        }
                    }
                }
            }
        case .denied, .restricted:
            showingPermissionAlert = true
        case .authorized:
            cameraPermissionGranted = true
            HapticManager.shared.success()
            withAnimation {
                hasCompletedOnboarding = true
            }
        @unknown default:
            break
        }
    }
}

// MARK: - Compact Privacy Feature Row
struct PrivacyFeatureRowCompact: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isVisible: Bool
    let isSmallScreen: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: isSmallScreen ? 36 : 40, height: isSmallScreen ? 36 : 40)
                
                Image(systemName: icon)
                    .font(.system(size: isSmallScreen ? 16 : 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: isSmallScreen ? 13 : 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: isSmallScreen ? 11 : 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, isSmallScreen ? 8 : 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0)
    }
}

#Preview {
    PrivacyPermissionView(currentPage: .constant(4), hasCompletedOnboarding: .constant(false))
}
