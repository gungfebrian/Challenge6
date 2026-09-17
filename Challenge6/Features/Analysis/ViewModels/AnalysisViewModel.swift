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
        case modelUnavailable
        case predictionUnavailable
        case serviceUnavailable

        var message: String {
            switch self {
            case .emptyInput:
                "Enter a message before analyzing."
            case .modelUnavailable:
                "The on-device model is unavailable. Try reopening the app."
            case .predictionUnavailable:
                "The model did not return a usable prediction. Edit the message and try again."
            case .serviceUnavailable:
                "The message could not be analyzed. Please try again."
            }
        }
    }

    enum PersistenceWarning: Equatable {
        case saveFailed

        var message: String {
            "The result is shown, but it could not be saved to History."
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
            persistenceWarning = nil
        }
    }

    private(set) var state: State = .idle
    private(set) var persistenceWarning: PersistenceWarning?

    private let mlService: any MLService
    private let historySaver: (any AnalysisHistorySaving)?
    private let isHistorySavingEnabled: () -> Bool
    private let now: () -> Date
    private let makeID: () -> UUID

    init(
        mlService: any MLService,
        historySaver: (any AnalysisHistorySaving)? = nil,
        isHistorySavingEnabled: @escaping () -> Bool = { true },
        now: @escaping () -> Date = Date.init,
        makeID: @escaping () -> UUID = UUID.init
    ) {
        self.mlService = mlService
        self.historySaver = historySaver
        self.isHistorySavingEnabled = isHistorySavingEnabled
        self.now = now
        self.makeID = makeID
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

        persistenceWarning = nil
        state = .loading

        do {
            let result = try await mlService.analyze(request)
            try Task.checkCancellation()
            guard AnalysisRequest(rawText: message)?.text == request.text else {
                state = .idle
                return
            }

            state = .success(result)

            if isHistorySavingEnabled(), let historySaver {
                do {
                    try historySaver.save(
                        AnalysisHistoryEntry(
                            id: makeID(),
                            message: request.text,
                            label: result.label,
                            confidence: result.confidence,
                            analyzedAt: now(),
                            modelIdentifier: result.model.identifier,
                            modelVersion: result.model.version
                        )
                    )
                } catch {
                    persistenceWarning = .saveFailed
#if DEBUG
                    print("Analysis history save failed: \(error)")
#endif
                }
            }
        } catch is CancellationError {
            state = .idle
        } catch let error as MLServiceError {
            switch error {
            case .modelUnavailable:
                state = .failure(.modelUnavailable)
            case .predictionUnavailable, .unsupportedLabel, .invalidPrediction:
                state = .failure(.predictionUnavailable)
            case .predictionFailed:
                state = .failure(.serviceUnavailable)
            }
        } catch {
            state = .failure(.serviceUnavailable)
        }
    }
}
