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
    private let modelActor: PostsModelActorProtocol
    private let userPreferencesInteractor: UserPreferencesInteractorInputProtocol

    init(modelActor: PostsModelActorProtocol, userPreferencesInteractor: UserPreferencesInteractorInputProtocol = UserPreferencesInteractor()) {
        self.modelActor = modelActor
        self.userPreferencesInteractor = userPreferencesInteractor
    }

    func saveSelectedUserId(_ userId: UUID?) {
        userPreferencesInteractor.saveSelectedUserId(userId)
    }

    func getSelectedUserId() -> UUID? {
        return userPreferencesInteractor.getSelectedUserId()
    }

    func fetchPosts() async {
        // Use the ModelActor to fetch posts safely
        let postDTOs = await modelActor.fetchPosts()

        // Convert DTOs to model objects
        let posts = postDTOs.map { dto -> Post in
            let post = Post(text: dto.text, imageName: dto.imageName, timestamp: dto.timestamp)
            post.id = dto.id

            // If there's an author, create a User object
            if let authorDTO = dto.author {
                let author = User(name: authorDTO.name, username: authorDTO.username, profileImageName: authorDTO.profileImageName)
                author.id = authorDTO.id
                post.author = author
            }

            return post
        }

        // Notify presenter with the fresh data
        presenter?.didFetchPosts(posts)
    }

    func createPost(text: String, imageName: String?, forUser userId: UUID) async {
        // Use the ModelActor to create a post safely
        if let postDTO = await modelActor.createPost(text: text, imageName: imageName, forUser: userId) {
            // Convert DTO to model object
            let post = Post(text: postDTO.text, imageName: postDTO.imageName, timestamp: postDTO.timestamp)
            post.id = postDTO.id

            // If there's an author, create a User object
            if let authorDTO = postDTO.author {
                let author = User(name: authorDTO.name, username: authorDTO.username, profileImageName: authorDTO.profileImageName)
                author.id = authorDTO.id
                post.author = author
            }

            // Notify the presenter that post was created successfully
            presenter?.didCreatePost(post)

            // Add a small delay to allow SwiftData to fully process the changes
            try? await Task.sleep(for: .milliseconds(300))

            // Explicitly fetch posts again to ensure the UI is updated
            await fetchPosts()
        } else {
            presenter?.onError(message: "Failed to create post")
        }
    }

    func fetchUsers() async {
        // Use the ModelActor to fetch users safely
        let userDTOs = await modelActor.fetchUsers()

        // Convert DTOs to model objects
        let users = userDTOs.map { dto -> User in
            let user = User(name: dto.name, username: dto.username, profileImageName: dto.profileImageName)
            user.id = dto.id
            return user
        }

        if users.isEmpty {
            // Setup dummy users if none exist
            let dummyUserDTOs = await modelActor.setupDummyUsers()

            // Convert DTOs to model objects
            let dummyUsers = dummyUserDTOs.map { dto -> User in
                let user = User(name: dto.name, username: dto.username, profileImageName: dto.profileImageName)
                user.id = dto.id
                return user
            }

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
