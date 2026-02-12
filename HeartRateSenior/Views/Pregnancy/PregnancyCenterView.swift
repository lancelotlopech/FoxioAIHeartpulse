//
//  PregnancyCenterView.swift
//  HeartRateSenior
//
//  Pregnancy Center - Main Hub View (Enhanced)
//

import SwiftUI

struct PregnancyCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedModule: PregnancyModule?
    @State private var animateCards = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.85, blue: 0.9),
                        Color(red: 1.0, green: 0.95, blue: 0.97),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Decorative circles
                GeometryReader { geometry in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.6, blue: 0.7).opacity(0.15), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 40)
                        .offset(x: -50, y: -50)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.75, blue: 0.8).opacity(0.12), Color.clear],
                                startPoint: .bottomTrailing,
                                endPoint: .topLeading
                            )
                        )
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: geometry.size.width - 100, y: geometry.size.height - 150)
                }
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Enhanced Header
                        VStack(spacing: 16) {
                            ZStack {
                                // Glow effect
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.6, blue: 0.7).opacity(0.3),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 60
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .blur(radius: 20)
                                
                                // Icon background
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.7, blue: 0.8),
                                                Color(red: 1.0, green: 0.6, blue: 0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.7).opacity(0.4), radius: 20, x: 0, y: 10)
                                
                                Image(systemName: "heart.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.white)
                            }
                            .scaleEffect(animateCards ? 1.0 : 0.8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animateCards)
                            
                            VStack(spacing: 8) {
                                Text("Pregnancy Center")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.5, blue: 0.65),
                                                Color(red: 0.9, green: 0.4, blue: 0.6)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("Choose what you need")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.2), value: animateCards)
                        }
                        .padding(.top, 20)
                        
                        // Enhanced Module Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(Array(PregnancyModule.allCases.enumerated()), id: \.element) { index, module in
                                EnhancedModuleCard(module: module)
                                    .opacity(animateCards ? 1 : 0)
                                    .offset(y: animateCards ? 0 : 30)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.3), value: animateCards)
                                    .onTapGesture {
                                        HapticManager.shared.mediumImpact()
                                        selectedModule = module
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Enhanced Disclaimer
                        EnhancedDisclaimerCard()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .opacity(animateCards ? 1 : 0)
                            .animation(.easeOut(duration: 0.6).delay(0.8), value: animateCards)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedModule) { module in
                module.destinationView
            }
            .onAppear {
                animateCards = true
            }
        }
    }
}

// MARK: - Enhanced Module Card
struct EnhancedModuleCard: View {
    let module: PregnancyModule
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 14) {
            // Enhanced Icon with gradient
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [module.color.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 40
                        )
                    )
                    .frame(width: 70, height: 70)
                    .blur(radius: 10)
                
                // Icon background with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [module.color.opacity(0.2), module.color.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Image(systemName: module.icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [module.color, module.color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Title
            Text(module.title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
            
            // Description
            Text(module.description)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [module.color.opacity(0.3), module.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: module.color.opacity(0.15), radius: isPressed ? 8 : 15, x: 0, y: isPressed ? 4 : 8)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Enhanced Disclaimer Card
struct EnhancedDisclaimerCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Important Notice")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(PregnancyEducationData.disclaimer)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.blue.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Disclaimer Card (Legacy)
struct DisclaimerCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                
                Text("Important Notice")
                    .font(.system(size: 14, weight: .semibold))
            }
            
            Text(PregnancyEducationData.disclaimer)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
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
        case .education: return "Learn About\nPregnancy"
        case .probability: return "Check My\nProbability"
        case .timing: return "When Should\nI Test"
        case .guide: return "How to Use a\nPregnancy Test"
        case .tracker: return "Cycle\nTracker"
        case .support: return "Emotional\nSupport"
        case .reminders: return "Reminder\nCenter"
        }
    }
    
    var description: String {
        switch self {
        case .education: return "Understanding basics"
        case .probability: return "Self-assessment"
        case .timing: return "Timing guidance"
        case .guide: return "Step-by-step"
        case .tracker: return "Track your cycle"
        case .support: return "While waiting"
        case .reminders: return "Set reminders"
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
