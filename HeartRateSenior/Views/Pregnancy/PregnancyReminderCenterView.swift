//
//  PregnancyReminderCenterView.swift
//  HeartRateSenior
//
//  Pregnancy-related reminder center
//

import SwiftUI

struct PregnancyReminderCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reminders: [PregnancyReminder] = []
    @State private var showAddReminder = false
    
    private let primaryColor = Color(red: 0.85, green: 0.45, blue: 0.65)
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Reminder Center")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showAddReminder = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(primaryColor)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                if reminders.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(reminders) { reminder in
                                ReminderCard(reminder: reminder) {
                                    toggleReminder(reminder)
                                } onDelete: {
                                    deleteReminder(reminder)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showAddReminder) {
            AddPregnancyReminderView { reminder in
                reminders.append(reminder)
            }
        }
        .onAppear {
            loadSampleReminders()
        }
    }
    
    private func toggleReminder(_ reminder: PregnancyReminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isEnabled.toggle()
            HapticManager.shared.selectionChanged()
        }
    }
    
    private func deleteReminder(_ reminder: PregnancyReminder) {
        reminders.removeAll { $0.id == reminder.id }
        HapticManager.shared.lightImpact()
    }
    
    private func loadSampleReminders() {
        reminders = [
            PregnancyReminder(
                title: "Take Pregnancy Test",
                time: Date().addingTimeInterval(86400),
                type: .test,
                isEnabled: true
            ),
            PregnancyReminder(
                title: "Track Period",
                time: Date().addingTimeInterval(172800),
                type: .period,
                isEnabled: true
            )
        ]
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    private let primaryColor = Color(red: 0.85, green: 0.45, blue: 0.65)
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(primaryColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 48))
                    .foregroundColor(primaryColor.opacity(0.5))
            }
            
            Text("No Reminders Yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text("Tap + to add your first reminder")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Reminder Card
struct ReminderCard: View {
    let reminder: PregnancyReminder
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    private let primaryColor = Color(red: 0.85, green: 0.45, blue: 0.65)
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(reminder.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: reminder.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(reminder.type.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(reminder.time, style: .time)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Add Reminder View
struct AddPregnancyReminderView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (PregnancyReminder) -> Void
    
    @State private var title = ""
    @State private var selectedType: PregnancyReminderType = .test
    @State private var selectedTime = Date()
    
    private let primaryColor = Color(red: 0.85, green: 0.45, blue: 0.65)
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder Details") {
                    TextField("Title", text: $title)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(PregnancyReminderType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    
                    DatePicker("Time", selection: $selectedTime)
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let reminder = PregnancyReminder(
                            title: title.isEmpty ? "Reminder" : title,
                            time: selectedTime,
                            type: selectedType,
                            isEnabled: true
                        )
                        onAdd(reminder)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Models
struct PregnancyReminder: Identifiable {
    let id = UUID()
    let title: String
    let time: Date
    let type: PregnancyReminderType
    var isEnabled: Bool
}

enum PregnancyReminderType: String, CaseIterable {
    case test = "Test"
    case period = "Period"
    case appointment = "Appointment"
    case medication = "Medication"
    
    var icon: String {
        switch self {
        case .test: return "testtube.2"
        case .period: return "calendar"
        case .appointment: return "stethoscope"
        case .medication: return "pills"
        }
    }
    
    var color: Color {
        switch self {
        case .test: return Color(red: 1.0, green: 0.6, blue: 0.7)
        case .period: return Color(red: 0.95, green: 0.65, blue: 0.75)
        case .appointment: return Color(red: 0.9, green: 0.5, blue: 0.7)
        case .medication: return Color(red: 0.85, green: 0.45, blue: 0.65)
        }
    }
}

#Preview {
    NavigationStack {
        PregnancyReminderCenterView()
    }
}
