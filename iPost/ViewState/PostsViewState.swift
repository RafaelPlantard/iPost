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
        objectWillChange.send() // Force UI update to show loading indicator
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
        // Turn off loading state
        isLoading = false

        // Create a completely new array to force SwiftUI to detect the change
        let newPosts = Array(posts)

        // First send objectWillChange to notify observers that a change is coming
        objectWillChange.send()

        // Then update the posts property
        self.posts = newPosts

        // Send another objectWillChange to ensure the view updates
        // This helps overcome SwiftUI's optimization that might skip updates
        Task {
            try? await Task.sleep(for: .milliseconds(10))
            await MainActor.run {
                objectWillChange.send()
            }
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

        // Force a view update right now to ensure the loading indicator shows
        objectWillChange.send()

        // The presenter will handle fetching the posts after dismissal
        // and will call updatePosts() with the new data
    }
}
