//
//  PostsViewSnapshotTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftUI
import SwiftData
import SnapshotTesting
@testable import iPost

/// Documentation for PostsViewSnapshotTests class.
/// This file contains snapshot tests for the PostsView component.

@MainActor
final class PostsViewSnapshotTests: XCTestCase {
    // Test components
    private var mockInteractor: MockPostsInteractor!
    private var mockRouter: MockPostsRouter!
    private var mockPresenter: MockPostsPresenter!
    private var viewStateController: PostsViewStateController!
    
    // Test data
    private var testUser: User!
    private var testPosts: [Post]!
    
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Set up test doubles
        mockInteractor = MockPostsInteractor()
        mockRouter = MockPostsRouter()
        mockPresenter = MockPostsPresenter()
        
        // Connect components 
        mockRouter.presenter = mockPresenter
        
        // Create view state controller
        viewStateController = PostsViewStateController(with: mockPresenter)
        
        // Initialize test data
        createTestData()
        
        // Set isRecording = true when creating new snapshots
        // isRecording = true
    }
    
    private func createTestData() {
        // Create test user
        testUser = User(name: "Test User", username: "@testuser", profileImageName: "person.fill")
        
        // Create test posts
        testPosts = [
            Post(text: "This is the first test post", author: testUser),
            Post(text: "This is another test post with an image", imageName: "photo", author: testUser),
            Post(text: "A third test post for good measure with a longer text content that should wrap to multiple lines", author: testUser)
        ]
    }
    
    override func tearDownWithError() throws {
        mockInteractor = nil
        mockRouter = nil
        mockPresenter = nil
        viewStateController = nil
        testUser = nil
        testPosts = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Snapshot Tests
    
    /// Tests the posts view in an empty state (no posts).
    @MainActor
    func testPostsViewEmpty() async throws {
        // Prepare mock presenter with test data
        mockPresenter.users = [testUser]
        mockPresenter.posts = []
        
        // Set up view state through controller
        viewStateController.setUsers([testUser])
        viewStateController.setPosts([])
        
        // Connect view state to presenter
        mockPresenter.viewState = viewStateController.viewState
        
        // Create actual PostsView with our mock presenter
        let postsView = PostsView(presenter: mockPresenter)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: postsView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    /// Tests the posts view with multiple posts displayed.
    @MainActor
    func testPostsViewWithPosts() async throws {
        // Prepare mock presenter with test data
        mockPresenter.users = [testUser]
        mockPresenter.posts = testPosts
        
        // Set up view state
        viewStateController.setUsers([testUser])
        viewStateController.setPosts(testPosts)
        
        // Connect view state to presenter
        mockPresenter.viewState = viewStateController.viewState
        
        // Create actual PostsView
        let postsView = PostsView(presenter: mockPresenter)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: postsView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
        
        // Also test dark mode
        assertSnapshot(
            of: UIHostingController(rootView: postsView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            named: "dark_mode"
        )
    }
    
    /// Tests the posts view in a loading state.
    @MainActor
    func testPostsViewLoading() async throws {
        // Set up presenter with minimal data
        mockPresenter.users = [testUser]
        mockPresenter.posts = []
        
        // Set up loading state
        viewStateController.setUsers([testUser])
        viewStateController.setPosts([])
        viewStateController.setLoading(true)
        
        // Connect view state to presenter
        mockPresenter.viewState = viewStateController.viewState
        
        // Create actual PostsView
        let postsView = PostsView(presenter: mockPresenter)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: postsView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
}
