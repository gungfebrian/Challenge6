struct SplitSummary: Codable, Equatable, Sendable {
    let name: String
    let total: Int
    let suspicious: Int
    let legitimate: Int
    let groups: Int
}

struct EvaluationRecord: Codable, Equatable, Sendable {
    let name: String
    let metrics: ClassificationMetrics
}

struct ErrorReview: Codable, Equatable, Sendable {
    let sampleID: String
    let expected: DatasetLabel
    let predicted: DatasetLabel
    let confidence: Double
    let category: String
}

struct DemoPrediction: Codable, Equatable, Sendable {
    let name: String
    let text: String
    let predicted: DatasetLabel
    let confidence: Double
}

struct ExperimentRecord: Codable, Equatable, Sendable {
    let experimentID: String
    let createdAt: String
    let datasetID: String
    let sourceSHA256: String
    let splitSeed: UInt64
    let modelIdentifier: String
    let modelVersion: String
    let algorithm: String
    let language: String
    let trainingDurationSeconds: Double
    let modelSizeBytes: Int
    let latencyMilliseconds: Double
    let totalSamples: Int
    let duplicateSummary: DuplicateSummary
    let splitSummaries: [SplitSummary]
    let evaluations: [EvaluationRecord]
    let errorReviews: [ErrorReview]
    let demoPredictions: [DemoPrediction]
}
