//
//  PostsPresenterTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import Foundation
import SwiftUI
import SwiftData
import Testing
@testable import iPost

@MainActor
@Suite("PostsPresenter Tests")
struct PostsPresenterTests {

    @Test("viewDidLoad should call fetchUsers on interactor")
    func viewDidLoadCallsFetchUsers() async throws {
        // GIVEN
        let mockInteractor = MockPostsInteractor()
        let mockRouter = MockPostsRouter()
        let mockViewState = MockPostsViewState()
        
        let sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
        
        // WHEN
        sut.viewDidLoad()
        
        // Wait for async tasks to complete
        try await Task.sleep(for: .milliseconds(200))
        
        // THEN
        #expect(mockInteractor.fetchUsersCalled)
    }
    
    @Test("createPost with no selected user should show error")
    func createPostWithNoSelectedUserShowsError() async throws {
        // GIVEN
        let mockInteractor = MockPostsInteractor()
        let mockRouter = MockPostsRouter()
        let mockViewState = MockPostsViewState()
        
        let sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
        
        // WHEN
        await sut.createPost(text: "Test post", imageName: nil)
        
        // THEN
        #expect(mockViewState.showErrorCalled)
        #expect(mockViewState.errorMessage == "Please select a user first")
        #expect(!mockInteractor.createPostCalled)
    }
    
    @Test("createPost with selected user should call interactor")
    func createPostWithSelectedUserCallsInteractor() async throws {
        // GIVEN
        let mockInteractor = MockPostsInteractor()
        let mockRouter = MockPostsRouter()
        let mockViewState = MockPostsViewState()
        
        let sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
        
        let userId = UUID()
        // We need to use selectUser to set the selectedUserId since it's private(set)
        await sut.selectUser(id: userId)
        
        // WHEN
        await sut.createPost(text: "Test post", imageName: "image.name")
        
        // Wait for async tasks to complete
        try await Task.sleep(for: .milliseconds(200))
        
        // THEN
        #expect(mockViewState.showToastCalled)
        #expect(mockViewState.toastMessage == "Creating post...")
        #expect(mockViewState.toastType == .info)
        
        #expect(mockInteractor.createPostCalled)
        #expect(mockInteractor.createPostText == "Test post")
        #expect(mockInteractor.createPostImageName == "image.name")
        #expect(mockInteractor.createPostUserId == userId)
    }
    
    @Test("selectUser should update selectedUserId and notify viewState")
    func selectUserUpdatesSelectedUserId() async throws {
        // GIVEN
        let mockInteractor = MockPostsInteractor()
        let mockRouter = MockPostsRouter()
        let mockViewState = MockPostsViewState()
        
        let sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
        
        let userId = UUID()
        
        // WHEN
        await sut.selectUser(id: userId)
        
        // THEN
        #expect(sut.selectedUserId == userId)
        #expect(mockViewState.updateSelectedUserCalled)
        #expect(mockViewState.selectedUserId == userId)
        #expect(mockInteractor.saveSelectedUserIdCalled)
        #expect(mockInteractor.savedUserId == userId)
    }
    
    @Test("didFetchPosts should update viewState with posts")
    func didFetchPostsUpdatesViewState() async throws {
        // GIVEN
        let mockInteractor = MockPostsInteractor()
        let mockRouter = MockPostsRouter()
        let mockViewState = MockPostsViewState()
        
        let sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
        
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        let posts = [
            Post(text: "Post 1", author: user),
            Post(text: "Post 2", author: user)
        ]
        
        // WHEN
        sut.didFetchPosts(posts)
        
        // THEN
        #expect(mockViewState.updatePostsCalled)
        #expect(mockViewState.posts.count == 2)
        #expect(mockViewState.posts[0].text == "Post 1")
        #expect(mockViewState.posts[1].text == "Post 2")
    }
    
    @Test("didFetchUsers should update viewState with users")
    func didFetchUsersUpdatesViewState() async throws {
        // GIVEN
        let mockInteractor = MockPostsInteractor()
        let mockRouter = MockPostsRouter()
        let mockViewState = MockPostsViewState()
        
        let sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
        
        let users = [
            User(name: "User 1", username: "@user1", profileImageName: "person.1"),
            User(name: "User 2", username: "@user2", profileImageName: "person.2")
        ]
        
        // WHEN
        await sut.didFetchUsers(users)
        
        // THEN
        #expect(mockViewState.updateUsersCalled)
        #expect(mockViewState.users.count == 2)
        #expect(mockViewState.users[0].name == "User 1")
        #expect(mockViewState.users[1].name == "User 2")
    }
    
