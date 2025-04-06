//
//  ToastContainerView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

/// A container view that shows toasts from the ToastManager
struct ToastContainerView<Content: View>: View {
    @StateObject private var toastManager = ToastManager.shared
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            
            VStack {
                if let activeToast = toastManager.currentToast {
                    ToastView(toast: activeToast)
                        .padding(.horizontal)
                        .padding(.top)
                        .zIndex(100)
                }
                
                Spacer()
            }
            .animation(.spring(), value: toastManager.currentToast)
        }
    }
}

/// Extension to add toast container to any view
extension View {
    func withToasts() -> some View {
        ToastContainerView {
            self
        }
    }
}
