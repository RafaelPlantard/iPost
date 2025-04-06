//
//  PostsRouter.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI
import SwiftData

// MARK: - PostsRouter
@MainActor
final class PostsRouter: PostsRouterProtocol {
    private weak var presenter: PostsPresenterInputProtocol?

    init(presenter: PostsPresenterInputProtocol? = nil) {
        self.presenter = presenter
    }

    @MainActor
    static func createModule(modelContext: ModelContext) -> (view: AnyView, presenter: PostsPresenterInputProtocol) {
        // Create router
        let router = PostsRouter()

        // Create user preferences interactor for persistence
        let userPreferencesInteractor = UserPreferencesInteractor()

        // Get the model container from the context
        let modelContainer = modelContext.container

        // Create model actor for SwiftData operations using the container
        let modelActor = PostsModelActor.shared(modelContainer: modelContainer)

        // Create main interactor with dependencies
        let interactor = PostsInteractor(modelActor: modelActor, userPreferencesInteractor: userPreferencesInteractor)

        // Create presenter (no view dependency)
        let presenter = PostsPresenter(interactor: interactor, router: router)

        // Create the view with presenter
        let view = PostsView(presenter: presenter)

        // Set presenter references (view/viewState connection happens in the view initializer)
        router.presenter = presenter
        interactor.presenter = presenter

        return (AnyView(view), presenter)
    }

    // MARK: - PostsRouterProtocol Implementation

    @MainActor
    func makeCreatePostView() -> AnyView {
        // In a more complex app, we might pass dependencies here
        guard let presentingPresenter = presenter else {
            return AnyView(Text("No presenter available"))
        }

        // Create view with dismiss callback - note this provides a protocol-based mechanism
        // for the view to communicate back to the router when it needs to dismiss
        return AnyView(CreatePostView(presenter: presentingPresenter))
    }
}
