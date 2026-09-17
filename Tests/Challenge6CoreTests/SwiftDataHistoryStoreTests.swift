import Foundation
import SwiftData

@MainActor
enum SwiftDataHistoryStoreTests {
    static func run() throws {
        try savesAndFetchesNewestFirst()
        try removesTheOldestRecordBeyondTheLimit()
        try deletesOneRecord()
        try clearsAllRecords()
    }

    private static func savesAndFetchesNewestFirst() throws {
        let store = try makeStore()
        try store.save(makeEntry(index: 1, date: Date(timeIntervalSince1970: 1)))
        try store.save(makeEntry(index: 2, date: Date(timeIntervalSince1970: 2)))

        let records = try store.fetchAll()
        expect(records.map(\.message) == ["Message 2", "Message 1"], "History should be newest first")
    }

    private static func removesTheOldestRecordBeyondTheLimit() throws {
        let store = try makeStore()
        for index in 0...HistoryRetentionPolicy.maximumRecordCount {
            try store.save(makeEntry(index: index, date: Date(timeIntervalSince1970: TimeInterval(index))))
        }

        let records = try store.fetchAll()
        expect(records.count == 50, "SwiftData history should retain at most 50 records")
        expect(!records.contains { $0.message == "Message 0" }, "The oldest record should be pruned")
    }

    private static func deletesOneRecord() throws {
        let store = try makeStore()
        let first = makeEntry(index: 1, date: Date(timeIntervalSince1970: 1))
        let second = makeEntry(index: 2, date: Date(timeIntervalSince1970: 2))
        try store.save(first)
        try store.save(second)

        try store.delete(id: first.id)

        let records = try store.fetchAll()
        expect(records.map(\.id) == [second.id], "Deleting one record should preserve the others")
    }

    private static func clearsAllRecords() throws {
        let store = try makeStore()
        try store.save(makeEntry(index: 1, date: Date()))
        try store.save(makeEntry(index: 2, date: Date()))

        try store.clearAll()

        let records = try store.fetchAll()
        expect(records.isEmpty, "Clear All should remove every history record")
    }

    private static func makeStore() throws -> SwiftDataHistoryStore {
        let configuration = ModelConfiguration(
            "Challenge6HistoryTests-\(UUID().uuidString)",
            schema: Schema([AnalysisRecord.self]),
            isStoredInMemoryOnly: true,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
        let container = try ModelContainer(
            for: AnalysisRecord.self,
            configurations: configuration
        )
        return SwiftDataHistoryStore(modelContext: container.mainContext)
    }

    private static func makeEntry(index: Int, date: Date) -> AnalysisHistoryEntry {
        AnalysisHistoryEntry(
            id: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", index))!,
            message: "Message \(index)",
            label: index.isMultiple(of: 2) ? .legitimate : .suspicious,
            confidence: 0.75,
            analyzedAt: date,
            modelIdentifier: "test-model",
            modelVersion: "1.0"
        )
    }
}
