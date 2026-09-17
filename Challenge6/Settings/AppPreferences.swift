import Foundation

enum PreferenceKeys {
    static let saveAnalysisHistory = "preferences.saveAnalysisHistory"
    static let hapticFeedback = "preferences.hapticFeedback"
}

struct AppPreferences {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var saveAnalysisHistory: Bool {
        get { defaults.object(forKey: PreferenceKeys.saveAnalysisHistory) as? Bool ?? true }
        nonmutating set { defaults.set(newValue, forKey: PreferenceKeys.saveAnalysisHistory) }
    }

    var hapticFeedback: Bool {
        get { defaults.object(forKey: PreferenceKeys.hapticFeedback) as? Bool ?? true }
        nonmutating set { defaults.set(newValue, forKey: PreferenceKeys.hapticFeedback) }
    }
}
