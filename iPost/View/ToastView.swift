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
        HStack(spacing: 14) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 36, height: 36)

                Image(systemName: toast.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Message with improved typography
            Text(toast.message)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // Dismiss button with improved styling
            Button(action: {
                ToastManager.shared.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 20))
                    .padding(4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(
            ZStack {
                // Blurred background for depth
                RoundedRectangle(cornerRadius: 16)
                    .fill(toast.type.backgroundColor)

                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                toast.type.backgroundColor.opacity(0.9),
                                toast.type.backgroundColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Top highlight for 3D effect
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: toast.type.backgroundColor.opacity(0.5), radius: 8, x: 0, y: 4)
        )
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95, anchor: .top)),
            removal: .opacity.combined(with: .scale(scale: 0.95))
        ))
    }
}
