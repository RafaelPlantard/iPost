//
//  PostsPresenterProtocol.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation

// PostsPresenterInputProtocol: Protocol that defines the methods the view can call on the presenter
@MainActor
protocol PostsPresenterInputProtocol: AnyObject {
    var selectedUserId: UUID? { get }
    
    func viewDidLoad()
    func createPost(text: String, imageName: String?)
    func selectUser(id: UUID)
    func fetchPosts() // Add explicit fetch posts method for refreshing
}

// PostsPresenterOutputProtocol: Protocol that defines the methods the presenter can call on the ViewState
@MainActor
protocol PostsPresenterOutputProtocol: AnyObject {
    // View state updates
    func updatePosts(_ posts: [Post])
    func updateUsers(_ users: [User])
    func updateSelectedUser(id: UUID?)
    
    // Loading state
    var isLoading: Bool { get set }
    
    // Notifications
    func showError(message: String)
    func showToast(message: String, type: ToastMessage.ToastType)
    func postCreated()
}
