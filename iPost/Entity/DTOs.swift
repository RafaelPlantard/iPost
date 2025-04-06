//
//  DTOs.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation

// Sendable Data Transfer Objects for safe actor boundary crossing

// UserDTO: A Sendable representation of User
struct UserDTO: Sendable {
    let id: UUID
    let name: String
    let username: String
    let profileImageName: String
    
    init(from user: User) {
        self.id = user.id
        self.name = user.name
        self.username = user.username
        self.profileImageName = user.profileImageName
    }
}

// PostDTO: A Sendable representation of Post
struct PostDTO: Sendable {
    let id: UUID
    let text: String
    let imageName: String?
    let timestamp: Date
    let author: UserDTO?
    
    init(from post: Post) {
        self.id = post.id
        self.text = post.text
        self.imageName = post.imageName
        self.timestamp = post.timestamp
        self.author = post.author.map { UserDTO(from: $0) }
    }
}
