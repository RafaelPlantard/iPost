//
//  PostsView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI
import SwiftData

struct PostsView: View {
    @ObservedObject var presenter: PostsPresenter
    @State private var showCreatePostSheet = false
    @State private var posts: [Post] = []
    @State private var users: [User] = []
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // User dropdown selector
                if !users.isEmpty {
                    userSelectionPicker
                }
                
                // Posts list
                List {
                    ForEach(posts) { post in
                        PostRowView(post: post)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    presenter.viewDidLoad()
                }
            }
            .navigationTitle("iPosts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreatePostSheet = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showCreatePostSheet) {
                CreatePostView(presenter: presenter)
            }
            .alert("Error", isPresented: $showingError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(errorMessage ?? "An unknown error occurred")
            })
            .onAppear {
                presenter.viewDidLoad()
            }
        }
    }
    
    // User selection picker component
    private var userSelectionPicker: some View {
        Menu {
            ForEach(users) { user in
                Button(action: {
                    presenter.selectUser(id: user.id)
                }) {
                    HStack {
                        Text(user.name)
                        if presenter.selectedUserId == user.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                let selectedUser = users.first(where: { $0.id == presenter.selectedUserId })
                Image(systemName: selectedUser?.profileImageName ?? "person.circle")
                Text(selectedUser?.name ?? "Select User")
                    .font(.headline)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
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

// MARK: - PostsPresenterOutputProtocol conformance
extension PostsView: PostsPresenterOutputProtocol {
    func showPosts(_ posts: [Post]) {
        self.posts = posts
    }
    
    func showUsers(_ users: [User]) {
        self.users = users
    }
    
    func showError(message: String) {
        self.errorMessage = message
        self.showingError = true
    }
    
    func postCreated() {
        self.showCreatePostSheet = false
    }
}

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
    
    // Initialize VIPER module
    let router = PostsRouter()
    let interactor = PostsInteractor(modelContext: modelContext)
    let view = PostsView()
    let presenter = PostsPresenter(view: view, interactor: interactor, router: router)
    
    router.presenter = presenter
    interactor.presenter = presenter
    view.presenter = presenter
    
    view
}
