//
//  PostsInteractor.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftData

// PostsInteractorInputProtocol: Protocol that defines the methods the presenter can call on the interactor
protocol PostsInteractorInputProtocol {
    func fetchPosts()
    func createPost(text: String, imageName: String?, forUser userId: UUID)
    func fetchUsers()
    func setupDummyUsers()
    func saveSelectedUserId(_ userId: UUID?)
    func getSelectedUserId() -> UUID?
}

// PostsInteractorOutputProtocol: Protocol that defines the methods the interactor can call on the presenter
protocol PostsInteractorOutputProtocol: AnyObject {
    func didFetchPosts(_ posts: [Post])
    func didFetchUsers(_ users: [User])
    func didCreatePost(_ post: Post)
    func onError(message: String)
    func didSelectUser(_ userId: UUID)
}

// MARK: - PostsInteractor
class PostsInteractor {
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
            presenter?.onError(message: "Failed to fetch user: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - PostsInteractorInputProtocol
extension PostsInteractor: PostsInteractorInputProtocol {
    func saveSelectedUserId(_ userId: UUID?) {
        userPreferencesInteractor.saveSelectedUserId(userId)
    }
    
    func getSelectedUserId() -> UUID? {
        return userPreferencesInteractor.getSelectedUserId()
    }
    func fetchPosts() {
        do {
            let descriptor = FetchDescriptor<Post>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let posts = try modelContext.fetch(descriptor)
            presenter?.didFetchPosts(posts)
        } catch {
            presenter?.onError(message: "Failed to fetch posts: \(error.localizedDescription)")
        }
    }
    
    func createPost(text: String, imageName: String?, forUser userId: UUID) {
        guard let user = fetchUser(withId: userId) else {
            presenter?.onError(message: "User not found")
            return
        }
        
        let post = Post(text: text, imageName: imageName, author: user)
        modelContext.insert(post)
        
        do {
            try modelContext.save()
            presenter?.didCreatePost(post)
        } catch {
            presenter?.onError(message: "Failed to create post: \(error.localizedDescription)")
        }
    }
    
    func fetchUsers() {
        do {
            let descriptor = FetchDescriptor<User>()
            let users = try modelContext.fetch(descriptor)
            
            if users.isEmpty {
                setupDummyUsers()
            } else {
                presenter?.didFetchUsers(users)
                
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
    
    func setupDummyUsers() {
        // Create 3 dummy users
        let user1 = User(name: "John Doe", username: "@johndoe", profileImageName: "person.fill")
        let user2 = User(name: "Jane Smith", username: "@janesmith", profileImageName: "person.fill.viewfinder")
        let user3 = User(name: "Alex Johnson", username: "@alexj", profileImageName: "person.fill.checkmark")
        
        modelContext.insert(user1)
        modelContext.insert(user2)
        modelContext.insert(user3)
        
        // Create some sample posts
        let post1 = Post(text: "Just started using iPost! Loving it so far!", author: user1)
        let post2 = Post(text: "Working on a new project today #coding", author: user2)
        let post3 = Post(text: "Beautiful weather for a hike!", imageName: "figure.hiking", author: user3)
        let post4 = Post(text: "Check out this cool app I'm building", imageName: "app.fill", author: user1)
        
        modelContext.insert(post1)
        modelContext.insert(post2)
        modelContext.insert(post3)
        modelContext.insert(post4)
        
        do {
            try modelContext.save()
            
            let descriptor = FetchDescriptor<User>()
            let users = try modelContext.fetch(descriptor)
            presenter?.didFetchUsers(users)
            
            fetchPosts()
        } catch {
            presenter?.onError(message: "Failed to setup dummy data: \(error.localizedDescription)")
        }
    }
}
