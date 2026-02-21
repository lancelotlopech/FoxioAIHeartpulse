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

// MARK: - Splash View (启动动画 - 带保底机制)
struct SplashView: View {
    @Binding var isReady: Bool  // 外部传入的加载完成标志
    let onComplete: () -> Void
    
    @State private var isBeating = false
    @State private var progressPercent: Int = 0
    @State private var showContent = false
    @State private var minTimeReached = false  // 最短时间已到
    
    private let heartColor = AppColors.primaryRed
    private let minDuration: Double = 1.2  // 最短动画时长
    private let timer = Timer.publish(every: 0.012, on: .main, in: .common).autoconnect()
    
    private let ringSize: CGFloat = 240
    private let ringLineWidth: CGFloat = 10
    
    var body: some View {
        ZStack {
            // 奶白色背景
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // 圆环进度 + 心形图标
                ZStack {
                    // 底环（灰色）
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: ringLineWidth)
                        .frame(width: ringSize, height: ringSize)
                    
                    // 进度弧线（红色）
                    Circle()
                        .trim(from: 0, to: CGFloat(progressPercent) / 100.0)
                        .stroke(
                            heartColor,
                            style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                        )
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.05), value: progressPercent)
                    
                    // 内圈淡灰背景
                    Circle()
                        .fill(Color.gray.opacity(0.04))
                        .frame(width: ringSize - ringLineWidth * 4, height: ringSize - ringLineWidth * 4)
                    
                    // 心形轮廓图标
                    Image(systemName: "heart")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(heartColor)
                }
                
                // 百分比数字
                Text("\(progressPercent)%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(heartColor)
                
                // App 名称
                VStack(spacing: 8) {
                    Text("Heart Pulse")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Your Health Companion")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) { showContent = true }
            // 最短时间计时器
            DispatchQueue.main.asyncAfter(deadline: .now() + minDuration) {
                minTimeReached = true
                checkCompletion()
            }
        }
        .onReceive(timer) { _ in
            updateProgress()
        }
        .onChange(of: isReady) { _, newValue in
            if newValue { checkCompletion() }
        }
    }
    
    /// 进度条更新策略：
    /// - 0-80%: 快速递增（前1秒）
    /// - 80-99%: 慢速递增（等待加载）
    /// - 100%: 只有 isReady && minTimeReached 才跳到100
    private func updateProgress() {
        if progressPercent < 80 {
            // 快速阶段: 每帧 +1
            progressPercent += 1
        } else if progressPercent < 99 {
            // 慢速阶段: 每3帧 +1 (等待加载)
            if Int.random(in: 0...2) == 0 {
                progressPercent += 1
            }
        }
        // 99% 卡住，等待 checkCompletion
    }
    
    /// 检查是否满足完成条件
    private func checkCompletion() {
        guard isReady && minTimeReached else { return }
        // 快速跳到 100%
        progressPercent = 100
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onComplete()
        }
    }
}

