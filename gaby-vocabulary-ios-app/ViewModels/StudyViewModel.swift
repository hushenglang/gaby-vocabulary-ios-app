import Foundation
import SwiftData

@Observable
final class StudyViewModel {
    var studyQueue: [ReviewCard] = []
    var currentIndex: Int = 0
    var isRevealed: Bool = false
    var totalWordsExist: Bool = false

    var currentCard: ReviewCard? {
        guard currentIndex < studyQueue.count else { return nil }
        return studyQueue[currentIndex]
    }

    var isComplete: Bool {
        !studyQueue.isEmpty && currentIndex >= studyQueue.count
    }

    var isEmpty: Bool {
        !totalWordsExist
    }

    var sessionTotal: Int {
        studyQueue.count
    }

    var sessionCompleted: Int {
        min(currentIndex, studyQueue.count)
    }

    var progress: Double {
        guard sessionTotal > 0 else { return 0 }
        return Double(sessionCompleted) / Double(sessionTotal)
    }

    func loadQueue(context: ModelContext) {
        let settings = SettingsService.shared
        let today = Calendar.current.startOfDay(for: .now)

        let allWordsDescriptor = FetchDescriptor<Word>()
        let allWordsCount = (try? context.fetchCount(allWordsDescriptor)) ?? 0
        totalWordsExist = allWordsCount > 0

        // Count words reviewed today
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let reviewedTodayDescriptor = FetchDescriptor<ReviewCard>(
            predicate: #Predicate<ReviewCard> {
                $0.lastReviewed != nil &&
                $0.lastReviewed! >= today &&
                $0.lastReviewed! < todayEnd
            }
        )
        let todayReviewedCount = (try? context.fetchCount(reviewedTodayDescriptor)) ?? 0

        // Fetch due words (nextReview <= today)
        var dueDescriptor = FetchDescriptor<ReviewCard>(
            predicate: #Predicate<ReviewCard> { $0.nextReview <= today },
            sortBy: [SortDescriptor(\.nextReview, order: .forward)]
        )
        dueDescriptor.relationshipKeyPathsForPrefetching = [\.word]
        let dueCards = (try? context.fetch(dueDescriptor)) ?? []

        // Calculate new words needed
        let newWordsNeeded = max(0, settings.dailyNewWords - todayReviewedCount)

        // Fetch new words (never reviewed)
        var newDescriptor = FetchDescriptor<ReviewCard>(
            predicate: #Predicate<ReviewCard> {
                $0.repetitions == 0 && $0.lastReviewed == nil
            },
            sortBy: [SortDescriptor(\.word?.createdAt, order: .forward)]
        )
        newDescriptor.fetchLimit = newWordsNeeded
        newDescriptor.relationshipKeyPathsForPrefetching = [\.word]
        let newCards = (try? context.fetch(newDescriptor)) ?? []

        // Merge and de-duplicate (due cards first)
        var seen = Set<PersistentIdentifier>()
        var queue: [ReviewCard] = []

        for card in dueCards {
            if seen.insert(card.persistentModelID).inserted {
                queue.append(card)
            }
        }
        for card in newCards {
            if seen.insert(card.persistentModelID).inserted {
                queue.append(card)
            }
        }

        studyQueue = queue
        currentIndex = 0
        isRevealed = false
    }

    func revealCard() {
        isRevealed = true
    }

    func rateCard(_ rating: RecallRating, context: ModelContext) {
        guard let card = currentCard else { return }

        let result = SM2Algorithm.calculate(
            quality: rating,
            easeFactor: card.easeFactor,
            interval: card.interval,
            repetitions: card.repetitions
        )

        card.easeFactor = result.easeFactor
        card.interval = result.interval
        card.repetitions = result.repetitions
        card.nextReview = result.nextReview
        card.lastReviewed = .now

        try? context.save()

        currentIndex += 1
        isRevealed = false
    }
}
