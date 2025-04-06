//
//  PostsInteractorTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import Foundation
import Testing
import SwiftData
@testable import iPost

@MainActor
@Suite("PostsInteractor Tests")
struct PostsInteractorTests {
    @Test("Fetch users when database is empty should create dummy users")
    func fetchUsersWhenDatabaseIsEmpty() async throws {
        // GIVEN
        let testContainer = try TestContainer()
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        
        let sut = PostsInteractor(
            modelContext: testContainer.mainContext,
            userPreferencesInteractor: mockUserPreferences
        )
        sut.presenter = mockPresenter
        
        // WHEN
        await sut.fetchUsers()
        
        // THEN
        try await Task.sleep(for: .milliseconds(100)) // Wait for async operations to complete
        #expect(mockPresenter.didFetchUsersCalled)
        #expect(!mockPresenter.didFetchUsersList.isEmpty)
        #expect(mockPresenter.didFetchUsersList.count == 3) // We expect 3 dummy users
    }
    
    @Test("Fetch users with existing users should return users")
    func fetchUsersWithExistingUsers() async throws {
        // GIVEN
        let testContainer = try TestContainer()
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        
        // Add test user to database
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        testContainer.mainContext.insert(user)
        try testContainer.mainContext.save()
        
        let sut = PostsInteractor(
            modelContext: testContainer.mainContext,
            userPreferencesInteractor: mockUserPreferences
        )
        sut.presenter = mockPresenter
        
        // WHEN
        await sut.fetchUsers()
        
        // THEN
        #expect(mockPresenter.didFetchUsersCalled)
        #expect(mockPresenter.didFetchUsersList.count == 1)
        #expect(mockPresenter.didFetchUsersList.first?.id == user.id)
    }
    
    @Test("Fetch posts should return posts in reverse chronological order")
    func fetchPostsInReverseChronologicalOrder() async throws {
        // GIVEN
        let testContainer = try TestContainer()
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        
        // Create test data with controlled timestamps
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        
        let oldPost = Post(text: "Old post", author: user)
        oldPost.timestamp = Date(timeIntervalSinceNow: -3600) // 1 hour ago
        
        let newPost = Post(text: "New post", author: user)
        // Current time by default
        
        testContainer.mainContext.insert(user)
        testContainer.mainContext.insert(oldPost)
        testContainer.mainContext.insert(newPost)
        try testContainer.mainContext.save()
        
        let sut = PostsInteractor(
            modelContext: testContainer.mainContext,
            userPreferencesInteractor: mockUserPreferences
        )
        sut.presenter = mockPresenter
        
        // WHEN
        await sut.fetchPosts()
        
        // Allow async operations to complete
        try await Task.sleep(for: .milliseconds(100))
        
        // THEN
        try #expect(mockPresenter.didFetchPostsCalled)
        try #expect(mockPresenter.didFetchPostsList.count > 0)
        try #expect(mockPresenter.didFetchPostsList.contains(where: { $0.id == newPost.id }))
        try #expect(mockPresenter.didFetchPostsList.contains(where: { $0.id == oldPost.id }))
        try #expect(mockPresenter.didFetchPostsList.first?.text == "New post")
        try #expect(mockPresenter.didFetchPostsList.last?.text == "Old post")
    }
    
    @Test("Create post should add post to database and notify presenter")
    func createPost() async throws {
        // GIVEN
        let testContainer = try TestContainer()
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        testContainer.mainContext.insert(user)
        try testContainer.mainContext.save()
        
        let sut = PostsInteractor(
            modelContext: testContainer.mainContext,
            userPreferencesInteractor: mockUserPreferences
        )
        sut.presenter = mockPresenter
        
        // WHEN
        await sut.createPost(text: "Test post content", imageName: "star.fill", forUser: user.id)
        
        // Allow async operations to complete
        try await Task.sleep(for: .milliseconds(100))
        
        // THEN
        try #expect(mockPresenter.didCreatePostCalled)
        try #expect(mockPresenter.didCreatePostParam?.text == "Test post content")
        try #expect(mockPresenter.didCreatePostParam?.imageName == "star.fill")
        try #expect(mockPresenter.didCreatePostParam?.author?.id == user.id)
        
        // Also verify it's in the database
        let descriptor = FetchDescriptor<Post>()
        let posts = try testContainer.mainContext.fetch(descriptor)
        #expect(posts.count > 0)
        #expect(posts.contains { $0.text == "Test post content" })
    }
    
    @Test("Save selected user ID should store value in preferences")
    func saveSelectedUserId() async throws {
        // GIVEN
        let testContainer = try TestContainer()
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        
        let sut = PostsInteractor(
            modelContext: testContainer.mainContext,
            userPreferencesInteractor: mockUserPreferences
        )
        
        let userId = UUID()
        
        // WHEN
        sut.saveSelectedUserId(userId)
        
        // THEN
        #expect(mockUserPreferences.savedUserId == userId)
    }
    
    @Test("Get selected user ID should retrieve value from preferences")
    func getSelectedUserId() async throws {
        // GIVEN
        let testContainer = try TestContainer()
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        
        let userId = UUID()
        mockUserPreferences.savedUserId = userId
        
        let sut = PostsInteractor(
            modelContext: testContainer.mainContext,
            userPreferencesInteractor: mockUserPreferences
        )
        
        // WHEN
        let result = await sut.getSelectedUserId()
        
        // THEN
        #expect(result == userId)
    }
}

// MARK: - Test Doubles

@MainActor
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
    
    func didFetchUsers(_ users: [User]) async {
        await MainActor.run {
            didFetchUsersCalled = true
            didFetchUsersList = users
        }
    }
    
    func didCreatePost(_ post: Post) async {
        await MainActor.run {
            didCreatePostCalled = true
            didCreatePostParam = post
        }
    }
    
    func didSelectUser(_ userId: UUID) {
        Task { @MainActor in
            didSelectUserCalled = true
            didSelectUserParam = userId
        }
    }
    
    func onError(message: String) {
        Task { @MainActor in
            onErrorCalled = true
            onErrorMessage = message
        }
    }
}

@MainActor
final class MockUserPreferencesInteractor: UserPreferencesInteractorInputProtocol {
    var savedUserId: UUID?
    
    func saveSelectedUserId(_ userId: UUID?) {
        savedUserId = userId
    }
    
    func getSelectedUserId() -> UUID? {
        return savedUserId
    }
}

// MARK: - Test Helpers

@MainActor
final class TestContainer {
    let container: ModelContainer
    var mainContext: ModelContext { container.mainContext }
    
    init() throws {
        // Create in-memory container for testing
        let schema = Schema([User.self, Post.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
