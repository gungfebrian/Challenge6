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
                HistoryPlaceholderView(isUnavailable: historyInitializationError)
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

private struct HistoryPlaceholderView: View {
    let isUnavailable: Bool

    var body: some View {
        ContentUnavailableView(
            isUnavailable ? "History Unavailable" : "No Analysis History",
            systemImage: isUnavailable ? "exclamationmark.triangle" : "clock",
            description: Text(
                isUnavailable
                    ? "Local history could not be opened. Message analysis is still available."
                    : "Successfully analyzed messages can appear here."
            )
        )
        .navigationTitle("History")
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
