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

@MainActor
final class CreatePostViewSnapshotTests: XCTestCase {
    
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
        
        // Set up test data
        await setupTestData()
    }
    
    @MainActor
    private func setupTestData() async {
        // Create a test user
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.fill")
        modelContext.insert(user)
        
        // Set as selected user
        await presenter.selectUser(id: user.id)
        
        do {
            try modelContext.save()
        } catch {
            XCTFail("Failed to save test data: \(error)")
        }
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
    func testCreatePostViewEmpty() throws {
        // Create the view with our presenter
        let createPostView = CreatePostView(
            presenter: presenter,
            dismiss: {}
        )
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: createPostView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    @MainActor
    func testCreatePostViewWithText() throws {
        // Create the view with our presenter
        let createPostView = CreatePostView(
            presenter: presenter,
            dismiss: {}
        )
        
        // Create the view first
        let createPostView = CreatePostView(presenter: presenter, dismiss: {})
        
        // Create our own view state to manipulate
        let customViewState = CreatePostViewState(presenter: presenter, dismiss: {})
        customViewState.postText = "This is a test post that I'm writing to test the snapshot of the CreatePostView with text content."
        
        // Use reflection to override the presenter's viewState
        injectViewState(customViewState, into: presenter)
        
        // Record snapshot
        assertSnapshot(
            matching: UIHostingController(rootView: createPostView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    @MainActor
    func testCreatePostViewWithImage() throws {
        // Create the view with our presenter
        let createPostView = CreatePostView(
            presenter: presenter,
            dismiss: {}
        )
        
        // Create our own view state to manipulate
        let customViewState = CreatePostViewState(presenter: presenter, dismiss: {})
        customViewState.postText = "Test post with an image"
        customViewState.selectedImageName = "photo"
        
        // Use reflection to override the presenter's viewState
        injectViewState(customViewState, into: presenter)
        
        // Record snapshot
        assertSnapshot(
            matching: UIHostingController(rootView: createPostView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
        
        // Also test dark mode
        assertSnapshot(
            matching: UIHostingController(rootView: createPostView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            named: "dark_mode"
        )
    }
    
    // Helper method to inject a viewState into a presenter
    private func injectViewState(_ viewState: CreatePostViewState, into presenter: PostsPresenter) {
        // Using Objective-C runtime to modify private property
        let selector = Selector("setViewState:")
        if presenter.responds(to: selector) {
            presenter.perform(selector, with: viewState)
        }
    }
}
