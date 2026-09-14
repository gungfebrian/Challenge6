//
//  AnalysisResult.swift
//  Challenge6
//

enum MessageLabel: String, Equatable, Sendable {
    case suspicious
    case legitimate
}

struct AnalysisResult: Equatable, Sendable { //PROTOCOL atau interface

    let label: MessageLabel

    // Expected range: 0...1. The future ML service owns validation and mapping.
    let confidence: Double
}
//PROTOCOL atau interface