// MARK: - ECG Wave Path with Heart Shape in the Middle
struct ECGWavePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height, midY = h / 2
        
        // 起点 - 平线
        path.move(to: CGPoint(x: 0, y: midY))
        path.addLine(to: CGPoint(x: w * 0.05, y: midY))
        
        // 左侧 QRS 波形
        path.addLine(to: CGPoint(x: w * 0.08, y: midY + h * 0.05))  // Q波
        path.addLine(to: CGPoint(x: w * 0.12, y: midY - h * 0.35)) // R波尖峰
        path.addLine(to: CGPoint(x: w * 0.16, y: midY + h * 0.15)) // S波
        path.addLine(to: CGPoint(x: w * 0.20, y: midY))            // 回归基线
        
        // 过渡到心形
        path.addLine(to: CGPoint(x: w * 0.28, y: midY))
        
        // ❤️ 心形轮廓 (从底部开始，逆时针画)
        let heartCenterX = w * 0.5
        let heartBottom = midY + h * 0.35  // 心形底部尖端
        let heartTop = midY - h * 0.30     // 心形顶部
        let heartWidth = w * 0.18          // 心形半宽
        
        // 移动到心形起点（左下角开始进入心形）
        path.addLine(to: CGPoint(x: heartCenterX - heartWidth * 0.8, y: midY))
        
        // 画心形 - 左半边（从中间往上到左边圆弧顶部）
        path.addQuadCurve(
            to: CGPoint(x: heartCenterX - heartWidth * 0.5, y: heartTop),
            control: CGPoint(x: heartCenterX - heartWidth * 1.1, y: heartTop + h * 0.05)
        )
        
        // 左边圆弧顶部到中间凹陷
        path.addQuadCurve(
            to: CGPoint(x: heartCenterX, y: heartTop + h * 0.12),
            control: CGPoint(x: heartCenterX - heartWidth * 0.15, y: heartTop - h * 0.05)
        )
        
        // 中间凹陷到右边圆弧顶部
        path.addQuadCurve(
            to: CGPoint(x: heartCenterX + heartWidth * 0.5, y: heartTop),
            control: CGPoint(x: heartCenterX + heartWidth * 0.15, y: heartTop - h * 0.05)
        )
        
        // 右边圆弧顶部往下到心形底部
        path.addQuadCurve(
            to: CGPoint(x: heartCenterX, y: heartBottom),
            control: CGPoint(x: heartCenterX + heartWidth * 1.1, y: heartTop + h * 0.05)
        )
        
        // 心形底部回到基线左侧
        path.addQuadCurve(
            to: CGPoint(x: heartCenterX - heartWidth * 0.8, y: midY),
            control: CGPoint(x: heartCenterX - heartWidth * 0.5, y: midY + h * 0.15)
        )
        
        // 从心形出来，继续右侧
        path.move(to: CGPoint(x: heartCenterX + heartWidth * 0.8, y: midY))
        path.addLine(to: CGPoint(x: w * 0.72, y: midY))
        
        // 右侧 QRS 波形
        path.addLine(to: CGPoint(x: w * 0.76, y: midY + h * 0.05))  // Q波
        path.addLine(to: CGPoint(x: w * 0.80, y: midY - h * 0.35)) // R波尖峰
        path.addLine(to: CGPoint(x: w * 0.84, y: midY + h * 0.15)) // S波
        path.addLine(to: CGPoint(x: w * 0.88, y: midY))            // 回归基线
        
        // 结尾平线
        path.addLine(to: CGPoint(x: w, y: midY))
        
        return path
    }
}

// MARK: - Disclaimer Footer View (Dashboard底部免责声明 - 可折叠)
struct DisclaimerFooterView: View {
    @State private var showReferencesDisclaimer = false
    
    // Reference URLs
    private let pubMedURL = "https://pubmed.ncbi.nlm.nih.gov/17322588/"
    private let wikipediaURL = "https://en.wikipedia.org/wiki/Heart_rate"
    private let privacyPolicyURL = "https://termsheartpulse.moonspace.workers.dev/privacy_policy.html"
    private let termsOfUseURL = "https://termsheartpulse.moonspace.workers.dev/terms_of_use.html"
    
    var body: some View {
        VStack(spacing: 12) {
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            // Collapsible Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showReferencesDisclaimer.toggle()
                }
                HapticManager.shared.lightImpact()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text("References & Disclaimer")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: showReferencesDisclaimer ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal, 20)
            }
            
            // Expandable Content
            if showReferencesDisclaimer {
                VStack(spacing: 16) {
                    // Scientific References Section
                    VStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            
                            Text("Scientific References")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        HStack(spacing: 20) {
                            Link(destination: URL(string: pubMedURL)!) {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 11))
                                    Text("PubMed")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                }
                                .foregroundColor(.green)
                            }
                            
                            Link(destination: URL(string: wikipediaURL)!) {
                                HStack(spacing: 4) {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 11))
                                    Text("Wikipedia")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // Medical Disclaimer
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            
                            Text("Medical Disclaimer")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Text("This app provides estimates for wellness purposes only. It is not a medical device and should not be used for diagnosis or treatment. Consult a healthcare professional for medical advice.")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(AppColors.textSecondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Legal Links
                    HStack(spacing: 16) {
                        Link(destination: URL(string: privacyPolicyURL)!) {
                            Text("Privacy Policy")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary.opacity(0.5))
                        
                        Link(destination: URL(string: termsOfUseURL)!) {
                            Text("Terms of Use")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 12)
    }
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
