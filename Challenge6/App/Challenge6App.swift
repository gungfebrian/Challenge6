//
//  Challenge6App.swift
//  Challenge6
//
//  Created by Gung  on 07/09/26.
//

import SwiftUI

@main
/// Builds the production dependencies and presents the app's first screen.
struct Challenge6App: App {
    private let mlService: any MLService

    init() {
        do {
            mlService = try CoreMLTextClassifierService()
        } catch {
            // A typed unavailable service keeps launch recoverable without disguising another model as Core ML.
            mlService = UnavailableMLService(error: .modelUnavailable)
        }
    }

    var body: some Scene {
        WindowGroup {
            AnalysisView(mlService: mlService)
        }
    }
}
