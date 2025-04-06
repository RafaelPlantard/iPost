//
//  PostsListTests.swift
//  iPostUITests
//
//  Created on 06/04/25.
//

import Testing
import SwiftUI
import SwiftData
@testable import iPost

@SwiftTest
struct PostsUITests {
    @UITest("Posts list displays correctly with expected elements")
    func postsListDisplaysCorrectly() async throws {
        // Start app for testing
        let app = try await UIApplication.launch(arguments: ["UI-TESTING"])
        
        // Verify navigation title
        try await app.verify { app in
            try app.find(navigationTitle: "iPosts").exists()
        }
        
        // Verify create post button exists
        try await app.verify { app in
            try app.find(buttonNamed: "Create Post").exists()
        }
        
        // Verify user selector exists
        try await app.verify { app in
            try app.find(viewWithId: "user-picker").exists()
        }
        
        // Verify posts list shows at least one post
        try await app.verify { app in
            let postsList = try app.find(viewWithId: "posts-list")
            try postsList.exists()
            
            let postItems = try app.findAll(viewsMatching: .anyView, withTag: "post-item")
            try postItems.count.isGreaterThan(0)
        }
    }
    
    @UITest("Creating a new post adds it to the list")
    func createNewPost() async throws {
        // Start app for testing
        let app = try await UIApplication.launch(arguments: ["UI-TESTING"])
        
        // Tap create post button
        try await app.find(buttonWithId: "create-post-button").tap()
        
        // Verify create post modal appears
        try await app.verify { app in
            try app.find(viewWithId: "create-post-view").exists()
        }
        
        // Enter post text
        try await app.find(textFieldWithId: "post-text-field").tap()
        try await app.keyboard.type("This is a UI test post")
        
        // Tap submit button
        try await app.find(buttonWithId: "submit-button").tap()
        
        // Wait for toast to appear
        try await app.wait(timeout: .seconds(2)) { app in
            do {
                return try app.find(viewWithId: "toast-message").exists()
            } catch {
                return false
            }
        }
        
        // Verify toast shows success message
        try await app.verify { app in
            try app.find(text: "Post created successfully!").exists()
        }
        
        // Verify post appears in the list
        try await app.wait(timeout: .seconds(2)) { app in
            do {
                return try app.find(text: "This is a UI test post").exists()
            } catch {
                return false
            }
        }
    }
    
    @UITest("Changing user updates the selected user")
    func changeUser() async throws {
        // Start app for testing
        let app = try await UIApplication.launch(arguments: ["UI-TESTING"])
        
        // Get initial user name for comparison
        let initialUserName = try await app.find(viewWithId: "selected-user-name").text()
        
        // Tap user picker
        try await app.find(viewWithId: "user-picker").tap()
        
        // Select second user option
        let userOptions = try await app.findAll(buttonsWithTag: "user-option")
        if userOptions.count > 1 {
            try await userOptions[1].tap()
        }
        
        // Verify user changed
        try await app.wait(timeout: .seconds(1)) { app in
            do {
                let newUserName = try app.find(viewWithId: "selected-user-name").text()
                return newUserName != initialUserName
            } catch {
                return false
            }
        }
    }
}

// Helper tests for individual VIPER components
@SwiftTest
struct PostsComponentTests {
    @Test("PostsView initializes with correct structure")
    @MainActor
    func postsViewInitializesCorrectly() async throws {
        // Create test container
        let testContainer = try TestContainer()
        
        // Add test data
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.circle")
        testContainer.mainContext.insert(user)
        
        let post = Post(text: "Test post content", author: user)
        testContainer.mainContext.insert(post)
        try testContainer.mainContext.save()
        
        // Create VIPER components
        let router = PostsRouter()
        let interactor = PostsInteractor(modelContext: testContainer.mainContext)
        let presenter = PostsPresenter(interactor: interactor, router: router)
        
        // Create the view to test
        let view = PostsView(presenter: presenter)
        
        // Wait for async operations to complete
        try await Task.sleep(for: .milliseconds(100))
        
        // Verify view structure
        try await Assertions.verify(view) { view in
            // Check navigation title
            try view.navigationTitle.equals("iPosts")
            
            // Check that user selection is available
            try view.find(viewWithId: "user-picker").exists()
            
            // Check create post button exists
            try view.find(buttonWithId: "create-post-button").exists()
            
            // Check post content will be displayed when data loads
            try await Task.sleep(for: .milliseconds(500))
            try view.find(viewWithTag: "post-item").exists()
        }
    }
    
