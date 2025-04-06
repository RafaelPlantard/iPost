//
//  PostsRouterProtocol.swift
//  iPost
//
//  Created by Rafael da Silva Ferreira on 06/04/25.
//

import SwiftUI

// PostsRouterProtocol: Protocol that defines the methods for navigating between views
@MainActor
protocol PostsRouterProtocol {
    func makeCreatePostView() -> AnyView
}

