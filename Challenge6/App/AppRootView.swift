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
                SettingsPlaceholderView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}

private struct SettingsPlaceholderView: View {
    var body: some View {
        Form {
            Section("Privacy") {
                Text("Messages are analyzed on this device.")
            }
        }
        .navigationTitle("Settings")
    }
}
