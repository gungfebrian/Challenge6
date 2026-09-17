import Foundation
import SwiftData

@Model
final class AnalysisRecord {
    @Attribute(.unique) var id: UUID
    var message: String
    var labelValue: String
    var confidence: Double
    var analyzedAt: Date
    var modelIdentifier: String
    var modelVersion: String

    init(
        id: UUID,
        message: String,
        labelValue: String,
        confidence: Double,
        analyzedAt: Date,
        modelIdentifier: String,
        modelVersion: String
    ) {
        self.id = id
        self.message = message
        self.labelValue = labelValue
        self.confidence = confidence
        self.analyzedAt = analyzedAt
        self.modelIdentifier = modelIdentifier
        self.modelVersion = modelVersion
    }

    convenience init(entry: AnalysisHistoryEntry) {
        self.init(
            id: entry.id,
            message: entry.message,
            labelValue: entry.label.rawValue,
            confidence: entry.confidence,
            analyzedAt: entry.analyzedAt,
            modelIdentifier: entry.modelIdentifier,
            modelVersion: entry.modelVersion
        )
    }

    var label: MessageLabel? {
        MessageLabel(rawValue: labelValue)
    }

    var historyEntry: AnalysisHistoryEntry? {
        guard let label else { return nil }

        return AnalysisHistoryEntry(
            id: id,
            message: message,
            label: label,
            confidence: confidence,
            analyzedAt: analyzedAt,
            modelIdentifier: modelIdentifier,
            modelVersion: modelVersion
        )
    }
}
