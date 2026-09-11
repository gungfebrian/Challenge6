//
//  AnalysisResult.swift
//  Challenge6
//

enum MessageLabel: String, Equatable, Sendable {
    case suspicious
    case legitimate
}

struct AnalysisResult: Equatable, Sendable {
    // Why: A domain label can remain stable if the model's generated output type changes.
    let label: MessageLabel

    // Expected range: 0...1. The future ML service owns validation and mapping.
    let confidence: Double
}
