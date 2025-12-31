//
//  HomeView.swift
//  HeartRateSenior
//
//  Continuous measurement view with camera preview and real-time waveform
//

import SwiftUI

struct HomeView: View {
    var autoStart: Bool = false
    var onDismiss: (() -> Void)? = nil
    
    @StateObject private var heartRateManager = HeartRateManager()
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingResult = false
    @State private var finalHRV: HRVMetrics?
    @State private var showCompletionAnimation = false
    @State private var previousState: MeasurementState = .idle
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main content based on state
                    switch heartRateManager.measurementState {
                    case .idle:
                        // autoStart 模式下直接显示加载状态，跳过中间页
                        if autoStart {
                            PreparingStateView()
                        } else {
                            IdleStateView(heartRateManager: heartRateManager)
                        }
                        
                    case .preparing:
                        PreparingStateView()
                        
                    case .measuring:
                        ContinuousMeasuringView(heartRateManager: heartRateManager)
                        
                    case .completed:
                        // 测量完成过渡动画
                        CompletionAnimationView(showingResult: $showingResult) {
                            finalHRV = heartRateManager.getFinalHRV()
                        }
                        
                    case .error(let message):
                        ErrorStateView(message: message, heartRateManager: heartRateManager)
                    }
                    
                    // Bottom spacer
                    if onDismiss == nil {
                        Spacer()
                            .frame(height: 80)
                    }
                }
            }
            .navigationTitle("Heart Rate")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if autoStart && heartRateManager.measurementState == .idle {
                    heartRateManager.startMeasurement()
                }
            }
            .onChange(of: heartRateManager.measurementState) { oldState, newState in
                if newState == .idle && (oldState == .measuring || oldState == .preparing) && autoStart {
                    onDismiss?()
                }
                previousState = newState
            }
            .navigationDestination(isPresented: $showingResult) {
                ResultView(
                    bpm: heartRateManager.currentBPM,
                    hrvMetrics: finalHRV,
                    onDismiss: {
                        showingResult = false
                        finalHRV = nil
                        heartRateManager.resetToIdle()
                        onDismiss?()
                    }
                )
            }
        }
    }
}

// MARK: - Idle State View
struct IdleStateView: View {
    @ObservedObject var heartRateManager: HeartRateManager
    
    var body: some View {
        VStack(spacing: AppDimensions.paddingXLarge) {
            Spacer()
            
            Text("Place your finger on the camera\nto measure your heart rate")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            
            MeasureButton {
                HapticManager.shared.mediumImpact()
                heartRateManager.startMeasurement()
            }
            
            Text("Tap to Measure")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, AppDimensions.paddingMedium)
    }
}

// MARK: - Preparing State View
struct PreparingStateView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: AppDimensions.paddingLarge) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(AppColors.cardBackground, lineWidth: 4)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(AppColors.primaryRed, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primaryRed)
            }
            
            Text("Starting Camera...")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Measurement Phase Indicator (6阶段)
struct MeasurementPhaseIndicator: View {
    let duration: TimeInterval
    let isFingerDetected: Bool
    
    // 6阶段配置（总50秒）
    private let phases: [(icon: String, text: String, endTime: Double)] = [
        ("camera.fill", "Initializing...", 4),
        ("heart.fill", "Detecting Heart Rate", 14),
        ("waveform.path.ecg", "Analyzing Heart Rhythm", 26),
        ("chart.bar.fill", "Calculating HRV", 38),
        ("leaf.fill", "Assessing Wellness", 46),
        ("sparkles", "Finalizing Results", 50)
    ]
    
