//
//  PostsModelActor.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftData

// Define a global actor for SwiftData operations
@globalActor actor PostsModelActor: GlobalActor {
    static let shared = PostsModelActor()

    // The ModelContext should only be accessed within this actor
    private var modelContext: ModelContext?

    // Initialize with a ModelContext
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - User Operations

    func fetchUser(withId id: UUID) async -> UserDTO? {
        guard let modelContext = modelContext else {
            return nil
        }

        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.id == id
            }
        )

        do {
            let users = try modelContext.fetch(descriptor)
            return users.first.map { UserDTO(from: $0) }
        } catch {
            return nil
        }
    }

    func fetchUsers() async -> [UserDTO] {
        guard let modelContext = modelContext else {
            return []
        }

        do {
            let descriptor = FetchDescriptor<User>()
            let users = try modelContext.fetch(descriptor)
            return users.map { UserDTO(from: $0) }
        } catch {
            return []
        }
    }

    func setupDummyUsers() async -> [UserDTO] {
        guard let modelContext = modelContext else {
            return []
        }

        // Create sample users with better profile images
        let users = [
            User(name: "John Doe", username: "@johndoe", profileImageName: "person.fill"),
            User(name: "Jane Smith", username: "@janesmith", profileImageName: "person.crop.circle.fill"),
            User(name: "Robert Johnson", username: "@robertj", profileImageName: "person.2.fill")
        ]

        // Add users to database
        for user in users {
            modelContext.insert(user)
        }

        // Create sample posts for each user with better images
        let post1 = Post(text: "Just started using iPost! Loving it so far!", author: users[0])
        let post2 = Post(text: "Working on a new project today #coding", author: users[1])
        let post3 = Post(text: "Beautiful weather for a hike!", imageName: "figure.hiking", author: users[2])
        let post4 = Post(text: "Check out this cool app I'm building", imageName: "laptopcomputer", author: users[0])
        let post5 = Post(text: "Just finished reading an amazing book!", imageName: "book.fill", author: users[1])

        // Add posts to database
        modelContext.insert(post1)
        modelContext.insert(post2)
        modelContext.insert(post3)
        modelContext.insert(post4)
        modelContext.insert(post5)

        do {
            try modelContext.save()
            return users.map { UserDTO(from: $0) }
        } catch {
            return []
        }
    }

    // MARK: - Post Operations

    func fetchPosts() async -> [PostDTO] {
        guard let modelContext = modelContext else {
            return []
        }

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

            // Convert to DTOs for safe actor boundary crossing
            return posts.map { PostDTO(from: $0) }
        } catch {
            return []
        }
    }

    func createPost(text: String, imageName: String?, forUser userId: UUID) async -> PostDTO? {
        guard let modelContext = modelContext else {
            return nil
        }

        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.id == userId
            }
        )

        guard let user = try? modelContext.fetch(descriptor).first else {
            return nil
        }

        // Create post with current timestamp
        let post = Post(text: text, imageName: imageName, author: user)
        user.posts?.append(post) // Ensure the post is linked to the user
        modelContext.insert(post)

        do {
            // Save immediately
            try modelContext.save()

            // Process pending changes to ensure data consistency
            modelContext.processPendingChanges()

            return PostDTO(from: post)
        } catch {
            return nil
        }
    }
}
