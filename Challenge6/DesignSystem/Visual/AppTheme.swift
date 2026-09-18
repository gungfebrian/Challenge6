import SwiftUI
import UIKit

enum AppTheme {
    static let background = adaptive(light: 0xF4F6FB, dark: 0x0D1424)
    static let surface = adaptive(light: 0xFFFFFF, dark: 0x182238)
    static let surfaceMuted = adaptive(light: 0xEEF2FA, dark: 0x222E47)
    static let ink = adaptive(light: 0x16213A, dark: 0xF6F8FF)
    static let secondaryText = adaptive(light: 0x5E6A82, dark: 0xB8C2D8)
    static let primary = adaptive(light: 0x2D57D9, dark: 0x9AB0FF)
    static let primaryPressed = adaptive(light: 0x2448B6, dark: 0xB4C4FF)
    static let primaryActionForeground = adaptive(light: 0xFFFFFF, dark: 0x0D1424)
    static let safe = adaptive(light: 0x136A4A, dark: 0x64D4AC)
    static let safeSurface = adaptive(light: 0xE5F5EE, dark: 0x173A33)
    static let warning = adaptive(light: 0xA83C32, dark: 0xFF9A80)
    static let warningSurface = adaptive(light: 0xFBECE9, dark: 0x422725)
    static let outline = adaptive(light: 0xD9DEEA, dark: 0x33415E)
    static let cloud = adaptive(light: 0xEEE9FF, dark: 0x26335B)
    static let skyTop = adaptive(light: 0x5E8CF0, dark: 0x1D3469)
    static let skyBottom = adaptive(light: 0xD9E4FF, dark: 0x0D1424)
    static let shadow = adaptive(light: 0x223B73, dark: 0x000000).opacity(0.14)

    static let cardRadius: CGFloat = 28
    static let fieldRadius: CGFloat = 20
    static let primaryControlHeight: CGFloat = 56
    static let compactContentWidth: CGFloat = 620

    static var skyGradient: LinearGradient {
        LinearGradient(
            colors: [skyTop, skyBottom, background],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primary, adaptive(light: 0x5686F2, dark: 0x6D8EF2)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(
            uiColor: UIColor { traits in
                UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
            }
        )
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
