//
//  InteractionButtonStyle.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

struct InteractionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Preview
#Preview {
    VStack(spacing: 20) {
        Button(action: {}) {
            Label("Like", systemImage: "heart")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .buttonStyle(InteractionButtonStyle())
        
        Button(action: {}) {
            Label("Comment", systemImage: "bubble.right")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .buttonStyle(InteractionButtonStyle())
        
        Button(action: {}) {
            Label("Share", systemImage: "square.and.arrow.up")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .buttonStyle(InteractionButtonStyle())
    }
    .padding()
}
