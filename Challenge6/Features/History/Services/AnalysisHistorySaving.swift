@MainActor
protocol AnalysisHistorySaving: AnyObject {
    func save(_ entry: AnalysisHistoryEntry) throws
}
