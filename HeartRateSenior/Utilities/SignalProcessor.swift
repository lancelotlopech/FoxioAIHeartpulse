//
//  SignalProcessor.swift
//  HeartRateSenior
//
//  Robust PPG Signal Processing V4.0
//  Features: HRV Analysis, Improved Stability, Larger Windows
//

import Foundation

// MARK: - HRV Quality Level
enum HRVQuality: String {
    case insufficient = "Insufficient Data"
    case estimated = "Estimated"
    case reliable = "Reliable"
}

// MARK: - HRV Metrics Structure
struct HRVMetrics {
    let sdnn: Double      // Standard deviation of NN intervals (ms)
    let rmssd: Double     // Root mean square of successive differences (ms)
    let pnn50: Double     // Percentage of successive differences > 50ms
    let meanRR: Double    // Mean R-R interval (ms)
    let minRR: Double     // Minimum R-R interval (ms)
    let maxRR: Double     // Maximum R-R interval (ms)
    let sd1: Double       // Poincaré plot SD1 - short-term variability (ms)
    let sd2: Double       // Poincaré plot SD2 - long-term variability (ms)
    let quality: HRVQuality // Data quality indicator
    let sampleCount: Int  // Number of R-R intervals used
    
    // HRV Status based on RMSSD
    var status: HRVStatus {
        // Clamp RMSSD to reasonable range (10-150 ms)
        let clampedRMSSD = min(max(rmssd, 10), 150)
        switch clampedRMSSD {
        case ..<25:
            return .low
        case 25..<60:
            return .normal
        default:
            return .high
        }
    }
    
    // Stress level estimation (inverse of HRV)
    var stressLevel: StressLevel {
        let clampedRMSSD = min(max(rmssd, 10), 150)
        switch clampedRMSSD {
        case ..<20:
            return .high
        case 20..<35:
            return .moderate
        case 35..<60:
            return .low
        default:
            return .veryLow
        }
    }
}

enum HRVStatus: String {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    
    var color: String {
        switch self {
        case .low: return "orange"
        case .normal: return "green"
        case .high: return "blue"
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Consider resting"
        case .normal: return "Good recovery"
        case .high: return "Excellent recovery"
        }
    }
}

enum StressLevel: String {
    case veryLow = "Very Low"
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

class SignalProcessor {
    
    // MARK: - Configuration
    private var sampleRate: Double = 30.0  // Dynamic, set by HeartRateManager
    
    // MARK: - Bandpass Filter (Simple IIR - 2nd Order Butterworth approximation)
    // Passband: 0.7Hz - 3.5Hz (42-210 BPM)
    // Coefficients are recalculated based on sample rate
    private var lowPassState: [Double] = [0, 0]
    private var highPassState: [Double] = [0, 0]
    
    // Filter coefficients (default for 30Hz)
    private var lpA: [Double] = [1.0, -1.5610, 0.6414]
    private var lpB: [Double] = [0.0201, 0.0402, 0.0201]
    private var hpA: [Double] = [1.0, -1.9112, 0.9150]
    private var hpB: [Double] = [0.9565, -1.9131, 0.9565]
    
    // MARK: - Multi-Frame Averaging (noise reduction)
    private var frameAverageBuffer: [Double] = []
    private var frameAverageCount = 2  // Dynamic based on sample rate
    
    // MARK: - Baseline (for detrending)
    private var rawBuffer: [Double] = []
    private var baselineWindowSize = 45 // Dynamic: 1.5 seconds
    
    // MARK: - Adaptive Threshold (INCREASED WINDOW)
    private var filteredBuffer: [Double] = []
    private var thresholdWindowSize = 90 // Dynamic: 3 seconds
    private let thresholdMultiplier: Double = 0.35
    
    // MARK: - Peak Detection State
    private var lastPeakTime: Double = 0
    private var currentRefractoryPeriod: Double = 0.35 // Adaptive, starts at 350ms
    private var localMax: Double = -Double.infinity
    private var localMaxTime: Double = 0
    private var isRising: Bool = false
    private var lastValue: Double = 0
    
    // MARK: - R-R Intervals & BPM (INCREASED HISTORY for HRV)
    private var rrIntervals: [Double] = []
    private let maxRRHistory = 50 // Increased for better HRV calculation
    
    // MARK: - Callbacks
    public var onHeartbeatDetected: (() -> Void)?
    
    // MARK: - Initialization
    init() {
        updateSampleRate(30.0)  // Default to 30fps
    }
    
    // MARK: - Dynamic Sample Rate Update
    func updateSampleRate(_ newRate: Double) {
        sampleRate = newRate
        
        // Update window sizes based on sample rate
        baselineWindowSize = Int(newRate * 1.5)   // 1.5 seconds
        thresholdWindowSize = Int(newRate * 3.0)  // 3 seconds
        frameAverageCount = newRate >= 60 ? 3 : 2  // More averaging at higher fps
        
        // Update filter coefficients based on sample rate
        if newRate >= 55 {
            // 60Hz coefficients
            lpA = [1.0, -1.7786, 0.8008]
            lpB = [0.0056, 0.0111, 0.0056]
            hpA = [1.0, -1.9556, 0.9565]
            hpB = [0.9780, -1.9560, 0.9780]
        } else {
            // 30Hz coefficients
            lpA = [1.0, -1.5610, 0.6414]
            lpB = [0.0201, 0.0402, 0.0201]
            hpA = [1.0, -1.9112, 0.9150]
            hpB = [0.9565, -1.9131, 0.9565]
        }
        
        // Reset buffers when sample rate changes
        reset()
    }
    
