import Foundation
import SwiftData

@Observable
final class SettingsViewModel {
    let settings = SettingsService.shared

    var totalWords: Int = 0
    var masteredWords: Int = 0
    var dueToday: Int = 0

    func loadStats(context: ModelContext) {
        let allWords = FetchDescriptor<Word>()
        totalWords = (try? context.fetchCount(allWords)) ?? 0

        let masteredDescriptor = FetchDescriptor<ReviewCard>(
            predicate: #Predicate<ReviewCard> { $0.interval >= 21 }
        )
        masteredWords = (try? context.fetchCount(masteredDescriptor)) ?? 0

        let today = Calendar.current.startOfDay(for: .now)
        let dueDescriptor = FetchDescriptor<ReviewCard>(
            predicate: #Predicate<ReviewCard> { $0.nextReview <= today }
        )
        dueToday = (try? context.fetchCount(dueDescriptor)) ?? 0
    }

    func toggleReminder(enabled: Bool) {
        settings.reminderEnabled = enabled
        if enabled {
            Task {
                let granted = await NotificationService.requestPermission()
                if granted {
                    NotificationService.scheduleDailyReminder(
                        hour: settings.reminderHour,
                        minute: settings.reminderMinute
                    )
                } else {
                    await MainActor.run {
                        settings.reminderEnabled = false
                    }
                }
            }
        } else {
            NotificationService.cancelAll()
        }
    }

    func updateReminderTime() {
        guard settings.reminderEnabled else { return }
        NotificationService.scheduleDailyReminder(
            hour: settings.reminderHour,
            minute: settings.reminderMinute
        )
    }

    func resetProgress(context: ModelContext) {
        let descriptor = FetchDescriptor<ReviewCard>()
        guard let cards = try? context.fetch(descriptor) else { return }

        let today = Calendar.current.startOfDay(for: .now)
        for card in cards {
            card.easeFactor = 2.5
            card.interval = 0
            card.repetitions = 0
            card.nextReview = today
            card.lastReviewed = nil
        }

        try? context.save()
        loadStats(context: context)
    }
}
