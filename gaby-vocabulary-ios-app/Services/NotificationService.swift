import Foundation
import UserNotifications

enum NotificationService {
    private static let center = UNUserNotificationCenter.current()
    private static let reminderIdentifier = "daily_study_reminder"

    static func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleDailyReminder(hour: Int, minute: Int) {
        cancelAll()

        let content = UNMutableNotificationContent()
        content.title = "Time to Study!"
        content.body = "You have vocabulary words waiting for review. Keep your streak going!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    static func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
