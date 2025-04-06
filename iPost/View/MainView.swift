//
//  MainView.swift
//  iPost
//
//  Created by Rafael da Silva Ferreira on 06/04/25.
//

import SwiftUI

@MainActor
struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var contentView: AnyView? = nil

    var body: some View {
        ZStack {
            if let view = contentView {
                view
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        Task { @MainActor in
                            let (view, _) = PostsRouter.createModule(modelContext: modelContext)
                            contentView = view
                        }
                    }
            }
        }
    }
}
