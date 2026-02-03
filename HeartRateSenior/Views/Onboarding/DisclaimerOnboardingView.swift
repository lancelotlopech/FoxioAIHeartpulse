//
//  DisclaimerOnboardingView.swift
//  HeartRateSenior
//
//  Disclaimer page for onboarding flow
//

import SwiftUI

struct DisclaimerOnboardingView: View {
    @Binding var currentPage: Int
    
    // Reference URLs
    private let pubMedURL = "https://pubmed.ncbi.nlm.nih.gov/17322588/"
    private let wikipediaURL = "https://en.wikipedia.org/wiki/Heart_rate"
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 44))
                    .foregroundColor(.orange)
            }
            .padding(.bottom, 24)
            
            // Title
            Text("Important Information")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .padding(.bottom, 8)
            
            Text("Please read before using")
                .font(.system(size: 17, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .padding(.bottom, 32)
            
            // Content Card
            VStack(alignment: .leading, spacing: 20) {
                // PPG Technology
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                        .frame(width: 28)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PPG Technology")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("This app uses camera-based optical sensing to estimate your heart rate.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Divider()
                
                // Estimates Only
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.purple)
                        .frame(width: 28)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Estimates Only")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Results are estimates for wellness purposes and may vary based on conditions.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Divider()
                
                // Not Medical Device
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                        .frame(width: 28)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Not a Medical Device")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("This app is not intended for medical diagnosis. Consult a healthcare professional for medical advice.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
            .padding(.horizontal, 24)
            
            // Scientific References
            VStack(spacing: 12) {
                Text("Scientific References")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                HStack(spacing: 16) {
                    // PubMed Link
                    Link(destination: URL(string: pubMedURL)!) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 14))
                            Text("PubMed")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.green)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.1))
                        )
                    }
                    
                    // Wikipedia Link
                    Link(destination: URL(string: wikipediaURL)!) {
                        HStack(spacing: 6) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 14))
                            Text("Wikipedia")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
            }
            .padding(.top, 24)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                HapticManager.shared.mediumImpact()
                withAnimation {
                    currentPage = 3
                }
            }) {
                HStack(spacing: 8) {
                    Text("I Understand")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

#Preview {
    DisclaimerOnboardingView(currentPage: .constant(2))
}
