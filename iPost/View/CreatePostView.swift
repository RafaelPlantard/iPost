//
//  CreatePostView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var environmentDismiss
    private var presenter: PostsPresenterInputProtocol
    private var customDismiss: (() -> Void)?
    @ObservedObject private var viewState: CreatePostViewState

    init(presenter: PostsPresenterInputProtocol, dismiss: @escaping (() -> Void) = {}) {
        self.presenter = presenter
        self.customDismiss = dismiss
        self.viewState = CreatePostViewState(presenter: presenter, dismiss: { dismiss() })

        // We don't set presenter.viewState here anymore to avoid overriding the main PostsViewState
        // This was causing the bug where new posts weren't visible after creation
    }

    // Sample system images for selection
    private let availableImages = [
        "photo", "camera", "car.fill", "airplane", "heart.fill",
        "star.fill", "figure.hiking", "gamecontroller.fill", "book.fill",
        "laptopcomputer", "desktopcomputer", "cup.and.saucer.fill",
        "fork.knife", "music.note", "film", "map", "graduationcap.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Post content
                    TextField("What's on your mind?", text: $viewState.postText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .frame(minHeight: 100, alignment: .topLeading)
                }

                Section("Add an image") {
                    // Selected image preview
                    if let imageName = viewState.selectedImageName {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .foregroundColor(.accentColor)

                                Button("Remove Image") {
                                    viewState.removeImage()
                                }
                                .foregroundColor(.red)
                                .padding(.top, 8)
                            }
                            Spacer()
                        }
                    } else {
                        Button(action: {
                            viewState.showImagePickerView()
                        }) {
                            Label("Select an Image", systemImage: "photo.on.rectangle.angled")
                        }
                    }
                }

                // User information
                Section("Posting as") {
                    HStack {
                        Image(systemName: viewState.selectedUser?.profileImageName ?? "person.circle")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {
                            Text(viewState.selectedUser?.name ?? "Select a user")
                                .font(.headline)
                            if let username = viewState.selectedUser?.username {
                                Text(username)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            // No need for onAppear - ViewState is initialized with presenter data
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewState.dismissView()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        viewState.createPost()
                    }
                    .disabled(viewState.postText.isEmpty || viewState.selectedUserId == nil)
                    .bold()
                }
            }
            .sheet(isPresented: $viewState.showImagePicker) {
                imagePicker
            }
        }
    }

    private var imagePicker: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(availableImages, id: \.self) { imageName in
                        VStack {
                            Image(systemName: imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)

                            Text(imageName)
                                .font(.caption)
                        }
                        .onTapGesture {
                            viewState.selectImage(imageName)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        viewState.hideImagePickerView()
                    }
                }
            }
        }
    }

    // createPost moved to ViewState
}

// The CreatePostView no longer directly conforms to PostsPresenterOutputProtocol
// Instead, the ViewState acts as this bridge
