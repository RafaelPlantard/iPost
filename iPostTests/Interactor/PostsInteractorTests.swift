//
//  PostsInteractorTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import Foundation
import Testing
import SwiftData
@testable import iPosts

@MainActor
@Suite("PostsInteractor Tests")
struct PostsInteractorTests {
    @Test("Fetch users when database is empty should create dummy users")
    func fetchUsersWhenDatabaseIsEmpty() async throws {
        // GIVEN
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        let testContainer = try TestContainer()
        let mockModelActor = MockPostsModelActor(modelContainer: testContainer.container)

        // Setup test data and configure mock to return empty users list first time
        await mockModelActor.setupDefaultTestData()
        await mockModelActor.setEmptyUsersList()

        let sut = PostsInteractor(
            modelActor: mockModelActor,
            userPreferencesInteractor: mockUserPreferences
        )
        sut.presenter = mockPresenter

        // WHEN
        await sut.fetchUsers()

        // THEN
        #expect(await mockModelActor.fetchUsersCalled)
        #expect(await mockModelActor.setupDummyUsersCalled)
        #expect(mockPresenter.didFetchUsersCalled)
        #expect(!mockPresenter.didFetchUsersList.isEmpty)
    }

    @Test("Fetch users with existing users should return users")
    func fetchUsersWithExistingUsers() async throws {
        // GIVEN
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        let testContainer = try TestContainer()
        let mockModelActor = MockPostsModelActor(modelContainer: testContainer.container)

        // Setup test data and configure mock to return specific test users
        await mockModelActor.setupDefaultTestData()
        let testUser = User(name: "Test User", username: "@test", profileImageName: "person")
        let testUserDTO = UserDTO(from: testUser)
        await mockModelActor.setUsersList([testUserDTO])

        let sut = PostsInteractor(
            modelActor: mockModelActor,
            userPreferencesInteractor: mockUserPreferences
        )
        sut.presenter = mockPresenter

        // WHEN
        await sut.fetchUsers()

        // THEN
        #expect(await mockModelActor.fetchUsersCalled)
        #expect(!(await mockModelActor.setupDummyUsersCalled))
        #expect(mockPresenter.didFetchUsersCalled)
        #expect(mockPresenter.didFetchUsersList.count == 1)
    }

    @Test("Fetch posts should return posts in reverse chronological order")
    func fetchPostsInReverseChronologicalOrder() async throws {
        // GIVEN
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        let testContainer = try TestContainer()
        let mockModelActor = MockPostsModelActor(modelContainer: testContainer.container)

        // Setup test data
        await mockModelActor.setupDefaultTestData()

        // Create test data with controlled timestamps
        let user = User(name: "Test User", username: "@test", profileImageName: "person")

        let oldPost = Post(text: "Old post", author: user)
        oldPost.timestamp = Date(timeIntervalSinceNow: -3600) // 1 hour ago

        let newPost = Post(text: "New post", author: user)
        // Current time by default

        // Configure mock to return posts in reverse chronological order
        let oldPostDTO = PostDTO(from: oldPost)
        let newPostDTO = PostDTO(from: newPost)
        await mockModelActor.setPostsList([newPostDTO, oldPostDTO]) // Newer first

        let sut = PostsInteractor(
            modelActor: mockModelActor,
            userPreferencesInteractor: mockUserPreferences
        )
        sut.presenter = mockPresenter

        // WHEN
        await sut.fetchPosts()

        // THEN
        #expect(await mockModelActor.fetchPostsCalled)
        #expect(mockPresenter.didFetchPostsCalled)
        #expect(mockPresenter.didFetchPostsList.count == 2)
        #expect(mockPresenter.didFetchPostsList.first?.text == "New post")
        #expect(mockPresenter.didFetchPostsList.last?.text == "Old post")
    }

    @Test("Create post should add post to database and notify presenter")
    func createPost() async throws {
        // GIVEN
        let mockPresenter = MockPostsInteractorOutput()
        let mockUserPreferences = MockUserPreferencesInteractor()
        let testContainer = try TestContainer()
        let mockModelActor = MockPostsModelActor(modelContainer: testContainer.container)

        // Setup test data
        await mockModelActor.setupDefaultTestData()

        // Create test user
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        let userId = user.id

        // Configure mock to return a post
        let post = Post(text: "Test post content", imageName: "star.fill", author: user)
        let postDTO = PostDTO(from: post)
        await mockModelActor.setPostToReturn(postDTO)

        let sut = PostsInteractor(
            modelActor: mockModelActor,
            userPreferencesInteractor: mockUserPreferences
        )
        sut.presenter = mockPresenter

        // WHEN
        await sut.createPost(text: "Test post content", imageName: "star.fill", forUser: userId)

        // THEN
        #expect(await mockModelActor.createPostCalled)
        #expect(await mockModelActor.capturedText == "Test post content")
        #expect(await mockModelActor.capturedImageName == "star.fill")
        #expect(await mockModelActor.capturedForUserId == userId)
        #expect(mockPresenter.didCreatePostCalled)
        #expect(mockPresenter.didCreatePostParam?.text == "Test post content")
        #expect(mockPresenter.didCreatePostParam?.imageName == "star.fill")
    }

    @Test("Save selected user ID should store value in preferences")
    func saveSelectedUserId() async throws {
        // GIVEN
        let mockUserPreferences = MockUserPreferencesInteractor()
        let testContainer = try TestContainer()
        let mockModelActor = MockPostsModelActor(modelContainer: testContainer.container)

        let sut = PostsInteractor(
            modelActor: mockModelActor,
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
        let mockUserPreferences = MockUserPreferencesInteractor()
        let testContainer = try TestContainer()
        let mockModelActor = MockPostsModelActor(modelContainer: testContainer.container)

        let userId = UUID()
        mockUserPreferences.savedUserId = userId

        let sut = PostsInteractor(
            modelActor: mockModelActor,
            userPreferencesInteractor: mockUserPreferences
        )

        // WHEN
        let result = sut.getSelectedUserId()

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
