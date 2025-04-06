//
//  ErrorRouterProtocol.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

protocol ErrorRouterProtocol {
    func presentErrorView(for error: AppError) -> AnyView
}
