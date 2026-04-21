import SwiftUI

struct CompletedStudyView: View {
    let reviewedCount: Int

    var body: some View {
        VStack(spacing: AppTheme.spacing24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.success)

            VStack(spacing: AppTheme.spacing8) {
                Text("All done for today!")
                    .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("You reviewed \(reviewedCount) words today.")
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()
        }
    }
}
