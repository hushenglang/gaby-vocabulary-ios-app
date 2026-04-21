import SwiftUI

struct EmptyStudyView: View {
    let onAddWords: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.spacing24) {
            Spacer()

            Image(systemName: "books.vertical")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.textTertiary)

            VStack(spacing: AppTheme.spacing8) {
                Text("No words yet.")
                    .font(.system(size: AppTheme.fontTitle3, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Add vocabulary to get started!")
                    .font(.system(size: AppTheme.fontBody))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Button(action: onAddWords) {
                Text("Add Words")
                    .font(.system(size: AppTheme.fontBody, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.spacing32)
                    .padding(.vertical, AppTheme.spacing16)
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius12))
            }

            Spacer()
        }
    }
}
