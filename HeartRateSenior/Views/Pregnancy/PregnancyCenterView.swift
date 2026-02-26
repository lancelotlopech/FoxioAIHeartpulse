//
//  PregnancyCenterView.swift
//  HeartRateSenior
//
//  Pregnancy Center - Redesigned Hub View
//

import SwiftUI

// MARK: - Main View
struct PregnancyCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedModule: PregnancyModule?
    @State private var animateIn = false
    
    // Theme colors
    private let primaryColor = Color(red: 0.90, green: 0.49, blue: 0.45) // #E67E73
    private let accentGradient = LinearGradient(
        colors: [Color(red: 0.90, green: 0.49, blue: 0.45), Color(red: 1.0, green: 0.72, blue: 0.65)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Mesh gradient background
                PregnancyMeshBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        pregnancyHeader
                            .padding(.top, 12)
                        
                        // Content
                        VStack(spacing: 16) {
                            // Hero card - Learn About Pregnancy
                            PregnancyHeroCard {
                                HapticManager.shared.mediumImpact()
                                selectedModule = .education
                            }
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateIn)
                            
                            // Timing banner - When Should I Test
                            PregnancyTimingBanner {
                                HapticManager.shared.lightImpact()
                                selectedModule = .timing
                            }
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 15)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: animateIn)
                            
                            // 2x2 Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 14),
                                GridItem(.flexible(), spacing: 14)
                            ], spacing: 14) {
                                // Probability - Organic style
                                PregnancyOrganicCard(
                                    icon: "chart.bar.doc.horizontal",
                                    title: pregnancyRawText("Probability"),
                                    subtitle: pregnancyRawText("Self Check")
                                ) {
                                    HapticManager.shared.mediumImpact()
                                    selectedModule = .probability
                                }
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.25), value: animateIn)
                                
                                // Cycle Tracker - Photo style
                                PregnancyPhotoCard(
                                    imageName: "PregnancyTracker",
                                    icon: "drop.fill",
                                    title: pregnancyRawText("Cycle Tracker"),
                                    subtitle: pregnancyRawText("Monitor Period")
                                ) {
                                    HapticManager.shared.mediumImpact()
                                    selectedModule = .tracker
                                }
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animateIn)
                                
                                // Support - Photo style
                                PregnancyPhotoCard(
                                    imageName: "PregnancyCare",
                                    icon: "heart.fill",
                                    title: pregnancyRawText("Support"),
                                    subtitle: pregnancyRawText("Emotional")
                                ) {
                                    HapticManager.shared.mediumImpact()
                                    selectedModule = .support
                                }
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35), value: animateIn)
                                
                                // Testing - Organic style
                                PregnancyOrganicCard(
                                    icon: "doc.text.magnifyingglass",
                                    title: pregnancyRawText("Testing"),
                                    subtitle: pregnancyRawText("How to use")
                                ) {
                                    HapticManager.shared.mediumImpact()
                                    selectedModule = .guide
                                }
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: animateIn)
                            }
                            
                            // Reminders bar
                            PregnancyReminderBar {
                                HapticManager.shared.mediumImpact()
                                selectedModule = .reminders
                            }
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 15)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.45), value: animateIn)
                            
                            // Disclaimer
                            PregnancyDisclaimerFooter()
                                .opacity(animateIn ? 1 : 0)
                                .animation(.easeOut(duration: 0.5).delay(0.55), value: animateIn)
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
    private var pregnancyHeader: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {
                    HapticManager.shared.lightImpact()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.5))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                }
                
                Spacer()
                
                // Center icon
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.88, green: 0.65, blue: 0.65), Color(red: 1.0, green: 0.78, blue: 0.68)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(3))
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(-3))
                    )
                    .shadow(color: Color(red: 0.90, green: 0.49, blue: 0.45).opacity(0.25), radius: 15, y: 5)
                
                Spacer()
                
                // Placeholder for symmetry
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text(pregnancyRawText("Pregnancy"))
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                Text(pregnancyRawText("Center"))
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Text(pregnancyRawText("NURTURING YOUR JOURNEY"))
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
struct PregnancyMeshBackground: View {
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.945, blue: 0.95) // #fff1f2 base
            
            // Warm peach top-left
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.93, blue: 0.88).opacity(0.9), .clear],
                center: UnitPoint(x: 0.1, y: 0.1),
                startRadius: 0, endRadius: 300
            )
            
            // Pink top-right
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.92, blue: 0.95).opacity(0.8), .clear],
                center: UnitPoint(x: 0.9, y: 0.0),
                startRadius: 0, endRadius: 280
            )
            
            // Peach bottom-right
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.90, blue: 0.85).opacity(0.7), .clear],
                center: UnitPoint(x: 0.8, y: 0.8),
                startRadius: 0, endRadius: 320
            )
            
            // Pink bottom-left
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.90, blue: 0.92).opacity(0.6), .clear],
                center: UnitPoint(x: 0.1, y: 0.9),
                startRadius: 0, endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Hero Card
