//
//  HIVSymptomsDetailView.swift
//  HeartRateSenior
//
//  HIV Symptoms - Identify early signs (Section 3)
//

import SwiftUI

struct HIVSymptomsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var section: HIVSection? {
        HIVEducationData.sections.first { $0.id == 3 }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                heroSection
                contentSection
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(HIVMeshBackground())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }
    
    private var backButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "arrow.left")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryRed.opacity(0.1))
                    .frame(width: 72, height: 72)
                Image(systemName: "stethoscope")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.primaryRed)
            }
            
            Text("Symptoms & Signs")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            
            Text("Recognize early indicators")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var contentSection: some View {
        if let section = section {
            mainCard(section: section)
            infoCard
        }
    }
    
    private func mainCard(section: HIVSection) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(section.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            
            Text(section.content)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .lineSpacing(4)
            
            if let symptoms = section.symptoms {
                HIVSymptomsView(symptoms: symptoms)
            }
            
            if let note = section.importantNote {
                HIVImportantNoteView(note: note)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
                Text("Key Takeaway")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            }
            
            Text("Many people with HIV don't show symptoms for years. The only way to know your status is through testing. Early detection leads to better outcomes.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.yellow.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        HIVSymptomsDetailView()
    }
}
