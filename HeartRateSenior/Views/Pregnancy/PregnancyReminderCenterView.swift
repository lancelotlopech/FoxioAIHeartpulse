//
//  PregnancyReminderCenterView.swift
//  HeartRateSenior
//
//  Pregnancy reminder center — Minimalist redesign
//

import SwiftUI

struct PregnancyReminderCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reminders: [PregnancyReminder] = []
    @State private var showAddReminder = false
    
    private let primaryColor = Color(red: 0.93, green: 0.17, blue: 0.36)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1a1a1a"))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(hex: "f8f6f6")))
                    }
                    
                    Spacer()
                    
                    Text("Reminders")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Spacer()
                    
                    Button {
                        HapticManager.shared.lightImpact()
                        showAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(primaryColor)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(primaryColor.opacity(0.1)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                if reminders.isEmpty {
                    MinimalEmptyStateView(primaryColor: primaryColor)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(reminders) { reminder in
                                MinimalReminderCard(
                                    reminder: reminder,
                                    primaryColor: primaryColor,
                                    onToggle: { toggleReminder(reminder) },
                                    onDelete: { deleteReminder(reminder) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddReminder) {
            MinimalAddReminderView(primaryColor: primaryColor) { reminder in
                withAnimation(.easeInOut(duration: 0.25)) {
                    reminders.append(reminder)
                }
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
        withAnimation(.easeInOut(duration: 0.25)) {
            reminders.removeAll { $0.id == reminder.id }
        }
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
private struct MinimalEmptyStateView: View {
    let primaryColor: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "bell.slash")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(Color(hex: "cccccc"))
            
            Text("No Reminders Yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "1a1a1a"))
            
            Text("Tap + to add your first reminder")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "999999"))
            
            Spacer()
        }
    }
}

// MARK: - Reminder Card with left indicator bar
private struct MinimalReminderCard: View {
    let reminder: PregnancyReminder
    let primaryColor: Color
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left colored indicator bar
            RoundedRectangle(cornerRadius: 2)
                .fill(reminder.type.accentColor)
                .frame(width: 4)
                .padding(.vertical, 12)
            
            HStack(spacing: 14) {
                // Icon
                Image(systemName: reminder.type.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(reminder.type.accentColor)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(reminder.type.accentColor.opacity(0.1))
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 3) {
                    Text(reminder.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "bbbbbb"))
                        
                        Text(reminder.time, style: .time)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "999999"))
                    }
                }
                
                Spacer()
                
                // Toggle with red tint
                Toggle("", isOn: Binding(
                    get: { reminder.isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .tint(primaryColor)
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(hex: "e8e6e6"), lineWidth: 1)
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

// MARK: - Add Reminder Sheet
private struct MinimalAddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    let primaryColor: Color
    let onAdd: (PregnancyReminder) -> Void
    
    @State private var title = ""
    @State private var selectedType: PregnancyReminderType = .test
    @State private var selectedTime = Date()
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "dddddd"))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)
                
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "999999"))
                    }
                    
                    Spacer()
                    
                    Text("New Reminder")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    
                    Spacer()
                    
                    Button {
                        let reminder = PregnancyReminder(
                            title: title.isEmpty ? "Reminder" : title,
                            time: selectedTime,
                            type: selectedType,
                            isEnabled: true
                        )
                        onAdd(reminder)
                        dismiss()
                    } label: {
                        Text("Add")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(primaryColor)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "999999"))
                                .tracking(0.5)
                            
                            TextField("e.g. Take pregnancy test", text: $title)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "1a1a1a"))
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "f8f6f6"))
                                )
                        }
                        
                        // Type selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Type")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "999999"))
                                .tracking(0.5)
                            
                            HStack(spacing: 8) {
                                ForEach(PregnancyReminderType.allCases, id: \.self) { type in
                                    Button {
                                        HapticManager.shared.selectionChanged()
                                        selectedType = type
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: type.icon)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(
                                                    selectedType == type ? .white : type.accentColor
                                                )
                                                .frame(width: 40, height: 40)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(
                                                            selectedType == type
                                                            ? type.accentColor
                                                            : type.accentColor.opacity(0.1)
                                                        )
                                                )
                                            
                                            Text(type.rawValue)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(
                                                    selectedType == type
                                                    ? Color(hex: "1a1a1a")
                                                    : Color(hex: "999999")
                                                )
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                        
                        // Time picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "999999"))
                                .tracking(0.5)
                            
                            DatePicker("", selection: $selectedTime)
                                .labelsHidden()
                                .datePickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .presentationDetents([.medium, .large])
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
    case appointment = "Appt"
    case medication = "Meds"
    
    var icon: String {
        switch self {
        case .test: return "testtube.2"
        case .period: return "calendar"
        case .appointment: return "stethoscope"
        case .medication: return "pills"
        }
    }
    
    var accentColor: Color {
        let primary = Color(red: 0.93, green: 0.17, blue: 0.36)
        switch self {
        case .test: return primary
        case .period: return Color(red: 0.95, green: 0.45, blue: 0.25)
        case .appointment: return Color(red: 0.35, green: 0.65, blue: 0.95)
        case .medication: return Color(red: 0.45, green: 0.78, blue: 0.45)
        }
    }
}

#Preview {
    PregnancyReminderCenterView()
}
