import Foundation

enum RecallRating: Int {
    case forgot = 1
    case hard = 3
    case good = 4
    case easy = 5
}

struct SM2Result {
    let easeFactor: Double
    let interval: Int
    let repetitions: Int
    let nextReview: Date
}

enum SM2Algorithm {
    static func calculate(
        quality: RecallRating,
        easeFactor: Double,
        interval: Int,
        repetitions: Int
    ) -> SM2Result {
        let q = Double(quality.rawValue)
        var newEF = easeFactor
        var newInterval = interval
        var newRepetitions = repetitions

        if quality.rawValue < 3 {
            newRepetitions = 0
            newInterval = 0
        } else {
            newRepetitions += 1
            switch newRepetitions {
            case 1:
                newInterval = 1
            case 2:
                newInterval = 3
            default:
                newInterval = Int(round(Double(interval) * easeFactor))
            }
        }

        newEF = easeFactor + (0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02))
        newEF = max(1.3, newEF)

        let today = Calendar.current.startOfDay(for: .now)
        let nextReview = Calendar.current.date(byAdding: .day, value: newInterval, to: today)!

        return SM2Result(
            easeFactor: newEF,
            interval: newInterval,
            repetitions: newRepetitions,
            nextReview: nextReview
        )
    }
}
