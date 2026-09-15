//
//  AnalysisResult.swift
//  Challenge6
//

/// The message categories exposed to the rest of the app.
enum MessageLabel: String, Equatable, Sendable {
    case suspicious
    case legitimate
}

/// A classifier prediction expressed in domain terms the UI can render.
struct AnalysisResult: Equatable, Sendable {
    let label: MessageLabel

    // Expected range: 0...1. The future ML service owns validation and mapping.
    let confidence: Double
}
