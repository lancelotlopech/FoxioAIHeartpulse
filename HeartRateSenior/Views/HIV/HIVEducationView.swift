//
//  HIVEducationView.swift
//  HeartRateSenior
//
//  HIV Education - What is HIV + Transmission (Section 1-2)
//

import SwiftUI

struct HIVEducationView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var sections: [HIVSection] {
        Array(HIVEducationData.sections.prefix(2))
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
                        Image(systemName: "book.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.primaryRed)
                    }
                    
                    Text("Understanding HIV")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text("Basics & transmission routes")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                // Section cards
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        HStack(spacing: 10) {
                            Circle()
                                .fill(AppColors.primaryRed.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text("\(section.id)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.primaryRed)
                                )
                            
                            Text(section.title)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                        
                        // Content
                        Text(section.content)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                        
                        // Key Points
                        if let keyPoints = section.keyPoints {
                            VStack(spacing: 10) {
                                ForEach(keyPoints) { point in
                                    HStack(spacing: 12) {
                                        Image(systemName: point.icon)
                                            .font(.system(size: 18))
                                            .foregroundColor(AppColors.primaryRed)
                                            .frame(width: 36, height: 36)
                                            .background(AppColors.primaryRed.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        Text(point.text)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        // Transmission Info
                        if let transmission = section.transmissionInfo {
                            HIVTransmissionView(info: transmission)
                        }
                        
                        // Disclaimer on first section
                        if section.id == 1 {
                            Text(HIVEducationData.disclaimer)
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                                .padding(.top, 8)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                }
                
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
}

#Preview {
    NavigationStack {
        HIVEducationView()
    }
}
