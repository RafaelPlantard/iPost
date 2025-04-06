//
//  PostsRouter.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftUI
import SwiftData

// PostsRouterProtocol: Protocol that defines the methods for navigating between views
protocol PostsRouterProtocol {
    func makeCreatePostView() -> AnyView
}

// MARK: - PostsRouter
class PostsRouter {
    private weak var presenter: PostsPresenterInputProtocol?
    
    init(presenter: PostsPresenterInputProtocol? = nil) {
        self.presenter = presenter
    }
    
    static func createModule(modelContext: ModelContext) -> (view: AnyView, presenter: PostsPresenterInputProtocol) {
        // Create router
        let router = PostsRouter()
        
        // Create interactor
        let interactor = PostsInteractor(modelContext: modelContext)
        
        // Create view
        let view = PostsView()
        
        // Create presenter and set dependencies
        let presenter = PostsPresenter(view: view, interactor: interactor, router: router)
        
        // Set presenter references
        router.presenter = presenter
        interactor.presenter = presenter
        view.presenter = presenter
        
        return (AnyView(view), presenter)
    }
}

// MARK: - PostsRouterProtocol
extension PostsRouter: PostsRouterProtocol {
    func makeCreatePostView() -> AnyView {
        // In a more complex app, we might pass dependencies here
        return AnyView(CreatePostView(presenter: presenter))
    }
}
