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
            case .success: return Color(red: 0.2, green: 0.8, blue: 0.4) // Vibrant green
            case .error: return Color(red: 0.9, green: 0.3, blue: 0.3) // Soft red
            case .warning: return Color(red: 0.95, green: 0.6, blue: 0.1) // Warm amber
            case .info: return Color(red: 0.2, green: 0.5, blue: 0.9) // Bright blue
            }
        }

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }

    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id
    }
}
