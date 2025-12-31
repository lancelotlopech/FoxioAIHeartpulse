//
//  DesignSystem.swift
//  HeartRateSenior
//
//  Design system constants for senior-friendly UI
//

import SwiftUI

// MARK: - Design System Namespace
enum DesignSystem {
    enum Colors {
        // 温暖柔和配色方案
        static let primaryRed = Color(hex: "F67280")      // 珊瑚红（温暖不刺眼）
        static let background = Color(hex: "FAF8F5")       // 奶白色
        static let cardBackground = Color(hex: "FFFFFF")   // 纯白卡片
        static let textPrimary = Color(hex: "4A4A4A")      // 暖灰文字
        static let textSecondary = Color(hex: "8E8E93")    // 中灰
        static let success = Color(hex: "6BCB77")          // 薄荷绿
        static let warning = Color(hex: "F5A623")          // 暖橙
    }
    
    enum Typography {
        // Large Titles: 34pt+
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        
        // BPM Number: 80pt, Bold
        static let bpmDisplay = Font.system(size: 80, weight: .bold, design: .rounded)
        
        // Section Headers
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        
        // Body text
        static let body = Font.system(size: 20, weight: .regular, design: .rounded)
        
        // Buttons: 22pt, Semibold
        static let button = Font.system(size: 22, weight: .semibold, design: .rounded)
        
        // Caption
        static let caption = Font.system(size: 16, weight: .regular, design: .rounded)
        
        // Small text
        static let small = Font.system(size: 14, weight: .regular, design: .rounded)
    }
    
    enum Dimensions {
        // Minimum button height for seniors (60pt)
        static let buttonMinHeight: CGFloat = 60
        
        // Large button size
        static let largeButtonSize: CGFloat = 200
        
        // Corner radius
        static let cornerRadius: CGFloat = 16
        static let cornerRadiusLarge: CGFloat = 20
        static let smallCornerRadius: CGFloat = 12
        
        // Padding
        static let paddingSmall: CGFloat = 8
        static let paddingMedium: CGFloat = 16
        static let paddingLarge: CGFloat = 24
        static let paddingXLarge: CGFloat = 32
        
        // Icon sizes
        static let iconSmall: CGFloat = 24
        static let iconMedium: CGFloat = 32
        static let iconLarge: CGFloat = 48
        static let iconXLarge: CGFloat = 80
    }
}

// MARK: - Legacy Colors (for backward compatibility)
struct AppColors {
    // 温暖柔和配色方案
    static let primaryRed = Color(hex: "F67280")      // 珊瑚红（温暖不刺眼）
    static let background = Color(hex: "FAF8F5")       // 奶白色
    static let cardBackground = Color(hex: "FFFFFF")   // 纯白卡片
    static let textPrimary = Color(hex: "4A4A4A")      // 暖灰文字
    static let textSecondary = Color(hex: "8E8E93")    // 中灰
    static let success = Color(hex: "6BCB77")          // 薄荷绿
    static let warning = Color(hex: "F5A623")          // 暖橙
}

// MARK: - Typography
struct AppTypography {
    // Large Titles: 34pt+
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    
    // BPM Number: 80pt, Bold
    static let bpmDisplay = Font.system(size: 80, weight: .bold, design: .rounded)
    
    // Section Headers
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    
    // Body text
    static let body = Font.system(size: 20, weight: .regular, design: .rounded)
    
    // Buttons: 22pt, Semibold
    static let button = Font.system(size: 22, weight: .semibold, design: .rounded)
    
    // Caption
    static let caption = Font.system(size: 16, weight: .regular, design: .rounded)
    
    // Small text
    static let small = Font.system(size: 14, weight: .regular, design: .rounded)
}

// MARK: - Dimensions
struct AppDimensions {
    // Minimum button height for seniors (60pt)
    static let buttonMinHeight: CGFloat = 60
    
    // Large button size
    static let largeButtonSize: CGFloat = 200
    
    // Corner radius
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 20
    static let smallCornerRadius: CGFloat = 12
    
    // Padding
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXLarge: CGFloat = 32
    
    // Icon sizes
    static let iconSmall: CGFloat = 24
    static let iconMedium: CGFloat = 32
    static let iconLarge: CGFloat = 48
    static let iconXLarge: CGFloat = 80
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct SeniorButtonStyle: ButtonStyle {
    var backgroundColor: Color = AppColors.primaryRed
    var foregroundColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.button)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppDimensions.buttonMinHeight)
            .background(backgroundColor)
            .cornerRadius(AppDimensions.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.button)
            .foregroundColor(AppColors.primaryRed)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppDimensions.buttonMinHeight)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: AppDimensions.cornerRadius)
                    .stroke(AppColors.primaryRed, lineWidth: 2)
            )
            .cornerRadius(AppDimensions.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppDimensions.paddingMedium)
            .background(AppColors.cardBackground)
            .cornerRadius(AppDimensions.cornerRadius)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
