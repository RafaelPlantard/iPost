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
        // First fetch users to ensure we have a selected user
        interactor.fetchUsers()
        // Then fetch posts with a small delay to ensure the users are processed first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.interactor.fetchPosts()
        }
    }
    
    func createPost(text: String, imageName: String?) {
        guard let userId = selectedUserId else {
            viewState?.showError(message: "Please select a user first")
            return
        }
        
        // Show creating toast before dispatching to avoid UI hang
        viewState?.showToast(message: "Creating post...", type: .info)
        
        // Dispatch the creation to avoid blocking the UI thread
        // This helps prevent SwiftData-related hangs
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.interactor.createPost(text: text, imageName: imageName, forUser: userId)
        }
    }
    
    func selectUser(id: UUID) {
        selectedUserId = id
        // Notify the viewState of the user change
        viewState?.updateSelectedUser(id: id)
        // Save the selected user to persist between app launches
        interactor.saveSelectedUserId(id)
        // When a user is selected, we might want to refresh the feed
        fetchPosts()
    }
    
    func fetchPosts() {
        // Show a loading state first
        viewState?.isLoading = true
        interactor.fetchPosts()
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
        
        // Ensure view update is on main thread
        DispatchQueue.main.async { [weak self] in
            self?.viewState?.updatePosts(updatedPosts)
        }
    }
    
    func didFetchUsers(_ users: [User]) {
        // Make a copy of the array to ensure we're working with a new instance
        let updatedUsers = Array(users)
        self.users = updatedUsers
        
        // Ensure view update is on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewState?.updateUsers(updatedUsers)
            
            // If no user is selected, select the first one
            if self.selectedUserId == nil && !updatedUsers.isEmpty {
                self.selectUser(id: updatedUsers[0].id)
            }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.viewState?.showToast(message: "Post created successfully!", type: .success)
            
            // After the toast is shown, fetch posts to ensure our list stays in sync
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.interactor.fetchPosts()
            }
        }
    }
    
    func onError(message: String) {
        viewState?.showError(message: message)
    }
}
