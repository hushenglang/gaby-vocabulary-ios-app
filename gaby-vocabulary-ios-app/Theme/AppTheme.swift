import SwiftUI

enum AppTheme {
    // MARK: - Colors

    static let primary = Color(hex: 0x4A90D9)
    static let primaryLight = Color(hex: 0xEBF2FB)
    static let background = Color(hex: 0xF8F9FA)
    static let surface = Color.white
    static let textPrimary = Color(hex: 0x1A1A1A)
    static let textSecondary = Color(hex: 0x6B7280)
    static let textTertiary = Color(hex: 0x9CA3AF)
    static let border = Color(hex: 0xE5E7EB)
    static let danger = Color(hex: 0xEF4444)
    static let success = Color(hex: 0x22C55E)
    static let warning = Color(hex: 0xF59E0B)

    // MARK: - Typography

    static let fontCaption: CGFloat = 12
    static let fontSmall: CGFloat = 14
    static let fontBody: CGFloat = 16
    static let fontTitle3: CGFloat = 20
    static let fontTitle2: CGFloat = 24
    static let fontTitle1: CGFloat = 32
    static let fontLargeTitle: CGFloat = 40

    // MARK: - Spacing

    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing16: CGFloat = 16
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    static let spacing48: CGFloat = 48

    // MARK: - Corner Radii

    static let radius8: CGFloat = 8
    static let radius12: CGFloat = 12
    static let radius16: CGFloat = 16
    static let radius20: CGFloat = 20
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