    // MARK: - Main Processing Function
    /// Process a raw sample and return the filtered waveform value
    func processSample(_ rawValue: Double, at time: Double, isValid: Bool = true) -> Double {
        // 1. Multi-frame averaging for noise reduction
        frameAverageBuffer.append(rawValue)
        if frameAverageBuffer.count > frameAverageCount {
            frameAverageBuffer.removeFirst()
        }
        let averagedValue = frameAverageBuffer.reduce(0, +) / Double(frameAverageBuffer.count)
        
        // 2. Invert (blood absorbs light, so more blood = less light)
        let inverted = -averagedValue
        
        // 3. Detrend (remove baseline using moving average)
        rawBuffer.append(inverted)
        if rawBuffer.count > baselineWindowSize {
            rawBuffer.removeFirst()
        }
        let baseline = rawBuffer.reduce(0, +) / Double(rawBuffer.count)
        let detrended = inverted - baseline
        
        // 4. Bandpass Filter
        let filtered = applyBandpassFilter(detrended)
        
        // 5. Store for adaptive threshold calculation
        filteredBuffer.append(filtered)
        if filteredBuffer.count > thresholdWindowSize {
            filteredBuffer.removeFirst()
        }
        
        // 6. Peak Detection (only if valid finger contact)
        if isValid && filteredBuffer.count >= thresholdWindowSize / 2 {
            detectPeak(value: filtered, time: time)
        }
        
        return filtered
    }
    
    // MARK: - Bandpass Filter Implementation
    private func applyBandpassFilter(_ input: Double) -> Double {
        // Low-pass filter
        let lpOutput = lpB[0] * input + lpB[1] * lowPassState[0] + lpB[2] * lowPassState[1]
                     - lpA[1] * lowPassState[0] - lpA[2] * lowPassState[1]
        lowPassState[1] = lowPassState[0]
        lowPassState[0] = lpOutput
        
        // High-pass filter
        let hpOutput = hpB[0] * lpOutput + hpB[1] * highPassState[0] + hpB[2] * highPassState[1]
                     - hpA[1] * highPassState[0] - hpA[2] * highPassState[1]
        highPassState[1] = highPassState[0]
        highPassState[0] = hpOutput
        
        return hpOutput
    }
    
    // MARK: - Adaptive Threshold Peak Detection
    private func detectPeak(value: Double, time: Double) {
        // Calculate adaptive threshold based on signal standard deviation
        let mean = filteredBuffer.reduce(0, +) / Double(filteredBuffer.count)
        let variance = filteredBuffer.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(filteredBuffer.count)
        let stdDev = sqrt(variance)
        let threshold = stdDev * thresholdMultiplier
        
        // Detect rising edge
        if value > lastValue {
            isRising = true
            if value > localMax {
                localMax = value
                localMaxTime = time
            }
        } else if isRising && value < lastValue {
            // We just passed a peak
            isRising = false
            
            // Validate peak with adaptive refractory period
            let timeSinceLastPeak = time - lastPeakTime
            if localMax > threshold && timeSinceLastPeak > currentRefractoryPeriod {
                // Valid peak detected!
                triggerBeat(at: localMaxTime)
            }
            
            // Reset for next peak
            localMax = -Double.infinity
        }
        
        lastValue = value
    }
    
    // MARK: - Beat Trigger
    private func triggerBeat(at time: Double) {
        let interval = time - lastPeakTime
        lastPeakTime = time
        
        // Sanity check: 0.27s (220 BPM) to 1.7s (35 BPM) - extended range for seniors
        if interval > 0.27 && interval < 1.7 {
            rrIntervals.append(interval)
            
            // Update adaptive refractory period based on current heart rate
            // Refractory = 50% of average R-R interval, clamped to [0.25, 0.5]s
            if rrIntervals.count >= 3 {
                let recentRR = rrIntervals.suffix(5)
                let avgRR = recentRR.reduce(0, +) / Double(recentRR.count)
                currentRefractoryPeriod = min(0.5, max(0.25, avgRR * 0.5))
            }
            if rrIntervals.count > maxRRHistory {
                rrIntervals.removeFirst()
            }
            
            // Notify callback
            DispatchQueue.main.async {
                self.onHeartbeatDetected?()
            }
        }
    }
    
    // MARK: - BPM Calculation (Median Filter)
    func getCurrentBPM() -> Int? {
        guard rrIntervals.count >= 3 else { return nil }
        
        // Use median for robustness against outliers
        let sorted = rrIntervals.sorted()
        let median: Double
        let count = sorted.count
        if count % 2 == 0 {
            median = (sorted[count/2 - 1] + sorted[count/2]) / 2.0
        } else {
            median = sorted[count/2]
        }
        
        let bpm = 60.0 / median
        
        // Final sanity check: 35-220 BPM range for seniors
        if bpm >= 35 && bpm <= 220 {
            return Int(round(bpm))
        }
        return nil
    }
    
