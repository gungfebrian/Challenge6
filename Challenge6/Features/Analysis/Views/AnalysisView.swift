//
//  AnalysisView.swift
//  Challenge6
//

import Accessibility
import SwiftUI

struct AnalysisView: View {
    @State private var viewModel: AnalysisViewModel

    init(mlService: any MLService) {
        _viewModel = State(initialValue: AnalysisViewModel(mlService: mlService))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $viewModel.message)
                        .frame(minHeight: 160)
                        .accessibilityLabel("Message to analyze")
                        .accessibilityHint("Enter or paste the message you want to check.")
                        .disabled(viewModel.isAnalyzing)
                } header: {
                    Text("Message")
                } footer: {
                    Text("This learning demo uses a tiny local dataset and is not real safety advice.")
                }

                Section {
                    Button {
                        Task {
                            await viewModel.analyze()
                        }
                    } label: {
                        HStack {
                            Spacer()

                            if viewModel.isAnalyzing {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Analyzing")
                            } else {
                                Label("Analyze Message", systemImage: "magnifyingglass")
                            }

                            Spacer()
                        }
                        .frame(minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isAnalyzing)
                    .accessibilityHint("Checks the entered message using the demo service.")
                }
                .listRowBackground(Color.clear)

                Section("Status") {
                    AnalysisStatusView(state: viewModel.state)
                }
            }
            .navigationTitle("Message Check")
            .onChange(of: viewModel.state) { _, newState in
                guard let announcement = newState.accessibilityAnnouncement else { return }
                AccessibilityNotification.Announcement(announcement).post()
            }
        }
    }
}

#Preview {
    AnalysisView(mlService: DemoMLService())
}
