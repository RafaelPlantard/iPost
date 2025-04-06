//
//  ModelContainerHelper.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftData

extension ModelContainer {
    static func makeForPreview() -> ModelContainer {
        do {
            let schema = Schema([User.self, Post.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error.localizedDescription)")
        }
    }
}
