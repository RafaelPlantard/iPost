//
//  PostsView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI
import SwiftData

struct PostsView: View {
    // Following VIPER principles - ViewState pattern
    private var presenter: PostsPresenterInputProtocol
    @ObservedObject private var viewState: PostsViewState

    init(presenter: PostsPresenterInputProtocol) {
        self.presenter = presenter
        self.viewState = PostsViewState(presenter: presenter)

        // Connect viewState to presenter
        if let presenter = presenter as? PostsPresenter {
            presenter.viewState = viewState
        }
    }

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

                VStack(spacing: 0) {
                    // User dropdown selector at the top with improved styling
                    if !viewState.users.isEmpty {
                        userSelectionPicker
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                            .accessibilityIdentifier("user-picker")
                            .background(
                                Rectangle()
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                            )
                    }

                    // Posts list content
                    if viewState.isLoading {
                        Spacer()
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .frame(width: 80, height: 80)
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )

                            Text("Loading posts...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else if viewState.posts.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            // Empty state illustration
                            ZStack {
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 120, height: 120)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                                Image(systemName: "doc.text.image")
                                    .font(.system(size: 50))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .padding(.bottom, 10)

                            Text("No posts yet")
                                .font(.title2.bold())

                            Text("Create your first post by tapping the pencil icon.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            // Add post button
                            Button(action: {
                                viewState.showCreatePost()
                            }) {
                                Label("Create Post", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(
                                        Capsule()
                                            .fill(LinearGradient(
                                                colors: [.blue, .cyan],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ))
                                    )
                                    .foregroundColor(.white)
                                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            .padding(.top, 10)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewState.posts) { post in
                                    PostRowView(post: post)
                                        .accessibilityIdentifier("post-item")
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .refreshable {
                            await viewState.refreshPosts()
                        }
                    }
                }
            }
            .navigationTitle("iPosts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewState.showCreatePost()
                    }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 36, height: 36)
                                .shadow(color: .blue.opacity(0.3), radius: 3, x: 0, y: 2)

                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .accessibilityIdentifier("create-post-button")
                }
            }
            .sheet(isPresented: $viewState.showCreatePostSheet, onDismiss: {
                // Refresh posts when the sheet is dismissed
                Task {
                    await viewState.refreshPosts()
                }
            }) {
                CreatePostView(
                    presenter: presenter,
                    dismiss: { viewState.hideCreatePost() }
                )
            }
            .alert("Error", isPresented: $viewState.showingError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(viewState.errorMessage ?? "An unknown error occurred")
            })
            .onAppear {
                viewState.loadInitialData()
            }
            .withToasts()
        }
    }

    // User selection picker component
    private var userSelectionPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("POSTING AS")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .tracking(1.2) // Letter spacing
                .padding(.horizontal, 16)

            Menu {
                ForEach(viewState.users) { user in
                    Button(action: {
                        Task {
                            await viewState.selectUser(id: user.id)
                        }
                    }) {
                        HStack(spacing: 12) {
                            // User profile image with gradient background
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.blue.opacity(0.7), .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 30, height: 30)

                                Image(systemName: user.profileImageName)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.name)
                                    .font(.subheadline.weight(.medium))

                                Text(user.username)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if viewState.selectedUserId == user.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    let selectedUser = viewState.users.first(where: { $0.id == viewState.selectedUserId })

                    // User profile image with gradient background
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue.opacity(0.7), .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 40, height: 40)

                        Image(systemName: selectedUser?.profileImageName ?? "person.circle")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedUser?.name ?? "Select User")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(selectedUser?.username ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.down.circle.fill")
                        .font(.headline)
                        .foregroundStyle(LinearGradient(
                            colors: [.blue.opacity(0.7), .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - PostRowView
struct PostRowView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info
            HStack(spacing: 12) {
                // Profile image with gradient background
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue.opacity(0.7), .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)

                    Image(systemName: post.author?.profileImageName ?? "person.circle")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author?.name ?? "Unknown User")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(post.author?.username ?? "@unknown")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Timestamp with icon
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(post.timestamp, format: .relative(presentation: .named))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Post content with dynamic padding
            Text(post.text)
                .font(.body)
                .lineSpacing(4)
                .padding(.vertical, 8)
                .fixedSize(horizontal: false, vertical: true)

            // Post image (if exists) with improved styling
            if let imageName = post.imageName {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))

                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
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
            }

            // Interaction buttons
            HStack(spacing: 20) {
                Button(action: {}) {
                    Label("Like", systemImage: "heart")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Label("Comment", systemImage: "bubble.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

// The PostsView no longer directly conforms to PostsPresenterOutputProtocol
// Instead, the ViewState acts as this bridge

#Preview {
    let modelContainer = try! ModelContainer(for: Post.self, User.self)
    let modelContext = modelContainer.mainContext

    // Create dummy data
    let user = User(name: "Preview User", username: "@preview", profileImageName: "person.fill")
    let post1 = Post(text: "This is a preview post with an image!", imageName: "photo", author: user)
    let post2 = Post(text: "Another post for preview purposes.", author: user)

    modelContext.insert(user)
    modelContext.insert(post1)
    modelContext.insert(post2)

    // Initialize VIPER module using the createModule helper
    let (view, _) = PostsRouter.createModule(modelContext: modelContext)

    return AnyView(view)
}
