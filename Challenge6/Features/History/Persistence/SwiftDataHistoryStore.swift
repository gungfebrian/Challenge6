import Foundation
import SwiftData

@MainActor
protocol AnalysisHistoryManaging: AnalysisHistorySaving {
    func fetchAll() throws -> [AnalysisHistoryEntry]
    func delete(id: UUID) throws
    func clearAll() throws
}

@MainActor
final class SwiftDataHistoryStore: AnalysisHistoryManaging {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        modelContainer = modelContext.container
        self.modelContext = modelContext
    }

    func save(_ entry: AnalysisHistoryEntry) throws {
        do {
            modelContext.insert(AnalysisRecord(entry: entry))
            let records = try fetchRecords()
            let entries = records.compactMap(\.historyEntry)
            let idsToRemove = Set(HistoryRetentionPolicy.recordIDsToRemove(from: entries))

            for record in records where idsToRemove.contains(record.id) {
                modelContext.delete(record)
            }

            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    func fetchAll() throws -> [AnalysisHistoryEntry] {
        try fetchRecords().compactMap(\.historyEntry)
    }

    private func fetchRecords() throws -> [AnalysisRecord] {
        let descriptor = FetchDescriptor<AnalysisRecord>(
            sortBy: [
                SortDescriptor(\.analyzedAt, order: .reverse),
                SortDescriptor(\.id, order: .reverse)
            ]
        )
        return try modelContext.fetch(descriptor)
    }

    func delete(id: UUID) throws {
        do {
            for record in try fetchRecords() where record.id == id {
                modelContext.delete(record)
            }
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    func clearAll() throws {
        do {
            try modelContext.delete(model: AnalysisRecord.self)
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
