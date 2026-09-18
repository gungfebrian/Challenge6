import Foundation

enum AnalysisPhoneLayout {
    static func mascotSize(
        viewportHeight: Double,
        usesAccessibilityText: Bool
    ) -> Double {
        let proportion = usesAccessibilityText ? 0.12 : 0.15
        let maximum = usesAccessibilityText ? 112.0 : 132.0
        return min(max(viewportHeight * proportion, 96), maximum)
    }
}

enum GuardianAnimationState: CaseIterable {
    case idle
    case checking
    case safe
    case warning
}

enum GuardianMotionPolicy {
    static func shouldAnimate(
        _ state: GuardianAnimationState,
        reduceMotion: Bool,
        allowsIdleMotion: Bool
    ) -> Bool {
        guard !reduceMotion else { return false }
        return state == .checking || (state == .idle && allowsIdleMotion)
    }
}
