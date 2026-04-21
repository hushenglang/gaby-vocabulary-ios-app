import Foundation

@Observable
final class SettingsService {
    static let shared = SettingsService()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let dailyNewWords = "daily_new_words"
        static let reminderEnabled = "reminder_enabled"
        static let reminderHour = "reminder_hour"
        static let reminderMinute = "reminder_minute"
    }

    var dailyNewWords: Int {
        get { defaults.object(forKey: Keys.dailyNewWords) as? Int ?? 10 }
        set { defaults.set(newValue, forKey: Keys.dailyNewWords) }
    }

    var reminderEnabled: Bool {
        get { defaults.bool(forKey: Keys.reminderEnabled) }
        set { defaults.set(newValue, forKey: Keys.reminderEnabled) }
    }

    var reminderHour: Int {
        get { defaults.object(forKey: Keys.reminderHour) as? Int ?? 9 }
        set { defaults.set(newValue, forKey: Keys.reminderHour) }
    }

    var reminderMinute: Int {
        get { defaults.object(forKey: Keys.reminderMinute) as? Int ?? 0 }
        set { defaults.set(newValue, forKey: Keys.reminderMinute) }
    }

    var reminderDate: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? .now
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 9
            reminderMinute = components.minute ?? 0
        }
    }

    private init() {}
}