    // MARK: - Signal Quality (based on R-R interval consistency)
    func getSignalQuality() -> Double {
        guard rrIntervals.count >= 3 else { return 0.0 }
        
        let mean = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let variance = rrIntervals.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(rrIntervals.count)
        let cv = sqrt(variance) / mean // Coefficient of Variation
        
        // Lower CV = more consistent = higher quality
        // CV < 0.1 is excellent, CV > 0.3 is poor
        let quality = max(0, min(1, 1.0 - (cv / 0.3)))
        return quality
    }
    
    // MARK: - HRV Calculation
    
    /// Get all R-R intervals in milliseconds
    func getRRIntervalsMs() -> [Double] {
        return rrIntervals.map { $0 * 1000.0 }
    }
    
    /// Filter outliers from R-R intervals using IQR method
    private func filterOutliers(_ data: [Double]) -> [Double] {
        guard data.count >= 4 else { return data }
        
        let sorted = data.sorted()
        let q1Index = sorted.count / 4
        let q3Index = (sorted.count * 3) / 4
        
        let q1 = sorted[q1Index]
        let q3 = sorted[q3Index]
        let iqr = q3 - q1
        
        // Use 1.5 * IQR rule for outlier detection
        let lowerBound = q1 - 1.5 * iqr
        let upperBound = q3 + 1.5 * iqr
        
        return data.filter { $0 >= lowerBound && $0 <= upperBound }
    }
    
    /// Calculate HRV metrics from R-R intervals with quality assessment
    func getHRVMetrics() -> HRVMetrics? {
        let rrMs = getRRIntervalsMs()
        
        // Need at least 5 intervals for any HRV calculation
        guard rrMs.count >= 5 else { return nil }
        
        // Filter outliers for more stable HRV
        let filteredRR = filterOutliers(rrMs)
        
        // Need at least 5 valid intervals after filtering
        guard filteredRR.count >= 5 else { return nil }
        
        // Determine quality based on sample count
        let quality: HRVQuality
        if filteredRR.count >= 30 {
            quality = .reliable
        } else if filteredRR.count >= 15 {
            quality = .estimated
        } else {
            quality = .insufficient
        }
        
        // Mean R-R interval
        let meanRR = filteredRR.reduce(0, +) / Double(filteredRR.count)
        
        // Min and Max R-R
        let minRR = filteredRR.min() ?? 0
        let maxRR = filteredRR.max() ?? 0
        
        // SDNN: Standard deviation of NN intervals
        let variance = filteredRR.reduce(0) { $0 + ($1 - meanRR) * ($1 - meanRR) } / Double(filteredRR.count)
        let sdnn = sqrt(variance)
        
        // RMSSD: Root mean square of successive differences
        var sumSquaredDiff: Double = 0
        var diffCount = 0
        var nn50Count = 0
        
        for i in 1..<filteredRR.count {
            let diff = abs(filteredRR[i] - filteredRR[i-1])
            sumSquaredDiff += diff * diff
            diffCount += 1
            
            // Count differences > 50ms for pNN50
            if diff > 50 {
                nn50Count += 1
            }
        }
        
        var rmssd = diffCount > 0 ? sqrt(sumSquaredDiff / Double(diffCount)) : 0
        
        // Clamp RMSSD to reasonable physiological range (10-150 ms)
        rmssd = min(max(rmssd, 10), 150)
        
        // pNN50: Percentage of successive differences > 50ms
        let pnn50 = diffCount > 0 ? (Double(nn50Count) / Double(diffCount)) * 100.0 : 0
        
        // Poincaré plot indices
        // SD1 = sqrt(0.5 * RMSSD²) - represents short-term variability (parasympathetic)
        let sd1 = sqrt(0.5) * rmssd
        
        // SD2 = sqrt(2 * SDNN² - 0.5 * RMSSD²) - represents long-term variability (combined)
        let sd2Squared = 2.0 * sdnn * sdnn - 0.5 * rmssd * rmssd
        let sd2 = sqrt(max(0, sd2Squared)) // Ensure non-negative
        
        return HRVMetrics(
            sdnn: sdnn,
            rmssd: rmssd,
            pnn50: pnn50,
            meanRR: meanRR,
            minRR: minRR,
            maxRR: maxRR,
            sd1: sd1,
            sd2: sd2,
            quality: quality,
            sampleCount: filteredRR.count
        )
    }
    
    // MARK: - Reset
    func reset() {
        rawBuffer.removeAll()
        filteredBuffer.removeAll()
        frameAverageBuffer.removeAll()
        rrIntervals.removeAll()
        lowPassState = [0, 0]
        highPassState = [0, 0]
        lastPeakTime = 0
        currentRefractoryPeriod = 0.35
        localMax = -Double.infinity
        isRising = false
        lastValue = 0
    }
}
