//
//  HIVTestingMethodDetailView.swift
//  HeartRateSenior
//
//  Testing Method Detail Sheet
//

import SwiftUI

struct HIVTestingMethodDetailView: View {
    let method: HIVTestingMethod
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: method.icon)
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(AppColors.primaryRed)
                        
                        Text(method.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(method.description)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                    
                    // Advantages
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Advantages")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        VStack(spacing: 10) {
                            ForEach(method.pros, id: \.self) { pro in
                                HStack(spacing: 10) {
                                    Text("•")
                                        .foregroundColor(.green)
                                    Text(pro)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    
                    // Considerations
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                            Text("Considerations")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        VStack(spacing: 10) {
                            ForEach(method.cons, id: \.self) { con in
                                HStack(spacing: 10) {
                                    Text("•")
                                        .foregroundColor(.orange)
                                    Text(con)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    
                    // Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Process")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        VStack(spacing: 10) {
                            ForEach(Array(method.details.enumerated()), id: \.offset) { index, detail in
                                HStack(spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(AppColors.primaryRed)
                                        .clipShape(Circle())
                                    
                                    Text(detail)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding(20)
            }
            .background(Color(red: 1.0, green: 0.96, blue: 0.96).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

#Preview {
    HIVTestingMethodDetailView(
        method: HIVEducationData.sections[6].testingMethods?.first ?? HIVTestingMethod(
            icon: "cross.case.fill",
            title: "Clinic Testing",
            description: "Most accurate",
            pros: ["Accurate"],
            cons: ["Requires appointment"],
            details: ["Step 1", "Step 2"]
        )
    )
}
