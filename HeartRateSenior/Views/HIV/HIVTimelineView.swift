//
//  HIVTimelineView.swift
//  HeartRateSenior
//
//  HIV Timeline - Window Period & When to Test (Section 5+6)
//

import SwiftUI

struct HIVTimelineView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var windowSection: HIVSection? {
        HIVEducationData.sections.first { $0.id == 5 }
    }
    
    private var whenToTestSection: HIVSection? {
        HIVEducationData.sections.first { $0.id == 6 }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Hero
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primaryRed.opacity(0.1))
                            .frame(width: 72, height: 72)
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 30))
                            .foregroundColor(AppColors.primaryRed)
                    }
                    
                    Text("Timeline & Testing")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text("Window period & when to get tested")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                // Section 5: Window Period
                if let section = windowSection {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(AppColors.primaryRed.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(AppColors.primaryRed)
                                )
                            
                            Text(section.title)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                        
                        Text(section.content)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                        
                        // Window Period test types
                        if let windowPeriod = section.windowPeriod {
                            VStack(spacing: 10) {
                                ForEach(windowPeriod.testTypes) { testType in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(testType.name)
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                                            Text(testType.detectableAfter)
                                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(AppColors.primaryRed.opacity(0.6))
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(AppColors.primaryRed.opacity(0.04))
                                    )
                                }
                            }
                            
                            // Tip
                            HStack(spacing: 10) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.yellow)
                                Text(windowPeriod.tip)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.yellow.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Timing Guidance
                        if let guidance = section.timingGuidance {
                            VStack(spacing: 10) {
                                ForEach(guidance) { item in
                                    HStack(spacing: 12) {
                                        Image(systemName: item.icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(colorForStatus(item.color))
                                            .frame(width: 36, height: 36)
                                            .background(colorForStatus(item.color).opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.daysRange)
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                                            Text(item.guidance)
                                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                }
                
                // Section 6: When to Test
                if let section = whenToTestSection {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(AppColors.primaryRed.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "calendar.badge.checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColors.primaryRed)
                                )
                            
                            Text(section.title)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                        
                        Text(section.content)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                        
                        if let whenToTest = section.whenToTest {
                            VStack(spacing: 10) {
                                ForEach(whenToTest, id: \.self) { item in
                                    HStack(spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.green)
                                        
                                        Text(item)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                                        
                                        Spacer()
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.green.opacity(0.04))
                                    )
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                }
                
                // Encouragement card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primaryRed)
                        Text("Remember")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    }
                    
                    Text("With modern treatment, people living with HIV can lead long, healthy lives. Early detection and consistent treatment are key to managing HIV effectively.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppColors.primaryRed.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(AppColors.primaryRed.opacity(0.15), lineWidth: 1)
                        )
                )
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(HIVMeshBackground())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private func colorForStatus(_ colorName: String) -> Color {
        switch colorName {
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        default: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        HIVTimelineView()
    }
}
