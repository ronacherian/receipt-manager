//
//  NotificationManager.swift
//  receipt manager
//
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// Requests user authorization for alert, sound, and badge notifications.
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Schedules return deadline reminder notifications (3 days and 1 day before return date) at 9:00 AM.
    func scheduleReturnReminders(for receipt: Receipt) {
        cancelReminders(for: receipt)

        guard let returnByDate = receipt.returnByDate, !receipt.isReturnCompleted else {
            return
        }

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            if settings.authorizationStatus == .notDetermined {
                Task {
                    let granted = await self.requestAuthorization()
                    if granted {
                        self.scheduleReminders(receipt: receipt, returnByDate: returnByDate)
                    }
                }
            } else if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                self.scheduleReminders(receipt: receipt, returnByDate: returnByDate)
            }
        }
    }

    private func scheduleReminders(receipt: Receipt, returnByDate: Date) {
        let center = UNUserNotificationCenter.current()
        let store = receipt.storeName.isEmpty ? "Receipt" : receipt.storeName

        // 3 days prior reminder
        if let threeDaysPrior = Calendar.current.date(byAdding: .day, value: -3, to: returnByDate),
           let targetDate = dateAt9AM(for: threeDaysPrior),
           targetDate > .now {
            let content = UNMutableNotificationContent()
            content.title = "Return Deadline in 3 Days"
            content.body = "\(store) purchase return deadline is approaching on \(formattedDate(returnByDate))."
            content.sound = .default

            let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: reminderIdentifier(receipt: receipt, daysPrior: 3),
                content: content,
                trigger: trigger
            )
            center.add(request)
        }

        // 1 day prior reminder
        if let oneDayPrior = Calendar.current.date(byAdding: .day, value: -1, to: returnByDate),
           let targetDate = dateAt9AM(for: oneDayPrior),
           targetDate > .now {
            let content = UNMutableNotificationContent()
            content.title = "Return Deadline Tomorrow"
            content.body = "\(store) purchase return deadline is tomorrow!"
            content.sound = .default

            let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: reminderIdentifier(receipt: receipt, daysPrior: 1),
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    /// Cancels any scheduled reminders for the specified receipt.
    func cancelReminders(for receipt: Receipt) {
        let center = UNUserNotificationCenter.current()
        let identifiers = [
            reminderIdentifier(receipt: receipt, daysPrior: 3),
            reminderIdentifier(receipt: receipt, daysPrior: 1)
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func reminderIdentifier(receipt: Receipt, daysPrior: Int) -> String {
        let timestamp = receipt.createdAt.timeIntervalSince1970
        let safeStore = receipt.storeName.replacingOccurrences(of: " ", with: "_")
        return "return_reminder_\(daysPrior)d_\(timestamp)_\(safeStore)"
    }

    private func dateAt9AM(for date: Date) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 9
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
