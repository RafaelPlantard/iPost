//
//  CreatePostViewSnapshotTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftUI
import SwiftData
import SnapshotTesting
@testable import iPost

/// Snapshot tests for the CreatePostView component.
/// These tests verify the visual appearance of the CreatePostView in different states.
@MainActor
final class CreatePostViewSnapshotTests: XCTestCase {
    // Test doubles
    private var mockPresenter: MockPostsPresenter!
    private var viewStateController: CreatePostViewStateController!
    
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPresenter = MockPostsPresenter()
        viewStateController = CreatePostViewStateController(with: mockPresenter)
        
        // Set isRecording based on your needs during test development
        // isRecording = true
    }
    
    override func tearDownWithError() throws {
        mockPresenter = nil
        viewStateController = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Snapshot Tests
    
    /// Tests an empty CreatePostView with no text or image.
    @MainActor
    func testCreatePostViewEmpty() throws {
        // Create the view with our mock presenter and a dummy dismiss action
        let createPostView = CreatePostView(
            presenter: mockPresenter,
            dismiss: {}
        )
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: createPostView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    /// Tests CreatePostView with text entered but no image selected.
    @MainActor
    func testCreatePostViewWithText() throws {
        // Set up the state with text
        viewStateController.setText("This is a test post that I'm writing to test the snapshot of the CreatePostView with text content.")
        
        // Create the actual CreatePostView that we want to test
        let createPostView = CreatePostView(
            presenter: mockPresenter,
            dismiss: {}
        )
        
        // Since we can't directly set the viewState of the CreatePostView,
        // we need to make our mock presenter return the prepared viewState
        // when the view is created
        mockPresenter.viewState = viewStateController.viewState
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: createPostView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    /// Tests CreatePostView with both text and an image selected.
    @MainActor
    func testCreatePostViewWithImage() throws {
        // Set up the state with text and image
        viewStateController.setText("Test post with an image")
        viewStateController.setImageName("photo")
        
        // Test user setup
        let testUser = User(name: "Test User", username: "@testuser", profileImageName: "person.fill")
        viewStateController.setSelectedUser(testUser)
        
        // Create the actual CreatePostView
        let createPostView = CreatePostView(
            presenter: mockPresenter,
            dismiss: {}
        )
        
        // Connect view state
        mockPresenter.viewState = viewStateController.viewState
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: createPostView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
        
        // Also test dark mode
        assertSnapshot(
            of: UIHostingController(rootView: createPostView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            named: "dark_mode"
        )
    }
}
