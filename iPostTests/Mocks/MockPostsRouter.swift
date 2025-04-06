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
    
    // Add any router methods from the protocol here
    // For example, if your router has navigation methods:
    func navigateToPostDetails(post: Post) {
        navigatedToRoutes.append("post_details")
    }
    
    func navigateToUserProfile(user: User) {
        navigatedToRoutes.append("user_profile")
    }
}
