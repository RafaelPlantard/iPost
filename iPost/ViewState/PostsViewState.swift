//
//  PostsViewState.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI
import Combine

final class PostsViewState: ObservableObject, PostsPresenterOutputProtocol {
    // UI state properties
    @Published var posts: [Post] = []
    @Published var users: [User] = []
    @Published var selectedUserId: UUID? = nil
    @Published var errorMessage: String? = nil
    @Published var showingError: Bool = false
    @Published var toast: ToastMessage? = nil
    @Published var showCreatePostSheet: Bool = false
    
    // Reference to the presenter for sending user actions
    private weak var presenter: PostsPresenterInputProtocol?
    
    init(presenter: PostsPresenterInputProtocol) {
        self.presenter = presenter
    }
    
    // MARK: - User actions
    
    func loadInitialData() {
        // Ensure UI is updated on the main thread
        DispatchQueue.main.async { [self] in
            presenter?.viewDidLoad()
        }
    }
    
    func selectUser(id: UUID) {
        presenter?.selectUser(id: id)
    }
    
    func createPost(text: String, imageName: String?) {
        presenter?.createPost(text: text, imageName: imageName)
    }
    
    func showCreatePost() {
        showCreatePostSheet = true
    }
    
    func hideCreatePost() {
        showCreatePostSheet = false
    }
    
    // MARK: - PostsPresenterOutputProtocol Implementation
    
    func updatePosts(_ posts: [Post]) {
        DispatchQueue.main.async { [weak self] in
            self?.posts = posts
        }
    }
    
    func updateUsers(_ users: [User]) {
        DispatchQueue.main.async { [weak self] in
            self?.users = users
        }
    }
    
    func updateSelectedUser(id: UUID?) {
        self.selectedUserId = id
    }
    
    func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.errorMessage = message
            self.showingError = true
        }
    }
    
    func showToast(message: String, type: ToastMessage.ToastType) {
        DispatchQueue.main.async { [weak self] in
            self?.toast = ToastMessage(message: message, type: type)
        }
    }
    
    func postCreated() {
        DispatchQueue.main.async { [weak self] in
            // First hide the sheet
            self?.showCreatePostSheet = false
            
            // Trigger a UI update by asking presenter to reload posts
            // We do this after a short delay to ensure the sheet has time to dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                self?.presenter?.viewDidLoad()
            }
        }
    }
}
