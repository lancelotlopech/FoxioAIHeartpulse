//
//  MainTabView.swift
//  HeartRateSenior
//
//  Custom tab bar with large touch targets for seniors
//  Structure: Home (Dashboard) | ❤️ Measure | Settings
//

import SwiftUI

// MARK: - Tab Item Enum
enum TabItem: Int, CaseIterable {
    case home = 0
    case measure = 1
    case settings = 2
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .measure: return "Measure"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .measure: return "heart.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @State private var shouldAutoStartMeasure = false
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Content
                Group {
                    switch selectedTab {
                    case .home:
                        DashboardView()
                    case .measure:
                        // Embedded HomeView within the tab structure
                        // Using ID to ensure it resets when auto-start is triggered repeatedly
                        HomeView(
                            autoStart: shouldAutoStartMeasure,
                            onDismiss: {
                                // When cancelled, return to home tab
                                shouldAutoStartMeasure = false
                                withAnimation {
                                    selectedTab = .home
                                }
                            }
                        )
                        .id(shouldAutoStartMeasure ? "measure-autostart" : "measure-idle")
                        
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 13) // Space for tab bar
                
                // Custom Tab Bar - Fixed at bottom
                VStack(spacing: 0) {
                    Spacer()
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        onMeasureTapped: {
                            startMeasurement()
                        }
                    )
                }
                .ignoresSafeArea(.keyboard)
                .ignoresSafeArea(edges: .bottom) // 让 Tab Bar 延伸到屏幕底部
            }
        }
        .ignoresSafeArea(.keyboard)
        // Listen for navigation requests from Dashboard
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToMeasure"))) { _ in
            startMeasurement()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToMeasureTab"))) { _ in
            startMeasurement()
        }
    }
    
    private func startMeasurement() {
        HapticManager.shared.mediumImpact()
        shouldAutoStartMeasure = true
        selectedTab = .measure
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var onMeasureTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Home Tab
            TabBarButton(
                tab: .home,
                isSelected: selectedTab == .home,
                action: { 
                    HapticManager.shared.selectionChanged()
                    selectedTab = .home 
                }
            )
            
            // Measure Tab (Center - Larger)
            CenterMeasureButton(
                action: onMeasureTapped
            )
            
            // Settings Tab
            TabBarButton(
                tab: .settings,
                isSelected: selectedTab == .settings,
                action: { 
                    HapticManager.shared.selectionChanged()
                    selectedTab = .settings 
                }
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, 5) // 距离屏幕底部 5 像素
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: -4)
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 28, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.textSecondary)
                
                Text(tab.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Center Measure Button
struct CenterMeasureButton: View {
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .shadow(color: AppColors.primaryRed.opacity(0.35), radius: 8, x: 0, y: 3)
                        .scaleEffect(scale)
                    
                    // Heart icon
                    Image(systemName: "heart.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                }
                .offset(y: -7)
                
                Text("Measure")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.primaryRed)
                    .offset(y: -3)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.08
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SettingsManager())
}
