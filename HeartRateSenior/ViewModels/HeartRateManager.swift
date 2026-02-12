//
//  HeartRateManager.swift
//  HeartRateSenior
//
//  Professional PPG Heart Rate Manager V7.0
//  行业标准版：Session 只创建一次，Torch 延迟开启，不闪烁
//

import Foundation
import AVFoundation
import UIKit
import Combine

// MARK: - Measurement State
enum MeasurementState: Equatable {
    case idle
    case preparing
    case measuring
    case completed
    case error(String)
    
    static func == (lhs: MeasurementState, rhs: MeasurementState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.preparing, .preparing),
             (.measuring, .measuring), (.completed, .completed):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - Measurement Phase
enum MeasurementPhase {
    case warmup      // First 3 seconds - calibrating
    case acquisition // 3-60 seconds - measuring
    case completed   // After 60 seconds
}

// MARK: - Heart Rate Manager (行业标准版)
@MainActor
class HeartRateManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    static let shared = HeartRateManager()
    
    // MARK: - Published Properties
    @Published var measurementState: MeasurementState = .idle
    @Published var currentBPM: Int = 0
    @Published var signalQuality: Double = 0.0
    @Published var waveformData: [Double] = []
    @Published var isFingerDetected: Bool = false
    @Published var warningMessage: String?
    @Published var measurementDuration: TimeInterval = 0
    @Published var measurementPhase: MeasurementPhase = .warmup
    @Published private(set) var previewSession: AVCaptureSession?
    
    // Heartbeat tick counter
    @Published var heartbeatTick: Int = 0
    
    // HRV Metrics
    @Published var currentHRV: HRVMetrics?
    
    // MARK: - Configuration
    private var actualSampleRate: Double = 30.0
    private let warmupDuration: TimeInterval = 4.0
    private let measurementTimeLimit: TimeInterval = 50.0
    private let hapticInterval: TimeInterval = 1.0
    
    // Time-weighted EMA
    private let emaAlphaMax: Double = 0.5
    private let emaAlphaMin: Double = 0.05
    
    // MARK: - 行业标准：单一 Session，只创建一次
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.heartrate.session", qos: .userInteractive)
    private var videoInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var isSessionConfigured = false
    
    // Signal Processor
    let signalProcessor: SignalProcessor
    
    // Timers & State
    private var updateTimer: Timer?
    private var hapticTimer: Timer?
    private var lastEffectiveDuration: TimeInterval = 0
    private var frameCount: Int = 0
    private var consecutiveGoodFrames: Int = 0
    
    // EMA Smoothing
    private var smoothedBPM: Double = 0
    private var bpmHistory: [Int] = []
    private var wasFingerDetected: Bool = false
    private var isMeasuring: Bool = false
    
    // 🔒 硬状态锁：防止 SwiftUI View 重建导致重复触发
    private var hasEverStarted: Bool = false
    
