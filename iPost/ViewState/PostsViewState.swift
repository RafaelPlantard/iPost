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
        // Use a strong approach to ensure the view updates
        // First create a brand new array instance to force SwiftUI to detect the change
        let newPosts = Array(posts)
        
        // Then assign to our property
        self.posts = newPosts
        
        // Force UI update by explicitly sending the change notification on main actor
        Task { @MainActor in
            // Double objectWillChange to ensure the view rebuilds completely
            objectWillChange.send()
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms delay
            objectWillChange.send() // Send again to ensure any SwiftUI optimizations don't skip the update
        }
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
        // Make sure we're on the main actor when showing toast
        if Thread.isMainThread {
            // Use the toast manager to show the message
            ToastManager.shared.show(message: message, type: type)
        } else {
            // If we're not on the main thread, dispatch to main
            Task { @MainActor in
                ToastManager.shared.show(message: message, type: type)
            }
        }
    }
    
    func postCreated() {
        // First hide the sheet immediately 
        showCreatePostSheet = false
        
        // Show loading spinner while refreshing
        isLoading = true
        
        // We're going to use a complete UI refresh approach
        // The presenter will handle fetching the posts after dismissal
        // We focus purely on UI state management here
        
        // Force a view update right now to ensure the loading indicator shows
        objectWillChange.send()
    }
}
