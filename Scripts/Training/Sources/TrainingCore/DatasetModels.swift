import Foundation

enum DatasetLabel: String, Codable, CaseIterable, Sendable {
    case suspicious
    case legitimate
}

enum ReviewStatus: String, Codable, Sendable {
    case singleReview = "single_review"
    case agreed
    case needsReview = "needs_review"
}

struct PreparedSample: Codable, Equatable, Hashable, Sendable {
    let sampleID: String
    let text: String
    let label: DatasetLabel
    let groupID: String
    let source: String
    let reviewStatus: ReviewStatus

    enum CodingKeys: String, CodingKey {
        case sampleID = "sample_id"
        case text
        case label
        case groupID = "group_id"
        case source
        case reviewStatus = "review_status"
    }
}

struct DuplicateSummary: Codable, Equatable, Sendable {
    let duplicateGroupCount: Int
    let duplicateSampleCount: Int
}

struct DatasetManifest: Codable, Equatable, Sendable {
    let datasetID: String
    let title: String
    let version: String
    let retrievedAt: String
    let canonicalPage: String
    let downloadURL: String
    let archiveSHA256: String
    let dataFile: String
    let dataFileSHA256: String
    let expectedRows: Int

    enum CodingKeys: String, CodingKey {
        case datasetID = "dataset_id"
        case title
        case version
        case retrievedAt = "retrieved_at"
        case canonicalPage = "canonical_page"
        case downloadURL = "download_url"
        case archiveSHA256 = "archive_sha256"
        case dataFile = "data_file"
        case dataFileSHA256 = "data_file_sha256"
        case expectedRows = "expected_rows"
    }
}

enum DatasetPreparationError: Error, Equatable {
    case sourceMissing
    case unreadableSource
    case invalidUTF8
    case checksumMismatch
    case rowCountMismatch(expected: Int, actual: Int)
    case malformedRows([Int])
}
