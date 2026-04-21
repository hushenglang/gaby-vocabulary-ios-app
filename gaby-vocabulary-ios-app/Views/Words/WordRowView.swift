import SwiftUI

struct WordRowView: View {
    let word: Word

    private var statusTag: (text: String, color: Color) {
        guard let card = word.reviewCard else {
            return ("New", AppTheme.primary)
        }

        if card.repetitions == 0 && card.lastReviewed == nil {
            return ("New", AppTheme.primary)
        }

        let nextReview = card.nextReview
        if nextReview <= Calendar.current.startOfDay(for: .now) {
            return ("Due today", AppTheme.danger)
        } else if nextReview.isTomorrow {
            return ("Tomorrow", AppTheme.warning)
        } else {
            let days = nextReview.daysFrom(.now)
            return ("In \(days) days", AppTheme.success)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                Text(word.english)
                    .font(.system(size: AppTheme.fontBody, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(word.chinese)
                    .font(.system(size: AppTheme.fontSmall))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Text(statusTag.text)
                .font(.system(size: AppTheme.fontCaption, weight: .medium))
                .foregroundStyle(statusTag.color)
                .padding(.horizontal, AppTheme.spacing8)
                .padding(.vertical, AppTheme.spacing4)
                .background(statusTag.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius8))
        }
        .padding(.vertical, AppTheme.spacing4)
    }
}
