//
//  PostsView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI
import SwiftData

struct PostsView: View {
    // Following VIPER principles: use protocol for communication
    var presenter: PostsPresenterInputProtocol
    @ObservedObject private var stateManager = ViewStateManager()
    @State private var showCreatePostSheet = false
    
    // State management class to bridge between protocol and SwiftUI observability
    class ViewStateManager: ObservableObject {
        @Published var posts: [Post] = []
        @Published var users: [User] = []
        @Published var selectedUserId: UUID? = nil
        @Published var errorMessage: String? = nil
        @Published var showingError: Bool = false
        @Published var toast: ToastMessage? = nil
    }
    
    var body: some View {
        NavigationStack {
            VStack {
            
                // User dropdown selector at the top
                if !stateManager.users.isEmpty {
                    userSelectionPicker
                        .padding(.top)
                }
                
                // Posts list
                List {
                    ForEach(stateManager.posts) { post in
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
            .alert("Error", isPresented: $stateManager.showingError, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(stateManager.errorMessage ?? "An unknown error occurred")
            })
            .onAppear {
                presenter.viewDidLoad()
            }
            .toast(message: $stateManager.toast)
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
                ForEach(stateManager.users) { user in
                    Button(action: {
                        presenter.selectUser(id: user.id)
                    }) {
                        HStack {
                            Image(systemName: user.profileImageName)
                                .foregroundColor(.accentColor)
                            Text(user.name)
                            Spacer()
                            Text(user.username)
                                .foregroundColor(.gray)
                            if stateManager.selectedUserId == user.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    let selectedUser = stateManager.users.first(where: { $0.id == stateManager.selectedUserId })
                    
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

// MARK: - PostsPresenterOutputProtocol conformance
extension PostsView: PostsPresenterOutputProtocol {
    func showPosts(_ posts: [Post]) {
        stateManager.posts = posts
    }
    
    func showUsers(_ users: [User]) {
        stateManager.users = users
    }
    
    func showError(message: String) {
        stateManager.errorMessage = message
        stateManager.showingError = true
    }
    
    func postCreated() {
        self.showCreatePostSheet = false
    }
    
    func selectedUserChanged(id: UUID?) {
        stateManager.selectedUserId = id
    }
    
    func showToast(message: String, type: ToastMessage.ToastType) {
        stateManager.toast = ToastMessage(message: message, type: type)
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
    
    // Initialize VIPER module using the createModule helper
    let (view, _) = PostsRouter.createModule(modelContext: modelContext)
    
    return AnyView(view)
}
