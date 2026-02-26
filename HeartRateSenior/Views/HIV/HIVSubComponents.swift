//
//  HIVSubComponents.swift
//  HeartRateSenior
//
//  Shared sub-components for HIV detail views
//

import SwiftUI

// MARK: - Transmission View (used in HIVEducationView)
struct HIVTransmissionView: View {
    let info: HIVTransmissionInfo
    
    var body: some View {
        VStack(spacing: 14) {
            // Can be transmitted
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    Text(hivRawText("Can be transmitted:"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                }
                
                ForEach(info.transmittedThrough, id: \.self) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(AppColors.primaryRed)
                            .frame(width: 5, height: 5)
                        Text(item)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.orange.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // NOT transmitted
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                    Text(hivRawText("NOT transmitted:"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                }
                
                ForEach(info.notTransmittedThrough, id: \.self) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 5, height: 5)
                        Text(item)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.green.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.green.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Symptoms View (used in HIVSymptomsDetailView)
struct HIVSymptomsView: View {
    let symptoms: [String]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            ForEach(symptoms, id: \.self) { symptom in
                HStack(spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(AppColors.primaryRed)
                    Text(symptom)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.primaryRed.opacity(0.04))
                )
            }
        }
    }
}

// MARK: - Important Note View (used in HIVSymptomsDetailView)
struct HIVImportantNoteView: View {
    let note: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryRed)
            
            Text(note)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.primaryRed.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.primaryRed.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppColors.primaryRed.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// MARK: - Testing Info View (used in HIVTestingGuideView)
struct HIVTestingInfoView: View {
    let info: HIVTestingInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(hivRawText("Tests detect:"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            
            ForEach(info.detects, id: \.self) { item in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                    Text(item)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            
            if !info.note.isEmpty {
                Text(info.note)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.primaryRed)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.green.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.green.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Testing Methods View (used in HIVTestingGuideView)
struct HIVTestingMethodsView: View {
    let methods: [HIVTestingMethod]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(methods) { method in
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: method.icon)
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryRed)
                            .frame(width: 40, height: 40)
                            .background(AppColors.primaryRed.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(method.title)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                            Text(method.description)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    // Pros
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(method.pros, id: \.self) { pro in
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                                Text(pro)
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    }
                    
                    // Cons
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(method.cons, id: \.self) { con in
                            HStack(spacing: 8) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)
                                Text(con)
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
            }
        }
    }
}

// MARK: - Test Expectations View (used in HIVTestingGuideView)
struct HIVTestExpectationsView: View {
    let expectations: HIVTestExpectation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(expectations.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            
            // Items
            ForEach(expectations.items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                        .padding(.top, 2)
                    Text(item)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            
            // Reminders
            if !expectations.reminders.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                ForEach(expectations.reminders, id: \.self) { reminder in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.primaryRed)
                            .padding(.top, 2)
                        Text(reminder)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        Spacer()
                    }
                }
            }
            
            // Tip card
            if !expectations.tipCard.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.yellow)
                    Text(expectations.tipCard)
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
        }
    }
}
