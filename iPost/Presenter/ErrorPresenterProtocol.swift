//
//  ErrorPresenterProtocol.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation

protocol ErrorPresenterInputProtocol: AnyObject {
    func dismissError()
    var errorMessage: String { get }
    var errorTitle: String { get }
}

protocol ErrorPresenterOutputProtocol {
    func errorDismissed()
}
