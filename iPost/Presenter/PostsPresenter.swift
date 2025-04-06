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
        // Notify view that post was created so it can dismiss sheet immediately
        viewState?.postCreated()
        
        // Show success toast after a small delay to allow the modal to dismiss first
        // This avoids potential UI jank during the dismissal animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.viewState?.showToast(message: "Post created successfully!", type: .success)
        }
        
        // Note: We don't need to call fetchPosts() here anymore as the interactor does this for us
    }
    
    func onError(message: String) {
        viewState?.showError(message: message)
    }
}
