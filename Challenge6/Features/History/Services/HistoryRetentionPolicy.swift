import Foundation

enum HistoryRetentionPolicy {
    static let maximumRecordCount = 50

    static func recordIDsToRemove(
        from entries: [AnalysisHistoryEntry],
        limit: Int = maximumRecordCount
    ) -> [UUID] {
        guard entries.count > limit else { return [] }

        return entries
            .sorted {
                if $0.analyzedAt == $1.analyzedAt {
                    return $0.id.uuidString < $1.id.uuidString
                }
                return $0.analyzedAt < $1.analyzedAt
            }
            .prefix(entries.count - limit)
            .map(\.id)
    }
}
