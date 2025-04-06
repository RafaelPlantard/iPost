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
            VStack {
            
                // User dropdown selector at the top
                if !viewState.users.isEmpty {
                    userSelectionPicker
                        .padding(.top)
                }
                
                // Posts list content
                if viewState.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Loading posts...")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else if viewState.posts.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "doc.text.image")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding()
                        Text("No posts yet")
                            .font(.title2)
                        Text("Create your first post by tapping the pencil icon.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewState.posts) { post in
                            PostRowView(post: post)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewState.isLoading = true
                        presenter.viewDidLoad()
                    }
                }
            }
            .navigationTitle("iPosts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewState.showCreatePost()
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $viewState.showCreatePostSheet) {
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
            .toast(message: $viewState.toast)
        }
    }
    
    // User selection picker component
    private var userSelectionPicker: some View {
        VStack(alignment: .leading) {
            Text("POSTING AS")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Menu {
                ForEach(viewState.users) { user in
                    Button(action: {
                        viewState.selectUser(id: user.id)
                    }) {
                        HStack {
                            Image(systemName: user.profileImageName)
                                .foregroundColor(.accentColor)
                            Text(user.name)
                            Spacer()
                            Text(user.username)
                                .foregroundColor(.gray)
                            if viewState.selectedUserId == user.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    let selectedUser = viewState.users.first(where: { $0.id == viewState.selectedUserId })
                    
                    Image(systemName: selectedUser?.profileImageName ?? "person.circle")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading) {
                        Text(selectedUser?.name ?? "Select User")
                            .font(.headline)
                        Text(selectedUser?.username ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
        }
    }
}

// MARK: - PostRowView
struct PostRowView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User info
            HStack {
                Image(systemName: post.author?.profileImageName ?? "person.circle")
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(post.author?.name ?? "Unknown User")
                        .font(.headline)
                    
                    Text(post.author?.username ?? "@unknown")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Post content
            Text(post.text)
                .font(.body)
                .padding(.vertical, 5)
            
            // Post image (if exists)
            if let imageName = post.imageName {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
            }
            
            // Post timestamp
            Text(post.timestamp, format: .relative(presentation: .named))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
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
