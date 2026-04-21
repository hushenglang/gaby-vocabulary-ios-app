import Foundation
import SwiftData

@Model
final class Word {
    #Unique<Word>([\.english])

    var english: String
    var chinese: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ReviewCard.word)
    var reviewCard: ReviewCard?

    init(english: String, chinese: String, createdAt: Date = .now) {
        self.english = english
        self.chinese = chinese
        self.createdAt = createdAt
    }
}
