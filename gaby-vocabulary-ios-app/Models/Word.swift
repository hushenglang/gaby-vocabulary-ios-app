import Foundation
import SwiftData

@Model
final class Word {
    #Unique<Word>([\.english])

    var english: String
    var chinese: String
    var phoneticNotation: String = ""
    var exampleSentence: String = ""
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ReviewCard.word)
    var reviewCard: ReviewCard?

    init(english: String, chinese: String, phoneticNotation: String = "", exampleSentence: String = "", createdAt: Date = .now) {
        self.english = english
        self.chinese = chinese
        self.phoneticNotation = phoneticNotation
        self.exampleSentence = exampleSentence
        self.createdAt = createdAt
    }
}
