//
//  UIComponents.swift
//  HeartRateSenior
//
//  Standardized UI components for consistent look and feel
//

import SwiftUI

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var backgroundColor: Color = AppColors.primaryRed
    var isDisabled: Bool = false
    
    init(title: String, icon: String? = nil, backgroundColor: Color = AppColors.primaryRed, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.mediumImpact()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                }
                Text(title)
                    .font(AppTypography.button)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isDisabled ? Color.gray : backgroundColor)
            .cornerRadius(16)
            .shadow(color: isDisabled ? .clear : backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(AppTypography.button)
            }
            .foregroundColor(AppColors.primaryRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.primaryRed, lineWidth: 2)
            )
        }
    }
}

// MARK: - Standard Card
struct StandardCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 20
    
    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Custom Navigation Bar
struct CustomNavigationBar: View {
    let title: String
    var showBackButton: Bool = true
    var rightButtonTitle: String? = nil
    var rightButtonIcon: String? = nil
    var onBackTapped: (() -> Void)? = nil
    var onRightButtonTapped: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            // Left Button (Back)
            if showBackButton {
                Button(action: {
                    if let action = onBackTapped {
                        action()
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.textSecondary)
                }
            } else {
                Spacer().frame(width: 32)
            }
            
            Spacer()
            
            // Title
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            // Right Button
            if let rightIcon = rightButtonIcon {
                Button(action: { onRightButtonTapped?() }) {
                    Image(systemName: rightIcon)
                        .font(.system(size: 28)) // Increased size for accessibility
                        .foregroundColor(AppColors.primaryRed)
                }
            } else if let rightTitle = rightButtonTitle {
                Button(action: { onRightButtonTapped?() }) {
                    Text(rightTitle)
                        .font(.system(size: 17, weight: .semibold)) // Increased size
                        .foregroundColor(AppColors.primaryRed)
                }
            } else {
                Spacer().frame(width: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.95))
    }
}

// MARK: - Icon Manager (SF Symbols Mapping)
struct AppIcons {
    static let heart = "heart.fill"
    static let history = "clock.fill" // More recognizable for seniors
    static let settings = "gearshape.fill"
    static let back = "chevron.left.circle.fill"
    static let close = "xmark.circle.fill"
    static let add = "plus.circle.fill"
    static let camera = "camera.fill"
    static let calendar = "calendar"
    static let share = "square.and.arrow.up"
    static let delete = "trash.fill"
    static let edit = "pencil.circle.fill"
    static let checkmark = "checkmark.circle.fill"
    static let warning = "exclamationmark.triangle.fill"
}

#Preview {
    VStack(spacing: 20) {
        CustomNavigationBar(title: "My Health", rightButtonIcon: "gearshape.fill")
        
        StandardCard {
            Text("This is a card")
            PrimaryButton(title: "Primary Action") {}
            SecondaryButton(title: "Secondary Action") {}
        }
        .padding()
        
        Spacer()
    }
    .background(AppColors.background)
}
