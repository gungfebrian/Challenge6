//
//  MLService.swift
//  Challenge6
//

/// Boundary used by the view model to request a prediction without knowing its implementation.
protocol MLService {
    /// Analyzes domain input and either returns a renderable result or throws an error.
    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult
}
