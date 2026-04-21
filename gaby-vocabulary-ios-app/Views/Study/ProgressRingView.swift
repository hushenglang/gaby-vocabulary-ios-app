import SwiftUI

struct ProgressRingView: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.border, lineWidth: 6)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppTheme.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)

            VStack(spacing: 2) {
                Text("\(completed)")
                    .font(.system(size: AppTheme.fontTitle2, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("/ \(total)")
                    .font(.system(size: AppTheme.fontSmall, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .frame(width: 80, height: 80)
    }
}
