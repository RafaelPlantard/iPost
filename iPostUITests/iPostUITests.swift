//
//  iPostUITests.swift
//  iPostUITests
//
//  Created by Rafael da Silva Ferreira on 06/04/25.
//

import XCTest

final class iPostUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testCreatePostAndVerifyAppearance() async throws {
        // UI tests must launch the application that they test
        let app = XCUIApplication()
        // Add UI testing argument to put the app in testing mode if needed
        app.launchArguments = ["UI-TESTING"]
        app.launch()
        
        // Wait for app to fully load
        let homeScreenExists = app.wait(for: .runningForeground, timeout: 2)
        XCTAssertTrue(homeScreenExists)
        
        // Verify the navigation title exists
        XCTAssertTrue(app.navigationBars["iPosts"].exists)
        
        // Tap the create post button
        let createPostButton = app.buttons["create-post-button"]
        XCTAssertTrue(createPostButton.exists, "Create Post button should exist")
        createPostButton.tap()
        
        // Wait for navigation title to show we're in create post view
        let createPostNavTitle = app.navigationBars["Create Post"]
        let createPostViewExists = createPostNavTitle.waitForExistence(timeout: 2)
        XCTAssertTrue(createPostViewExists, "Create post view should appear")
        
        // Enter post text - Find the text field by placeholder text
        let uniquePostText = "Test post created at \(Date().formatted(date: .numeric, time: .standard))"
        let textField = app.textFields["What's on your mind?"]
        XCTAssertTrue(textField.exists, "Post text field should exist")
        textField.tap()
        textField.typeText(uniquePostText)
        
        // Submit the post using the "Post" button
        let submitButton = app.buttons["Post"]
        XCTAssertTrue(submitButton.exists, "Post button should exist")
        submitButton.tap()
        
        // Verify we return to the main screen by checking for navigation title
        let postsNavTitle = app.navigationBars["iPosts"]
        let postsScreenExists = postsNavTitle.waitForExistence(timeout: 2)
        XCTAssertTrue(postsScreenExists, "Posts screen should reappear after submitting")
        
        // Verify the new post appears in the list
        let postText = app.staticTexts[uniquePostText]
        let postExists = postText.waitForExistence(timeout: 3)
        XCTAssertTrue(postExists, "The newly created post should appear in the list")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
