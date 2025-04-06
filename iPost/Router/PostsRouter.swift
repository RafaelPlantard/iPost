//
//  PostsRouter.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI
import SwiftData

// MARK: - PostsRouter
final class PostsRouter: PostsRouterProtocol {
    private weak var presenter: PostsPresenterInputProtocol?
    
    init(presenter: PostsPresenterInputProtocol? = nil) {
        self.presenter = presenter
    }
    
    static func createModule(modelContext: ModelContext) -> (view: AnyView, presenter: PostsPresenterInputProtocol) {
        // Create router
        let router = PostsRouter()
        
        // Create interactor
        let interactor = PostsInteractor(modelContext: modelContext)
        
        // Create presenter first with a temporary dummy view implementation
        let presenter = PostsPresenter(interactor: interactor, router: router)
        
        // Now create the real view with the presenter
        let view = PostsView(presenter: presenter)
        
        // Update presenter with the real view
        presenter.view = view
        
        // Set presenter references
        router.presenter = presenter
        interactor.presenter = presenter
        
        return (AnyView(view), presenter)
    }

    // MARK: - PostsRouterProtocol Implementation

    func makeCreatePostView() -> AnyView {
        // In a more complex app, we might pass dependencies here
        guard let presentingPresenter = presenter else {
            return AnyView(Text("No presenter available"))
        }
        
        // Wrap the CreatePostView in a toast container
        return AnyView(CreatePostView(presenter: presentingPresenter))
    }
}
