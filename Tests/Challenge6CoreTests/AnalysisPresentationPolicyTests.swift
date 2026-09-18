import Foundation

enum AnalysisPresentationPolicyTests {
    static func run() {
        mascotShrinksForAccessibilityText()
        mascotStaysWithinPhoneFriendlyBounds()
        checkArtworkMatchesAnalysisState()
        idleMotionRequiresExplicitOptIn()
        historyIdleStateStaysStatic()
        reduceMotionStopsCheckingAnimation()
    }

    private static func checkArtworkMatchesAnalysisState() {
        expect(
            CheckArtwork.assetName(isAnalyzing: false) == "GuardianPasteMessage",
            "The idle Check screen should invite message entry"
        )
        expect(
            CheckArtwork.assetName(isAnalyzing: true) == "GuardianCheckingScan",
            "The loading Check screen should show the scan artwork"
        )
    }

    private static func mascotShrinksForAccessibilityText() {
        let regular = AnalysisPhoneLayout.mascotSize(
            viewportHeight: 852,
            usesAccessibilityText: false
        )
        let accessibility = AnalysisPhoneLayout.mascotSize(
            viewportHeight: 852,
            usesAccessibilityText: true
        )

        expect(
            accessibility < regular,
            "Accessibility text should reduce decorative mascot space"
        )
    }

    private static func mascotStaysWithinPhoneFriendlyBounds() {
        let compactPhone = AnalysisPhoneLayout.mascotSize(
            viewportHeight: 667,
            usesAccessibilityText: false
        )
        let tallPhone = AnalysisPhoneLayout.mascotSize(
            viewportHeight: 956,
            usesAccessibilityText: false
        )

        expectApproximatelyEqual(
            compactPhone,
            100.05,
            "Compact phones should keep the mascot proportional",
            tolerance: 0.01
        )
        expectApproximatelyEqual(
            tallPhone,
            132,
            "Tall phones should cap decorative mascot growth",
            tolerance: 0.01
        )
    }

    private static func idleMotionRequiresExplicitOptIn() {
        expect(
            GuardianMotionPolicy.shouldAnimate(
                .idle,
                reduceMotion: false,
                allowsIdleMotion: true
            ),
            "Reusable mascot motion should require explicit opt-in"
        )
    }

    private static func historyIdleStateStaysStatic() {
        expect(
            !GuardianMotionPolicy.shouldAnimate(
                .idle,
                reduceMotion: false,
                allowsIdleMotion: false
            ),
            "Decorative History mascots should stay static"
        )
    }

    private static func reduceMotionStopsCheckingAnimation() {
        expect(
            !GuardianMotionPolicy.shouldAnimate(
                .checking,
                reduceMotion: true,
                allowsIdleMotion: true
            ),
            "Reduce Motion should render the checking mascot statically"
        )
    }
}
