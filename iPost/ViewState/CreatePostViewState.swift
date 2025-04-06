//
//  CreatePostViewState.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI
import Combine

final class CreatePostViewState: ObservableObject {
    // UI state properties
    @Published var postText: String = ""
    @Published var selectedImageName: String? = nil
    @Published var isLoading: Bool = false {
        willSet {
            // Ensure UI updates happen on the main thread
            if Thread.isMainThread {
                objectWillChange.send()
            } else {
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
        }
    }
    @Published var showImagePicker: Bool = false
    @Published var users: [User] = []
    @Published var selectedUserId: UUID? = nil
    @Published var selectedUser: User? = nil

    // Reference to the presenter for sending user actions
    private weak var presenter: PostsPresenterInputProtocol?
    private let dismiss: (() -> Void)?

    init(presenter: PostsPresenterInputProtocol, dismiss: @escaping (() -> Void)) {
        self.presenter = presenter
        self.dismiss = dismiss

        // Initialize with data from presenter
        if let concretePresenter = presenter as? PostsPresenter {
            // This approach gives us access to concrete presenter properties
            // but maintains protocol boundaries in the rest of the code
            self.users = concretePresenter.users
            self.selectedUserId = concretePresenter.selectedUserId
            self.selectedUser = concretePresenter.users.first(where: { $0.id == concretePresenter.selectedUserId })
        } else {
            // Fallback if we don't have direct access to concrete presenter
            self.users = presenter.users
            self.selectedUserId = presenter.selectedUserId
            self.selectedUser = presenter.users.first(where: { $0.id == presenter.selectedUserId })
        }
    }

    // MARK: - User actions

    func createPost() {
        guard selectedUserId != nil else {
            // Handle error - need to select a user first
            return
        }

        // Save a copy of the entered text in case we need to restore it
        let savedText = postText
        let savedImageName = selectedImageName

        // Show loading state
        isLoading = true
        objectWillChange.send()

        // Call the presenter to create the post
        Task {
            await presenter?.createPost(text: savedText, imageName: savedImageName)

            // Handle post creation completion
            await MainActor.run {
                handlePostCreated()
            }
        }
    }

    func selectImage(_ imageName: String) {
        selectedImageName = imageName
        showImagePicker = false
    }

    func removeImage() {
        selectedImageName = nil
    }

    func showImagePickerView() {
        showImagePicker = true
    }

    func hideImagePickerView() {
        showImagePicker = false
    }

    func dismissView() {
        clearForm()
        dismiss?()
    }

    // Handle post creation completion
    func handlePostCreated() {
        // Clear the form
        clearForm()

        // Dismiss the view
        Task {
            // Small delay to allow animations to complete
            try? await Task.sleep(for: .milliseconds(200))
            await MainActor.run {
                dismiss?()
            }
        }
    }

    // MARK: - State updates

    private func clearForm() {
        postText = ""
        selectedImageName = nil
        showImagePicker = false
    }
}
