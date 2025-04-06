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

    // Sample system images for selection - all verified to work in iOS 17.6
    private let availableImages = [
        "photo", "camera", "car.fill", "airplane", "heart.fill",
        "star.fill", "figure.hiking", "gamecontroller.fill", "book.fill",
        "laptopcomputer", "desktopcomputer", "cup.and.saucer.fill",
        "fork.knife", "music.note", "film", "map", "graduationcap.fill",
        "sun.max.fill", "cloud.fill", "moon.stars.fill", "flame.fill"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // User information card
                        HStack(spacing: 16) {
                            // User profile image with gradient background
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.blue.opacity(0.7), .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 50, height: 50)

                                Image(systemName: viewState.selectedUser?.profileImageName ?? "person.circle")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewState.selectedUser?.name ?? "Select a user")
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                if let username = viewState.selectedUser?.username {
                                    Text(username)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            // Post status indicator
                            Text("Public")
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                )
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )

                        // Post content card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What's on your mind?")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)

                            // Text input area with placeholder text
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $viewState.postText)
                                    .frame(minHeight: 120)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.blue.opacity(0.3), .cyan.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: viewState.postText.isEmpty ? 1 : 2
                                            )
                                    )
                                    .accessibilityIdentifier("post-text-editor")

                                // Placeholder text that disappears when typing
                                if viewState.postText.isEmpty {
                                    Text("Share what's on your mind...")
                                        .foregroundColor(.gray.opacity(0.7))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 20)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )

                        // Image selection card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Add an image")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)

                            // Selected image preview or selection button
                            if let imageName = viewState.selectedImageName {
                                VStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.secondarySystemBackground))

                                        Image(systemName: imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .padding(16)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .cyan],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                                    Button(action: {
                                        viewState.removeImage()
                                    }) {
                                        Label("Remove Image", systemImage: "trash")
                                            .font(.subheadline.weight(.medium))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 16)
                                            .background(
                                                Capsule()
                                                    .fill(Color(.systemRed).opacity(0.1))
                                            )
                                            .foregroundColor(.red)
                                    }
                                }
                            } else {
                                Button(action: {
                                    viewState.showImagePickerView()
                                }) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.title2)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .cyan],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )

                                        Text("Select an Image")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.secondarySystemBackground))
                                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    )
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )

                        // Post button
                        Button(action: {
                            viewState.createPost()
                        }) {
                            Text("Post")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    Group {
                                        if viewState.postText.isEmpty || viewState.selectedUserId == nil {
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.6)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                                        } else {
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.blue, .cyan],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                                        }
                                    }
                                )
                        }
                        .disabled(viewState.postText.isEmpty || viewState.selectedUserId == nil)
                        .accessibilityIdentifier("create-post-submit-button")
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewState.dismissView()
                    }) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $viewState.showImagePicker) {
                imagePicker
            }
        }
    }

    private var imagePicker: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Search bar (non-functional but adds visual appeal)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        Text("Search icons")
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                    .padding(.horizontal)

                    // Category tabs (non-functional but adds visual appeal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(["All", "Recent", "Nature", "Tech", "Travel", "Food", "Sports"], id: \.self) { category in
                                Text(category)
                                    .font(category == "All" ? .subheadline.weight(.semibold) : .subheadline.weight(.regular))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Group {
                                            if category == "All" {
                                                Capsule()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [.blue.opacity(0.7), .cyan],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                            } else {
                                                Capsule()
                                                    .fill(Color(.systemBackground))
                                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                            }
                                        }
                                    )
                                    .foregroundStyle(category == "All" ? Color.white : Color.primary)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Grid of images with improved UI
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 16) {
                            ForEach(availableImages, id: \.self) { imageName in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewState.selectImage(imageName)
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color(.systemBackground))
                                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                                .frame(height: 100)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                )

                                            Image(systemName: imageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .padding(20)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.blue, .cyan],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                        .scaleEffect(viewState.selectedImageName == imageName ? 1.05 : 1.0)
                                        .shadow(color: viewState.selectedImageName == imageName ? .blue.opacity(0.3) : .clear, radius: 5, x: 0, y: 2)

                                        Text(imageName)
                                            .font(.caption)
                                            .foregroundColor(viewState.selectedImageName == imageName ? .blue : .secondary)
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(InteractionButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Select Image")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewState.hideImagePickerView()
                    }) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityIdentifier("image-picker-cancel-button")
                }
            }
        }
    }

    // createPost moved to ViewState
}

// The CreatePostView no longer directly conforms to PostsPresenterOutputProtocol
// Instead, the ViewState acts as this bridge
