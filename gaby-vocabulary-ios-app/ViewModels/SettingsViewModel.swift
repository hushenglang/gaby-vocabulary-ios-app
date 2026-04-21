import Foundation
import SwiftData
import SwiftUI

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

    // MARK: - Reminders

    func addReminder() {
        let reminder = StudyReminder()
        settings.reminders.append(reminder)
        scheduleWithPermission(reminder)
    }

    func removeReminders(at offsets: IndexSet) {
        for index in offsets {
            NotificationService.cancelReminder(id: settings.reminders[index].id)
        }
        settings.reminders.remove(atOffsets: offsets)
    }

    func removeReminder(_ reminder: StudyReminder) {
        NotificationService.cancelReminder(id: reminder.id)
        settings.reminders.removeAll { $0.id == reminder.id }
    }

    func toggleReminder(_ reminder: StudyReminder, enabled: Bool) {
        guard let index = settings.reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        settings.reminders[index].isEnabled = enabled
        if enabled {
            scheduleWithPermission(settings.reminders[index])
        } else {
            NotificationService.cancelReminder(id: reminder.id)
        }
    }

    func updateReminderTime(_ reminder: StudyReminder, date: Date) {
        guard let index = settings.reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        settings.reminders[index].hour = components.hour ?? 9
        settings.reminders[index].minute = components.minute ?? 0
        if settings.reminders[index].isEnabled {
            NotificationService.scheduleReminder(settings.reminders[index])
        }
    }

    private func scheduleWithPermission(_ reminder: StudyReminder) {
        Task {
            let granted = await NotificationService.requestPermission()
            if granted {
                NotificationService.scheduleReminder(reminder)
            } else {
                await MainActor.run {
                    if let idx = settings.reminders.firstIndex(where: { $0.id == reminder.id }) {
                        settings.reminders[idx].isEnabled = false
                    }
                }
            }
        }
    }

    // MARK: - Data

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
