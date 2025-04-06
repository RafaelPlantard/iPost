//
//  PostsPresenterTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import XCTest
@testable import iPost

final class PostsPresenterTests: XCTestCase {
    
    private var sut: PostsPresenter!
    private var mockInteractor: MockPostsInteractor!
    private var mockRouter: MockPostsRouter!
    private var mockViewState: MockPostsViewState!
    
    override func setUpWithError() throws {
        // Create mocks
        mockInteractor = MockPostsInteractor()
        mockRouter = MockPostsRouter()
        mockViewState = MockPostsViewState()
        
        // Create system under test
        sut = PostsPresenter(interactor: mockInteractor, router: mockRouter)
        sut.viewState = mockViewState
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockInteractor = nil
        mockRouter = nil
        mockViewState = nil
    }
    
    @MainActor
    func testViewDidLoad_callsFetchUsers() async {
        // When
        sut.viewDidLoad()
        
        // Wait a bit for async tasks to complete
        let expectation = expectation(description: "Wait for async calls")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(mockInteractor.fetchUsersCalled)
    }
    
    @MainActor
    func testCreatePost_withNoSelectedUser_showsError() {
        // Given
        sut.selectedUserId = nil
        
        // When
        sut.createPost(text: "Test post", imageName: nil)
        
        // Then
        XCTAssertTrue(mockViewState.showErrorCalled)
        XCTAssertEqual(mockViewState.errorMessage, "Please select a user first")
        XCTAssertFalse(mockInteractor.createPostCalled)
    }
    
    @MainActor
    func testCreatePost_withSelectedUser_callsInteractor() async {
        // Given
        let userId = UUID()
        sut.selectedUserId = userId
        
        // When
        sut.createPost(text: "Test post", imageName: "image.name")
        
        // Wait a bit for async tasks to complete
        let expectation = expectation(description: "Wait for async calls")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(mockViewState.showToastCalled)
        XCTAssertEqual(mockViewState.toastMessage, "Creating post...")
        XCTAssertEqual(mockViewState.toastType, .info)
        
        XCTAssertTrue(mockInteractor.createPostCalled)
        XCTAssertEqual(mockInteractor.createPostText, "Test post")
        XCTAssertEqual(mockInteractor.createPostImageName, "image.name")
        XCTAssertEqual(mockInteractor.createPostUserId, userId)
    }
    
    @MainActor
    func testSelectUser_updatesSelectedUserId() {
        // Given
        let userId = UUID()
        
        // When
        sut.selectUser(id: userId)
        
        // Then
        XCTAssertEqual(sut.selectedUserId, userId)
        XCTAssertTrue(mockViewState.updateSelectedUserCalled)
        XCTAssertEqual(mockViewState.selectedUserId, userId)
        XCTAssertTrue(mockInteractor.saveSelectedUserIdCalled)
        XCTAssertEqual(mockInteractor.savedUserId, userId)
    }
    
    @MainActor
    func testDidFetchPosts_updatesViewState() {
        // Given
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        let posts = [
            Post(text: "Post 1", author: user),
            Post(text: "Post 2", author: user)
        ]
        
        // When
        sut.didFetchPosts(posts)
        
        // Then
        XCTAssertTrue(mockViewState.updatePostsCalled)
        XCTAssertEqual(mockViewState.posts.count, 2)
        XCTAssertEqual(mockViewState.posts[0].text, "Post 1")
        XCTAssertEqual(mockViewState.posts[1].text, "Post 2")
    }
    
    @MainActor
    func testDidFetchUsers_updatesViewState() {
        // Given
        let users = [
            User(name: "User 1", username: "@user1", profileImageName: "person.1"),
            User(name: "User 2", username: "@user2", profileImageName: "person.2")
        ]
        
        // When
        sut.didFetchUsers(users)
        
        // Then
        XCTAssertTrue(mockViewState.updateUsersCalled)
        XCTAssertEqual(mockViewState.users.count, 2)
        XCTAssertEqual(mockViewState.users[0].name, "User 1")
        XCTAssertEqual(mockViewState.users[1].name, "User 2")
    }
    
    @MainActor
    func testDidCreatePost_notifiesViewState() async {
        // Given
        let user = User(name: "Test User", username: "@test", profileImageName: "person")
        let post = Post(text: "New post", author: user)
        
        // When
        sut.didCreatePost(post)
        
        // Then
        XCTAssertTrue(mockViewState.postCreatedCalled)
        
        // Wait a bit for the async toast display
        let expectation = expectation(description: "Wait for async toast")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockViewState.showToastCalled)
        XCTAssertEqual(mockViewState.toastMessage, "Post created successfully!")
        XCTAssertEqual(mockViewState.toastType, .success)
    }
    
    @MainActor
    func testOnError_showsErrorInViewState() {
        // When
        sut.onError(message: "Test error")
        
        // Then
        XCTAssertTrue(mockViewState.showErrorCalled)
        XCTAssertEqual(mockViewState.errorMessage, "Test error")
    }
}

// MARK: - Test Doubles

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
    var mockSelectedUserId: UUID?
    
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
    
    func saveSelectedUserId(_ userId: UUID?) {
        saveSelectedUserIdCalled = true
        savedUserId = userId
    }
    
    func getSelectedUserId() -> UUID? {
        getSelectedUserIdCalled = true
        return mockSelectedUserId
    }
}

final class MockPostsRouter: PostsRouter {
    var makeCreatePostViewCalled = false
    
    override func makeCreatePostView() -> AnyView {
        makeCreatePostViewCalled = true
        return super.makeCreatePostView()
    }
}

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
