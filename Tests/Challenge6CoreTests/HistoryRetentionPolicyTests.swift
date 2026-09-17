import Foundation

enum HistoryRetentionPolicyTests {
    static func run() {
        let baseDate = Date(timeIntervalSince1970: 1_000)
        let entries = (0..<51).map { index in
            AnalysisHistoryEntry(
                id: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", index))!,
                message: "Message \(index)",
                label: .legitimate,
                confidence: 0.5,
                analyzedAt: baseDate.addingTimeInterval(Double(index)),
                modelIdentifier: "model",
                modelVersion: "1"
            )
        }

        expect(
            HistoryRetentionPolicy.recordIDsToRemove(from: Array(entries.prefix(50))).isEmpty,
            "Fifty records should be retained"
        )
        expect(
            HistoryRetentionPolicy.recordIDsToRemove(from: entries) == [entries[0].id],
            "Record 51 should deterministically remove the oldest timestamp"
        )

        let sameDateEntries = [
            historyEntry(id: "00000000-0000-0000-0000-000000000002", date: baseDate),
            historyEntry(id: "00000000-0000-0000-0000-000000000001", date: baseDate),
            historyEntry(id: "00000000-0000-0000-0000-000000000003", date: baseDate)
        ]
        expect(
            HistoryRetentionPolicy.recordIDsToRemove(from: sameDateEntries, limit: 2) == [sameDateEntries[1].id],
            "UUID should break equal-timestamp ties so retention never depends on fetch order"
        )
    }

    private static func historyEntry(id: String, date: Date) -> AnalysisHistoryEntry {
        AnalysisHistoryEntry(
            id: UUID(uuidString: id)!,
            message: "Message",
            label: .suspicious,
            confidence: 0.8,
            analyzedAt: date,
            modelIdentifier: "model",
            modelVersion: "1"
        )
    }
}
