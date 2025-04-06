//
//  ErrorPresenter.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftUI
import Combine

final class ErrorPresenter: ObservableObject, ErrorPresenterInputProtocol {
    var view: ErrorPresenterOutputProtocol?
    private let router: ErrorRouterProtocol
    
    @Published private(set) var error: AppError?
    
    var errorMessage: String {
        error?.localizedDescription ?? "Unknown error"
    }
    
    var errorTitle: String {
        switch error {
        case .modelContainerCreationFailed:
            return "Database Error"
        case .dataFetchFailed:
            return "Data Load Error"
        case .dataInsertionFailed:
            return "Save Error"
        case .userNotFound:
            return "User Selection Error"
        case .unknown:
            return "Error"
        case .none:
            return "Error"
        }
    }
    
    init(router: ErrorRouterProtocol, error: AppError? = nil) {
        self.router = router
        self.error = error
    }
    
    func dismissError() {
        view?.errorDismissed()
    }
}
