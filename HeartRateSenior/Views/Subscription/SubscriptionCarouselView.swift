//
//  SubscriptionCarouselView.swift
//  HeartRateSenior
//
//  Feature carousel for subscription paywall
//

import SwiftUI
import Combine

struct SubscriptionCarouselView: View {
    let items: [CarouselItem]
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $currentIndex) {
                ForEach(0..<items.count, id: \.self) { index in
                    VStack(spacing: 16) {
                        // SF Symbol Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: PaywallConfiguration.gradientColors.map { $0.opacity(0.15) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: items[index].systemIcon)
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: PaywallConfiguration.gradientColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text(items[index].title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(items[index].subtitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 220)
            
            // Custom Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<items.count, id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? PaywallConfiguration.primaryColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(currentIndex == index ? 1.2 : 1.0)
                        .animation(.spring(), value: currentIndex)
                }
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex = (currentIndex + 1) % items.count
            }
        }
    }
}

#Preview {
    SubscriptionCarouselView(items: PaywallConfiguration.carouselItems)
        .padding()
        .background(AppColors.background)
}
