import Foundation
import UserNotifications

enum NotificationService {
    private static let center = UNUserNotificationCenter.current()

    static func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleReminder(_ reminder: StudyReminder) {
        cancelReminder(id: reminder.id)
        guard reminder.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Gaby公主，Time to Study!"
        content.body = "Gaby公主，你需要复习了。继续保持你的学习习惯哦！"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = reminder.hour
        dateComponents.minute = reminder.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    static func cancelReminder(id: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    static func syncAllReminders(_ reminders: [StudyReminder]) {
        center.removeAllPendingNotificationRequests()
        for reminder in reminders where reminder.isEnabled {
            scheduleReminder(reminder)
        }
    }

    static func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
