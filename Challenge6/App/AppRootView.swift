import SwiftUI

struct AppRootView: View {
    let mlService: any MLService
    let historyStore: (any AnalysisHistoryManaging)?
    let historyInitializationError: Bool

    var body: some View {
        TabView {
            NavigationStack {
                AnalysisView(
                    mlService: mlService,
                    historySaver: historyStore,
                    isHistorySavingEnabled: {
                        AppPreferences().saveAnalysisHistory
                    }
                )
            }
            .tabItem {
                Label("Check", systemImage: "checkmark.shield")
            }

            NavigationStack {
                HistoryView(
                    store: historyStore,
                    isPersistenceUnavailable: historyInitializationError
                )
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }

            NavigationStack {
                SettingsView(historyStore: historyStore)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .tint(AppTheme.primary)
    }
}
