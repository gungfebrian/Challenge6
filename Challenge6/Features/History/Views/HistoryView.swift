import SwiftUI

struct HistoryView: View {
    let store: (any AnalysisHistoryManaging)?
    let isPersistenceUnavailable: Bool

    @State private var entries: [AnalysisHistoryEntry] = []
    @State private var errorMessage: String?
    @State private var isShowingClearConfirmation = false

    var body: some View {
        Group {
            if store == nil {
                unavailableState
            } else if let errorMessage, entries.isEmpty {
                ContentUnavailableView(
                    "History Could Not Load",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if entries.isEmpty {
                emptyState
            } else {
                historyList
            }
        }
        .navigationTitle("History")
        .toolbar {
            if !entries.isEmpty {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear All", role: .destructive) {
                        isShowingClearConfirmation = true
                    }
                    .accessibilityHint("Asks for confirmation before deleting all analysis history.")
                }
            }
        }
        .confirmationDialog(
            "Clear all analysis history?",
            isPresented: $isShowingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All History", role: .destructive, action: clearAll)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes every saved message and result from this device.")
        }
        .task {
            reload()
        }
    }

    private var unavailableState: some View {
        ContentUnavailableView(
            "History Unavailable",
            systemImage: "exclamationmark.triangle",
            description: Text(
                isPersistenceUnavailable
                    ? "Local history could not be opened. Message analysis is still available."
                    : "History is unavailable in this app configuration."
            )
        )
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Analysis History",
            systemImage: "clock",
            description: Text("Successful checks appear here when Save Analysis History is enabled.")
        )
    }

    private var historyList: some View {
        List {
            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                        .accessibilityLabel("History warning. \(errorMessage)")
                }
            }

            Section {
                ForEach(entries) { entry in
                    NavigationLink {
                        HistoryDetailView(entry: entry)
                    } label: {
                        HistoryRow(entry: entry)
                    }
                    .accessibilityHint("Opens the complete saved analysis.")
                }
                .onDelete(perform: delete)
            } footer: {
                Text("Saved only on this device. At most 50 completed analyses are retained.")
            }
        }
        .frame(maxWidth: AppSpacing.readableContentWidth)
        .frame(maxWidth: .infinity)
    }

    private func reload() {
        guard let store else { return }
        do {
            entries = try store.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = "Saved analyses could not be loaded. Try again later."
        }
    }

    private func delete(at offsets: IndexSet) {
        guard let store else { return }
        let ids = offsets.map { entries[$0].id }
        do {
            for id in ids {
                try store.delete(id: id)
            }
            reload()
        } catch {
            errorMessage = "The selected analysis could not be deleted."
        }
    }

    private func clearAll() {
        guard let store else { return }
        do {
            try store.clearAll()
            reload()
        } catch {
            errorMessage = "Analysis history could not be cleared."
        }
    }
}

private struct HistoryRow: View {
    let entry: AnalysisHistoryEntry

    private var title: String {
        entry.label == .suspicious ? "Likely Spam" : "Likely Not Spam"
    }

    private var icon: String {
        entry.label == .suspicious ? "exclamationmark.shield.fill" : "checkmark.shield.fill"
    }

    private var tint: Color {
        entry.label == .suspicious ? .orange : .green
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .font(.title3)
                .frame(width: AppSpacing.large)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(entry.message)
                    .font(.body)
                    .lineLimit(2)

                VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                    HStack {
                        Text(title)
                        Text(entry.confidence, format: .percent.precision(.fractionLength(0)))
                    }
                    Text(entry.analyzedAt, format: .relative(presentation: .named))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppSpacing.extraSmall)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(title), \(entry.confidence.formatted(.percent.precision(.fractionLength(0)))) confidence. \(entry.message). Analyzed \(entry.analyzedAt.formatted(.relative(presentation: .named)))."
        )
    }
}

#Preview {
    NavigationStack {
        HistoryView(store: nil, isPersistenceUnavailable: false)
    }
}
