//
//  AnalysisViewModel.swift
//  Challenge6
//

import Foundation
import Observation

@MainActor
@Observable
final class AnalysisViewModel {
    enum State: Equatable {
        case idle
        case loading
        case success(AnalysisResult)
        case failure(String)
    }

    var message = "" {
        didSet {
            guard message != oldValue, !isAnalyzing else { return }
            state = .idle
        }
    }

    // Why: One state prevents loading, result, and error UI from being active together.
    private(set) var state: State = .idle

    // Why: Depending on the protocol keeps Core ML out of view-state management.
    private let mlService: any MLService

    init(mlService: any MLService) {
        self.mlService = mlService
    }

    var isAnalyzing: Bool {
        state == .loading
    }

    func analyze() async {
        guard !isAnalyzing else { return }

        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            state = .failure("Enter a message before analyzing.")
            return
        }

        state = .loading

        do {
            state = .success(try await mlService.analyze(AnalysisRequest(text: trimmedMessage)))
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failure("The message could not be analyzed. Please try again.")
        }
    }
}
