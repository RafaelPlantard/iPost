//
//  iPostApp.swift
//  iPost
//
//  Created by Rafael da Silva Ferreira on 06/04/25.
//

import SwiftUI
import SwiftData

@main
struct iPostApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Post.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(sharedModelContainer)
        }
    }
}

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        let (view, _) = PostsRouter.createModule(modelContext: modelContext)

        return view
    }
}
