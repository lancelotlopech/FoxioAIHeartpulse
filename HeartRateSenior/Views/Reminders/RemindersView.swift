//
//  RemindersView.swift
//  HeartRateSenior
//
//  View for managing health reminders
//

import SwiftUI
import SwiftData

struct RemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.time) private var reminders: [Reminder]
    @StateObject private var reminderManager = ReminderManager.shared
    
    @State private var showingAddReminder = false
    @State private var selectedReminder: Reminder?
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                if reminders.isEmpty {
                    emptyStateView
                } else {
                    remindersList
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        checkPermissionAndAdd()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.primaryRed)
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
            .sheet(item: $selectedReminder) { reminder in
                AddReminderView(editingReminder: reminder)
            }
            .alert("Enable Notifications", isPresented: $showingPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable notifications in Settings to receive reminders.")
            }
            .onAppear {
                Task {
                    await reminderManager.checkAuthorizationStatus()
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge")
                .font(.system(size: 80))
                .foregroundColor(DesignSystem.Colors.primaryRed.opacity(0.5))
            
            Text("No Reminders")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("Set up reminders to help you\ntrack your health regularly")
                .font(.system(size: 18, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                checkPermissionAndAdd()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Reminder")
                }
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(DesignSystem.Colors.primaryRed)
                .cornerRadius(16)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    // MARK: - Reminders List
    
    private var remindersList: some View {
        List {
            // Group by reminder type
            ForEach(ReminderType.allCases, id: \.self) { type in
                let typeReminders = reminders.filter { $0.reminderType == type }
                if !typeReminders.isEmpty {
                    Section {
                        ForEach(typeReminders) { reminder in
                            ReminderRow(reminder: reminder)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedReminder = reminder
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteReminder(reminder)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        HStack {
                            Image(systemName: type.icon)
                                .foregroundColor(colorForType(type))
                            Text(type.rawValue)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Helper Methods
    
    private func checkPermissionAndAdd() {
        Task {
            if reminderManager.authorizationStatus == .notDetermined {
                let granted = await reminderManager.requestAuthorization()
                if granted {
                    await MainActor.run {
                        showingAddReminder = true
                    }
                }
            } else if reminderManager.authorizationStatus == .denied {
                await MainActor.run {
                    showingPermissionAlert = true
                }
            } else {
                await MainActor.run {
                    showingAddReminder = true
                }
            }
        }
    }
    
    private func deleteReminder(_ reminder: Reminder) {
        Task {
            await reminderManager.cancelNotification(for: reminder)
        }
        modelContext.delete(reminder)
        HapticManager.shared.mediumImpact()
    }
    
    private func colorForType(_ type: ReminderType) -> Color {
        switch type {
        case .heartRate: return DesignSystem.Colors.primaryRed
        case .bloodPressure: return .blue
        case .bloodGlucose: return .purple
        case .medication: return .green
        case .pregnancyTest: return .pink
        }
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var reminderManager = ReminderManager.shared
    let reminder: Reminder
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(colorForType(reminder.reminderType).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: reminder.reminderType.icon)
                    .font(.system(size: 22))
                    .foregroundColor(colorForType(reminder.reminderType))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                HStack(spacing: 8) {
                    Text(reminder.timeString)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(reminder.isEnabled ? DesignSystem.Colors.textPrimary : .secondary)
                    
                    Text(reminder.repeatDescription)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                if reminder.reminderType == .medication,
                   let medName = reminder.medicationName {
                    Text(medName)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { newValue in
                    reminder.isEnabled = newValue
                    Task {
                        await reminderManager.scheduleNotification(for: reminder)
                    }
                    HapticManager.shared.lightImpact()
                }
            ))
            .labelsHidden()
            .tint(DesignSystem.Colors.primaryRed)
        }
        .padding(.vertical, 8)
    }
    
    private func colorForType(_ type: ReminderType) -> Color {
        switch type {
        case .heartRate: return DesignSystem.Colors.primaryRed
        case .bloodPressure: return .blue
        case .bloodGlucose: return .purple
        case .medication: return .green
        case .pregnancyTest: return .pink
        }
    }
}

#Preview {
    RemindersView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
