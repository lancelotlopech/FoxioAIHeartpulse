//
//  HeartRateManager.swift
//  HeartRateSenior
//
//  Professional PPG Heart Rate Manager V4.0
//  Features: Realistic Heartbeat Haptics, Time-Weighted EMA, Stable Torch
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

// MARK: - Heart Rate Manager
@MainActor
class HeartRateManager: NSObject, ObservableObject {
    
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
    
    // Heartbeat tick counter - increments on each haptic trigger for UI sync
    @Published var heartbeatTick: Int = 0
    
    // HRV Metrics
    @Published var currentHRV: HRVMetrics?
    
    // MARK: - Configuration
    private let torchLevel: Float = 0.8
    private var actualSampleRate: Double = 30.0  // Will be set based on device capability
    private let warmupDuration: TimeInterval = 4.0
    private let measurementTimeLimit: TimeInterval = 50.0
    
    // Fixed heartbeat rhythm: 1 second interval (60 BPM feel)
    private let hapticInterval: TimeInterval = 1.0
    
    // Time-weighted EMA: starts responsive, becomes stable over time
    private let emaAlphaMax: Double = 0.5   // Initial: responsive
    private let emaAlphaMin: Double = 0.05  // Final: very stable
    
    // MARK: - Private Properties
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var captureDevice: AVCaptureDevice?
    
    // Signal Processor
    let signalProcessor: SignalProcessor
    
    // Timers & State
    private var updateTimer: Timer?
    private var hapticTimer: Timer?
    private var lastEffectiveDuration: TimeInterval = 0
    private var lastTorchCheckTime: Date = Date()
    private var frameCount: Int = 0
    private var consecutiveGoodFrames: Int = 0
    private let processingQueue = DispatchQueue(label: "com.heartrate.processing", qos: .userInteractive)
    
    // EMA Smoothing
    private var smoothedBPM: Double = 0
    
    // Final BPM calculation
    private var bpmHistory: [Int] = []
    
    // KVO
    private var torchObservation: NSKeyValueObservation?
    
    // Track if finger was previously detected (for reset logic)
    private var wasFingerDetected: Bool = false
    
    // Track if torch has been turned on for this session
    private var isTorchOnForSession: Bool = false
    
