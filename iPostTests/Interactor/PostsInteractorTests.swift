//
//  PostsInteractorTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftData
@testable import iPost

final class PostsInteractorTests: XCTestCase {
    
    private var sut: PostsInteractor!
    private var modelContext: ModelContext!
    private var mockPresenter: MockPostsInteractorOutput!
    private var mockUserPreferences: MockUserPreferencesInteractor!
    
    override func setUpWithError() throws {
        // Create in-memory SwiftData container for testing
        let schema = Schema([User.self, Post.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
        
        // Set up mocks
        mockPresenter = MockPostsInteractorOutput()
        mockUserPreferences = MockUserPreferencesInteractor()
        
        // Create the system under test with mocks
        sut = PostsInteractor(
            modelContext: modelContext,
            userPreferencesInteractor: mockUserPreferences
        )
        sut.presenter = mockPresenter
    }
    
    override func tearDownWithError() throws {
        sut = nil
        modelContext = nil
        mockPresenter = nil
        mockUserPreferences = nil
    }
    
    func testFetchUsers_whenDbEmpty_shouldCreateDummyUsers() async throws {
        // Given
        // Empty database (from setup)
        
        // When
        await sut.fetchUsers()
        
        // Then
        XCTAssertTrue(mockPresenter.didFetchUsersCalled)
        XCTAssertFalse(mockPresenter.didFetchUsersList.isEmpty)
        XCTAssertEqual(mockPresenter.didFetchUsersList.count, 3) // We expect 3 dummy users
    }
    
    func testFetchUsers_withExistingUsers_shouldReturnUsers() async throws {
        // Given
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        modelContext.insert(user)
        try modelContext.save()
        
        // When
        await sut.fetchUsers()
        
        // Then
        XCTAssertTrue(mockPresenter.didFetchUsersCalled)
        XCTAssertEqual(mockPresenter.didFetchUsersList.count, 1)
        XCTAssertEqual(mockPresenter.didFetchUsersList.first?.name, "Test User")
    }
    
    func testFetchPosts_returnsPostsInReverseChronologicalOrder() async throws {
        // Given
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        
        let oldPost = Post(text: "Old post", author: user)
        // Manipulate timestamps to ensure predictable order
        oldPost.timestamp = Date(timeIntervalSinceNow: -3600) // 1 hour ago
        
        let newPost = Post(text: "New post", author: user)
        // Current time by default
        
        modelContext.insert(user)
        modelContext.insert(oldPost)
        modelContext.insert(newPost)
        try modelContext.save()
        
        // When
        await sut.fetchPosts()
        
        // Then
        XCTAssertTrue(mockPresenter.didFetchPostsCalled)
        XCTAssertEqual(mockPresenter.didFetchPostsList.count, 2)
        
        // Verify newest post is first (reverse chronological order)
        XCTAssertEqual(mockPresenter.didFetchPostsList.first?.text, "New post")
        XCTAssertEqual(mockPresenter.didFetchPostsList.last?.text, "Old post")
    }
    
    func testCreatePost() async throws {
        // Given
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        modelContext.insert(user)
        try modelContext.save()
        
        // When
        await sut.createPost(text: "Test post content", imageName: "star.fill", forUser: user.id)
        
        // Then
        XCTAssertTrue(mockPresenter.didCreatePostCalled)
        XCTAssertEqual(mockPresenter.didCreatePostParam?.text, "Test post content")
        XCTAssertEqual(mockPresenter.didCreatePostParam?.imageName, "star.fill")
        XCTAssertEqual(mockPresenter.didCreatePostParam?.author?.id, user.id)
        
        // Also verify it's in the database
        let descriptor = FetchDescriptor<Post>()
        let posts = try modelContext.fetch(descriptor)
        XCTAssertEqual(posts.count, 1)
        XCTAssertEqual(posts.first?.text, "Test post content")
    }
    
    func testSaveSelectedUserId() {
        // Given
        let userId = UUID()
        
        // When
        sut.saveSelectedUserId(userId)
        
        // Then
        XCTAssertEqual(mockUserPreferences.savedUserId, userId)
    }
    
    func testGetSelectedUserId() {
        // Given
        let userId = UUID()
        mockUserPreferences.savedUserId = userId
        
        // When
        let result = sut.getSelectedUserId()
        
        // Then
        XCTAssertEqual(result, userId)
    }
}

// MARK: - Test Doubles

final class MockPostsInteractorOutput: PostsInteractorOutputProtocol {
    var didFetchPostsCalled = false
    var didFetchPostsList: [Post] = []
    
    var didFetchUsersCalled = false
    var didFetchUsersList: [User] = []
    
    var didCreatePostCalled = false
    var didCreatePostParam: Post?
    
    var didSelectUserCalled = false
    var didSelectUserParam: UUID?
    
    var onErrorCalled = false
    var onErrorMessage: String?
    
    func didFetchPosts(_ posts: [Post]) {
        didFetchPostsCalled = true
        didFetchPostsList = posts
    }
    
    func didFetchUsers(_ users: [User]) {
        didFetchUsersCalled = true
        didFetchUsersList = users
    }
    
    func didCreatePost(_ post: Post) {
        didCreatePostCalled = true
        didCreatePostParam = post
    }
    
    func didSelectUser(_ userId: UUID) {
        didSelectUserCalled = true
        didSelectUserParam = userId
    }
    
    func onError(message: String) {
        onErrorCalled = true
        onErrorMessage = message
    }
}

final class MockUserPreferencesInteractor: UserPreferencesInteractorInputProtocol {
    var savedUserId: UUID?
    
    func saveSelectedUserId(_ userId: UUID?) {
        savedUserId = userId
    }
    
    func getSelectedUserId() -> UUID? {
        return savedUserId
    }
}
