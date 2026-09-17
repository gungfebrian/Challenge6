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
    let confidence: Double
    let model: ModelMetadata

    nonisolated init(
        label: MessageLabel,
        confidence: Double,
        model: ModelMetadata = .educationalNaiveBayes
    ) {
        self.label = label
        self.confidence = confidence
        self.model = model
    }
}
