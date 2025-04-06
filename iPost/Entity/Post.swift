//
//  Post.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftData

@Model
final class Post {
    var id: UUID
    var text: String
    var imageName: String?
    var timestamp: Date
    var author: User?
    
    init(id: UUID = UUID(), text: String, imageName: String? = nil, timestamp: Date = Date(), author: User? = nil) {
        self.id = id
        self.text = text
        self.imageName = imageName
        self.timestamp = timestamp
        self.author = author
    }
}
