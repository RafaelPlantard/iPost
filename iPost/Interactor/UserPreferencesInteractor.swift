//
//  UserPreferencesInteractor.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation

protocol UserPreferencesInteractorInputProtocol {
    func saveSelectedUserId(_ userId: UUID?)
    func getSelectedUserId() -> UUID?
}

final class UserPreferencesInteractor: UserPreferencesInteractorInputProtocol {
    private let userIdKey = "selected_user_id"
    
    func saveSelectedUserId(_ userId: UUID?) {
        UserDefaults.standard.set(userId?.uuidString, forKey: userIdKey)
    }
    
    func getSelectedUserId() -> UUID? {
        guard let uuidString = UserDefaults.standard.string(forKey: userIdKey),
              let uuid = UUID(uuidString: uuidString) else {
            return nil
        }
        return uuid
    }
}
