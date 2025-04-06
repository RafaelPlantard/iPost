//
//  PostsViewState.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI
import Combine

@MainActor
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
        presenter?.viewDidLoad()
    }
    
    func refreshPosts() async {
        // Explicit refresh action
        isLoading = true
        await presenter?.fetchPosts()
    }
    
    func selectUser(id: UUID) async {
        isLoading = true
        await presenter?.selectUser(id: id)
    }
    
    func createPost(text: String, imageName: String?) async {
        await presenter?.createPost(text: text, imageName: imageName)
    }
    
    func showCreatePost() {
        showCreatePostSheet = true
    }
    
    func hideCreatePost() {
        showCreatePostSheet = false
    }
    
    // MARK: - PostsPresenterOutputProtocol Implementation
    
    func updatePosts(_ posts: [Post]) {
        isLoading = false
        // Force view update with a new array instance
        self.posts = posts
        // Force view update by explicitly calling objectWillChange
        objectWillChange.send()
    }
    
    func updateUsers(_ users: [User]) {
        self.users = users
        objectWillChange.send()
    }
    
    func updateSelectedUser(id: UUID?) {
        self.selectedUserId = id
        objectWillChange.send()
    }
    
    func showError(message: String) {
        self.errorMessage = message
        self.showingError = true
    }
    
    func showToast(message: String, type: ToastMessage.ToastType) {
        // Use the toast manager instead of managing toast state ourselves
        ToastManager.shared.show(message: message, type: type)
    }
    
    func postCreated() {
        // First hide the sheet
        showCreatePostSheet = false
        
        // Show loading spinner while refreshing
        isLoading = true
        
        // Immediately fetch posts with no delay
        // This ensures the UI is updated with the latest posts right away
        Task {
            // No need for artificial delay as we're just waiting for the view to update
            await presenter?.fetchPosts()
            
            // This explicit call to objectWillChange ensures the UI rebuilds
            // even if SwiftUI doesn't detect the changes automatically
            objectWillChange.send()
        }
    }
}
