//
//  AnalysisRequest.swift
//  Challenge6
//

import Foundation

/// App-facing input that keeps the UI independent from a classifier's internal API.
struct AnalysisRequest: Equatable, Sendable {
    let text: String

    init(text: String) {
        self.text = text
    }

    init?(rawText: String) {
        let normalizedText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedText.isEmpty else { return nil }

        text = normalizedText
    }
}
