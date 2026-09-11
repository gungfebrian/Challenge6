//
//  AnalysisViewModel.swift
//  Challenge6
//

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

    var message = ""

    // Why: One state prevents loading, result, and error UI from being active together.
    private(set) var state: State = .idle

    // Why: Depending on the protocol keeps Core ML out of view-state management.
    private let mlService: any MLService

    init(mlService: any MLService) {
        self.mlService = mlService
    }

    // The analysis action is intentionally learner-owned. Its first version should validate
    // the message, await MLService, and make every state transition explicit.
}
