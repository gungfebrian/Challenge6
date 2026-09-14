//
//  Challenge6App.swift
//  Challenge6
//
//  Created by Gung  on 07/09/26.
//

import SwiftUI

@main
struct Challenge6App: App {
    var body: some Scene {
        WindowGroup {
            AnalysisView(mlService: MultinomialNaiveBayesService())
        }
    }
}