    @Test("didCreatePost should notify viewState and show success toast")
    func didCreatePostNotifiesViewState() async throws {
        // GIVEN
        let mockInteractor = MockPostsInteractor()
        let mockRouter = MockPostsRouter()
        let mockViewState = MockPostsViewState()
        
        let sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
        
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        let post = Post(text: "New post", author: user)
        
        // WHEN
        sut.didCreatePost(post)
        
        // THEN - First check if postCreated was called
        #expect(mockViewState.postCreatedCalled)
        
        // Wait for the async toast display
        try await Task.sleep(for: .milliseconds(500))
        
        // Then check toast was displayed
        #expect(mockViewState.showToastCalled)
        #expect(mockViewState.toastMessage == "Post created successfully!")
        #expect(mockViewState.toastType == .success)
    }
    
    @Test("onError should show error in viewState")
    func onErrorShowsErrorInViewState() async throws {
        // GIVEN
        let mockInteractor = MockPostsInteractor()
        let mockRouter = MockPostsRouter()
        let mockViewState = MockPostsViewState()
        
        let sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
        
        // WHEN
        sut.onError(message: "Test error")
        
        // THEN
        #expect(mockViewState.showErrorCalled)
        #expect(mockViewState.errorMessage == "Test error")
    }
    
    @Test("fetchPosts should update isLoading state")
    func fetchPostsUpdatesLoadingState() async throws {
        // GIVEN
        let mockInteractor = MockPostsInteractor()
        let mockRouter = MockPostsRouter()
        let mockViewState = MockPostsViewState()
        
        let sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
        
        // WHEN
        await sut.fetchPosts()
        
        // THEN
        #expect(mockViewState.isLoading)
        #expect(mockInteractor.fetchPostsCalled)
    }
}

// MARK: - Test Doubles

@MainActor
final class MockPostsInteractor: PostsInteractorInputProtocol {
    var fetchPostsCalled = false
    var fetchUsersCalled = false
    var createPostCalled = false
    var createPostText: String?
    var createPostImageName: String?
    var createPostUserId: UUID?
    var saveSelectedUserIdCalled = false
    var savedUserId: UUID?
    var getSelectedUserIdCalled = false
    
    // Since this is just for testing and UUID is a value type,
    // we can make this nonisolated
    nonisolated var mockSelectedUserId: UUID?
    
    func fetchPosts() async {
        fetchPostsCalled = true
    }
    
    func createPost(text: String, imageName: String?, forUser userId: UUID) async {
        createPostCalled = true
        createPostText = text
        createPostImageName = imageName
        createPostUserId = userId
    }
    
    func fetchUsers() async {
        fetchUsersCalled = true
    }
    
    nonisolated func saveSelectedUserId(_ userId: UUID?) {
        Task { @MainActor in
            saveSelectedUserIdCalled = true
            savedUserId = userId
        }
        mockSelectedUserId = userId
    }
    
    nonisolated func getSelectedUserId() -> UUID? {
        Task { @MainActor in
            getSelectedUserIdCalled = true
        }
        return mockSelectedUserId
    }
}

@MainActor
final class MockPostsRouter: PostsRouterProtocol {
    var makeCreatePostViewCalled = false
    
    func makeCreatePostView() -> SwiftUI.AnyView {
        makeCreatePostViewCalled = true
        return SwiftUI.AnyView(Text("Mock Create Post View"))
    }
}

@MainActor
final class MockPostsViewState: PostsPresenterOutputProtocol {
    var isLoading: Bool = false
    
    var updatePostsCalled = false
    var posts: [Post] = []
    
    var updateUsersCalled = false
    var users: [User] = []
    
    var updateSelectedUserCalled = false
    var selectedUserId: UUID?
    
    var showErrorCalled = false
    var errorMessage: String?
    
    var showToastCalled = false
    var toastMessage: String?
    var toastType: ToastMessage.ToastType?
    
    var postCreatedCalled = false
    
    func updatePosts(_ posts: [Post]) {
        updatePostsCalled = true
        self.posts = posts
    }
    
    func updateUsers(_ users: [User]) {
        updateUsersCalled = true
        self.users = users
    }
    
    func updateSelectedUser(id: UUID?) {
        updateSelectedUserCalled = true
        selectedUserId = id
    }
    
    func showError(message: String) {
        showErrorCalled = true
        errorMessage = message
    }
    
    func showToast(message: String, type: ToastMessage.ToastType) {
        showToastCalled = true
        toastMessage = message
        toastType = type
    }
    
    func postCreated() {
        postCreatedCalled = true
    }
}
