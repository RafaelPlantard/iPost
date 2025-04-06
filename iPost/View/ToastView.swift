//
//  ToastView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

/// A view that shows a toast notification
final class ToastManager: ObservableObject {
    @Published var currentToast: ToastMessage?
    
    /// Singleton instance
    static let shared = ToastManager()
    
    private init() {}
    
    @MainActor
    func show(message: String, type: ToastMessage.ToastType, duration: TimeInterval = 3.0) {
        // Clear any existing toast first
        currentToast = nil
        
        // Slight delay to ensure animation works correctly when showing sequential toasts
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(50))
            currentToast = ToastMessage(message: message, type: type)
            
            // Auto dismiss after duration
            try? await Task.sleep(for: .seconds(duration))
            withAnimation {
                currentToast = nil
            }
        }
    }
    
    @MainActor
    func dismiss() {
        withAnimation {
            currentToast = nil
        }
    }
}

/// The actual toast view component
struct ToastView: View {
    let toast: ToastMessage
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.title3)
                .foregroundColor(.white)
            
            Text(toast.message)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer()
            
            Button(action: {
                ToastManager.shared.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(toast.type.backgroundColor)
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
