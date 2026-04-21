import SwiftUI

struct FlashcardView: View {
    let english: String
    let chinese: String
    let isRevealed: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.spacing24) {
            Spacer()

            Text(english)
                .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)

            if isRevealed {
                Rectangle()
                    .fill(AppTheme.border)
                    .frame(height: 1)
                    .padding(.horizontal, AppTheme.spacing32)
                    .transition(.opacity)

                Text(chinese)
                    .font(.system(size: AppTheme.fontTitle3, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer()

            if !isRevealed {
                HStack(spacing: AppTheme.spacing4) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: AppTheme.fontSmall))
                    Text("Tap to reveal")
                        .font(.system(size: AppTheme.fontSmall, weight: .medium))
                }
                .foregroundStyle(AppTheme.textTertiary)
                .padding(.bottom, AppTheme.spacing16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacing24)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius16))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                onTap()
            }
        }
    }
}