struct PregnancyHeroCard: View {
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Image
                GeometryReader { geo in
                    Image("Pregnancy")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                
                // Gradient overlay
                LinearGradient(
                    colors: [.black.opacity(0.6), .black.opacity(0.1), .clear],
                    startPoint: .bottom, endPoint: .top
                )
                
                // Content
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        // Featured tag
                        Text(pregnancyRawText("FEATURED"))
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
                        
                        Text(pregnancyRawText("Learn About\nPregnancy"))
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .lineSpacing(2)
                        
                        Text(pregnancyRawText("Essential guide for your 9 months"))
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // Arrow button
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
        .buttonStyle(PregnancyCardButtonStyle())
    }
}

// MARK: - Timing Banner
struct PregnancyTimingBanner: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.91, blue: 0.90), Color(red: 1.0, green: 0.96, blue: 0.95)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "clock.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.90, green: 0.49, blue: 0.45), Color(red: 1.0, green: 0.72, blue: 0.65)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(pregnancyRawText("When Should I Test?"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    Text(pregnancyRawText("Find the right timing for accurate results"))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.90, green: 0.49, blue: 0.45).opacity(0.6))
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
            .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.5).opacity(0.08), radius: 10, y: 4)
        }
        .buttonStyle(PregnancyCardButtonStyle())
    }
}

// MARK: - Organic Card (Glass white)
struct PregnancyOrganicCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // 3D Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.91, blue: 0.90), Color(red: 1.0, green: 0.96, blue: 0.95)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: Color(red: 0.82, green: 0.71, blue: 0.69).opacity(0.2), radius: 8, x: 4, y: 4)
                        .shadow(color: .white.opacity(0.9), radius: 8, x: -4, y: -4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.90, green: 0.49, blue: 0.45), Color(red: 1.0, green: 0.72, blue: 0.65)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                }
                
                Spacer()
                
                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(pregnancyRawText(title))
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text(pregnancyRawText(subtitle).uppercased())
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
            .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.5).opacity(0.1), radius: 15, y: 8)
        }
        .buttonStyle(PregnancyCardButtonStyle())
    }
}