    private var currentPhaseIndex: Int {
        for (index, phase) in phases.enumerated() {
            if duration < phase.endTime {
                return index
            }
        }
        return phases.count - 1
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if isFingerDetected {
                let phase = phases[currentPhaseIndex]
                
                HStack(spacing: 10) {
                    Image(systemName: phase.icon)
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text(phase.text)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                .animation(.easeInOut(duration: 0.3), value: currentPhaseIndex)
                
                // 6个进度点
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(index <= currentPhaseIndex ? AppColors.primaryRed : AppColors.primaryRed.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "hand.point.up.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.warning)
                    
                    Text("Place finger on camera")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.warning)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Continuous Measuring View (Main View)
struct ContinuousMeasuringView: View {
    @ObservedObject var heartRateManager: HeartRateManager
    @State private var pulseScale: CGFloat = 1.0
    @State private var heartScale: CGFloat = 1.0
    @State private var wasFingerDetected: Bool = false
    
    // 单层涟漪动画
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 1. Center Display (Camera + Heart + BPM + Progress Ring)
            ZStack {
                // 进度环底色
                Circle()
                    .stroke(AppColors.primaryRed.opacity(0.15), lineWidth: 10)
                    .frame(width: 260, height: 260)
                
                // 单层柔和涟漪效果
                if heartRateManager.isFingerDetected {
                    Circle()
                        .stroke(AppColors.primaryRed.opacity(rippleOpacity * 0.3), lineWidth: 2)
                        .frame(width: 260, height: 260)
                        .scaleEffect(rippleScale)
                }
                
                // Progress Ring - 珊瑚红，10pt 线宽（50秒）
                Circle()
                    .trim(from: 0, to: CGFloat(min(1.0, heartRateManager.measurementDuration / 50.0)))
                    .stroke(
                        AppColors.primaryRed,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: heartRateManager.measurementDuration)
                
                // Camera Preview Container
                ZStack {
                    CameraPreviewView(session: heartRateManager.previewSession)
                        .frame(width: 220, height: 220)
                        .clipShape(Circle())
                    
                    // Finger Detection Warning Overlay
                    if !heartRateManager.isFingerDetected {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.75))
                            
                            VStack(spacing: 12) {
                                Image(systemName: "hand.point.up.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                                Text("Cover Camera")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .frame(width: 220, height: 220)
                        .clipShape(Circle())
                    }
                    
                    // Heart + BPM Overlay
                    if heartRateManager.isFingerDetected {
                        VStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.primaryRed)
                                .scaleEffect(heartScale)
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            
                            Text("\(heartRateManager.currentBPM)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .contentTransition(.numericText())
                                .scaleEffect(pulseScale)
                            
                            Text("BPM")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        }
                    }
                }
            }
            .onChange(of: heartRateManager.isFingerDetected) { oldValue, newValue in
                if newValue && !oldValue {
                    HapticManager.shared.lightImpact()
                }
                wasFingerDetected = newValue
            }
            .onChange(of: heartRateManager.heartbeatTick) { _, _ in
                withAnimation(.easeOut(duration: 0.12)) {
                    heartScale = 1.15
                }
                withAnimation(.easeOut(duration: 0.2).delay(0.12)) {
                    heartScale = 1.0
                }
                
                withAnimation(.easeOut(duration: 0.1)) {
                    pulseScale = 1.03
                }
                withAnimation(.easeOut(duration: 0.2).delay(0.1)) {
                    pulseScale = 1.0
                }
                
                rippleScale = 1.0
                rippleOpacity = 1.0
                withAnimation(.easeOut(duration: 0.6)) {
                    rippleScale = 1.12
                    rippleOpacity = 0.0
                }
            }
            
            Spacer()
            
            // 2. 脉冲条形图
            PulseBarChartView(heartbeatTick: heartRateManager.heartbeatTick)
                .frame(height: 60)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // 3. 阶段进度提示
            MeasurementPhaseIndicator(
                duration: heartRateManager.measurementDuration,
                isFingerDetected: heartRateManager.isFingerDetected
            )
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Completion Animation View
struct CompletionAnimationView: View {
    @Binding var showingResult: Bool
    let onPrepareResult: () -> Void
    
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var ringProgress: CGFloat = 0
    @State private var textOpacity: Double = 0
    
    private let successGreen = Color(red: 0.2, green: 0.75, blue: 0.4)
    
    var body: some View {
        VStack(spacing: AppDimensions.paddingLarge) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(successGreen.opacity(0.2), lineWidth: 6)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(successGreen, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .fill(successGreen.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .scaleEffect(checkmarkScale)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(successGreen)
                    .scaleEffect(checkmarkScale)
                    .opacity(checkmarkOpacity)
            }
            
            Text("Complete!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(successGreen)
                .opacity(textOpacity)
            
            Text("Your heart rate has been measured")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .opacity(textOpacity)
            
            Spacer()
        }
        .onAppear {
            startCompletionAnimation()
        }
    }
    
    private func startCompletionAnimation() {
        HapticManager.shared.success()
        onPrepareResult()
        
        withAnimation(.easeOut(duration: 0.4)) {
            ringProgress = 1.0
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2)) {
            checkmarkScale = 1.0
            checkmarkOpacity = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.3).delay(0.4)) {
            textOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingResult = true
            }
        }
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let message: String
    @ObservedObject var heartRateManager: HeartRateManager
    
    var body: some View {
        VStack(spacing: AppDimensions.paddingLarge) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppColors.cardBackground)
                    .frame(width: 150, height: 150)
                
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(AppColors.warning)
            }
            
            Text("Error")
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)
            
            Text(message)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                HapticManager.shared.mediumImpact()
                heartRateManager.stopMeasurement()
            }) {
                Text("Try Again")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SeniorButtonStyle())
            .padding(.horizontal, AppDimensions.paddingLarge)
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SettingsManager())
}
