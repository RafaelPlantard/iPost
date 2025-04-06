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

// PostsPresenterOutputProtocol: Protocol that defines the methods the presenter can call on the view
protocol PostsPresenterOutputProtocol {
    func showPosts(_ posts: [Post])
    func showUsers(_ users: [User])
    func showError(message: String)
    func postCreated()
    func selectedUserChanged(id: UUID?)
}
