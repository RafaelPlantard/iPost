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
    
    // State that's needed across views - not directly exposed to views
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
        interactor.fetchUsers()
    }
    
    func createPost(text: String, imageName: String?) {
        guard let userId = selectedUserId else {
            viewState?.showError(message: "Please select a user first")
            return
        }
        
        // First notify viewState that post creation started (helps with animation timing)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Show toast first for better UX - it will appear as the modal animates away
            self.viewState?.showToast(message: "Creating post...", type: .info)
        }
        
        // Call the interactor directly - viewState will handle UI updates
        interactor.createPost(text: text, imageName: imageName, forUser: userId)
    }
    
    func selectUser(id: UUID) {
        selectedUserId = id
        // Notify the viewState of the user change
        viewState?.updateSelectedUser(id: id)
        // Save the selected user to persist between app launches
        interactor.saveSelectedUserId(id)
        // When a user is selected, we might want to refresh the feed
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
        self.posts = posts
        viewState?.updatePosts(posts)
    }
    
    func didFetchUsers(_ users: [User]) {
        self.users = users
        viewState?.updateUsers(users)
        
        // After users are fetched, we fetch posts
        interactor.fetchPosts()
    }
    
    func didCreatePost(_ post: Post) {
        // Refresh posts after creating a new one
        interactor.fetchPosts()
        
        // First notify the viewState to close the sheet
        viewState?.postCreated()
        
        // Show success toast after a slight delay to ensure it appears after modal dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.viewState?.showToast(message: "Post created successfully!", type: .success)
        }
    }
    
    func onError(message: String) {
        viewState?.showError(message: message)
    }
}
