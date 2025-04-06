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
    private var dismissTask: Task<Void, Never>? = nil
    
    /// Singleton instance
    static let shared = ToastManager()
    
    private init() {}
    
    @MainActor
    func show(message: String, type: ToastMessage.ToastType, duration: TimeInterval = 3.0) {
        // Cancel any existing dismiss task
        dismissTask?.cancel()
        dismissTask = nil
        
        // Force a UI refresh by clearing and then setting with a small delay
        withAnimation(.easeOut(duration: 0.3)) {
            // First clear existing toast
            currentToast = nil
        }
        
        // Create a new toast with a slight delay for animation
        Task { @MainActor in
            // Small delay to ensure animation sequence works correctly
            try? await Task.sleep(for: .milliseconds(100))
            
            // Show the new toast with animation
            withAnimation(.spring(duration: 0.5)) {
                currentToast = ToastMessage(message: message, type: type, id: UUID())
                // We add a unique ID to force SwiftUI to recognize it as a new value
            }
            
            // Create a new task for auto-dismissal
            dismissTask = Task { @MainActor in
                do {
                    // Wait for the duration
                    try await Task.sleep(for: .seconds(duration))
                    // Only dismiss if not cancelled
                    if !Task.isCancelled {
                        withAnimation(.easeOut(duration: 0.3)) {
                            currentToast = nil
                        }
                    }
                } catch {
                    // Task was cancelled, do nothing
                }
            }
        }
    }
    
    @MainActor
    func dismiss() {
        // Cancel any existing dismiss task
        dismissTask?.cancel()
        dismissTask = nil
        
        // Animate the dismissal
        withAnimation(.easeOut(duration: 0.3)) {
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
