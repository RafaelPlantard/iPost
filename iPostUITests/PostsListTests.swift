//
//  PostsListTests.swift
//  iPostUITests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftUI
import SwiftData
@testable import iPost

final class PostsListTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testPostsListDisplaysCorrectly() throws {
        // Verify navigation title
        XCTAssertTrue(app.navigationBars["iPosts"].exists)
        
        // Verify create post button exists
        let createPostButton = app.buttons["Create Post"]
        XCTAssertTrue(createPostButton.exists)
        
        // Verify user selector exists
        let userPicker = app.otherElements["user-picker"]
        XCTAssertTrue(userPicker.exists)
        
        // Expect at least one post to be visible (from sample data)
        let postsList = app.collectionViews.firstMatch
        XCTAssertTrue(postsList.exists)
        XCTAssertTrue(postsList.cells.count > 0)
    }
    
    func testCreateNewPost() throws {
        // Tap create post button
        app.buttons["Create Post"].tap()
        
        // Verify create post modal appears
        let createPostModal = app.otherElements["create-post-view"]
        XCTAssertTrue(createPostModal.exists)
        
        // Enter post text
        let postTextField = app.textViews["post-text-field"]
        XCTAssertTrue(postTextField.exists)
        postTextField.tap()
        postTextField.typeText("This is a UI test post")
        
        // Tap submit button
        app.buttons["submit-button"].tap()
        
        // Verify toast appears
        let toast = app.otherElements["toast-message"]
        let predicate = NSPredicate(format: "exists == true")
        expectation(for: predicate, evaluatedWith: toast, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Verify post is in list
        let postText = app.staticTexts["This is a UI test post"]
        XCTAssertTrue(postText.exists)
    }
    
    func testChangeUser() throws {
        // Tap user picker
        app.otherElements["user-picker"].tap()
        
        // Select second user from the list
        let userOptions = app.buttons.matching(identifier: "user-option")
        if userOptions.count > 1 {
            userOptions.element(boundBy: 1).tap()
        }
        
        // Verify user changed (by checking the new user appears in the picker)
        let selectedUser = app.otherElements["user-picker"]
        XCTAssertTrue(selectedUser.staticTexts.element(boundBy: 0).label != "John Doe")
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
