//
//  PostsPresenter.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftData
import Combine

// MARK: - PostsPresenter
@MainActor
final class PostsPresenter: ObservableObject {
    weak var viewState: PostsPresenterOutputProtocol?
    private let interactor: PostsInteractorInputProtocol
    private let router: PostsRouterProtocol
    
    // State that's needed across views - exposed as per protocol requirements
    private(set) var users: [User] = []
    private(set) var posts: [Post] = []
    private(set) var selectedUserId: UUID?
    
    init(interactor: PostsInteractorInputProtocol, router: PostsRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - PostsPresenterInputProtocol
extension PostsPresenter: PostsPresenterInputProtocol {
    func viewDidLoad() {
        Task {
            // First fetch users to ensure we have a selected user
            await interactor.fetchUsers()
            
            // Then fetch posts with a small delay to ensure the users are processed first
            try? await Task.sleep(for: .milliseconds(100))
            await interactor.fetchPosts()
        }
    }
    
    func createPost(text: String, imageName: String?) async {
        guard let userId = selectedUserId else {
            viewState?.showError(message: "Please select a user first")
            return
        }
        
        // Show creating toast before creating the post
        // Add an explicit delay to ensure toast is visible
        viewState?.showToast(message: "Creating post...", type: .info)
        
        // Small delay to ensure the toast is displayed before heavy operations begin
        try? await Task.sleep(for: .milliseconds(200))
        
        // Since this method is now async, we can directly await the interactor call
        await interactor.createPost(text: text, imageName: imageName, forUser: userId)
    }
    
    func selectUser(id: UUID) async {
        selectedUserId = id
        // Notify the viewState of the user change
        viewState?.updateSelectedUser(id: id)
        // Save the selected user to persist between app launches
        interactor.saveSelectedUserId(id)
        // When a user is selected, we might want to refresh the feed
        await fetchPosts()
    }
    
    func fetchPosts() async {
        // Show a loading state first
        viewState?.isLoading = true
        await interactor.fetchPosts()
    }
}

// MARK: - PostsInteractorOutputProtocol
extension PostsPresenter: PostsInteractorOutputProtocol {
    func didSelectUser(_ userId: UUID) {
        selectedUserId = userId
        viewState?.updateSelectedUser(id: userId)
    }
    func didFetchPosts(_ posts: [Post]) {
        // Make a copy of the array to ensure we're working with a new instance
        let updatedPosts = Array(posts)
        self.posts = updatedPosts
        
        // Since we're using @MainActor, we're already on the main thread
        viewState?.updatePosts(updatedPosts)
    }
    
    func didFetchUsers(_ users: [User]) async {
        // Make a copy of the array to ensure we're working with a new instance
        let updatedUsers = Array(users)
        self.users = updatedUsers
        
        // Since we're using @MainActor, we're already on the main thread
        viewState?.updateUsers(updatedUsers)
        
        // If no user is selected, select the first one
        if selectedUserId == nil && !updatedUsers.isEmpty {
            await selectUser(id: updatedUsers[0].id)
        }
    }
    
    func didCreatePost(_ post: Post) {
        // We're going to use a different approach that's more reliable
        // Notify view that post was created so it can dismiss sheet first
        viewState?.postCreated()
        
        // Create a separate task for UI updates to avoid blocking
        Task { @MainActor in
            // Short delay to let the dismiss animation begin
            try? await Task.sleep(for: .milliseconds(100))
            
            // First show the success toast
            viewState?.showToast(message: "Post created successfully!", type: .success)
            
            // Perform a complete refresh from the database to ensure all
            // SwiftData observers are properly updated
            await interactor.fetchPosts()
            
            // Add newly created post to the beginning of our list
            // This ensures it's visible even if the fetch is delayed
            // But we need to check it's not already there first
            if !posts.contains(where: { $0.id == post.id }) {
                var updatedPosts = posts
                updatedPosts.insert(post, at: 0)
                self.posts = updatedPosts  // Update the presenter's copy
                viewState?.updatePosts(updatedPosts)  // Update the UI
            }
        }
    }
    
    func onError(message: String) {
        viewState?.showError(message: message)
    }
}
