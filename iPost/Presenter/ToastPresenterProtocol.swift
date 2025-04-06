//
//  ToastPresenterProtocol.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation

protocol ToastPresenterInputProtocol: AnyObject {
    func showToast(message: String, type: ToastMessage.ToastType)
    func hideToast()
}

protocol ToastPresenterOutputProtocol {
    func displayToast(_ toast: ToastMessage)
    func hideToast()
}
