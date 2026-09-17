import Foundation
import SwiftData

@MainActor
struct ApplicationDependencies {
    let mlService: any MLService
    let historyStore: (any AnalysisHistoryManaging)?
    let historyInitializationError: Bool

    init() {
        do {
            mlService = try CoreMLTextClassifierService()
        } catch {
            // The unavailable service preserves the active-model contract without substituting a baseline.
            mlService = UnavailableMLService(error: .modelUnavailable)
#if DEBUG
            print("Core ML service initialization failed: \(error)")
#endif
        }

        do {
            let schema = Schema([AnalysisRecord.self])
            let configuration = ModelConfiguration(
                "Challenge6History",
                schema: schema,
                groupContainer: .none,
                cloudKitDatabase: .none
            )
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            historyStore = SwiftDataHistoryStore(modelContext: container.mainContext)
            historyInitializationError = false
        } catch {
            historyStore = nil
            historyInitializationError = true
#if DEBUG
            print("Local history initialization failed: \(error)")
#endif
        }
    }
}
