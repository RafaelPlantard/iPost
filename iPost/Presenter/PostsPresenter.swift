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
    var view: PostsPresenterOutputProtocol?
    private let interactor: PostsInteractorInputProtocol
    private let router: PostsRouter
    
    // View state
    @Published private(set) var users: [User] = []
    @Published private(set) var posts: [Post] = []
    @Published private(set) var selectedUserId: UUID?
    
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
            view?.showError(message: "Please select a user first")
            return
        }
        
        // First notify view that post creation started (helps with animation timing)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Show toast first for better UX - it will appear as the modal animates away
            self.view?.showToast(message: "Creating post...", type: .info)
        }
        
        // Slight delay to allow UI to update before we process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.interactor.createPost(text: text, imageName: imageName, forUser: userId)
        }
    }
    
    func selectUser(id: UUID) {
        selectedUserId = id
        // Notify the view of the user change
        view?.selectedUserChanged(id: id)
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
        view?.selectedUserChanged(id: userId)
    }
    func didFetchPosts(_ posts: [Post]) {
        self.posts = posts
        view?.showPosts(posts)
    }
    
    func didFetchUsers(_ users: [User]) {
        self.users = users
        view?.showUsers(users)
        
        // Select first user by default
        if let firstUser = users.first, selectedUserId == nil {
            selectedUserId = firstUser.id
        }
        
        // After users are fetched, we fetch posts
        interactor.fetchPosts()
    }
    
    func didCreatePost(_ post: Post) {
        // Refresh posts after creating a new one
        interactor.fetchPosts()
        
        // First notify the view to close the sheet
        view?.postCreated()
        
        // Show success toast after a slight delay to ensure it appears after modal dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.view?.showToast(message: "Post created successfully!", type: .success)
        }
    }
    
    func onError(message: String) {
        view?.showError(message: message)
    }
}
