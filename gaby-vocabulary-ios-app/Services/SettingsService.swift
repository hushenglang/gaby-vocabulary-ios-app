import Foundation

@Observable
final class SettingsService {
    static let shared = SettingsService()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let dailyNewWords = "daily_new_words"
        static let reminders = "study_reminders"
        // Legacy single-reminder keys for migration
        static let legacyReminderEnabled = "reminder_enabled"
        static let legacyReminderHour = "reminder_hour"
        static let legacyReminderMinute = "reminder_minute"
    }

    var dailyNewWords: Int {
        didSet { defaults.set(dailyNewWords, forKey: Keys.dailyNewWords) }
    }

    var reminders: [StudyReminder] {
        didSet { persistReminders() }
    }

    private func persistReminders() {
        if let data = try? JSONEncoder().encode(reminders) {
            defaults.set(data, forKey: Keys.reminders)
        }
    }

    private init() {
        self.dailyNewWords = defaults.object(forKey: Keys.dailyNewWords) as? Int ?? 10
        self.reminders = Self.loadReminders(from: UserDefaults.standard)
    }

    private static func loadReminders(from defaults: UserDefaults) -> [StudyReminder] {
        if let data = defaults.data(forKey: Keys.reminders),
           let decoded = try? JSONDecoder().decode([StudyReminder].self, from: data) {
            return decoded
        }

        // Migrate from legacy single-reminder format
        if defaults.object(forKey: Keys.legacyReminderHour) != nil {
            let reminder = StudyReminder(
                hour: defaults.object(forKey: Keys.legacyReminderHour) as? Int ?? 9,
                minute: defaults.object(forKey: Keys.legacyReminderMinute) as? Int ?? 0,
                isEnabled: defaults.bool(forKey: Keys.legacyReminderEnabled)
            )
            defaults.removeObject(forKey: Keys.legacyReminderEnabled)
            defaults.removeObject(forKey: Keys.legacyReminderHour)
            defaults.removeObject(forKey: Keys.legacyReminderMinute)
            if let data = try? JSONEncoder().encode([reminder]) {
                defaults.set(data, forKey: Keys.reminders)
            }
            return [reminder]
        }

        return []
    }
}
