//
//  User.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftData

@Model
final class User {
    var id: UUID = UUID()
    var name: String = ""
    var username: String = ""
    var profileImageName: String = ""

    @Relationship(deleteRule: .cascade, inverse: \Post.author) var posts: [Post]? = []

    init(id: UUID = UUID(), name: String, username: String, profileImageName: String) {
        self.id = id
        self.name = name
        self.username = username
        self.profileImageName = profileImageName
    }
}
