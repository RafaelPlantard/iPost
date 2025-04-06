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

@MainActor
final class PostsViewSnapshotTests: XCTestCase {
    
    // Test helpers
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    private var interactor: PostsInteractor!
    private var router: PostsRouter!
    private var presenter: PostsPresenter!
    
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create an in-memory container for testing
        let schema = Schema([User.self, Post.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
        
        // Set up the VIPER components
        interactor = PostsInteractor(modelContext: modelContext)
        router = PostsRouter()
        presenter = PostsPresenter(interactor: interactor, router: router)
        
        // Connect components
        interactor.presenter = presenter
        router.presenter = presenter
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
        interactor = nil
        presenter = nil
        router = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Snapshot Tests
    
    @MainActor
    func testPostsViewEmpty() async throws {
        // Setup test user
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.fill")
        modelContext.insert(user)
        try modelContext.save()
        
        // Wait for data to be loaded
        await presenter.viewDidLoad()
        
        // Create the view with our presenter
        let postsView = PostsView(presenter: presenter)
        
        // Record snapshot
        assertSnapshot(
            matching: UIHostingController(rootView: postsView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    @MainActor
    func testPostsViewWithPosts() async throws {
        // Setup test user
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.fill")
        modelContext.insert(user)
        
        // Add sample posts
        let post1 = Post(text: "This is the first test post", author: user)
        let post2 = Post(text: "This is another test post with an image", imageName: "photo", author: user)
        let post3 = Post(text: "A third test post for good measure with a longer text content that should wrap to multiple lines", author: user)
        
        modelContext.insert(post1)
        modelContext.insert(post2)
        modelContext.insert(post3)
        
        try modelContext.save()
        
        // Wait for data to be loaded
        await presenter.viewDidLoad()
        
        // Create the view with our presenter
        let postsView = PostsView(presenter: presenter)
        
        // Record snapshot
        assertSnapshot(
            matching: UIHostingController(rootView: postsView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
        
        // Also test dark mode
        assertSnapshot(
            matching: UIHostingController(rootView: postsView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            named: "dark_mode"
        )
    }
    
    @MainActor
    func testPostsViewLoading() async throws {
        // Setup test user
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.fill")
        modelContext.insert(user)
        try modelContext.save()
        
        // Force loading state without waiting for viewDidLoad
        let postsView = PostsView(presenter: presenter)
        
        // Manually set loading state on the view state
        if let viewState = presenter.viewState as? PostsViewState {
            viewState.isLoading = true
        }
        
        // Record snapshot
        assertSnapshot(
            matching: UIHostingController(rootView: postsView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
}
