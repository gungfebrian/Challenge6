//
//  MLService.swift
//  Challenge6
//

protocol MLService {
    // Why: The app depends on its own domain types instead of a generated Core ML interface.
    // This also leaves room for a small test double when the learner reaches dependency injection.
    func analyze(_ request: AnalysisRequest) async throws -> AnalysisResult
}
