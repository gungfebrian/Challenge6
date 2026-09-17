//
//  DemoMLService.swift
//  Challenge6
//

import Foundation

/// A deterministic learning aid that makes the MVVM flow runnable before a Core ML model exists.
/// Its output must not be treated as real safety advice.
struct DemoMLService: MLService {
    private let suspiciousTerms = [
        "account", "click", "password", "prize", "urgent", "verify", "winner"
    ]

    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult {
        try await Task.sleep(for: .milliseconds(600))

        let normalizedText = request.text.lowercased()
        let matchCount = suspiciousTerms.count { normalizedText.contains($0) }
        let label: MessageLabel = matchCount > 0 ? .suspicious : .legitimate
        let confidence = matchCount > 0
            ? min(0.55 + (Double(matchCount) * 0.1), 0.95)
            : 0.65

        return AnalysisResult(
            label: label,
            confidence: confidence,
            model: .deterministicDemo
        )
    }
}
