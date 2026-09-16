//
//  AnalysisViewModel.swift
//  Challenge6
//

import Foundation
import Observation

@MainActor
@Observable
/// Owns the analysis screen's input and translates service outcomes into UI state.
final class AnalysisViewModel {
    enum Failure: Equatable {
        case emptyInput
        case serviceUnavailable

        var message: String {
            switch self {
            case .emptyInput:
                "Enter a message before analyzing."
            case .serviceUnavailable:
                "The message could not be analyzed. Please try again."
            }
        }
    }

    enum State: Equatable {
        case idle
        case loading
        case success(AnalysisResult)
        case failure(Failure)
    }

    var message = "" {
        didSet {
            guard message != oldValue, !isAnalyzing else { return }
            state = .idle
        }
    }

    private(set) var state: State = .idle

    private let mlService: any MLService

    init(mlService: any MLService) {
        self.mlService = mlService
    }

    var isAnalyzing: Bool {
        state == .loading
    }

    func analyze() async {
        guard !isAnalyzing else { return }

        guard let request = AnalysisRequest(rawText: message) else {
            state = .failure(.emptyInput)
            return
        }

        state = .loading

        do {
            state = .success(try await mlService.analyze(request))
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failure(.serviceUnavailable)
        }
    }
}