// MARK: - Photo Card
struct PregnancyPhotoCard: View {
    let imageName: String
    let icon: String
    let title: String
    let subtitle: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Image
                GeometryReader { geo in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                
                // Dark overlay
                Color.black.opacity(0.25)
                
                // Gradient from bottom
                LinearGradient(
                    colors: [.black.opacity(0.55), .black.opacity(0.1), .clear],
                    startPoint: .bottom, endPoint: .top
                )
                
                // Content
                VStack(alignment: .leading) {
                    // Top icon
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
                    
                    // Bottom text
                    VStack(alignment: .leading, spacing: 3) {
                        Text(pregnancyRawText(title))
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        
                        Text(pregnancyRawText(subtitle).uppercased())
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
        .buttonStyle(PregnancyCardButtonStyle())
    }
}

// MARK: - Reminder Bar
struct PregnancyReminderBar: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 3D Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.91, blue: 0.90), Color(red: 1.0, green: 0.96, blue: 0.95)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: Color(red: 0.82, green: 0.71, blue: 0.69).opacity(0.2), radius: 8, x: 4, y: 4)
                        .shadow(color: .white.opacity(0.9), radius: 8, x: -4, y: -4)
                    
                    Image(systemName: "bell.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.90, green: 0.49, blue: 0.45), Color(red: 1.0, green: 0.72, blue: 0.65)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(pregnancyRawText("Reminders"))
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text(pregnancyRawText("Set Alerts & Appointments"))
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Arrow
                Circle()
                    .fill(Color(red: 1.0, green: 0.95, blue: 0.94))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.90, green: 0.55, blue: 0.50))
                    )
                    .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.white.opacity(0.8), lineWidth: 1)
                    )
            )
            .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.5).opacity(0.08), radius: 12, y: 6)
        }
        .buttonStyle(PregnancyCardButtonStyle())
    }
}

// MARK: - Disclaimer Footer
struct PregnancyDisclaimerFooter: View {
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
                        .foregroundColor(Color(red: 0.90, green: 0.55, blue: 0.50))
                    
                    Text(pregnancyRawText("Medical Disclaimer"))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                
                if isExpanded {
                    Text(pregnancyRawText(PregnancyEducationData.disclaimer))
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
struct PregnancyCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Pregnancy Module Enum
enum PregnancyModule: String, CaseIterable, Identifiable {
    case education = "Learn About Pregnancy"
    case probability = "Check My Probability"
    case timing = "When Should I Test"
    case guide = "How to Use a Test"
    case tracker = "Cycle Tracker"
    case support = "Emotional Support"
    case reminders = "Reminder Center"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .education: return pregnancyRawText("Learn About\nPregnancy")
        case .probability: return pregnancyRawText("Check My\nProbability")
        case .timing: return pregnancyRawText("When Should\nI Test")
        case .guide: return pregnancyRawText("How to Use a\nPregnancy Test")
        case .tracker: return pregnancyRawText("Cycle\nTracker")
        case .support: return pregnancyRawText("Emotional\nSupport")
        case .reminders: return pregnancyRawText("Reminder\nCenter")
        }
    }
    
    var description: String {
        switch self {
        case .education: return pregnancyRawText("Understanding basics")
        case .probability: return pregnancyRawText("Self-assessment")
        case .timing: return pregnancyRawText("Timing guidance")
        case .guide: return pregnancyRawText("Step-by-step")
        case .tracker: return pregnancyRawText("Track your cycle")
        case .support: return pregnancyRawText("While waiting")
        case .reminders: return pregnancyRawText("Set reminders")
        }
    }
    
    var icon: String {
        switch self {
        case .education: return "book.fill"
        case .probability: return "magnifyingglass.circle.fill"
        case .timing: return "clock.fill"
        case .guide: return "doc.text.fill"
        case .tracker: return "calendar"
        case .support: return "heart.fill"
        case .reminders: return "bell.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .education: return Color(red: 1.0, green: 0.75, blue: 0.8)
        case .probability: return Color(red: 1.0, green: 0.6, blue: 0.7)
        case .timing: return Color(red: 0.9, green: 0.5, blue: 0.7)
        case .guide: return Color(red: 1.0, green: 0.7, blue: 0.75)
        case .tracker: return Color(red: 0.95, green: 0.65, blue: 0.75)
        case .support: return Color(red: 1.0, green: 0.55, blue: 0.65)
        case .reminders: return Color(red: 0.85, green: 0.45, blue: 0.65)
        }
    }
    
    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .education:
            PregnancyEducationView()
        case .probability:
            PregnancyProbabilityView()
        case .timing:
            PregnancyTestTimingView()
        case .guide:
            PregnancyTestGuideView()
        case .tracker:
            CycleTrackerView()
        case .support:
            EmotionalSupportView()
        case .reminders:
            PregnancyReminderCenterView()
        }
    }
}

#Preview {
    PregnancyCenterView()
}
