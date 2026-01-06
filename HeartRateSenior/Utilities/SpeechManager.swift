//
//  SpeechManager.swift
//  HeartRateSenior
//
//  Voice synthesis for reading health results aloud (senior-friendly)
//

import Foundation
import AVFoundation

class SpeechManager: NSObject, ObservableObject {
    
    static let shared = SpeechManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Heart Rate Result
    
    /// Speak the heart rate measurement result
    func speakHeartRateResult(bpm: Int) {
        let status = getHeartRateStatus(bpm: bpm)
        let message = "Your heart rate is \(bpm) beats per minute. \(status)"
        speak(message)
    }
    
    /// Speak with HRV info
    func speakHeartRateResultWithHRV(bpm: Int, hrvRMSSD: Double?) {
        let status = getHeartRateStatus(bpm: bpm)
        var message = "Your heart rate is \(bpm) beats per minute. \(status)"
        
        if let hrv = hrvRMSSD {
            let hrvStatus = getHRVStatus(rmssd: hrv)
            message += " Your heart rate variability is \(hrvStatus)."
        }
        
        speak(message)
    }
    
    // MARK: - Blood Pressure Result
    
    func speakBloodPressureResult(systolic: Int, diastolic: Int, category: String) {
        let message = "Your blood pressure is \(systolic) over \(diastolic). This is \(category)."
        speak(message)
    }
    
    // MARK: - Blood Glucose Result
    
    func speakBloodGlucoseResult(value: Int, category: String) {
        let message = "Your blood glucose is \(value) milligrams per deciliter. This is \(category)."
        speak(message)
    }
    
    // MARK: - Generic Speak
    
    func speak(_ text: String) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Senior-friendly: Slower rate, clearer voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85 // Slightly slower
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Use high-quality enhanced voice if available
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        // Add slight pauses for clarity
        utterance.preUtteranceDelay = 0.3
        utterance.postUtteranceDelay = 0.2
        
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
    
    // MARK: - Helper Methods
    
    private func getHeartRateStatus(bpm: Int) -> String {
        if bpm >= 60 && bpm <= 100 {
            return "This is normal."
        } else if bpm > 100 {
            return "This is elevated. Consider resting and measuring again."
        } else if bpm < 60 {
            if bpm >= 50 {
                return "This is on the lower side but may be normal for athletes."
            } else {
                return "This is low. Please consult your doctor if you feel unwell."
            }
        }
        return ""
    }
    
    private func getHRVStatus(rmssd: Double) -> String {
        if rmssd >= 40 {
            return "excellent"
        } else if rmssd >= 25 {
            return "good"
        } else if rmssd >= 15 {
            return "moderate"
        } else {
            return "low"
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechManager: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}
