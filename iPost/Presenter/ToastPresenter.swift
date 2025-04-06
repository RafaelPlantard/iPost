//
//  ToastPresenter.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import Combine

final class ToastPresenter: ObservableObject, ToastPresenterInputProtocol {
    var view: ToastPresenterOutputProtocol?
    
    @Published private(set) var currentToast: ToastMessage?
    
    func showToast(message: String, type: ToastMessage.ToastType) {
        let toast = ToastMessage(message: message, type: type)
        view?.displayToast(toast)
    }
    
    func hideToast() {
        view?.hideToast()
    }
}
