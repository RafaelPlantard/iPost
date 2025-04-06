//
//  ToastView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

struct ToastView: View {
    let toast: ToastMessage
    let onDismiss: () -> Void
    
    @State private var isShowing = false
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: toast.type.icon)
                    .foregroundColor(.white)
                Text(toast.message)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    withAnimation {
                        isShowing = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDismiss()
                        }
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(toast.type.backgroundColor)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
        .opacity(isShowing ? 1 : 0)
        .offset(y: isShowing ? 0 : -20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isShowing = true
            }
            
            // Auto-dismiss after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                if isShowing {
                    withAnimation(.easeIn(duration: 0.3)) {
                        isShowing = false
                    }
                    
                    // Allow animation to complete before dismissal
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }
            }
        }
    }
}
