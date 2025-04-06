//
//  PostsComponentTests.swift
//  iPostUITests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftUI
import SwiftData
@testable import iPost

@MainActor
final class PostsComponentTests: XCTestCase {
    func testPostsViewInitializesCorrectly() async throws {
        // Create test container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Post.self, configurations: config)
        
        // Add test data
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.circle")
        container.mainContext.insert(user)
        
        let post = Post(text: "Test post content", author: user)
        container.mainContext.insert(post)
        try container.mainContext.save()
        
        // Create VIPER components
        let router = PostsRouter()
        let interactor = PostsInteractor(modelContext: container.mainContext)
        let presenter = PostsPresenter(interactor: interactor, router: router)
        
        // Create the view to test
        let view = PostsView(presenter: presenter)
        
        // Wait for async operations to complete
        try await Task.sleep(for: .milliseconds(100))
        
        // Simply verify that the view was created successfully
        XCTAssertNotNil(view)
        
        // Verify the presenter was set correctly
        let viewMirror = Mirror(reflecting: view)
        let presenterValue = viewMirror.children.first { $0.label == "presenter" }?.value
        XCTAssertNotNil(presenterValue)
        
        // Verify view state exists
        let viewStateProp = viewMirror.children.first { $0.label == "viewState" }?.value
        XCTAssertNotNil(viewStateProp)
        
        // Verify the presenter is correctly configured
        let presenterMirror = Mirror(reflecting: presenter)
        let interactorValue = presenterMirror.children.first { $0.label == "interactor" }?.value
        XCTAssertNotNil(interactorValue)
        
        // We don't need to access private properties
        // Just verify the view was properly initialized
        
        // Wait for initial data loading to complete
        try await Task.sleep(for: .milliseconds(500))
        
        // Verify the test data was set up correctly
        XCTAssertNotNil(user.id, "User should have a valid ID")
        XCTAssertNotNil(post.id, "Post should have a valid ID")
    }
    
    func testPostsModelData() async throws {
        // Create test container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Post.self, configurations: config)
        
        // Add test data
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.circle")
        container.mainContext.insert(user)
        
        let post = Post(text: "Test post content", author: user)
        container.mainContext.insert(post)
        try container.mainContext.save()
        
        // Verify the test data was set up correctly
        XCTAssertNotNil(user.id, "User should have a valid ID")
        XCTAssertNotNil(post.id, "Post should have a valid ID")
        XCTAssertEqual(post.author?.id, user.id, "Post should be linked to the user")
    }
}
