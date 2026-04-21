import Foundation
import SwiftData

struct ImportResult {
    let imported: Int
    let total: Int
    var skipped: Int { total - imported }
}

@Observable
final class WordListViewModel {
    var searchText: String = ""
    var words: [Word] = []

    func fetchWords(context: ModelContext) {
        var descriptor = FetchDescriptor<Word>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.relationshipKeyPathsForPrefetching = [\.reviewCard]
        words = (try? context.fetch(descriptor)) ?? []
    }

    var filteredWords: [Word] {
        guard !searchText.isEmpty else { return words }
        let query = searchText.lowercased()
        return words.filter {
            $0.english.lowercased().contains(query) ||
            $0.chinese.lowercased().contains(query)
        }
    }

    var wordCount: Int {
        words.count
    }

    func addWord(english: String, chinese: String, phoneticNotation: String = "", exampleSentence: String = "", context: ModelContext) throws -> Bool {
        let trimmedEnglish = english.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedChinese = chinese.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEnglish.isEmpty, !trimmedChinese.isEmpty else { return false }

        let predicate = #Predicate<Word> { $0.english == trimmedEnglish }
        let descriptor = FetchDescriptor<Word>(predicate: predicate)
        let existing = (try? context.fetch(descriptor)) ?? []
        if !existing.isEmpty {
            return false
        }

        let word = Word(
            english: trimmedEnglish,
            chinese: trimmedChinese,
            phoneticNotation: phoneticNotation.trimmingCharacters(in: .whitespacesAndNewlines),
            exampleSentence: exampleSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        context.insert(word)

        let card = ReviewCard(word: word)
        context.insert(card)

        try context.save()
        fetchWords(context: context)
        return true
    }

    func deleteWord(_ word: Word, context: ModelContext) {
        context.delete(word)
        try? context.save()
        fetchWords(context: context)
    }

    func importWords(from text: String, context: ModelContext) -> ImportResult {
        let parsed = MarkdownParser.parse(text)
        var imported = 0

        for entry in parsed {
            let englishToCheck = entry.english
            let predicate = #Predicate<Word> { $0.english == englishToCheck }
            let descriptor = FetchDescriptor<Word>(predicate: predicate)
            let existing = (try? context.fetch(descriptor)) ?? []

            if existing.isEmpty {
                let word = Word(
                    english: entry.english,
                    chinese: entry.chinese,
                    phoneticNotation: entry.phoneticNotation,
                    exampleSentence: entry.exampleSentence
                )
                context.insert(word)

                let card = ReviewCard(word: word)
                context.insert(card)

                imported += 1
            }
        }

        try? context.save()
        fetchWords(context: context)
        return ImportResult(imported: imported, total: parsed.count)
    }
}
