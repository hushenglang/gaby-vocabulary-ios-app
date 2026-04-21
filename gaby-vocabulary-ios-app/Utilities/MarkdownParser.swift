import Foundation

struct ParsedWord {
    let english: String
    let chinese: String
}

enum MarkdownParser {
    static func parse(_ text: String) -> [ParsedWord] {
        var results: [ParsedWord] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("|") else { continue }

            let columns = trimmed
                .split(separator: "|", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            guard columns.count >= 3 else { continue }

            // Skip separator rows (e.g., |---|---|---|)
            if columns[0].allSatisfy({ $0 == "-" || $0 == ":" }) {
                continue
            }

            // Skip if first column is not a number (header row) or is "#"
            let firstCol = columns[0]
            if firstCol == "#" || Int(firstCol) == nil {
                continue
            }

            let english = columns[1].trimmingCharacters(in: .whitespaces)
            let chinese = columns[2].trimmingCharacters(in: .whitespaces)

            guard !english.isEmpty, !chinese.isEmpty else { continue }

            results.append(ParsedWord(english: english, chinese: chinese))
        }

        return results
    }
}
