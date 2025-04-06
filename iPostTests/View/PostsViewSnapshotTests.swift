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

// MARK: - Test Doubles 

@MainActor
final class MockPostsInteractor: PostsInteractorInputProtocol {
    weak var presenter: PostsInteractorOutputProtocol?
    
    func fetchPosts() async {
        // Do nothing in test
    }
    
    func createPost(text: String, imageName: String?, forUser userId: UUID) async {
        // Do nothing in test
    }
    
    func fetchUsers() async {
        // Do nothing in test
    }
    
    func saveSelectedUserId(_ userId: UUID?) {
        // Do nothing in test
    }
    
    func getSelectedUserId() -> UUID? {
        return nil
    }
}

@MainActor
final class MockPostsRouter: PostsRouterProtocol {
    weak var presenter: PostsPresenterInputProtocol?
    
    // Add any router methods if needed
}

@MainActor
final class TestablePostsViewState: PostsViewState {
    // Allow test-specific manipulation of state
    override init(presenter: PostsPresenterInputProtocol) {
        super.init(presenter: presenter)
    }
    
    // Helper to set posts directly for testing
    func setPosts(_ newPosts: [Post]) {
        posts = newPosts
        objectWillChange.send()
    }
    
    // Helper to set users directly for testing
    func setUsers(_ newUsers: [User]) {
        users = newUsers
        objectWillChange.send()
    }
    
    // Helper to set loading state
    func setLoading(_ loading: Bool) {
        isLoading = loading
        objectWillChange.send()
    }
}

// A testable wrapper that uses our custom view state
struct TestablePostsView: View {
    @ObservedObject var viewState: TestablePostsViewState
    private var presenter: PostsPresenterInputProtocol
    
    init(presenter: PostsPresenterInputProtocol, viewState: TestablePostsViewState) {
        self.presenter = presenter
        self.viewState = viewState
    }
    
    var body: some View {
        PostsView(presenter: presenter)
            .environmentObject(viewState)
    }
}

@MainActor
final class PostsViewSnapshotTests: XCTestCase {
    // Test components
    private var mockInteractor: MockPostsInteractor!
    private var mockRouter: MockPostsRouter!
    private var presenter: PostsPresenter!
    private var viewState: TestablePostsViewState!
    
    // Test data
    private var testUser: User!
    private var testPosts: [Post]!
    
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Set up test doubles
        mockInteractor = MockPostsInteractor()
        mockRouter = MockPostsRouter()
        presenter = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        
        // Connect components
        mockInteractor.presenter = presenter
        mockRouter.presenter = presenter
        
        // Create our testable view state
        viewState = TestablePostsViewState(presenter: presenter)
        
        // Initialize test data
        createTestData()
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
        presenter = nil
        viewState = nil
        testUser = nil
        testPosts = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Snapshot Tests
    
    @MainActor
    func testPostsViewEmpty() async throws {
        // Set up empty state with just a user
        viewState.setUsers([testUser])
        viewState.setPosts([])
        
        // Create our testable view
        let view = TestablePostsView(presenter: presenter, viewState: viewState)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    @MainActor
    func testPostsViewWithPosts() async throws {
        // Set up state with posts
        viewState.setUsers([testUser])
        viewState.setPosts(testPosts)
        
        // Create our testable view
        let view = TestablePostsView(presenter: presenter, viewState: viewState)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
        
        // Also test dark mode
        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            named: "dark_mode"
        )
    }
    
    @MainActor
    func testPostsViewLoading() async throws {
        // Set up loading state
        viewState.setUsers([testUser])
        viewState.setPosts([])
        viewState.setLoading(true)
        
        // Create our testable view
        let view = TestablePostsView(presenter: presenter, viewState: viewState)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
}
