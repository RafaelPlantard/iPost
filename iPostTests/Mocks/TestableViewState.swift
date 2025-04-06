//
//  TestableViewState.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import Foundation
import SwiftUI
import Combine
@testable import iPosts

// Instead of subclassing, which won't work with final classes,
// we create a protocol for testable state management
protocol TestablePresentationState {
    func prepareForTesting()
}

// A wrapper for directly manipulating view state without subclassing
@MainActor
final class PostsViewStateController {
    let viewState: PostsViewState
    
    init(with presenter: PostsPresenterInputProtocol) {
        self.viewState = PostsViewState(presenter: presenter)
    }
    
    func setPosts(_ posts: [Post]) {
        viewState.posts = posts
        viewState.objectWillChange.send()
    }
    
    func setUsers(_ users: [User]) {
        viewState.users = users
        viewState.objectWillChange.send()
    }
    
    func setLoading(_ isLoading: Bool) {
        viewState.isLoading = isLoading
        viewState.objectWillChange.send()
    }
    
    func setSelectedUser(id: UUID?) {
        viewState.selectedUserId = id
        viewState.objectWillChange.send()
    }
    
    func showToast(message: String, type: ToastMessage.ToastType) {
        viewState.showToast(message: message, type: type)
    }
}

// A similar controller for CreatePostViewState
@MainActor
final class CreatePostViewStateController {
    let viewState: CreatePostViewState
    
    init(with presenter: PostsPresenterInputProtocol, dismiss: @escaping () -> Void = {}) {
        self.viewState = CreatePostViewState(presenter: presenter, dismiss: dismiss)
    }
    
    func setText(_ text: String) {
        viewState.postText = text
        viewState.objectWillChange.send()
    }
    
    func setImageName(_ imageName: String?) {
        viewState.selectedImageName = imageName
        viewState.objectWillChange.send()
    }
    
    func setSelectedUser(_ user: User?) {
        if let user = user {
            viewState.selectedUserId = user.id
            viewState.selectedUser = user
        } else {
            viewState.selectedUserId = nil
            viewState.selectedUser = nil
        }
        viewState.objectWillChange.send()
    }
}
