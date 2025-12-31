//
//  PulseBarChartView.swift
//  HeartRateSenior
//
//  脉冲波动图 - 心跳触发从右向左的流动波浪（柔和版）
//

import SwiftUI

struct PulseBarChartView: View {
    let heartbeatTick: Int
    
    private let dotCount = 8
    private let dotSpacing: CGFloat = 14
    private let minDotSize: CGFloat = 6
    private let maxDotHeight: CGFloat = 28       // 稍矮一点
    private let maxDotWidth: CGFloat = 8
    private let waveDelay: Double = 0.08         // 稍慢一点
    
    // 每个点的缩放状态
    @State private var dotScales: [CGFloat] = Array(repeating: 0, count: 8)
    
    var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<dotCount, id: \.self) { index in
                // 从小圆点变成竖条
                RoundedRectangle(cornerRadius: minDotSize / 2)
                    .fill(AppColors.primaryRed.opacity(0.5 + 0.5 * Double(dotScales[index])))
                    .frame(
                        width: minDotSize + (maxDotWidth - minDotSize) * dotScales[index],
                        height: minDotSize + (maxDotHeight - minDotSize) * dotScales[index]
                    )
            }
        }
        .frame(height: maxDotHeight)
        .onChange(of: heartbeatTick) { _, _ in
            triggerWave()
        }
    }
    
    private func triggerWave() {
        // 从右向左依次触发波浪（索引7→0）
        for i in 0..<dotCount {
            let reverseIndex = dotCount - 1 - i  // 7, 6, 5, 4, 3, 2, 1, 0
            let delay = Double(i) * waveDelay
            
            // 放大 - 更柔和的曲线
            withAnimation(.easeInOut(duration: 0.12).delay(delay)) {
                dotScales[reverseIndex] = 1.0
            }
            
            // 缩小 - 更长的回落时间
            withAnimation(.easeInOut(duration: 0.35).delay(delay + 0.15)) {
                dotScales[reverseIndex] = 0
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        // 静态
        PulseBarChartView(heartbeatTick: 0)
        
        // 动态模拟
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            PulseBarChartView(heartbeatTick: Int(timeline.date.timeIntervalSince1970))
        }
    }
    .padding()
    .background(AppColors.background)
}
