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
final class PostsInteractor: PostsInteractorInputProtocol {
    weak var presenter: PostsInteractorOutputProtocol?
    private var modelContext: ModelContext
    private let userPreferencesInteractor: UserPreferencesInteractorInputProtocol

    init(modelContext: ModelContext, userPreferencesInteractor: UserPreferencesInteractorInputProtocol = UserPreferencesInteractor()) {
        self.modelContext = modelContext
        self.userPreferencesInteractor = userPreferencesInteractor
    }

    private func fetchUser(withId id: UUID) -> User? {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.id == id
            }
        )

        do {
            let users = try modelContext.fetch(descriptor)
            return users.first
        } catch {
            Task { @MainActor in
                presenter?.onError(message: "Failed to fetch user: \(error.localizedDescription)")
            }
            return nil
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
        do {
            // Force SwiftData to process any pending changes first
            modelContext.processPendingChanges()

            // Create descriptor with explicit fetch policy for fresh results
            var descriptor = FetchDescriptor<Post>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            descriptor.fetchLimit = 50 // Limit to prevent performance issues

            // Always include pending changes to ensure we get the latest data
            descriptor.includePendingChanges = true

            // Explicitly tell SwiftData we want a fresh fetch
            let posts = try modelContext.fetch(descriptor)
            print("DEBUG: PostsInteractor.fetchPosts fetched \(posts.count) posts")

            // Create a new array to ensure reference changes are detected
            let freshPosts = Array(posts)

            // Notify presenter with the fresh data
            print("DEBUG: PostsInteractor calling presenter?.didFetchPosts with \(freshPosts.count) posts")
            presenter?.didFetchPosts(freshPosts)
        } catch {
            print("DEBUG: PostsInteractor.fetchPosts error: \(error.localizedDescription)")
            presenter?.onError(message: "Failed to fetch posts: \(error.localizedDescription)")
        }
    }

    func createPost(text: String, imageName: String?, forUser userId: UUID) async {
        print("DEBUG: PostsInteractor.createPost called with userId: \(userId)")
        guard let user = fetchUser(withId: userId) else {
            print("DEBUG: PostsInteractor.createPost - User not found")
            presenter?.onError(message: "User not found")
            return
        }

        // Create post with current timestamp
        let post = Post(text: text, imageName: imageName, author: user)
        user.posts.append(post) // Ensure the post is linked to the user
        modelContext.insert(post)
        print("DEBUG: PostsInteractor.createPost - Created post with ID: \(post.id)")

        do {
            // Save immediately
            try modelContext.save()
            print("DEBUG: PostsInteractor.createPost - Saved to ModelContext")

            // Process pending changes to ensure data consistency
            modelContext.processPendingChanges()
            print("DEBUG: PostsInteractor.createPost - Processed pending changes")

            // Notify the presenter that post was created successfully
            print("DEBUG: PostsInteractor.createPost - Calling presenter?.didCreatePost")
            presenter?.didCreatePost(post)

            // Add a small delay to allow SwiftData to fully process the changes
            print("DEBUG: PostsInteractor.createPost - Waiting for 300ms before fetching posts")
            try await Task.sleep(for: .milliseconds(300))

            // Explicitly fetch posts again to ensure the UI is updated
            print("DEBUG: PostsInteractor.createPost - Calling fetchPosts()")
            await fetchPosts()
        } catch {
            print("DEBUG: PostsInteractor.createPost - Error: \(error.localizedDescription)")
            presenter?.onError(message: "Failed to create post: \(error.localizedDescription)")
        }
    }

    func fetchUsers() async {
        do {
            let descriptor = FetchDescriptor<User>()
            let users = try modelContext.fetch(descriptor)
            if users.isEmpty {
                await setupDummyUsers()
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
        } catch {
            presenter?.onError(message: "Failed to fetch users: \(error.localizedDescription)")
        }
    }

    private func setupDummyUsers() async {
        // Create sample users
        let users = [
            User(name: "John Doe", username: "@johndoe", profileImageName: "person.fill"),
            User(name: "Jane Smith", username: "@janesmith", profileImageName: "person.crop.circle.fill"),
            User(name: "Robert Johnson", username: "@robertj", profileImageName: "person.2.fill")
        ]

        // Add users to database
        for user in users {
            modelContext.insert(user)
        }

        // Create sample posts for each user
        let post1 = Post(text: "Just started using iPost! Loving it so far!", author: users[0])
        let post2 = Post(text: "Working on a new project today #coding", author: users[1])
        let post3 = Post(text: "Beautiful weather for a hike!", imageName: "figure.hiking", author: users[2])
        let post4 = Post(text: "Check out this cool app I'm building", imageName: "laptopcomputer.and.iphone", author: users[0])

        // Add posts to database
        modelContext.insert(post1)
        modelContext.insert(post2)
        modelContext.insert(post3)
        modelContext.insert(post4)

        do {
            try modelContext.save()

            // Fetch users to update presenter
            let descriptor = FetchDescriptor<User>()
            let fetchedUsers = try modelContext.fetch(descriptor)
            await presenter?.didFetchUsers(fetchedUsers)

            // Fetch posts after users
            await fetchPosts()
        } catch {
            presenter?.onError(message: "Failed to setup dummy data: \(error.localizedDescription)")
        }
    }
}
