//
//  AddReminderView.swift
//  HeartRateSenior
//
//  View for adding or editing a reminder
//

import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var reminderManager = ReminderManager.shared
    
    // Editing mode
    var editingReminder: Reminder?
    var isEditing: Bool { editingReminder != nil }
    
    // Form state
    @State private var title: String = ""
    @State private var reminderType: ReminderType = .heartRate
    @State private var time: Date = Date()
    @State private var repeatFrequency: RepeatFrequency = .daily
    @State private var customDays: WeekDays = WeekDays()
    @State private var medicationName: String = ""
    @State private var medicationDosage: String = ""
    @State private var notes: String = ""
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Reminder Type Section
                Section {
                    reminderTypePicker
                } header: {
                    Text("Reminder Type")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Title Section
                Section {
                    TextField("Reminder Name", text: $title)
                        .font(.system(size: 18, design: .rounded))
                } header: {
                    Text("Title")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Time Section
                Section {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                        .font(.system(size: 18, design: .rounded))
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                } header: {
                    Text("Time")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Repeat Section
                Section {
                    repeatFrequencyPicker
                    
                    if repeatFrequency == .custom {
                        customDaysPicker
                    }
                } header: {
                    Text("Repeat")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Medication Details (only for medication type)
                if reminderType == .medication {
                    Section {
                        TextField("Medication Name", text: $medicationName)
                            .font(.system(size: 18, design: .rounded))
                        
                        TextField("Dosage (e.g., 10mg)", text: $medicationDosage)
                            .font(.system(size: 18, design: .rounded))
                    } header: {
                        Text("Medication Details")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                }
                
                // Notes Section
                Section {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .font(.system(size: 18, design: .rounded))
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                
                // Delete Button (only in edit mode)
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Reminder")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Reminder" : "New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 17, design: .rounded))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReminder()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.primaryRed)
                    .disabled(!isFormValid)
                }
            }
            .alert("Delete Reminder", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteReminder()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this reminder?")
            }
            .onAppear {
                loadExistingReminder()
            }
        }
    }
    
    // MARK: - Reminder Type Picker
    
    private var reminderTypePicker: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(ReminderType.allCases, id: \.self) { type in
                Button(action: {
                    reminderType = type
                    if title.isEmpty || ReminderType.allCases.map({ $0.rawValue }).contains(title) {
                        title = type.rawValue
                    }
                    HapticManager.shared.lightImpact()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: type.icon)
                            .font(.system(size: 28))
                        Text(type.rawValue)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(reminderType == type ? colorForType(type).opacity(0.15) : Color(UIColor.secondarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(reminderType == type ? colorForType(type) : Color.clear, lineWidth: 2)
                    )
                    .foregroundColor(reminderType == type ? colorForType(type) : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Repeat Frequency Picker
    
    private var repeatFrequencyPicker: some View {
        Picker("Repeat", selection: $repeatFrequency) {
            ForEach(RepeatFrequency.allCases, id: \.self) { frequency in
                Text(frequency.rawValue).tag(frequency)
            }
        }
        .pickerStyle(.menu)
        .font(.system(size: 18, design: .rounded))
    }
    
    // MARK: - Custom Days Picker
    
    private var customDaysPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Days")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                DayToggle(label: "S", isSelected: $customDays.sunday)
                DayToggle(label: "M", isSelected: $customDays.monday)
                DayToggle(label: "T", isSelected: $customDays.tuesday)
                DayToggle(label: "W", isSelected: $customDays.wednesday)
                DayToggle(label: "T", isSelected: $customDays.thursday)
                DayToggle(label: "F", isSelected: $customDays.friday)
                DayToggle(label: "S", isSelected: $customDays.saturday)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Helper Methods
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        (repeatFrequency != .custom || customDays.selectedDays.count > 0)
    }
    
    private func colorForType(_ type: ReminderType) -> Color {
        switch type {
        case .heartRate: return DesignSystem.Colors.primaryRed
        case .bloodPressure: return .blue
        case .bloodGlucose: return .purple
        case .medication: return .green
        }
    }
    
    private func loadExistingReminder() {
        guard let reminder = editingReminder else {
            title = reminderType.rawValue
            return
        }
        
        title = reminder.title
        reminderType = reminder.reminderType
        time = reminder.time
        repeatFrequency = reminder.repeatFrequency
        customDays = reminder.customDays
        medicationName = reminder.medicationName ?? ""
        medicationDosage = reminder.medicationDosage ?? ""
        notes = reminder.notes ?? ""
    }
    
    private func saveReminder() {
        if let existing = editingReminder {
            // Update existing reminder
            existing.title = title
            existing.reminderType = reminderType
            existing.time = time
            existing.repeatFrequency = repeatFrequency
            existing.customDays = customDays
            existing.medicationName = medicationName.isEmpty ? nil : medicationName
            existing.medicationDosage = medicationDosage.isEmpty ? nil : medicationDosage
            existing.notes = notes.isEmpty ? nil : notes
            
            Task {
                await reminderManager.scheduleNotification(for: existing)
            }
        } else {
            // Create new reminder
            let reminder = Reminder(
                title: title,
                reminderType: reminderType,
                time: time,
                repeatFrequency: repeatFrequency,
                customDays: customDays,
                medicationName: medicationName.isEmpty ? nil : medicationName,
                medicationDosage: medicationDosage.isEmpty ? nil : medicationDosage,
                notes: notes.isEmpty ? nil : notes
            )
            
            modelContext.insert(reminder)
            
            Task {
                await reminderManager.scheduleNotification(for: reminder)
            }
        }
        
        HapticManager.shared.success()
        dismiss()
    }
    
    private func deleteReminder() {
        guard let reminder = editingReminder else { return }
        
        Task {
            await reminderManager.cancelNotification(for: reminder)
        }
        
        modelContext.delete(reminder)
        HapticManager.shared.warning()
        dismiss()
    }
}

// MARK: - Day Toggle Button

struct DayToggle: View {
    let label: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            HapticManager.shared.lightImpact()
        }) {
            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isSelected ? DesignSystem.Colors.primaryRed : Color(UIColor.secondarySystemBackground))
                )
                .foregroundColor(isSelected ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddReminderView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
