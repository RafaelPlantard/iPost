//
//  PostsPresenter.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftData
import Combine

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
}

// MARK: - PostsPresenter
final class PostsPresenter: ObservableObject {
    weak var view: PostsPresenterOutputProtocol?
    private let interactor: PostsInteractorInputProtocol
    private let router: PostsRouter
    
    // View state
    @Published private(set) var users: [User] = []
    @Published private(set) var posts: [Post] = []
    @Published private(set) var selectedUserId: UUID?
    
    init(view: PostsPresenterOutputProtocol, interactor: PostsInteractorInputProtocol, router: PostsRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - PostsPresenterInputProtocol
extension PostsPresenter: PostsPresenterInputProtocol {
    func viewDidLoad() {
        interactor.fetchUsers()
    }
    
    func createPost(text: String, imageName: String?) {
        guard let userId = selectedUserId else {
            view?.showError(message: "Please select a user first")
            return
        }
        
        interactor.createPost(text: text, imageName: imageName, forUser: userId)
    }
    
    func selectUser(id: UUID) {
        selectedUserId = id
        // When a user is selected, we might want to refresh the feed
        interactor.fetchPosts()
    }
}

// MARK: - PostsInteractorOutputProtocol
extension PostsPresenter: PostsInteractorOutputProtocol {
    func didFetchPosts(_ posts: [Post]) {
        self.posts = posts
        view?.showPosts(posts)
    }
    
    func didFetchUsers(_ users: [User]) {
        self.users = users
        view?.showUsers(users)
        
        // Select first user by default
        if let firstUser = users.first, selectedUserId == nil {
            selectedUserId = firstUser.id
        }
        
        // After users are fetched, we fetch posts
        interactor.fetchPosts()
    }
    
    func didCreatePost(_ post: Post) {
        // Refresh posts after creating a new one
        interactor.fetchPosts()
        view?.postCreated()
    }
    
    func onError(message: String) {
        view?.showError(message: message)
    }
}
