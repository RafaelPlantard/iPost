//
//  ToastMessage.swift
//  iPost
//
//  Created on 06/04/25.
//

import Foundation
import SwiftUI

struct ToastMessage: Identifiable, Equatable {
    let id: UUID
    let message: String
    let type: ToastType
    var duration: TimeInterval = 3
    
    init(message: String, type: ToastType, duration: TimeInterval = 3, id: UUID = UUID()) {
        self.message = message
        self.type = type
        self.duration = duration
        self.id = id
    }
    
    enum ToastType {
        case success
        case error
        case warning
        case info
        
        var backgroundColor: Color {
            switch self {
            case .success: return Color.green
            case .error: return Color.red
            case .warning: return Color.orange
            case .info: return Color.blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle"
            case .error: return "exclamationmark.circle"
            case .warning: return "exclamationmark.triangle"
            case .info: return "info.circle"
            }
        }
    }
    
    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id
    }
}
