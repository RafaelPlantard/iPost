//
//  ErrorRouter.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

final class ErrorRouter: ErrorRouterProtocol {
    func presentErrorView(for error: AppError) -> AnyView {
        return AnyView(ErrorView(error: error))
    }
    
    static func createModule(error: AppError) -> AnyView {
        let router = ErrorRouter()
        let presenter = ErrorPresenter(router: router)
        let view = ErrorView(presenter: presenter, error: error)
        presenter.view = view
        
        return AnyView(view)
    }
}
