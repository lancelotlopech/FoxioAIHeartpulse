//
//  HIVCenterView.swift
//  HeartRateSenior
//
//  HIV Awareness Center - Hub View (modeled after PregnancyCenterView)
//

import SwiftUI

// MARK: - HIV Module Enum
enum HIVModule: String, CaseIterable, Identifiable, Hashable {
    case education   = "Learn About HIV"
    case symptoms    = "Symptoms"
    case testing     = "Testing Guide"
    case timeline    = "Timeline"
    case assessment  = "Risk Assessment"
    case overview    = "Full Overview"
    
    var id: String { rawValue }
    
    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .education:
            HIVEducationView()
        case .symptoms:
            HIVSymptomsDetailView()
        case .testing:
            HIVTestingGuideView()
        case .timeline:
            HIVTimelineView()
        case .assessment:
            HIVRiskAssessmentView()
        case .overview:
            HIVAwarenessView()
        }
    }
}

// MARK: - Main View
struct HIVCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedModule: HIVModule?
    @State private var animateIn = false
    
    private let primaryColor = AppColors.primaryRed
    private let accentGradient = LinearGradient(
        colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.7)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                HIVMeshBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        hivHeader
                            .padding(.top, 12)
                        
                        VStack(spacing: 16) {
                            // Hero card - Learn About HIV
                            HIVHeroCard {
                                HapticManager.shared.mediumImpact()
                                selectedModule = .education
                            }
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateIn)
                            
                            // Risk Assessment banner
                            HIVAssessmentBanner {
                                HapticManager.shared.lightImpact()
                                selectedModule = .assessment
                            }
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 15)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: animateIn)
                            
                            // 2x2 Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 14),
                                GridItem(.flexible(), spacing: 14)
                            ], spacing: 14) {
                                // Symptoms - Organic style
                                HIVOrganicCard(
                                    icon: "stethoscope",
                                    title: hivRawText("Symptoms"),
                                    subtitle: hivRawText("Identify")
                                ) {
                                    HapticManager.shared.mediumImpact()
                                    selectedModule = .symptoms
                                }
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.25), value: animateIn)
                                
                                // Testing - Photo style
                                HIVPhotoCard(
                                    imageName: "HIV1",
                                    icon: "cross.case.fill",
                                    title: hivRawText("Testing"),
                                    subtitle: hivRawText("Methods")
                                ) {
                                    HapticManager.shared.mediumImpact()
                                    selectedModule = .testing
                                }
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animateIn)
                                
                                // Timeline - Photo style
                                HIVPhotoCard(
                                    imageName: "HIV2",
                                    icon: "calendar.badge.clock",
                                    title: hivRawText("Timeline"),
                                    subtitle: hivRawText("When Test")
                                ) {
                                    HapticManager.shared.mediumImpact()
                                    selectedModule = .timeline
                                }
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35), value: animateIn)
                                
                                // Overview - Organic style
                                HIVOrganicCard(
                                    icon: "list.bullet.rectangle.portrait",
                                    title: hivRawText("Overview"),
                                    subtitle: hivRawText("All Info")
                                ) {
                                    HapticManager.shared.mediumImpact()
                                    selectedModule = .overview
                                }
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: animateIn)
                            }
                            
                            // Disclaimer
                            HIVDisclaimerFooter()
                                .opacity(animateIn ? 1 : 0)
                                .animation(.easeOut(duration: 0.5).delay(0.5), value: animateIn)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedModule) { module in
                module.destinationView
            }
            .onAppear {
                withAnimation { animateIn = true }
            }
        }
    }
    
    // MARK: - Header
    private var hivHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    HapticManager.shared.lightImpact()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.5))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                }
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primaryRed.opacity(0.8), AppColors.primaryRed.opacity(0.5)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(3))
                    .overlay(
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(-3))
                    )
                    .shadow(color: AppColors.primaryRed.opacity(0.25), radius: 15, y: 5)
                
                Spacer()
                
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(hivRawText("HIV"))
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                Text(hivRawText("Awareness"))
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Text(hivRawText("PREVENTION & EARLY CARE"))
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2.5)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Mesh Gradient Background
struct HIVMeshBackground: View {
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.95, blue: 0.95)
            
            RadialGradient(
                colors: [AppColors.primaryRed.opacity(0.08), .clear],
                center: UnitPoint(x: 0.1, y: 0.1),
                startRadius: 0, endRadius: 300
            )
            
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.92, blue: 0.92).opacity(0.8), .clear],
                center: UnitPoint(x: 0.9, y: 0.0),
                startRadius: 0, endRadius: 280
            )
            
            RadialGradient(
                colors: [AppColors.primaryRed.opacity(0.06), .clear],
                center: UnitPoint(x: 0.8, y: 0.8),
                startRadius: 0, endRadius: 320
            )
            
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.90, blue: 0.90).opacity(0.6), .clear],
                center: UnitPoint(x: 0.1, y: 0.9),
                startRadius: 0, endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Hero Card
