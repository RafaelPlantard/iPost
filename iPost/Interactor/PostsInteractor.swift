//
//  PostsInteractor.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftData

// PostsInteractorInputProtocol: Protocol that defines the methods the presenter can call on the interactor
@MainActor
protocol PostsInteractorInputProtocol {
    func fetchPosts() async
    func createPost(text: String, imageName: String?, forUser userId: UUID) async
    func fetchUsers() async
    func saveSelectedUserId(_ userId: UUID?)
    func getSelectedUserId() -> UUID?
}

// PostsInteractorOutputProtocol: Protocol that defines the methods the interactor can call on the presenter
@MainActor
protocol PostsInteractorOutputProtocol: AnyObject {
    func didFetchPosts(_ posts: [Post])
    func didFetchUsers(_ users: [User]) async
    func didCreatePost(_ post: Post)
    func onError(message: String)
    func didSelectUser(_ userId: UUID)
}

// MARK: - PostsInteractor
@MainActor
final class PostsInteractor: PostsInteractorInputProtocol, @unchecked Sendable {
    weak var presenter: PostsInteractorOutputProtocol?
    private let modelActor: PostsModelActor
    private let userPreferencesInteractor: UserPreferencesInteractorInputProtocol

    init(modelContext: ModelContext, userPreferencesInteractor: UserPreferencesInteractorInputProtocol = UserPreferencesInteractor()) {
        self.modelActor = PostsModelActor.shared
        self.userPreferencesInteractor = userPreferencesInteractor

        // Set the model context in the actor
        Task {
            await modelActor.setModelContext(modelContext)
        }
    }

    func saveSelectedUserId(_ userId: UUID?) {
        userPreferencesInteractor.saveSelectedUserId(userId)
    }

    func getSelectedUserId() -> UUID? {
        return userPreferencesInteractor.getSelectedUserId()
    }

    func fetchPosts() async {
        print("DEBUG: PostsInteractor.fetchPosts called")

        // Use the ModelActor to fetch posts safely
        let posts = await modelActor.fetchPosts()
        print("DEBUG: PostsInteractor.fetchPosts fetched \(posts.count) posts")

        // Notify presenter with the fresh data
        print("DEBUG: PostsInteractor calling presenter?.didFetchPosts with \(posts.count) posts")
        presenter?.didFetchPosts(posts)
    }

    func createPost(text: String, imageName: String?, forUser userId: UUID) async {
        print("DEBUG: PostsInteractor.createPost called with userId: \(userId)")

        // Use the ModelActor to create a post safely
        if let post = await modelActor.createPost(text: text, imageName: imageName, forUser: userId) {
            print("DEBUG: PostsInteractor.createPost - Created post with ID: \(post.id)")

            // Notify the presenter that post was created successfully
            print("DEBUG: PostsInteractor.createPost - Calling presenter?.didCreatePost")
            presenter?.didCreatePost(post)

            // Add a small delay to allow SwiftData to fully process the changes
            print("DEBUG: PostsInteractor.createPost - Waiting for 300ms before fetching posts")
            try? await Task.sleep(for: .milliseconds(300))

            // Explicitly fetch posts again to ensure the UI is updated
            print("DEBUG: PostsInteractor.createPost - Calling fetchPosts()")
            await fetchPosts()
        } else {
            print("DEBUG: PostsInteractor.createPost - Failed to create post")
            presenter?.onError(message: "Failed to create post")
        }
    }

    func fetchUsers() async {
        // Use the ModelActor to fetch users safely
        let users = await modelActor.fetchUsers()

        if users.isEmpty {
            // Setup dummy users if none exist
            let dummyUsers = await modelActor.setupDummyUsers()
            await presenter?.didFetchUsers(dummyUsers)

            // Select the first user by default
            if let firstUser = dummyUsers.first {
                saveSelectedUserId(firstUser.id)
                presenter?.didSelectUser(firstUser.id)
            }

            // Fetch posts after setting up dummy users
            await fetchPosts()
        } else {
            await presenter?.didFetchUsers(users)

            // Check if there's a saved user selection
            if let savedUserId = getSelectedUserId() {
                if users.contains(where: { $0.id == savedUserId }) {
                    presenter?.didSelectUser(savedUserId)
                } else if let firstUser = users.first {
                    // Fallback to first user if saved user doesn't exist anymore
                    saveSelectedUserId(firstUser.id)
                    presenter?.didSelectUser(firstUser.id)
                }
            } else if let firstUser = users.first {
                // Default to first user if none selected
                saveSelectedUserId(firstUser.id)
                presenter?.didSelectUser(firstUser.id)
            }
        }
    }
}
