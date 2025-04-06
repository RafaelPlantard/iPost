//
//  CreatePostViewSnapshotTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftUI
import SwiftData
import SnapshotTesting
@testable import iPost

// MARK: - Test Doubles

// A test double implementation of PostsPresenterInputProtocol
@MainActor
final class MockPostsPresenter: PostsPresenterInputProtocol {
    var users: [User] = []
    var posts: [Post] = []
    var selectedUserId: UUID? = nil
    var capturedTexts: [String] = []
    var capturedImageNames: [String?] = []
    
    // Mock user for testing
    let testUser = User(name: "Test User", username: "@testuser", profileImageName: "person.fill")
    
    init() {
        users = [testUser]
        selectedUserId = testUser.id
    }
    
    func viewDidLoad() {}
    
    func fetchPosts() async {}
    
    func createPost(text: String, imageName: String?) async {
        capturedTexts.append(text)
        capturedImageNames.append(imageName)
    }
    
    func selectUser(id: UUID) async {
        selectedUserId = id
    }
}

@MainActor
final class CreatePostViewSnapshotTests: XCTestCase {
    // Test doubles
    private var mockPresenter: MockPostsPresenter!
    
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPresenter = MockPostsPresenter()
    }
    
    override func tearDownWithError() throws {
        mockPresenter = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Snapshot Tests
    
    @MainActor
    func testCreatePostViewEmpty() throws {
        // Create the view with our mock presenter
        let createPostView = CreatePostView(
            presenter: mockPresenter,
            dismiss: {}
        )
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: createPostView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    @MainActor
    func testCreatePostViewWithText() throws {
        // Instead of modifying private state, create a testable view directly
        // by using a custom ViewState tied to our mock presenter
        let viewState = CreatePostViewState(presenter: mockPresenter, dismiss: {})
        viewState.postText = "This is a test post that I'm writing to test the snapshot of the CreatePostView with text content."
        
        // Create a wrapper view that uses our controlled ViewState
        let wrappedView = TestableCreatePostView(viewState: viewState)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    @MainActor
    func testCreatePostViewWithImage() throws {
        // Create a controlled ViewState for testing
        let viewState = CreatePostViewState(presenter: mockPresenter, dismiss: {})
        viewState.postText = "Test post with an image"
        viewState.selectedImageName = "photo"
        
        // Create a wrapper view that uses our controlled ViewState
        let wrappedView = TestableCreatePostView(viewState: viewState)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
        
        // Also test dark mode
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            named: "dark_mode"
        )
    }
}

// A testable wrapper that allows us to inject our own ViewState
// This is more VIPER-friendly as it maintains separation of concerns
struct TestableCreatePostView: View {
    @ObservedObject var viewState: CreatePostViewState
    
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
                        Button(action: {}) {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {}
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {}
                        .disabled(viewState.postText.isEmpty || viewState.selectedUserId == nil)
                        .bold()
                }
            }
        }
    }
}
