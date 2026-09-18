import Foundation
import SwiftUI

struct AppRootView: View {
    let mlService: any MLService
    let historyStore: (any AnalysisHistoryManaging)?
    let historyInitializationError: Bool
    @State private var selectedTab = AppTab.launchSelection

    var body: some View {
        TabView(selection: $selectedTab) {
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
            .tag(AppTab.check)

            NavigationStack {
                HistoryView(
                    store: historyStore,
                    isPersistenceUnavailable: historyInitializationError
                )
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
            .tag(AppTab.history)

            NavigationStack {
                SettingsView(historyStore: historyStore)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppTab.settings)
        }
        .tint(AppTheme.primary)
    }
}

private enum AppTab: String {
    case check
    case history
    case settings

    static var launchSelection: AppTab {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if let flagIndex = arguments.firstIndex(of: "-DemoTab"),
           arguments.indices.contains(flagIndex + 1),
           let requestedTab = AppTab(rawValue: arguments[flagIndex + 1]) {
            return requestedTab
        }
#endif
        return .check
    }
}