    // MARK: - Initialization
    override init() {
        self.signalProcessor = SignalProcessor()
        super.init()
        
        self.signalProcessor.onHeartbeatDetected = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let bpm = self.signalProcessor.getCurrentBPM() {
                    self.applyBPM(bpm)
                }
            }
        }
        
        // 设置 previewSession 引用
        self.previewSession = session
    }
    
    // MARK: - EMA Alpha
    private func getCurrentEMAAlpha() -> Double {
        let progress = min(1.0, lastEffectiveDuration / measurementTimeLimit)
        return emaAlphaMax - (emaAlphaMax - emaAlphaMin) * progress
    }
    
    // MARK: - BPM Application
    private func applyBPM(_ bpm: Int) {
        let alpha = getCurrentEMAAlpha()
        if smoothedBPM == 0 {
            smoothedBPM = Double(bpm)
        } else {
            smoothedBPM = alpha * Double(bpm) + (1 - alpha) * smoothedBPM
        }
        currentBPM = Int(round(smoothedBPM))
        bpmHistory.append(currentBPM)
    }
    
    // MARK: - Haptic System
    private func startHapticTimer() {
        stopHapticTimer()
        hapticTimer = Timer.scheduledTimer(withTimeInterval: hapticInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.triggerHaptic()
            }
        }
        triggerHaptic()
    }
    
    private func stopHapticTimer() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
    
    private func triggerHaptic() {
        guard measurementState == .measuring && isFingerDetected else { return }
        HapticManager.shared.playHeartbeatPattern()
        heartbeatTick += 1
    }
    
    // MARK: - ==================== PUBLIC METHODS ====================
    
    func startMeasurement() {
        print("🎬 [START] startMeasurement() - hasEverStarted=\(hasEverStarted), isMeasuring=\(isMeasuring), state=\(measurementState)")
        
        // 🔒 硬状态锁：防止 SwiftUI View 重建导致重复触发
        guard !hasEverStarted else {
            print("🎬 [START] ❌ BLOCKED - already started once (hasEverStarted=true)")
            return
        }
        
        guard !isMeasuring else {
            print("🎬 [START] ⚠️ IGNORED - already measuring")
            return
        }
        
        guard measurementState == .idle || measurementState == .completed else {
            print("🎬 [START] ⚠️ IGNORED - state is \(measurementState)")
            return
        }
        
        // 🔒 设置硬状态锁
        hasEverStarted = true
        print("🎬 [START] ✅ PROCEEDING (hasEverStarted set to true)")
        isMeasuring = true
        measurementState = .preparing
        resetMeasurementData()
        
        // 在 sessionQueue 中执行所有相机操作
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 1. 配置 Session（只配置一次）
            if !self.isSessionConfigured {
                print("📷 [SESSION] 首次配置 Session...")
                self.configureSession()
            }
            
            // 2. 启动 Session
            if !self.session.isRunning {
                print("📷 [SESSION] 启动 Session...")
                self.session.startRunning()
                print("📷 [SESSION] Session running = \(self.session.isRunning)")
            }
            
            // 3. ⚠️ 关键修复：在 sessionQueue 中预先创建 PreviewLayer
            // 这样可以确保 PreviewLayer 在手电筒开启前就已经连接到 session
            // 避免 SwiftUI 延迟渲染导致的时序问题
            DispatchQueue.main.sync {
                _ = PreviewLayerManager.shared.getPreviewLayer(for: self.session)
                print("📹 [PREVIEW] PreviewLayer 预先创建完成")
            }
            
            // 4. 等 session 和 PreviewLayer 稳定（300ms 延迟）
            Thread.sleep(forTimeInterval: 0.3)
            
            // 5. 开启手电筒
            print("🔦 [TORCH] 延迟 300ms 后开启手电筒...")
            self.enableTorch(true)
            
            // 6. 回到主线程开始测量
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.startContinuousMeasurement()
                print("🎬 [START] ✅ COMPLETED")
            }
        }
    }
    
    func stopMeasurement() {
        print("🛑 [STOP] stopMeasurement() called")
        
        guard isMeasuring else {
            print("🛑 [STOP] ⚠️ IGNORED - not measuring")
            return
        }
        
        isMeasuring = false
        
        // 1. 停止定时器
        updateTimer?.invalidate()
        updateTimer = nil
        stopHapticTimer()
        
        // 2. 只关闭手电筒，不停止 Session（行业标准做法）
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 只关手电筒
            self.enableTorch(false)
            
            // ❌ 不要 stopRunning - 保持 session 运行，避免系统重新接管 Camera
            // if self.session.isRunning {
            //     self.session.stopRunning()
            // }
            print("🛑 [STOP] Torch OFF, Session kept running")
        }
        
        // 3. 更新状态
        if currentBPM > 0 {
            measurementState = .completed
            measurementPhase = .completed
        } else {
            measurementState = .idle
        }
        
        // 4. 🔓 重置硬状态锁，允许下次测量
        hasEverStarted = false
        print("🛑 [STOP] ✅ COMPLETED, state=\(measurementState), hasEverStarted reset to false")
    }
    
    func resetToIdle() {
        print("🔄 [RESET] resetToIdle() called")
        stopMeasurement()
        resetMeasurementData()
        measurementState = .idle
        // 🔓 确保重置硬状态锁
        hasEverStarted = false
        print("🔄 [RESET] ✅ COMPLETED, hasEverStarted reset to false")
    }
    
    func getFinalBPM() -> Int {
        let last20Seconds = bpmHistory.suffix(20 * 2)
        if last20Seconds.isEmpty { return currentBPM }
        return last20Seconds.reduce(0, +) / last20Seconds.count
    }
    
    func getFinalHRV() -> HRVMetrics? {
        return signalProcessor.getHRVMetrics()
    }
    
    // MARK: - ==================== SESSION CONFIGURATION (只执行一次) ====================
    
    /// 配置 Session - 只执行一次
    private func configureSession() {
        session.beginConfiguration()
        
        // 使用低分辨率，减少功耗和发热
        session.sessionPreset = .low
        
        // 获取后置摄像头
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("📷 [CONFIG] ❌ No camera available")
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.measurementState = .error("No camera available")
            }
            return
        }
        
        // 配置设备
        do {
            try device.lockForConfiguration()
            
            // 设置帧率
            let maxFrameRate = device.activeFormat.videoSupportedFrameRateRanges.map { $0.maxFrameRate }.max() ?? 30.0
            actualSampleRate = min(60.0, maxFrameRate)
            
            let frameDuration = CMTime(value: 1, timescale: Int32(actualSampleRate))
            device.activeVideoMinFrameDuration = frameDuration
            device.activeVideoMaxFrameDuration = frameDuration
            
            signalProcessor.updateSampleRate(actualSampleRate)
            
            // 锁定曝光
            if device.isExposureModeSupported(.custom) {
                let minISO = device.activeFormat.minISO
                let targetISO = min(minISO * 2, 80.0)
                device.setExposureModeCustom(duration: CMTime(value: 1, timescale: 60), iso: targetISO) { _ in }
            } else if device.isExposureModeSupported(.locked) {
                device.exposureMode = .locked
            }
            
            // 锁定白平衡
            if device.isWhiteBalanceModeSupported(.locked) {
                device.whiteBalanceMode = .locked
            }
            
            // 锁定对焦
            if device.isFocusModeSupported(.locked) {
                device.focusMode = .locked
                if device.isLockingFocusWithCustomLensPositionSupported {
                    device.setFocusModeLocked(lensPosition: 0.0) { _ in }
                }
            }
            
            device.unlockForConfiguration()
            
        } catch {
            print("📷 [CONFIG] ❌ Device configuration failed: \(error)")
        }
        
        // 添加输入
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                self.videoInput = input
                print("📷 [CONFIG] ✅ Input added")
            }
        } catch {
            print("📷 [CONFIG] ❌ Input creation failed: \(error)")
        }
        
        // 添加输出
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: sessionQueue)
        output.alwaysDiscardsLateVideoFrames = true
        
        if session.canAddOutput(output) {
            session.addOutput(output)
            self.videoOutput = output
            print("📷 [CONFIG] ✅ Output added")
        }
        
        session.commitConfiguration()
        isSessionConfigured = true
        print("📷 [CONFIG] ✅ Session configured")
    }
    
    // MARK: - ==================== TORCH CONTROL (行业标准) ====================
    
    /// 开启/关闭手电筒 - 只在 session 稳定后调用
    private func enableTorch(_ on: Bool) {
        guard let device = videoInput?.device, device.hasTorch else {
            print("🔦 [TORCH] ❌ No torch available")
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            if on {
                if device.torchMode != .on {
                    try device.setTorchModeOn(level: 0.8)
                    print("🔦 [TORCH] ✅ ON (level: 0.8)")
                }
            } else {
                device.torchMode = .off
                print("🔦 [TORCH] ✅ OFF")
            }
            
            device.unlockForConfiguration()
        } catch {
            print("🔦 [TORCH] ❌ Error: \(error)")
        }
    }
    
    // MARK: - Measurement Logic
    private func startContinuousMeasurement() {
        measurementState = .measuring
        measurementPhase = .warmup
        lastEffectiveDuration = 0
        
        startHapticTimer()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress()
            }
        }
    }
    
    private func updateProgress() {
        if !isFingerDetected && wasFingerDetected {
            resetProgressOnFingerLift()
        }
        wasFingerDetected = isFingerDetected
        
        if isFingerDetected {
            lastEffectiveDuration += 0.1
            measurementDuration = lastEffectiveDuration
            
            if lastEffectiveDuration < warmupDuration {
                measurementPhase = .warmup
                warningMessage = "Calibrating..."
            } else if lastEffectiveDuration < measurementTimeLimit {
                measurementPhase = .acquisition
                if warningMessage == "Calibrating..." {
                    warningMessage = nil
                }
            } else {
                if currentBPM > 0 {
                    stopMeasurement()
                }
            }
        }
        
        signalQuality = signalProcessor.getSignalQuality()
    }
    
    private func resetProgressOnFingerLift() {
        lastEffectiveDuration = 0
        measurementDuration = 0
        measurementPhase = .warmup
        currentBPM = 0
        smoothedBPM = 0
        bpmHistory.removeAll()
        signalProcessor.reset()
    }
    
    private func resetMeasurementData() {
        currentBPM = 0
        smoothedBPM = 0
        measurementDuration = 0
        lastEffectiveDuration = 0
        signalQuality = 0.0
        waveformData = []
        bpmHistory = []
        isFingerDetected = false
        wasFingerDetected = false
        warningMessage = nil
        frameCount = 0
        consecutiveGoodFrames = 0
        measurementPhase = .warmup
        signalProcessor.reset()
    }
    
    // MARK: - Frame Processing
    private func processPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        frameCount += 1
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
        
        let sampleSize = 60
        let centerX = width / 2
        let centerY = height / 2
        
        var totalR: Double = 0
        var totalG: Double = 0
        var totalB: Double = 0
        var sampleCount = 0
        
        let startY = max(0, centerY - sampleSize/2)
        let endY = min(height, centerY + sampleSize/2)
        let startX = max(0, centerX - sampleSize/2)
        let endX = min(width, centerX + sampleSize/2)
        
        for y in stride(from: startY, to: endY, by: 4) {
            for x in stride(from: startX, to: endX, by: 4) {
                let offset = y * bytesPerRow + x * 4
                let b = Double(buffer[offset])
                let g = Double(buffer[offset + 1])
                let r = Double(buffer[offset + 2])
                
                totalR += r
                totalG += g
                totalB += b
                sampleCount += 1
            }
        }
        
        guard sampleCount > 0 else { return }
        
        let avgR = totalR / Double(sampleCount)
        let avgG = totalG / Double(sampleCount)
        let avgB = totalB / Double(sampleCount)
        
        let isRedDominant = avgR > (avgG + avgB) * 0.8
        let isBrightnessOK = avgR > 30 && avgR < 250
        let hasFinger = isRedDominant && isBrightnessOK
        
        if hasFinger {
            consecutiveGoodFrames += 1
        } else {
            consecutiveGoodFrames = 0
        }
        
        let isStable = consecutiveGoodFrames > 15
        
        let timestamp = Double(frameCount) / actualSampleRate
        let processedValue = signalProcessor.processSample(avgR, at: timestamp, isValid: isStable)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isFingerDetected = isStable
            
            if !isStable {
                if avgR < 30 {
                    self.warningMessage = "Press lightly (Too Dark)"
                } else if avgR >= 250 {
                    self.warningMessage = "Press lightly (Too Bright)"
                } else {
                    self.warningMessage = "Cover camera fully"
                }
            } else if self.measurementPhase != .warmup {
                self.warningMessage = nil
            }
            
            self.waveformData.append(processedValue)
            if self.waveformData.count > 100 {
                self.waveformData.removeFirst()
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension HeartRateManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        Task { @MainActor in
            processPixelBuffer(pixelBuffer)
        }
    }
}
