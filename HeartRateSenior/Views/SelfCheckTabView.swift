//
//  SelfCheckTabView.swift
//  HeartRateSenior
//
//  Check tab - HIV Awareness & Pregnancy self-check entries
//

import SwiftUI

struct SelfCheckTabView: View {
    @State private var showingHIVCenter = false
    @State private var showingPregnancyCenter = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 6) {
                        Text("Self Check")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Health awareness & self-assessment tools")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 16)
                    
                    // HIV Awareness Card
                    SelfCheckEntryCard(
                        imageName: "HIV",
                        title: "HIV Awareness",
                        subtitle: "Prevention, testing & early care steps",
                        iconName: "cross.case.fill",
                        gradientColors: [Color(red: 0.6, green: 0.1, blue: 0.1), Color(red: 0.4, green: 0.05, blue: 0.05)],
                        onTap: {
                            HapticManager.shared.lightImpact()
                            showingHIVCenter = true
                        }
                    )
                    
                    // Pregnancy Card
                    SelfCheckEntryCard(
                        imageName: "Pregnancy",
                        title: "Pregnancy",
                        subtitle: "Weekly guide & health monitoring",
                        iconName: "figure.stand",
                        gradientColors: [Color(red: 0.6, green: 0.1, blue: 0.3), Color(red: 0.4, green: 0.05, blue: 0.2)],
                        onTap: {
                            HapticManager.shared.lightImpact()
                            showingPregnancyCenter = true
                        }
                    )
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            .background(Color(red: 0.973, green: 0.976, blue: 0.984).ignoresSafeArea())
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showingHIVCenter) {
                HIVCenterView()
            }
            .fullScreenCover(isPresented: $showingPregnancyCenter) {
                PregnancyCenterView()
            }
        }
    }
}

// MARK: - Self Check Entry Card
struct SelfCheckEntryCard: View {
    let imageName: String
    let title: String
    let subtitle: String
    let iconName: String
    let gradientColors: [Color]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Background image
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
                
                // Gradient overlay
                LinearGradient(
                    colors: [.clear, gradientColors[0].opacity(0.7), gradientColors[1].opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text(title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                    
                    HStack(spacing: 4) {
                        Text("Explore")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SelfCheckTabView()
}
