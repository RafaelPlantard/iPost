//
//  MockPostsRouter.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import Foundation
import SwiftUI
@testable import iPost

@MainActor
final class MockPostsRouter: PostsRouterProtocol {
    weak var presenter: PostsPresenterInputProtocol?

    // Track navigation actions for testing
    var navigatedToRoutes: [String] = []
    var makeCreatePostViewCalled = false

    // Implementation of PostsRouterProtocol
    func makeCreatePostView() -> AnyView {
        makeCreatePostViewCalled = true
        navigatedToRoutes.append("create_post")
        return AnyView(Text("Mock Create Post View"))
    }

    // Additional mock methods for testing
    func navigateToPostDetails(post: Post) {
        navigatedToRoutes.append("post_details")
    }

    func navigateToUserProfile(user: User) {
        navigatedToRoutes.append("user_profile")
    }
}