    // MARK: - Initialization
    override init() {
        self.signalProcessor = SignalProcessor()
        super.init()
        
        // Connect BPM callback
        self.signalProcessor.onHeartbeatDetected = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Update BPM when detected
                if let bpm = self.signalProcessor.getCurrentBPM() {
                    self.applyBPM(bpm)
                }
            }
        }
    }
    
    deinit {
        torchObservation?.invalidate()
    }
    
    // MARK: - Time-Weighted EMA Alpha
    
    /// Calculate EMA alpha based on elapsed time
    /// Starts at 0.5 (responsive), decreases to 0.05 (stable) over 60 seconds
    private func getCurrentEMAAlpha() -> Double {
        let progress = min(1.0, lastEffectiveDuration / measurementTimeLimit)
        return emaAlphaMax - (emaAlphaMax - emaAlphaMin) * progress
    }
    
    // MARK: - BPM Application with Time-Weighted EMA
    
    private func applyBPM(_ bpm: Int) {
        let alpha = getCurrentEMAAlpha()
        
        if smoothedBPM == 0 {
            smoothedBPM = Double(bpm)
        } else {
            smoothedBPM = alpha * Double(bpm) + (1 - alpha) * smoothedBPM
        }
        currentBPM = Int(round(smoothedBPM))
        
        // Store for final calculation
        bpmHistory.append(currentBPM)
    }
    
    // MARK: - Fixed-Rhythm Haptic System (Realistic Heartbeat)
    
    private func startHapticTimer() {
        stopHapticTimer()
        
        // Fixed 1-second interval for consistent heartbeat feel
        hapticTimer = Timer.scheduledTimer(withTimeInterval: hapticInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.triggerHaptic()
            }
        }
        
        // Trigger first haptic immediately
        triggerHaptic()
    }
    
    private func stopHapticTimer() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
    
    private func triggerHaptic() {
        // Only trigger if finger is detected and measuring
        guard measurementState == .measuring && isFingerDetected else { return }
        
        // Use realistic "lub-dub" heartbeat pattern
        HapticManager.shared.playHeartbeatPattern()
        
        // Increment tick for UI animation sync
        heartbeatTick += 1
    }
    
    // MARK: - Public Methods
    
    func startMeasurement() {
        resetMeasurement()
        Task {
            await requestCameraPermission()
        }
    }
    
    func stopMeasurement() {
        stopCapture()
        stopHapticTimer()
        
        if currentBPM > 0 {
            measurementState = .completed
            measurementPhase = .completed
        } else {
            measurementState = .idle
        }
    }
    
    /// Reset to idle state after viewing results
    func resetToIdle() {
        stopCapture()
        stopHapticTimer()
        resetMeasurement()
        measurementState = .idle
    }
    
    func getFinalBPM() -> Int {
        // Use last 20 seconds of data for final calculation
        let last20Seconds = bpmHistory.suffix(20 * 2)
        if last20Seconds.isEmpty {
            return currentBPM
        }
        let sum = last20Seconds.reduce(0, +)
        return sum / last20Seconds.count
    }
    
    /// Get final HRV metrics from the measurement
    func getFinalHRV() -> HRVMetrics? {
        return signalProcessor.getHRVMetrics()
    }
    
    // MARK: - Camera Permission
    
    private func requestCameraPermission() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            await setupCaptureSession()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                await setupCaptureSession()
            } else {
                measurementState = .error("Camera access denied")
            }
        case .denied, .restricted:
            measurementState = .error("Camera access denied. Please enable in Settings.")
        @unknown default:
            measurementState = .error("Unknown camera authorization status")
        }
    }
    
    // MARK: - Capture Session Setup
    
    private func setupCaptureSession() async {
        measurementState = .preparing
        
        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            measurementState = .error("No camera available")
            return
        }
        
        self.captureDevice = device
        
        do {
            try device.lockForConfiguration()
            
            // Frame Rate - detect device capability
            let maxSupportedFrameRate = device.activeFormat.videoSupportedFrameRateRanges
                .map { $0.maxFrameRate }
                .max() ?? 30.0
            actualSampleRate = min(60.0, maxSupportedFrameRate)  // Use up to 60fps if supported
            
            let targetFrameDuration = CMTime(value: 1, timescale: Int32(actualSampleRate))
            device.activeVideoMinFrameDuration = targetFrameDuration
            device.activeVideoMaxFrameDuration = targetFrameDuration
            
            // Update signal processor with actual sample rate
            signalProcessor.updateSampleRate(actualSampleRate)
            
            // Manual Exposure
            if device.isExposureModeSupported(.custom) {
                let minISO = device.activeFormat.minISO
                let targetISO = min(minISO * 2, 80.0)
                let targetDuration = CMTime(value: 1, timescale: 60)
                device.setExposureModeCustom(duration: targetDuration, iso: targetISO) { _ in }
            } else if device.isExposureModeSupported(.locked) {
                device.exposureMode = .locked
            }
            
            // Locked White Balance
            if device.isWhiteBalanceModeSupported(.locked) {
                device.whiteBalanceMode = .locked
            }
            
            // Fixed Focus
            if device.isFocusModeSupported(.locked) {
                device.focusMode = .locked
                if device.isLockingFocusWithCustomLensPositionSupported {
                    device.setFocusModeLocked(lensPosition: 0.0) { _ in }
                }
            }
            
            // NOTE: Torch will be turned on when finger is detected (not here)
            // to avoid flash before user places finger
            
            device.unlockForConfiguration()
            
            // Input
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            // Output
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            output.setSampleBufferDelegate(self, queue: processingQueue)
            output.alwaysDiscardsLateVideoFrames = true
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            self.captureSession = session
            self.videoOutput = output
            self.previewSession = session
            
            setupTorchObservation(for: device)
            
            processingQueue.async { [weak self] in
                session.startRunning()
                
                DispatchQueue.main.async {
                    self?.startContinuousMeasurement()
                }
            }
            
        } catch {
            measurementState = .error("Failed to setup camera: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Torch Control
    
    private func setupTorchObservation(for device: AVCaptureDevice) {
        torchObservation = device.observe(\.isTorchActive, options: [.new]) { [weak self] device, _ in
            guard let self = self, self.measurementState == .measuring else { return }
            
            if !device.isTorchActive {
                DispatchQueue.main.async {
                    self.setTorch(on: true)
                }
            }
        }
    }
    
    private func setTorch(on: Bool) {
        guard let device = captureDevice, device.hasTorch && device.isTorchAvailable else { return }
        
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: torchLevel)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch control failed: \(error)")
        }
    }
    
    // MARK: - Measurement Logic
    
    private func startContinuousMeasurement() {
        measurementState = .measuring
        measurementPhase = .warmup
        lastEffectiveDuration = 0
        lastTorchCheckTime = Date()
        
        // Start fixed-rhythm haptic timer
        startHapticTimer()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress()
            }
        }
    }
    
    private func updateProgress() {
        // Check for finger lift → reset progress
        if !isFingerDetected && wasFingerDetected {
            resetProgressOnFingerLift()
        }
        wasFingerDetected = isFingerDetected
        
        if isFingerDetected {
            lastEffectiveDuration += 0.1
            measurementDuration = lastEffectiveDuration
            
            // Phase transitions
            if lastEffectiveDuration < warmupDuration {
                measurementPhase = .warmup
                warningMessage = "Calibrating..."
            } else if lastEffectiveDuration < measurementTimeLimit {
                measurementPhase = .acquisition
                if warningMessage == "Calibrating..." {
                    warningMessage = nil
                }
            } else {
                // Auto-complete at 60 seconds
                if currentBPM > 0 {
                    stopMeasurement()
                }
            }
        }
        
        signalQuality = signalProcessor.getSignalQuality()
    }
    
    // MARK: - Reset on Finger Lift
    
    private func resetProgressOnFingerLift() {
        lastEffectiveDuration = 0
        measurementDuration = 0
        measurementPhase = .warmup
        currentBPM = 0
        smoothedBPM = 0
        bpmHistory.removeAll()
        signalProcessor.reset()
    }
    
    // MARK: - Cleanup
    
    private func stopCapture() {
        updateTimer?.invalidate()
        updateTimer = nil
        
        torchObservation?.invalidate()
        torchObservation = nil
        
        processingQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            
            if let device = self?.captureDevice, device.hasTorch {
                try? device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
            }
        }
        
        captureSession = nil
        videoOutput = nil
        previewSession = nil
        captureDevice = nil
    }
    
    private func resetMeasurement() {
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
        isTorchOnForSession = false
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
        
        // Sample center region
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
        
        // Torch watchdog
        if avgR < 20 && measurementState == .measuring {
            let now = Date()
            if now.timeIntervalSince(lastTorchCheckTime) > 1.0 {
                DispatchQueue.main.async { [weak self] in
                    self?.setTorch(on: true)
                }
                lastTorchCheckTime = now
            }
        }
        
        // Finger detection
        let isRedDominant = avgR > (avgG + avgB) * 0.8
        let isBrightnessOK = avgR > 30 && avgR < 250
        let hasFinger = isRedDominant && isBrightnessOK
        
        if hasFinger {
            consecutiveGoodFrames += 1
        } else {
            consecutiveGoodFrames = 0
        }
        
        let isStable = consecutiveGoodFrames > 15
        
        // Turn on torch when finger is first detected (not before)
        if isStable && !isTorchOnForSession {
            isTorchOnForSession = true
            DispatchQueue.main.async { [weak self] in
                self?.setTorch(on: true)
            }
        }
        
        // Process signal
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
            
            // Update waveform
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
