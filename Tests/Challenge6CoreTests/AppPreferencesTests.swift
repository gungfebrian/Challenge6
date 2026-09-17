import Foundation

enum AppPreferencesTests {
    static func run() {
        defaultsAreEnabled()
        valuesPersistInTheProvidedStore()
    }

    private static func defaultsAreEnabled() {
        withIsolatedDefaults { defaults in
            let preferences = AppPreferences(defaults: defaults)

            expect(preferences.saveAnalysisHistory, "History saving should default to enabled")
            expect(preferences.hapticFeedback, "Haptic feedback should default to enabled")
        }
    }

    private static func valuesPersistInTheProvidedStore() {
        withIsolatedDefaults { defaults in
            let preferences = AppPreferences(defaults: defaults)
            preferences.saveAnalysisHistory = false
            preferences.hapticFeedback = false

            let reloaded = AppPreferences(defaults: defaults)
            expect(!reloaded.saveAnalysisHistory, "History preference should persist")
            expect(!reloaded.hapticFeedback, "Haptic preference should persist")
        }
    }

    private static func withIsolatedDefaults(_ operation: (UserDefaults) -> Void) {
        let suiteName = "Challenge6CoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Could not create isolated defaults")
        }

        defaults.removePersistentDomain(forName: suiteName)
        operation(defaults)
        defaults.removePersistentDomain(forName: suiteName)
    }
}
