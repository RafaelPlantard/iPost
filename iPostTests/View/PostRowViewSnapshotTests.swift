//
//  PostRowViewSnapshotTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftUI
import SwiftData
import SnapshotTesting
@testable import iPost

@MainActor
final class PostRowViewSnapshotTests: XCTestCase {
    
    // Test helpers
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create an in-memory container for testing
        let schema = Schema([User.self, Post.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Snapshot Tests
    
    @MainActor
    func testPostRowWithTextOnly() throws {
        // Create test user
        let user = User(name: "John Doe", username: "@johndoe", profileImageName: "person.fill")
        modelContext.insert(user)
        
        // Create test post
        let post = Post(text: "This is a test post with text only. No image is included in this post.", author: user)
        modelContext.insert(post)
        
        // Ensure post is saved
        try modelContext.save()
        
        // Create the view with our post
        let postRowView = PostRowView(post: post)
        
        // Wrap in List for proper styling
        let wrappedView = List {
            postRowView
        }
        .listStyle(.plain)
        
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
    
    @MainActor
    func testPostRowWithImage() throws {
        // Create test user
        let user = User(name: "Jane Smith", username: "@janesmith", profileImageName: "person.crop.circle.fill")
        modelContext.insert(user)
        
        // Create test post with image
        let post = Post(
            text: "Check out this photo I just took!",
            imageName: "photo",
            author: user
        )
        modelContext.insert(post)
        
        // Ensure post is saved
        try modelContext.save()
        
        // Create the view with our post
        let postRowView = PostRowView(post: post)
        
        // Wrap in List for proper styling
        let wrappedView = List {
            postRowView
        }
        .listStyle(.plain)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    @MainActor
    func testPostRowWithLongText() throws {
        // Create test user
        let user = User(name: "Robert Johnson", username: "@robertj", profileImageName: "person.2.fill")
        modelContext.insert(user)
        
        // Create test post with long text
        let post = Post(
            text: "This is a very long post that should wrap to multiple lines. Testing how the PostRowView handles lengthy content. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit. Donec et mollis dolor. Praesent et diam eget libero egestas mattis sit amet vitae augue.",
            author: user
        )
        modelContext.insert(post)
        
        // Ensure post is saved
        try modelContext.save()
        
        // Create the view with our post
        let postRowView = PostRowView(post: post)
        
        // Wrap in List for proper styling
        let wrappedView = List {
            postRowView
        }
        .listStyle(.plain)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    @MainActor
    func testPostRowWithMissingAuthor() throws {
        // Create test post with no author
        let post = Post(
            text: "This post has no author, testing how the UI handles this edge case.",
            imageName: nil,
            author: nil
        )
        modelContext.insert(post)
        
        // Ensure post is saved
        try modelContext.save()
        
        // Create the view with our post
        let postRowView = PostRowView(post: post)
        
        // Wrap in List for proper styling
        let wrappedView = List {
            postRowView
        }
        .listStyle(.plain)
        
        // Record snapshot
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
}
