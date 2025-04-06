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
        
        // Verify view structure
        let navigationTitle = view.navigationTitle
        XCTAssertEqual(navigationTitle, "iPosts")
        
        // Use ViewInspector to check view hierarchy
        let mirror = Mirror(reflecting: view)
        let hasUserPicker = mirror.children.contains { $0.label == "user-picker" }
        XCTAssertTrue(hasUserPicker)
        
        let hasCreateButton = mirror.children.contains { $0.label == "create-post-button" }
        XCTAssertTrue(hasCreateButton)
        
        // Wait for data to load
        try await Task.sleep(for: .milliseconds(500))
        let hasPostItem = mirror.children.contains { $0.label == "post-item" }
        XCTAssertTrue(hasPostItem)
    }
    
    func testToastManagerShowsDismissesToast() async throws {
        // Create toast manager
        let toastManager = ToastManager.shared
        
        // Initially no toast should be displayed
        XCTAssertNil(toastManager.currentToast)
        
        // Show toast
        toastManager.show(message: "Test Toast", type: .info, duration: 0.5)
        
        // Verify toast is shown
        XCTAssertNotNil(toastManager.currentToast)
        XCTAssertEqual(toastManager.currentToast?.message, "Test Toast")
        XCTAssertEqual(toastManager.currentToast?.type, .info)
        
        // Wait for auto-dismiss
        try await Task.sleep(for: .seconds(0.6))
        
        // Verify toast is dismissed
        XCTAssertNil(toastManager.currentToast)
    }
}
