//
//  PostsViewTests.swift
//  iPostUITests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftUI
import SwiftData
@testable import iPost

@MainActor
final class PostsViewTests: XCTestCase {
    func testPostsViewInitialState() async throws {
        // Create test container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Post.self, configurations: config)
        
        // Create test data
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.circle")
        container.mainContext.insert(user)
        
        let post = Post(text: "Test post content", author: user)
        container.mainContext.insert(post)
        try container.mainContext.save()
        
        // Create VIPER components
        let router = PostsRouter()
        let interactor = PostsInteractor(modelContext: container.mainContext)
        let presenter = PostsPresenter(interactor: interactor, router: router)
        
        // Create view with test data
        let view = PostsView(presenter: presenter)
        
        // Wait for initial data load
        try await Task.sleep(for: .milliseconds(100))
        
        // Verify initial state
        XCTAssertNotNil(view)
        
        // Use ViewInspector to verify view structure
        let mirror = Mirror(reflecting: view)
        XCTAssertTrue(mirror.children.contains { $0.label == "user-picker" })
        XCTAssertTrue(mirror.children.contains { $0.label == "posts-list" })
    }
}
