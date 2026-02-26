//
//  MainTabView.swift
//  HeartRateSenior
//
//  Custom tab bar with 5 tabs
//  Structure: Home | Check | ❤️ Measure | History | Settings
//

import SwiftUI

// MARK: - Tab Item Enum
enum TabItem: Int, CaseIterable {
    case home = 0
    case check = 1
    case measure = 2
    case history = 3
    case settings = 4
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .check: return "Check"
        case .measure: return "Measure"
        case .history: return "History"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .check: return "stethoscope"
        case .measure: return "heart.fill"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape.fill"
        }
    }
    
    /// Premium locked tabs
    var isPremiumOnly: Bool {
        switch self {
        case .check, .history: return true
        default: return false
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @State private var showingMeasureFullScreen = false
    @State private var showingSubscription = false
    @State private var lastActiveTime: Date = Date()
    @State private var isReturningFromBackground = false
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        GeometryReader { geometry in
            let bottomInset = geometry.safeAreaInsets.bottom
            
            ZStack(alignment: .bottom) {
                // Content area
                Group {
                    switch selectedTab {
                    case .home:
                        DashboardView()
                    case .check:
                        SelfCheckTabView()
                    case .measure:
                        if !showingMeasureFullScreen {
                            HomeView(autoStart: false, onDismiss: nil)
                        } else {
                            Color.white
                        }
                    case .history:
                        HistoryView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 1 + bottomInset)
                
                // Tab Bar
                VStack(spacing: 0) {
                    Spacer()
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        isPremium: subscriptionManager.isPremium,
                        bottomInset: bottomInset,
                        onMeasureTapped: { startMeasurement() },
                        onLockedTabTapped: { showingSubscription = true }
                    )
                }
                .ignoresSafeArea(.keyboard)
                .ignoresSafeArea(edges: .bottom)
                
                // Subscription overlay
                if showingSubscription {
                    Color(hex: "EFF0F3")
                        .ignoresSafeArea()
                        .overlay(
                            SubscriptionView(isPresented: $showingSubscription)
                        )
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $showingMeasureFullScreen) {
            HomeView(
                autoStart: true,
                onDismiss: { showingMeasureFullScreen = false }
            )
            .environmentObject(settingsManager)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                let elapsed = Date().timeIntervalSince(lastActiveTime)
                if elapsed > 1.0 {
                    isReturningFromBackground = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isReturningFromBackground = false
                    }
                }
                lastActiveTime = Date()
            case .inactive, .background:
                lastActiveTime = Date()
            @unknown default: break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToMeasure"))) { _ in
            guard !isReturningFromBackground else { return }
            startMeasurement()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToMeasureTab"))) { _ in
            guard !isReturningFromBackground else { return }
            startMeasurement()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSubscription"))) { _ in
            showingSubscription = true
        }
    }
    
    private func startMeasurement() {
        guard !showingMeasureFullScreen else { return }
        HapticManager.shared.mediumImpact()
        showingMeasureFullScreen = true
    }
}

// MARK: - Custom Tab Bar (5 tabs)
struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var isPremium: Bool
    var bottomInset: CGFloat
    var onMeasureTapped: () -> Void
    var onLockedTabTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Home
            TabBarButton(tab: .home, isSelected: selectedTab == .home) {
                HapticManager.shared.selectionChanged()
                selectedTab = .home
            }
            
            // Check (premium)
            TabBarButton(tab: .check, isSelected: selectedTab == .check, isLocked: !isPremium) {
                HapticManager.shared.selectionChanged()
                if isPremium { selectedTab = .check } else { onLockedTabTapped() }
            }
            
            // Measure (center)
            CenterMeasureButton(action: onMeasureTapped)
            
            // History (premium)
            TabBarButton(tab: .history, isSelected: selectedTab == .history, isLocked: !isPremium) {
                HapticManager.shared.selectionChanged()
                if isPremium { selectedTab = .history } else { onLockedTabTapped() }
            }
            
            // Settings
            TabBarButton(tab: .settings, isSelected: selectedTab == .settings) {
                HapticManager.shared.selectionChanged()
                selectedTab = .settings
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 6)
        .padding(.bottom, max(bottomInset - 12, 0))
        .background(
            Color.white
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: -3)
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    var isLocked: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.textSecondary)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.white)
                            .padding(2.5)
                            .background(AppColors.primaryRed)
                            .clipShape(Circle())
                            .offset(x: 5, y: -3)
                    }
                }
                
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
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
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryRed, AppColors.primaryRed.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: AppColors.primaryRed.opacity(0.3), radius: 6, x: 0, y: 2)
                        .scaleEffect(scale)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                }
                .offset(y: -10)
                
                Text("Measure")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.primaryRed)
                    .offset(y: -8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                scale = 1.08
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SettingsManager())
}
