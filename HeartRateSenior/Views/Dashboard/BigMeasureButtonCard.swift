//
//  BigMeasureButtonCard.swift
//  HeartRateSenior
//
//  Heart Rate Card with Button and Info
//  心率卡片组件 - 无边框透明背景版本
//

import SwiftUI

// MARK: - Heart Rate Card (心率卡片 - 水平布局，无边框)
struct BigMeasureButtonCard: View {
    let lastRecord: HeartRateRecord?
    let onMeasureTap: () -> Void
    
    // ═══════════════════════════════════════════════════════════════
    // 【动画状态变量】
    // ═══════════════════════════════════════════════════════════════
    @State private var glowOpacity: Double = 0.3      // 荧光透明度（呼吸动画）
    @State private var glowScale: CGFloat = 1.0       // 荧光缩放（呼吸动画）
    @State private var buttonScale: CGFloat = 1.0     // 按钮缩放（呼吸动画）
    @State private var isPressed = false              // 按下状态
    
    var body: some View {
        // ═══════════════════════════════════════════════════════════════
        // 【主容器】VStack - 垂直布局
        // spacing: 标题和内容区的垂直间距
        // ═══════════════════════════════════════════════════════════════
        VStack(spacing: 8) {
            
            // ───────────────────────────────────────────────────────────
            // 【区域 A】顶部标题栏
            // ───────────────────────────────────────────────────────────
            HStack {
                // 【A1】标题文字 - "Heart Rate"
                Text("Heart Rate")
                    .font(.system(size: 22, weight: .bold, design: .rounded))  // 字体大小：22pt
                    .foregroundColor(.black)  // 颜色：纯黑色
                
                Spacer()
                
                // 【A2】See More 按钮 - 跳转到心率报告
                if let record = lastRecord {
                    NavigationLink(destination: ResultView(record: record)) {
                        HStack(spacing: 4) {
                            Text("See More")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            
            // ───────────────────────────────────────────────────────────
            // 【区域 B】主内容区：心形按钮（左） + 心率信息（右）
            // spacing: 按钮和右侧信息的水平间距（改小可让按钮往左）
            // ───────────────────────────────────────────────────────────
            HStack(alignment: .center, spacing: -30) {  // 【可调】负值让按钮更靠左（从-1改为-30）
                
                // ─────────────────────────────────────────────────────
                // 【区域 B1】左侧：大心形按钮 + 荧光效果
                // ─────────────────────────────────────────────────────
                Button(action: {
                    // 按下动画
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isPressed = false
                        }
                        onMeasureTap()
                    }
                }) {
                    ZStack {
                        // 【B1-Layer1】最外层荧光（大模糊）
                        // frame: 荧光范围大小，改大=荧光范围更大
                        // blur: 模糊程度，改大=更模糊
                        // opacity: 透明度，改小=更淡
                        Image("homebutton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 260, height: 170)  // 【可调】荧光范围（高度从220减到170）
                            .blur(radius: 30)                 // 【可调】模糊程度
                            .opacity(glowOpacity * 0.5)       // 【可调】荧光透明度
                            .scaleEffect(glowScale * 1.1)
                        
                        // 【B1-Layer2】中层荧光（中等模糊）
                        Image("homebutton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 230, height: 230)   // 【可调】（放大）
                            .blur(radius: 18)                  // 【可调】
                            .opacity(glowOpacity * 0.6)        // 【可调】
                            .scaleEffect(glowScale)
                        
                        // 【B1-Layer3】内层荧光（轻微模糊）
                        Image("homebutton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 210, height: 210)   // 【可调】（放大）
                            .blur(radius: 10)                  // 【可调】
                            .opacity(glowOpacity * 0.5)        // 【可调】
                            .scaleEffect(glowScale * 0.98)
                        
                        // 【B1-Layer4】主图片（清晰的心形按钮）
                        // frame: 心形按钮实际大小
                        // opacity: 心形按钮透明度（0.7 = 70%）
                        Image("homebutton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)   // 【可调】心形大小（从170放大到200）
                            .opacity(0.7)                      // 【可调】透明度 70%
                            .scaleEffect(buttonScale)
                            .shadow(color: Color.red.opacity(0.25), radius: 18, x: 0, y: 10)
                    }
                    .scaleEffect(isPressed ? 0.92 : 1.0)  // 按下时缩小效果
                }
                .frame(width: 260, height: 170)  // 【可调】按钮容器大小（高度从220减到170，减少上下间距）
                .offset(x: -20)  // 【新增】往左偏移20pt
                .onAppear {
                    startAnimations()
                }
                
                // ─────────────────────────────────────────────────────
                // 【区域 B2】右侧：心率信息显示
                // ─────────────────────────────────────────────────────
                if let record = lastRecord {
                    VStack(alignment: .trailing, spacing: 8) {
                        // 【B2-1】BPM 数值（超大字体）
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(record.bpm)")
                                .font(.system(size: 50, weight: .bold, design: .rounded))  // 【可调】数字大小
                                .foregroundColor(.black)
                            
                            Text("BPM")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))  // 【可调】
                                .foregroundColor(AppColors.primaryRed)
                        }
                        
                        // 【B2-2】时间显示
                        Text(timeAgo(from: record.timestamp))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                        
                        // 【B2-3】状态标签（Normal/Low/High）
                        HStack(spacing: 6) {
                            Circle()
                                .fill(statusColor(for: record.bpm))
                                .frame(width: 12, height: 12)
                            Text(statusText(for: record.bpm))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(statusColor(for: record.bpm))
                        }
                    }
                    .fixedSize(horizontal: true, vertical: false)  // 防止文本换行
                } else {
                    // 【B2-无数据】无记录时的占位显示
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("--")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.3))
                        
                        Text("BPM")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.primaryRed.opacity(0.5))
                        
                        Text("No readings yet")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.4))
                    }
                    .fixedSize(horizontal: true, vertical: false)  // 防止文本换行
                }
                
