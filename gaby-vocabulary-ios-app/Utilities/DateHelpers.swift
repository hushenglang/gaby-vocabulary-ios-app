import Foundation

extension Date {
    var startOfDayDate: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    func daysFrom(_ other: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: other)
        let end = calendar.startOfDay(for: self)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
}
