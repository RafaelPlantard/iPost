//
//  Item.swift
//  iPost
//
//  Created by Rafael da Silva Ferreira on 06/04/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
