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
    private let router: PostsRouter
    
    // State that's needed across views - exposed as per protocol requirements
    private(set) var users: [User] = []
    private(set) var posts: [Post] = []
    private(set) var selectedUserId: UUID?
    
    init(interactor: PostsInteractorInputProtocol, router: PostsRouter) {
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
    
    func createPost(text: String, imageName: String?) {
        guard let userId = selectedUserId else {
            viewState?.showError(message: "Please select a user first")
            return
        }
        
        // Show creating toast before dispatching to avoid UI hang
        viewState?.showToast(message: "Creating post...", type: .info)
        
        // Use Swift concurrency to handle the creation
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            await self.interactor.createPost(text: text, imageName: imageName, forUser: userId)
        }
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
        // First add the new post to our local array to update the UI immediately
        // This ensures we don't have to wait for a full refresh
        if !posts.contains(where: { $0.id == post.id }) {
            posts.insert(post, at: 0) // Add to the beginning since posts are shown newest first
            viewState?.updatePosts(posts) // Update UI with the modified array
        }
        
        // Notify view that post was created so it can dismiss sheet
        viewState?.postCreated()
        
        // Show success toast after a small delay to allow the modal to dismiss first
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            viewState?.showToast(message: "Post created successfully!", type: .success)
            
            // After the toast is shown, fetch posts to ensure our list stays in sync
            try? await Task.sleep(for: .milliseconds(500))
            await interactor.fetchPosts()
        }
    }
    
    func onError(message: String) {
        viewState?.showError(message: message)
    }
}
