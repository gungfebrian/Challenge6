//
//  AnalysisRequest.swift
//  Challenge6
//

struct AnalysisRequest: Equatable, Sendable {
    // Why: Keep raw user input in a value type so views do not depend on Core ML input names.
    let text: String
}
