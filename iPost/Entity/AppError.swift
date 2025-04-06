//
//  AppError.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation

// Define different types of errors the app might encounter
enum AppError: Error {
    case modelContainerCreationFailed(description: String)
    case dataFetchFailed(description: String)
    case dataInsertionFailed(description: String)
    case userNotFound
    case unknown(description: String)
    
    var localizedDescription: String {
        switch self {
        case .modelContainerCreationFailed(let description):
            return "Failed to create model container: \(description)"
        case .dataFetchFailed(let description):
            return "Failed to fetch data: \(description)"
        case .dataInsertionFailed(let description):
            return "Failed to save data: \(description)"
        case .userNotFound:
            return "User not found. Please select a user."
        case .unknown(let description):
            return "An unknown error occurred: \(description)"
        }
    }
}
