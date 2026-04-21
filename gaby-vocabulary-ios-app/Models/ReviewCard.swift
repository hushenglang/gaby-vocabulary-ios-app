import Foundation
import SwiftData

@Model
final class ReviewCard {
    var word: Word?
    var easeFactor: Double = 2.5
    var interval: Int = 0
    var repetitions: Int = 0
    var nextReview: Date = Calendar.current.startOfDay(for: .now)
    var lastReviewed: Date?

    init(word: Word) {
        self.word = word
        self.easeFactor = 2.5
        self.interval = 0
        self.repetitions = 0
        self.nextReview = Calendar.current.startOfDay(for: .now)
        self.lastReviewed = nil
    }
}
