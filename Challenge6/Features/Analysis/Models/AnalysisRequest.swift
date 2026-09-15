//
//  AnalysisRequest.swift
//  Challenge6
//

/// App-facing input that keeps the UI independent from a classifier's internal API.
struct AnalysisRequest: Equatable, Sendable {
    let text: String
}