                Spacer(minLength: 0)  // 让右侧内容靠右对齐
            }
        }
        // ═══════════════════════════════════════════════════════════════
        // 【外层样式】无背景、无边框，直接显示在页面背景上
        // padding: 整体内边距（改小可让内容往左移）
        // ═══════════════════════════════════════════════════════════════
        .padding(.horizontal, 4)   // 【可调】水平内边距（改小往左移）
        .padding(.vertical, 4)     // 【可调】垂直内边距
        // 注意：已删除 .background(...) 去掉白色卡片背景和阴影
    }
    
    private func startAnimations() {
        // 统一脉动周期 1.5s
        let pulseDuration: Double = 1.5
        
        // 荧光透明度呼吸动画
        withAnimation(
            Animation.easeInOut(duration: pulseDuration)
                .repeatForever(autoreverses: true)
        ) {
            glowOpacity = 0.6
        }
        
        // 荧光大小呼吸动画
        withAnimation(
            Animation.easeInOut(duration: pulseDuration)
                .repeatForever(autoreverses: true)
        ) {
            glowScale = 1.08
        }
        
        // 按钮呼吸缩放
        withAnimation(
            Animation.easeInOut(duration: pulseDuration)
                .repeatForever(autoreverses: true)
        ) {
            buttonScale = 1.04
        }
    }
    
    // 根据 BPM 判断状态文字
    private func statusText(for bpm: Int) -> String {
        if bpm >= 60 && bpm <= 100 {
            return "Normal"
        } else if bpm < 60 {
            return "Low"
        } else if bpm <= 120 {
            return "Elevated"
        } else {
            return "High"
        }
    }
    
    // 根据 BPM 判断状态颜色
    private func statusColor(for bpm: Int) -> Color {
        if bpm >= 60 && bpm <= 100 {
            return Color.green
        } else if bpm < 60 {
            return Color.blue
        } else if bpm <= 120 {
            return Color.orange
        } else {
            return Color.red
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        else if interval < 3600 { return "\(Int(interval / 60)) min ago" }
        else if interval < 86400 { return "\(Int(interval / 3600)) hr ago" }
        else { return "\(Int(interval / 86400)) days ago" }
    }
}
