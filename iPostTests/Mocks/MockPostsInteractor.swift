//
//  MockPostsInteractor.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import Foundation
import SwiftUI
@testable import iPosts

@MainActor
final class MockPostsInteractor: PostsInteractorInputProtocol {
    weak var presenter: PostsInteractorOutputProtocol?
    private var storedUserId: UUID? = nil

    // Tracking properties for test verification
    var fetchPostsCalled = false
    var fetchUsersCalled = false
    var createPostCalled = false
    var createPostText: String = ""
    var createPostImageName: String? = nil
    var createPostUserId: UUID? = nil
    var saveSelectedUserIdCalled = false
    var savedUserId: UUID? = nil

    func fetchPosts() async {
        fetchPostsCalled = true
        // Do nothing in test by default
    }

    func createPost(text: String, imageName: String?, forUser userId: UUID) async {
        createPostCalled = true
        createPostText = text
        createPostImageName = imageName
        createPostUserId = userId

        // Create post and notify presenter
        if let presenter = presenter {
            let mockUser = User(
                id: userId,
                name: "Test User",
                username: "@testuser",
                profileImageName: "person.fill"
            )

            let post = Post(
                text: text,
                imageName: imageName,
                author: mockUser
            )

            presenter.didCreatePost(post)
        }
    }

    func fetchUsers() async {
        fetchUsersCalled = true

        // Return mock users if presenter exists
        if let presenter = presenter {
            let users = [
                User(name: "Test User 1", username: "@test1", profileImageName: "person.fill"),
                User(name: "Test User 2", username: "@test2", profileImageName: "person.circle.fill"),
                User(name: "Test User 3", username: "@test3", profileImageName: "person.2.fill")
            ]
            await presenter.didFetchUsers(users)
        }
    }

    func saveSelectedUserId(_ userId: UUID?) {
        saveSelectedUserIdCalled = true
        savedUserId = userId
        storedUserId = userId
    }

    func getSelectedUserId() -> UUID? {
        return storedUserId
    }

    // Helper methods for testing
    func simulateFetchPostsSuccess(posts: [Post]) async {
        if let presenter = presenter {
            presenter.didFetchPosts(posts)
        }
    }

    func simulateFetchPostsFailure(errorMessage: String) {
        if let presenter = presenter {
            presenter.onError(message: errorMessage)
        }
    }
}
