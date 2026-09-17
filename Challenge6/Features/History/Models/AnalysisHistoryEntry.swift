import Foundation

struct AnalysisHistoryEntry: Equatable, Sendable, Identifiable {
    let id: UUID
    let message: String
    let label: MessageLabel
    let confidence: Double
    let analyzedAt: Date
    let modelIdentifier: String
    let modelVersion: String
}
