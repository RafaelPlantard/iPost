//
//  MockPostsModelActor.swift
//  iPostTests
//
//  Created on 06/04/25.
//

@testable import iPosts

import Foundation
import SwiftData

// A mock implementation of PostsModelActorProtocol for testing
@ModelActor
actor MockPostsModelActor: PostsModelActorProtocol {
    // Test control properties
    var fetchUserCalled = false
    var fetchUsersCalled = false
    var setupDummyUsersCalled = false
    var fetchPostsCalled = false
    var createPostCalled = false

    // Test data
    private var userToReturn: UserDTO?
    private var usersToReturn: [UserDTO] = []
    private var dummyUsersToReturn: [UserDTO] = []
    private var postsToReturn: [PostDTO] = []
    private var postToReturn: PostDTO?

    // Captured parameters
    var capturedUserId: UUID?
    var capturedText: String?
    var capturedImageName: String?
    var capturedForUserId: UUID?

    // Setup methods for test data
    func setupDefaultTestData() {
        // Create some test data
        let user1 = UserDTO(from: User(name: "Test User 1", username: "@test1", profileImageName: "person.fill"))
        let user2 = UserDTO(from: User(name: "Test User 2", username: "@test2", profileImageName: "person.circle"))
        let user3 = UserDTO(from: User(name: "Test User 3", username: "@test3", profileImageName: "person.2.fill"))

        userToReturn = user1
        usersToReturn = [user1, user2, user3]
        dummyUsersToReturn = [user1, user2, user3]

        let post1 = PostDTO(from: Post(text: "Test post 1", author: User(name: "Test User 1", username: "@test1", profileImageName: "person.fill")))
        let post2 = PostDTO(from: Post(text: "Test post 2", author: User(name: "Test User 2", username: "@test2", profileImageName: "person.circle")))

        postsToReturn = [post1, post2]
        postToReturn = post1
    }

    // Methods to configure test data
    func setEmptyUsersList() {
        usersToReturn = []
    }

    func setUsersList(_ users: [UserDTO]) {
        usersToReturn = users
    }

    func setPostsList(_ posts: [PostDTO]) {
        postsToReturn = posts
    }

    func setPostToReturn(_ post: PostDTO) {
        postToReturn = post
    }

    // MARK: - Protocol Implementation

    func fetchUser(withId id: UUID) async -> UserDTO? {
        fetchUserCalled = true
        capturedUserId = id
        return userToReturn
    }

    func fetchUsers() async -> [UserDTO] {
        fetchUsersCalled = true
        return usersToReturn
    }

    func setupDummyUsers() async -> [UserDTO] {
        setupDummyUsersCalled = true
        return dummyUsersToReturn
    }

    func fetchPosts() async -> [PostDTO] {
        fetchPostsCalled = true
        return postsToReturn
    }

    func createPost(text: String, imageName: String?, forUser userId: UUID) async -> PostDTO? {
        createPostCalled = true
        capturedText = text
        capturedImageName = imageName
        capturedForUserId = userId
        return postToReturn
    }
}
