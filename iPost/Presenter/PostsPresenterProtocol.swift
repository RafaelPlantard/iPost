//
//  PostsPresenterProtocol.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation

// PostsPresenterInputProtocol: Protocol that defines the methods the view can call on the presenter
protocol PostsPresenterInputProtocol: AnyObject {
    func viewDidLoad()
    func createPost(text: String, imageName: String?)
    func selectUser(id: UUID)
    var selectedUserId: UUID? { get }
    var users: [User] { get }
    var posts: [Post] { get }
}

// PostsPresenterOutputProtocol: Protocol that defines the methods the presenter can call on the ViewState
protocol PostsPresenterOutputProtocol: AnyObject {
    func updatePosts(_ posts: [Post])
    func updateUsers(_ users: [User])
    func showError(message: String)
    func postCreated()
    func updateSelectedUser(id: UUID?)
    func showToast(message: String, type: ToastMessage.ToastType)
}
