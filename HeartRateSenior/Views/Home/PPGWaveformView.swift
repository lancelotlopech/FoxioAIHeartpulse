//
//  ECGAnimationView.swift
//  HeartRateSenior
//
//  Simulated ECG (Electrocardiogram) visualization
//  Features:
//  - Scroll mode animation
//  - Medical grid background
//  - Dynamic QRS amplitude and baseline wander
//  - Synchronized with haptic feedback
//

import SwiftUI

struct ECGAnimationView: View {
    let heartbeatTick: Int
    
    // Data buffer
    @State private var data: [Double] = Array(repeating: 0, count: 300)
    @State private var timer: Timer?
    @State private var qrsIndex = -1
    
    // Animation state
    @State private var phase: Double = 0
    @State private var baselinePhase: Double = 0
    
    // Dynamic parameters for current beat
    @State private var currentAmplitude: Double = 1.0
    @State private var currentTWaveAmp: Double = 0.15
    
    // Standard ECG P-QRS-T wave template (normalized duration)
    private let qrsTemplate: [Double] = [
        0.05, 0.1, 0.05, 0, // P wave
        0, 0, -0.15, 1.0, -0.35, 0, // QRS complex (Sharp spike)
        0, 0, 0, 0.1, 0.2, 0.25, 0.2, 0.1, 0 // T wave (Slower rise/fall)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Medical Grid Background
                MedicalGridBackground()
                
                // 2. ECG Line
                // We use a mask to fade in the line from the "write head" position (approx 2/3 screen width)
                ZStack {
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let midHeight = height / 2
                        // Display 200 points across the screen width
                        let step = width / 200.0
                        
                        // Start drawing
                        if data.count >= 200 {
                            // Take the last 200 points
                            let visibleData = Array(data.suffix(200))
                            
                            path.move(to: CGPoint(x: 0, y: midHeight - CGFloat(visibleData[0]) * height * 0.35))
                            
                            for i in 1..<visibleData.count {
                                let x = CGFloat(i) * step
                                let y = midHeight - CGFloat(visibleData[i]) * height * 0.35
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(AppColors.primaryRed, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    .shadow(color: AppColors.primaryRed.opacity(0.4), radius: 2)
                }
                .mask(
                    HStack(spacing: 0) {
                        // Fade in mask on the right side to simulate "appearing"
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .black, location: 0.8), // Fully visible up to 80%
                                    .init(color: .clear, location: 1.0)  // Fade out at right edge
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    }
                )
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
        .onChange(of: heartbeatTick) { _ in
            triggerBeat()
        }
    }
    
    private func triggerBeat() {
        qrsIndex = 0
        // Randomize amplitude slightly for natural feel
        currentAmplitude = Double.random(in: 0.9...1.1)
        currentTWaveAmp = Double.random(in: 0.12...0.18)
    }
    
    private func startAnimation() {
        stopAnimation()
        // 60fps update loop
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateWaveform()
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateWaveform() {
        var newValue: Double = 0
        
        // 1. Baseline Wander (Respiratory Sinus Arrhythmia simulation)
        // Slow sine wave
        baselinePhase += 0.02
        let baselineWander = sin(baselinePhase) * 0.05
        newValue += baselineWander
        
        // 2. High frequency noise (Muscle noise / sensor noise)
        let noise = Double.random(in: -0.01...0.01)
        newValue += noise
        
        // 3. QRS Complex injection
        if qrsIndex >= 0 && qrsIndex < qrsTemplate.count {
            // Apply scale factors
            let rawValue = qrsTemplate[qrsIndex]
            
            if qrsIndex > 10 { // T-wave part
                 newValue += rawValue * (currentTWaveAmp / 0.2) // Scale T-wave
            } else { // QRS part
                 newValue += rawValue * currentAmplitude
            }
            
            qrsIndex += 1
        } else {
            qrsIndex = -1
        }
        
        // 4. Shift buffer
        data.append(newValue)
        if data.count > 300 {
            data.removeFirst()
        }
    }
}

// Medical Paper Grid Style
struct MedicalGridBackground: View {
    var body: some View {
        Canvas { context, size in
            // Small grid (1mm equivalent)
            let smallSpacing: CGFloat = 10
            // Large grid (5mm equivalent)
            let largeSpacing: CGFloat = 50
            
            // Draw small grid
            var smallPath = Path()
            for x in stride(from: 0, to: size.width, by: smallSpacing) {
                smallPath.move(to: CGPoint(x: x, y: 0))
                smallPath.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, to: size.height, by: smallSpacing) {
                smallPath.move(to: CGPoint(x: 0, y: y))
                smallPath.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(smallPath, with: .color(AppColors.primaryRed.opacity(0.05)), lineWidth: 0.5)
            
            // Draw large grid
            var largePath = Path()
            for x in stride(from: 0, to: size.width, by: largeSpacing) {
                largePath.move(to: CGPoint(x: x, y: 0))
                largePath.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, to: size.height, by: largeSpacing) {
                largePath.move(to: CGPoint(x: 0, y: y))
                largePath.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(largePath, with: .color(AppColors.primaryRed.opacity(0.15)), lineWidth: 1.0)
        }
        .background(Color.white) // Clean white background
    }
}

#Preview {
    ECGAnimationView(heartbeatTick: 0)
        .frame(height: 150)
}