    @Test("ToastManager correctly shows and dismisses toast")
    @MainActor
    func toastManagerShowsDismissesToast() async throws {
        // Create toast manager
        let toastManager = ToastManager.shared
        
        // Initially no toast should be displayed
        try #expect(toastManager.currentToast == nil)
        
        // Show toast
        toastManager.show(message: "Test Toast", type: .info, duration: 0.5)
        
        // Verify toast is shown
        try #expect(toastManager.currentToast != nil)
        try #expect(toastManager.currentToast?.message == "Test Toast")
        try #expect(toastManager.currentToast?.type == .info)
        
        // Wait for auto-dismiss
        try await Task.sleep(for: .seconds(0.6))
        
        // Verify toast is dismissed
        try #expect(toastManager.currentToast == nil)
    }
}

// MARK: - SwiftTesting Test Case

import SwiftTesting

@SwiftTest
struct PostsViewsTests {
    
    @MainActor
    func testPostsViewInitialState() async throws {
        // GIVEN
        let modelContainer = try TestContainer(modelConfiguration: .init(isStoredInMemoryOnly: true))
        
        // Create test data
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.circle")
        modelContainer.mainContext.insert(user)
        
        let post = Post(text: "Test post content", author: user)
        modelContainer.mainContext.insert(post)
        try modelContainer.mainContext.save()
        
        // Create VIPER module
        let router = PostsRouter()
        let interactor = PostsInteractor(modelContext: modelContainer.mainContext)
        let presenter = PostsPresenter(interactor: interactor, router: router)
        
        // WHEN
        let view = PostsView(presenter: presenter)
        
        // Await data to load
        try await Task.sleep(for: .milliseconds(100))
        
        // THEN
        Assertions.assert(view) { view in
            // Check navigation title
            view.navigationTitle.equals("iPosts")
            
            // Check post list exists
            view.find(viewWithId: "posts-list").isNotNil()
            
            // Check user picker exists
            view.find(viewWithId: "user-picker").isNotNil()
            
            // Check post content is displayed
            view.find(text: "Test post content").isNotNil()
            view.find(text: "@testuser").isNotNil()
        }
    }
    
    @MainActor
    func testCreatePostFlow() async throws {
        // GIVEN
        let modelContainer = try TestContainer(modelConfiguration: .init(isStoredInMemoryOnly: true))
        
        // Create test user
        let user = User(name: "Test User", username: "@testuser", profileImageName: "person.circle")
        modelContainer.mainContext.insert(user)
        try modelContainer.mainContext.save()
        
        // Create VIPER module
        let router = PostsRouter()
        let interactor = PostsInteractor(modelContext: modelContainer.mainContext)
        let presenter = PostsPresenter(interactor: interactor, router: router)
        
        // WHEN
        let view = PostsView(presenter: presenter)
        
        // Await data to load
        try await Task.sleep(for: .milliseconds(100))
        
        // Open create post sheet
        await view.find(buttonWithId: "create-post-button").tap()
        
        // THEN
        Assertions.assert(view) { view in
            // Check create post view is presented
            view.find(viewWithId: "create-post-view").isNotNil()
            
            // Enter post text
            view.find(textFieldWithId: "post-text-field")
                .enter("New post from SwiftTesting")
            
            // Submit post
            view.find(buttonWithId: "submit-button").tap()
            
            // Check toast appears
            try Task.sleep(for: .milliseconds(500))
            view.find(viewWithId: "toast-message").isNotNil()
            
            // Check new post appears in list
            try Task.sleep(for: .milliseconds(1000))
            view.find(text: "New post from SwiftTesting").isNotNil()
        }
    }
}

// Helper for creating test containers
extension ModelContainer {
    static func createTestContainer() throws -> ModelContainer {
        let schema = Schema([User.self, Post.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

final class TestContainer {
    let container: ModelContainer
    var mainContext: ModelContext { container.mainContext }
    
    init(modelConfiguration: ModelConfiguration) throws {
        let schema = Schema([User.self, Post.self])
        self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
