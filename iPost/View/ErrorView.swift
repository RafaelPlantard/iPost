//
//  ErrorView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

struct ErrorView: View {
    @ObservedObject var presenter: ErrorPresenter
    let error: AppError
    @Environment(\.presentationMode) var presentationMode
    
    init(presenter: ErrorPresenter, error: AppError) {
        self.presenter = presenter
        self.error = error
    }
    
    // Initializer directly from error (for convenience)
    init(error: AppError) {
        let router = ErrorRouter()
        self.presenter = ErrorPresenter(router: router, error: error)
        self.error = error
        self.presenter.view = self
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .padding(.top, 30)
            
            Text(presenter.errorTitle)
                .font(.title)
                .fontWeight(.bold)
            
            Text(presenter.errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                presenter.dismissError()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("OK")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .frame(width: 300)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}

extension ErrorView: ErrorPresenterOutputProtocol {
    func errorDismissed() {
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    ErrorView(error: .modelContainerCreationFailed(description: "Database error"))
        .preferredColorScheme(.dark)
}