struct HIVHeroCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                GeometryReader { geo in
                    Image("HIV")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                
                LinearGradient(
                    colors: [.black.opacity(0.6), .black.opacity(0.1), .clear],
                    startPoint: .bottom, endPoint: .top
                )
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(hivRawText("FEATURED"))
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
                        
                        Text(hivRawText("Learn About\nHIV"))
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .lineSpacing(2)
                        
                        Text(hivRawText("Prevention, testing & early care"))
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                        .overlay(
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .padding(.bottom, 4)
                }
                .padding(24)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        }
        .buttonStyle(HIVCardButtonStyle())
    }
}

// MARK: - Assessment Banner
struct HIVAssessmentBanner: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryRed.opacity(0.15), AppColors.primaryRed.opacity(0.05)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "checklist.checked")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.7)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(hivRawText("Risk Assessment"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    Text(hivRawText("Check your risk level with a quick quiz"))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.primaryRed.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.8), lineWidth: 1)
                    )
            )
            .shadow(color: AppColors.primaryRed.opacity(0.08), radius: 10, y: 4)
        }
        .buttonStyle(HIVCardButtonStyle())
    }
}

// MARK: - Organic Card (Glass white)
struct HIVOrganicCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryRed.opacity(0.12), AppColors.primaryRed.opacity(0.04)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: AppColors.primaryRed.opacity(0.15), radius: 8, x: 4, y: 4)
                        .shadow(color: .white.opacity(0.9), radius: 8, x: -4, y: -4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.7)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text(subtitle.uppercased())
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1.8)
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .frame(height: 170)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.white.opacity(0.8), lineWidth: 1)
                    )
            )
            .shadow(color: AppColors.primaryRed.opacity(0.08), radius: 15, y: 8)
        }
        .buttonStyle(HIVCardButtonStyle())
    }
}

// MARK: - Photo Card
struct HIVPhotoCard: View {
    let imageName: String
    let icon: String
    let title: String
    let subtitle: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                GeometryReader { geo in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                
                Color.black.opacity(0.25)
                
                LinearGradient(
                    colors: [.black.opacity(0.55), .black.opacity(0.1), .clear],
                    startPoint: .bottom, endPoint: .top
                )
                
                VStack(alignment: .leading) {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                        )
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        Text(subtitle.uppercased())
                            .font(.system(size: 9, weight: .medium))
                            .tracking(1.8)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
            }
            .frame(height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.12), radius: 15, y: 8)
        }
        .buttonStyle(HIVCardButtonStyle())
    }
}

// MARK: - Disclaimer Footer
struct HIVDisclaimerFooter: View {
    @State private var isExpanded = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text(hivRawText("Medical Disclaimer"))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                
                if isExpanded {
                    Text(HIVEducationData.localizedDisclaimer)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.gray)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 10)
                        .padding(.leading, 32)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Button Style
struct HIVCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    HIVCenterView()
}
