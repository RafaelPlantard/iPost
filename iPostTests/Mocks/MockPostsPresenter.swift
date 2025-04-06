//
//  MockPostsPresenter.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import Foundation
import SwiftUI
@testable import iPost

/// A mock implementation of the PostsPresenterInputProtocol for testing.
/// This class provides controlled behavior and state tracking for tests.
@MainActor
final class MockPostsPresenter: PostsPresenterInputProtocol {
    // MARK: - Properties for testing
    
    // State tracking
    var users: [User] = []
    var posts: [Post] = []
    var selectedUserId: UUID? = nil
    
    // Captured method calls for verification
    var capturedTexts: [String] = []
    var capturedImageNames: [String?] = []
    var viewDidLoadCalled = false
    var fetchPostsCalled = false
    var selectUserCalls: [UUID] = []
    
    // Allow injection of a custom viewState for testing
    var viewState: PostsPresenterOutputProtocol?
    
    // Mock user for testing
    let testUser = User(name: "Test User", username: "@testuser", profileImageName: "person.fill")
    
    init() {
        users = [testUser]
        selectedUserId = testUser.id
    }
    
    // MARK: - Protocol Implementation
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPosts() async {
        fetchPostsCalled = true
    }
    
    func createPost(text: String, imageName: String?) async {
        capturedTexts.append(text)
        capturedImageNames.append(imageName)
        
        // Simulate success behavior for tests
        viewState?.showToast(message: "Post created successfully", type: .success)
    }
    
    func selectUser(id: UUID) async {
        selectedUserId = id
        selectUserCalls.append(id)
        viewState?.updateSelectedUser(id: id)
    }
}
