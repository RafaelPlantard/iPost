//
//  ToastView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

struct ToastView: View {
    let message: ToastMessage
    
    // Internal animation state
    @State private var isVisible = false
    
    private var iconName: String {
        message.type.icon
    }
    
    private var backgroundColor: Color {
        message.type.backgroundColor
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(.white)
            
            Text(message.message)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = false
                }
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
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -20)
        .onAppear {
            // Appear with animation
            withAnimation(.spring(response: 0.3)) {
                isVisible = true
            }
            
            // Auto dismiss after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = false
                }
            }
        }
    }
}

// Toast modifier for any view
struct ToastModifier: ViewModifier {
    @Binding var toast: ToastMessage?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast = toast {
                    ToastView(message: toast)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            // Auto dismiss after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.toast = nil
                            }
                        }
                        .animation(.spring(), value: toast)
                }
            }
    }
}

extension View {
    func toast(message: Binding<ToastMessage?>) -> some View {
        self.modifier(ToastModifier(toast: message))
    }
}
