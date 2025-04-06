//
//  CreatePostViewState.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI
import Combine

final class CreatePostViewState: ObservableObject, PostsPresenterOutputProtocol {
    // UI state properties
    @Published var postText: String = ""
    @Published var selectedImageName: String? = nil
    @Published var showImagePicker: Bool = false
    @Published var users: [User] = []
    @Published var selectedUserId: UUID? = nil
    @Published var selectedUser: User? = nil
    
    // Reference to the presenter for sending user actions
    private weak var presenter: PostsPresenterInputProtocol?
    private let dismiss: () -> Void
    
    init(presenter: PostsPresenterInputProtocol, dismiss: @escaping () -> Void) {
        self.presenter = presenter
        self.dismiss = dismiss
        
        // Initialize with data from presenter
        self.users = presenter.users
        self.selectedUserId = presenter.selectedUserId
        self.selectedUser = presenter.users.first(where: { $0.id == presenter.selectedUserId })
    }
    
    // MARK: - User actions
    
    func createPost() {
        guard let userId = selectedUserId else {
            // Handle error - need to select a user first
            return
        }
        
        // Save a copy of the entered text in case we need to restore it
        let savedText = postText
        let savedImageName = selectedImageName
        
        // Call the presenter to create the post
        presenter?.createPost(text: savedText, imageName: savedImageName)
        
        // Clear the form
        clearForm()
        
        // Dismiss the view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss()
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
        dismiss()
    }
    
    // MARK: - PostsPresenterOutputProtocol Implementation
    
    func updatePosts(_ posts: [Post]) {
        // Not needed in this view
    }
    
    func updateUsers(_ users: [User]) {
        self.users = users
    }
    
    func showError(message: String) {
        // Could be enhanced to show an error overlay or alert
    }
    
    func showToast(message: String, type: ToastMessage.ToastType) {
        // Toast is handled by the parent view
    }
    
    func postCreated() {
        clearForm()
        dismiss()
    }
    
    // MARK: - State updates
    
    func updateSelectedUser(id: UUID?) {
        selectedUserId = id
        selectedUser = users.first(where: { $0.id == id })
    }
    
    private func clearForm() {
        postText = ""
        selectedImageName = nil
        showImagePicker = false
    }
}
