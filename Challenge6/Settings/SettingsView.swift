import SwiftUI

struct SettingsView: View {
    let historyStore: (any AnalysisHistoryManaging)?

    @AppStorage(PreferenceKeys.saveAnalysisHistory) private var saveAnalysisHistory = true
    @AppStorage(PreferenceKeys.hapticFeedback) private var hapticFeedback = true
    @State private var isShowingClearConfirmation = false
    @State private var clearErrorMessage: String?

    var body: some View {
        Form {
            Section {
                Toggle("Save Analysis History", isOn: $saveAnalysisHistory)
                    .accessibilityHint("Controls whether future successful analyses are saved on this device.")
            } header: {
                Text("Analysis")
            } footer: {
                Text("Turning this off prevents future records. It does not delete existing history.")
            }

            Section("Feedback") {
                Toggle("Haptic Feedback", isOn: $hapticFeedback)
                    .accessibilityHint("Controls success, warning, and error vibration feedback.")
            }

            Section("Model") {
                LabeledContent("Active Model", value: ModelMetadata.coreMLMaxEnt.displayName)
                LabeledContent("Version", value: ModelMetadata.coreMLMaxEnt.version)
                LabeledContent("Type", value: "Maximum Entropy")
                LabeledContent("Language", value: "English")
                Label("Runs on device", systemImage: "iphone.and.arrow.forward.inward")

                NavigationLink("Model & Dataset Information") {
                    ModelInformationView()
                }
            }

            Section {
                Text("Analyzed messages stay on this device. Saved history contains message text. The app uses no CloudKit, analytics, or network analysis service.")

                Button("Clear Analysis History", systemImage: "trash", role: .destructive) {
                    isShowingClearConfirmation = true
                }
                .disabled(historyStore == nil)
                .frame(minHeight: AppSpacing.minimumTouchTarget)
                .accessibilityHint("Asks for confirmation before deleting all saved messages and results.")
            } header: {
                Text("Privacy")
            } footer: {
                if historyStore == nil {
                    Text("Local history is currently unavailable.")
                }
            }

            Section("About") {
                LabeledContent("Purpose", value: "Educational demo")
                Text("This learning-first classifier does not represent every modern scam, guarantee safety, or replace your judgment and official reporting channels.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: AppSpacing.readableContentWidth)
        .frame(maxWidth: .infinity)
        .navigationTitle("Settings")
        .confirmationDialog(
            "Clear all analysis history?",
            isPresented: $isShowingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All History", role: .destructive, action: clearHistory)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes every saved message and result from this device.")
        }
        .alert(
            "History Could Not Be Cleared",
            isPresented: Binding(
                get: { clearErrorMessage != nil },
                set: { if !$0 { clearErrorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(clearErrorMessage ?? "Please try again later.")
        }
    }

    private func clearHistory() {
        do {
            try historyStore?.clearAll()
        } catch {
            clearErrorMessage = "Your existing history was not changed. Please try again later."
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(historyStore: nil)
    }
}
