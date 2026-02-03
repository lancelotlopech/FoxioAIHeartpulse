//
//  DisclaimerView.swift
//  HeartRateSenior
//
//  Scientific references and medical disclaimer
//

import SwiftUI

struct DisclaimerView: View {
    // Reference URLs
    private let pubMedURL = "https://pubmed.ncbi.nlm.nih.gov/17322588/"
    private let wikipediaURL = "https://en.wikipedia.org/wiki/Heart_rate"
    private let ppgWikipediaURL = "https://en.wikipedia.org/wiki/Photoplethysmogram"
    
    var body: some View {
        List {
            // SECTION 1: How PPG Works
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 22))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PPG Technology")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            Text("Photoplethysmography")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("This app uses Photoplethysmography (PPG), a non-invasive optical technique that detects blood volume changes in the microvascular bed of tissue.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("When you place your finger over the camera with the flashlight on, the app detects subtle color changes caused by blood flow with each heartbeat. These changes are analyzed to estimate your heart rate.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            } header: {
                Text("How It Works")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            
            // SECTION 2: Scientific References
            Section {
                // PubMed Reference
                Link(destination: URL(string: pubMedURL)!) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Verkruysse et al. (2008)")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Remote plethysmographic imaging using ambient light")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            Text("PubMed • PMID: 17322588")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                
                // Wikipedia - Heart Rate
                Link(destination: URL(string: wikipediaURL)!) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "book.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Heart Rate")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Overview of heart rate and measurement methods")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text("Wikipedia")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                
                // Wikipedia - PPG
                Link(destination: URL(string: ppgWikipediaURL)!) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "waveform")
                                .font(.system(size: 18))
                                .foregroundColor(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Photoplethysmography")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Technical details of PPG technology")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text("Wikipedia")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.purple)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            } header: {
                Text("Scientific References")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            } footer: {
                Text("Tap to open in Safari")
                    .font(.system(size: 12, design: .rounded))
            }
            
            // SECTION 3: Accuracy Information
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                        
                        Text("About Accuracy")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        AccuracyRow(text: "Results are estimates based on optical sensing")
                        AccuracyRow(text: "Accuracy may vary based on skin tone, movement, and lighting")
                        AccuracyRow(text: "For best results, remain still and ensure good finger coverage")
                        AccuracyRow(text: "This technology is similar to that used in fitness trackers")
                    }
                }
                .padding(.vertical, 8)
            }
            
            // SECTION 4: Medical Disclaimer
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.orange)
                        
                        Text("Medical Disclaimer")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    
                    Text("This app is designed for general wellness and informational purposes only. It is NOT a medical device and should NOT be used to diagnose, treat, cure, or prevent any disease or health condition.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("The heart rate estimates provided by this app are for reference only and may not be accurate. Do not rely on this app for any medical decisions.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Always consult a qualified healthcare professional for medical advice, diagnosis, or treatment. If you experience any symptoms of a medical emergency, call emergency services immediately.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            // SECTION 5: Not Intended For
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    NotIntendedRow(text: "Medical diagnosis or treatment")
                    NotIntendedRow(text: "Detecting heart conditions or arrhythmias")
                    NotIntendedRow(text: "Replacing professional medical equipment")
                    NotIntendedRow(text: "Emergency medical situations")
                }
                .padding(.vertical, 4)
            } header: {
                Text("This App Is Not Intended For")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("About & Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views

private struct AccuracyRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.green)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

private struct NotIntendedRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.red)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        DisclaimerView()
    }
}
