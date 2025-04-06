//
//  CreatePostViewStateAdapter.swift
//  iPostTests
//
//  Created by Rafael da Silva Ferreira on 06/04/25.
//

@testable import iPosts

import Foundation

/// An adapter class that allows a CreatePostViewState to be used where a PostsPresenterOutputProtocol is expected
@MainActor
final class CreatePostViewStateAdapter: PostsPresenterOutputProtocol {
    private let viewState: CreatePostViewState

    var isLoading: Bool {
        get { return viewState.isLoading }
        set { viewState.isLoading = newValue }
    }

    init(viewState: CreatePostViewState) {
        self.viewState = viewState
    }

    func updatePosts(_ posts: [Post]) {
        // Not needed for CreatePostView tests
    }

    func updateUsers(_ users: [User]) {
        viewState.users = users
    }

    func updateSelectedUser(id: UUID?) {
        viewState.selectedUserId = id
        viewState.selectedUser = viewState.users.first(where: { $0.id == id })
    }

    func showError(message: String) {
        // Not needed for CreatePostView tests
    }

    func showToast(message: String, type: ToastMessage.ToastType) {
        // Not needed for CreatePostView tests
    }

    func postCreated() {
        viewState.handlePostCreated()
    }
}
