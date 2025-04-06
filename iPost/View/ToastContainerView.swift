//
//  ToastContainerView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

struct ToastContainerView<Content: View>: View {
    @Binding var toast: ToastMessage?
    let content: Content
    
    init(toast: Binding<ToastMessage?>, @ViewBuilder content: () -> Content) {
        self._toast = toast
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            
            VStack {
                if let activeToast = toast {
                    ToastView(toast: activeToast) {
                        toast = nil
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
                }
                
                Spacer()
            }
            .animation(.easeInOut, value: toast != nil)
        }
    }
}

extension View {
    func toast(message: Binding<ToastMessage?>) -> some View {
        ToastContainerView(toast: message) {
            self
        }
    }
}
