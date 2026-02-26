//
//  PregnancyReminderCenterView.swift
//  HeartRateSenior
//
//  Pregnancy reminders (uses shared Reminder + local notifications).
//

import SwiftUI
import SwiftData
import UIKit

struct PregnancyReminderCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allReminders: [Reminder]
    
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var reminderManager = ReminderManager.shared
    
    @State private var showingAddReminder = false
    @State private var selectedReminder: Reminder?
    @State private var showingSubscription = false
    @State private var showingPermissionAlert = false
    
    private let primaryColor = Color(red: 0.93, green: 0.17, blue: 0.36)
    
    private var pregnancyTestReminders: [Reminder] {
        allReminders
            .filter { $0.reminderTypeRaw == ReminderType.pregnancyTest.rawValue }
            .sorted(by: { $0.time < $1.time })
    }
    
    private var enabledPregnancyTestReminderCount: Int {
        pregnancyTestReminders.filter { $0.isEnabled }.count
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                if pregnancyTestReminders.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(pregnancyTestReminders) { reminder in
                                PregnancyReminderCard(
                                    reminder: reminder,
                                    primaryColor: primaryColor,
                                    onToggle: { newValue in
                                        if newValue,
                                           !subscriptionManager.isPremium,
                                           !reminder.isEnabled,
                                           enabledPregnancyTestReminderCount >= 1 {
                                            showingSubscription = true
                                            return
                                        }
                                        reminder.isEnabled = newValue
                                        Task { @MainActor in
                                            await reminderManager.scheduleNotification(for: reminder)
                                        }
                                    },
                                    onDelete: {
                                        deleteReminder(reminder)
                                    }
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedReminder = reminder
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    }
                }
                
                if !subscriptionManager.isPremium {
                    Text(pregnancyRawText("Free plan: 1 enabled pregnancy test reminder. Upgrade for unlimited."))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "999999"))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(initialType: .pregnancyTest, initialTitle: pregnancyRawText("Pregnancy Test"))
        }
        .sheet(item: $selectedReminder) { reminder in
            AddReminderView(editingReminder: reminder)
        }
        .fullScreenCover(isPresented: $showingSubscription) {
            SubscriptionView(isPresented: $showingSubscription)
        }
        .alert(pregnancyText(.enableNotificationsTitle), isPresented: $showingPermissionAlert) {
            Button(pregnancyText(.openSettings)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(pregnancyText(.cancel), role: .cancel) {}
        } message: {
            Text(pregnancyText(.enableNotificationsMessage))
        }
        .onAppear {
            Task { @MainActor in
                await reminderManager.checkAuthorizationStatus()
            }
        }
    }
    
    private var header: some View {
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
            
            Text(pregnancyRawText("Reminders"))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(hex: "1a1a1a"))
            
            Spacer()
            
            Button {
                HapticManager.shared.lightImpact()
                checkPermissionAndAdd()
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
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "bell.slash")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(Color(hex: "cccccc"))
            
            Text(pregnancyRawText("No Reminders Yet"))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "1a1a1a"))
            
            Text(pregnancyRawText("Tap + to add your first pregnancy test reminder"))
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "999999"))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private func checkPermissionAndAdd() {
        if !subscriptionManager.isPremium, enabledPregnancyTestReminderCount >= 1 {
            showingSubscription = true
            return
        }
        
        Task { @MainActor in
            let status = reminderManager.authorizationStatus
            if status == .notDetermined {
                let granted = await reminderManager.requestAuthorization()
                if granted {
                    showingAddReminder = true
                }
            } else if status == .denied {
                showingPermissionAlert = true
            } else {
                showingAddReminder = true
            }
        }
    }
    
    private func deleteReminder(_ reminder: Reminder) {
        Task { @MainActor in
            await reminderManager.cancelNotification(for: reminder)
        }
        modelContext.delete(reminder)
        HapticManager.shared.lightImpact()
    }
}

private struct PregnancyReminderCard: View {
    let reminder: Reminder
    let primaryColor: Color
    let onToggle: (Bool) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.pink)
                .frame(width: 4)
                .padding(.vertical, 12)
            
            HStack(spacing: 14) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.pink)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.pink.opacity(0.12))
                    )
                
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
                        
                        Text(reminder.repeatDescription)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "999999"))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { reminder.isEnabled },
                    set: { newValue in onToggle(newValue) }
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
                Label(pregnancyRawText("Delete"), systemImage: "trash")
            }
        }
    }
}
