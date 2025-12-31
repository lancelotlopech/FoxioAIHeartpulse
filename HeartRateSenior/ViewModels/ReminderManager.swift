//
//  ReminderManager.swift
//  HeartRateSenior
//
//  Manages local notifications for reminders
//

import Foundation
import UserNotifications
import SwiftUI

@MainActor
class ReminderManager: ObservableObject {
    static let shared = ReminderManager()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
            }
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleNotification(for reminder: Reminder) async {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        // Remove existing notifications for this reminder
        await cancelNotification(for: reminder)
        
        guard reminder.isEnabled else { return }
        
        let content = createNotificationContent(for: reminder)
        
        switch reminder.repeatFrequency {
        case .once:
            await scheduleOnceNotification(reminder: reminder, content: content)
        case .daily:
            await scheduleDailyNotification(reminder: reminder, content: content)
        case .weekdays:
            await scheduleWeekdayNotifications(reminder: reminder, content: content)
        case .weekends:
            await scheduleWeekendNotifications(reminder: reminder, content: content)
        case .custom:
            await scheduleCustomNotifications(reminder: reminder, content: content)
        }
    }
    
    private func createNotificationContent(for reminder: Reminder) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        
        switch reminder.reminderType {
        case .heartRate:
            content.body = "Time to measure your heart rate. Tap to start."
            content.categoryIdentifier = "HEART_RATE_REMINDER"
        case .bloodPressure:
            content.body = "Time to record your blood pressure."
            content.categoryIdentifier = "BLOOD_PRESSURE_REMINDER"
        case .bloodGlucose:
            content.body = "Time to check your blood glucose level."
            content.categoryIdentifier = "BLOOD_GLUCOSE_REMINDER"
        case .medication:
            if let medName = reminder.medicationName, let dosage = reminder.medicationDosage {
                content.body = "Take \(medName) - \(dosage)"
            } else if let medName = reminder.medicationName {
                content.body = "Time to take \(medName)"
            } else {
                content.body = "Time to take your medication."
            }
            content.categoryIdentifier = "MEDICATION_REMINDER"
        }
        
        if let notes = reminder.notes, !notes.isEmpty {
            content.body += "\n\(notes)"
        }
        
        content.sound = .default
        content.badge = 1
        
        return content
    }
    
    private func scheduleOnceNotification(reminder: Reminder, content: UNNotificationContent) async {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: reminder.notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("Scheduled one-time notification for \(reminder.title)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    private func scheduleDailyNotification(reminder: Reminder, content: UNNotificationContent) async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: reminder.notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("Scheduled daily notification for \(reminder.title)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    private func scheduleWeekdayNotifications(reminder: Reminder, content: UNNotificationContent) async {
        let weekdays = [2, 3, 4, 5, 6] // Monday to Friday
        await scheduleNotificationsForDays(reminder: reminder, content: content, days: weekdays)
    }
    
    private func scheduleWeekendNotifications(reminder: Reminder, content: UNNotificationContent) async {
        let weekends = [1, 7] // Sunday and Saturday
        await scheduleNotificationsForDays(reminder: reminder, content: content, days: weekends)
    }
    
    private func scheduleCustomNotifications(reminder: Reminder, content: UNNotificationContent) async {
        let days = reminder.customDays.selectedDays
        await scheduleNotificationsForDays(reminder: reminder, content: content, days: days)
    }
    
    private func scheduleNotificationsForDays(reminder: Reminder, content: UNNotificationContent, days: [Int]) async {
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
        
        for day in days {
            var components = DateComponents()
            components.weekday = day
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let identifier = "\(reminder.notificationIdentifier)_day\(day)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            do {
                try await notificationCenter.add(request)
                print("Scheduled notification for \(reminder.title) on day \(day)")
            } catch {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelNotification(for reminder: Reminder) async {
        // Cancel the main notification
        var identifiers = [reminder.notificationIdentifier]
        
        // Cancel day-specific notifications
        for day in 1...7 {
            identifiers.append("\(reminder.notificationIdentifier)_day\(day)")
        }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled notifications for \(reminder.title)")
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("Cancelled all notifications")
    }
    
    // MARK: - Pending Notifications
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    // MARK: - Badge Management
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    // MARK: - Notification Categories
    
    func setupNotificationCategories() {
        let measureAction = UNNotificationAction(
            identifier: "MEASURE_ACTION",
            title: "Measure Now",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 10 min",
            options: []
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive]
        )
        
        let heartRateCategory = UNNotificationCategory(
            identifier: "HEART_RATE_REMINDER",
            actions: [measureAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let bloodPressureCategory = UNNotificationCategory(
            identifier: "BLOOD_PRESSURE_REMINDER",
            actions: [measureAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let bloodGlucoseCategory = UNNotificationCategory(
            identifier: "BLOOD_GLUCOSE_REMINDER",
            actions: [measureAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let takenAction = UNNotificationAction(
            identifier: "TAKEN_ACTION",
            title: "Mark as Taken",
            options: []
        )
        
        let medicationCategory = UNNotificationCategory(
            identifier: "MEDICATION_REMINDER",
            actions: [takenAction, snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([
            heartRateCategory,
            bloodPressureCategory,
            bloodGlucoseCategory,
            medicationCategory
        ])
    }
}
