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
    @State private var appError: AppError?
    @State private var showErrorAlert = false
    
    private var sharedModelContainer: ModelContainer? = nil
    
    init() {
        do {
            let schema = Schema([
                User.self,
                Post.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            appError = .modelContainerCreationFailed(description: error.localizedDescription)
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if let container = sharedModelContainer {
                    MainView()
                        .modelContainer(container)
                } else {
                    ErrorRouter.createModule(error: appError ?? .unknown(description: "Unknown error"))
                }
            }
        }
    }
}
