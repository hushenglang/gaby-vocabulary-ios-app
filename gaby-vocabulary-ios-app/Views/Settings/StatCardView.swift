import SwiftUI

struct StatCardView: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.spacing4) {
            Text("\(value)")
                .font(.system(size: AppTheme.fontTitle2, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(label)
                .font(.system(size: AppTheme.fontCaption, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacing16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radius12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
