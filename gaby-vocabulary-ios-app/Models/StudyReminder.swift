import Foundation

struct StudyReminder: Identifiable, Codable, Equatable {
    let id: UUID
    var hour: Int
    var minute: Int
    var isEnabled: Bool

    init(id: UUID = UUID(), hour: Int = 9, minute: Int = 0, isEnabled: Bool = true) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
    }

    var date: Date {
        get {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return Calendar.current.date(from: components) ?? .now
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            hour = components.hour ?? 9
            minute = components.minute ?? 0
        }
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
