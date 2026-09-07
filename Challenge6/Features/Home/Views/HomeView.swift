//
//  HomeView.swift
//  Challenge6
//
//  Created by Gung  on 07/09/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Foundation ready", systemImage: "hammer.fill")
            } description: {
                Text("Start building your first feature when you are ready.")
            }
            .padding(AppSpacing.large)
            .navigationTitle("Challenge6")
        }
    }
}

#Preview {
    HomeView()
}
