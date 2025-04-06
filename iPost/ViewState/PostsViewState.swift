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
    @Published var isLoading: Bool = false
    
    // Reference to the presenter for sending user actions
    private weak var presenter: PostsPresenterInputProtocol?
    
    init(presenter: PostsPresenterInputProtocol) {
        self.presenter = presenter
    }
    
    // MARK: - User actions
    
    func loadInitialData() {
        // Show loading state
        isLoading = true
        DispatchQueue.main.async { [weak self] in
            self?.presenter?.viewDidLoad()
        }
    }
    
    func refreshPosts() {
        // Explicit refresh action
        isLoading = true
        presenter?.fetchPosts()
    }
    
    func selectUser(id: UUID) {
        isLoading = true
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
        DispatchQueue.main.async { [self] in
            isLoading = false
            // Force view update with a new array instance
            self.posts = posts
            
            // Force view update by explicitly calling objectWillChange
            objectWillChange.send()
        }
    }
    
    func updateUsers(_ users: [User]) {
        DispatchQueue.main.async { [self] in
            self.users = users
            objectWillChange.send()
        }
    }
    
    func updateSelectedUser(id: UUID?) {
        DispatchQueue.main.async { [self] in
            self.selectedUserId = id
            objectWillChange.send()
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.errorMessage = message
            self.showingError = true
        }
    }
    
    func showToast(message: String, type: ToastMessage.ToastType) {
        DispatchQueue.main.async { [self] in
            // Remove any existing toast first
            self.toast = nil
            
            // Small delay to ensure the toast appears as a new notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                // Set new toast and force update
                self.toast = ToastMessage(message: message, type: type)
                objectWillChange.send()
            }
        }
    }
    
    func postCreated() {
        DispatchQueue.main.async { [self] in
            // First hide the sheet
            showCreatePostSheet = false
            
            // Show loading spinner while refreshing
            isLoading = true
            
            // Trigger a UI update by asking presenter to reload posts
            // We do this after a short delay to ensure the sheet has time to dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                // Force refresh of data
                presenter?.viewDidLoad()
            }
        }
    }
}
