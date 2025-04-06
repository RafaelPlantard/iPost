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

        // Verify user picker exists and test it
        let userPicker = app.otherElements["user-picker"]
        XCTAssertTrue(userPicker.waitForExistence(timeout: 2), "User picker should exist")

        // Tap the create post button (now with a gradient blue circle and plus icon)
        let createPostButton = app.buttons["create-post-button"]
        XCTAssertTrue(createPostButton.exists, "Create Post button should exist")
        createPostButton.tap()

        // Wait for navigation title to show we're in create post view
        let createPostNavTitle = app.navigationBars["Create Post"]
        let createPostViewExists = createPostNavTitle.waitForExistence(timeout: 2)
        XCTAssertTrue(createPostViewExists, "Create post view should appear")

        // Verify user info card exists (showing the selected user)
        let userInfoCard = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Public"))
        XCTAssertTrue(userInfoCard.element.exists, "User info card should exist")

        // Enter post text in the TextEditor (not TextField)
        let uniquePostText = "Test post created at \(Date().formatted(date: .numeric, time: .standard))"
        let textEditorArea = app.textViews.firstMatch
        XCTAssertTrue(textEditorArea.waitForExistence(timeout: 2), "Post text editor should exist")
        textEditorArea.tap()
        textEditorArea.typeText(uniquePostText)

        // Test image selection functionality
        let addImageText = app.staticTexts["Add an image"]
        XCTAssertTrue(addImageText.exists, "Add image section should exist")

        // Tap on the image selection button
        let selectImageButton = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Choose an image")).firstMatch
        if selectImageButton.exists {
            selectImageButton.tap()

            // Verify image picker appears
            let imagePicker = app.navigationBars["Select Image"]
            XCTAssertTrue(imagePicker.waitForExistence(timeout: 2), "Image picker should appear")

            // Select the first image (if available)
            let firstImage = app.images.firstMatch
            if firstImage.exists {
                firstImage.tap()
            }

            // If we can't select an image, dismiss the picker
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }

        // Submit the post using the "Post" button with gradient background
        let submitButton = app.buttons["Post"]
        XCTAssertTrue(submitButton.exists, "Post button should exist")
        submitButton.tap()

        // Verify we return to the main screen by checking for navigation title
        let postsNavTitle = app.navigationBars["iPosts"]
        let postsScreenExists = postsNavTitle.waitForExistence(timeout: 2)
        XCTAssertTrue(postsScreenExists, "Posts screen should reappear after submitting")

        // Wait a moment for the list to refresh with the new post
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Verify the new post appears in the list with the improved UI
        let postExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", uniquePostText))
            .element.waitForExistence(timeout: 5)

        XCTAssertTrue(postExists, "The newly created post should appear in the list")

        // Optional: scroll to ensure the text is visible if it's not found
        if !postExists {
            app.swipeUp() // Try scrolling up to find the post
            let postExistsAfterScroll = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", uniquePostText))
                .element.waitForExistence(timeout: 2)
            XCTAssertTrue(postExistsAfterScroll, "The post should be visible after scrolling")
        }

        // Verify post item has the new UI elements (interaction buttons)
        let postItem = app.otherElements["post-item"].firstMatch
        if postItem.exists {
            // Verify like, comment, and share buttons exist
            let likeButton = postItem.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Like")).firstMatch
            let commentButton = postItem.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Comment")).firstMatch
            let shareButton = postItem.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Share")).firstMatch

            XCTAssertTrue(likeButton.exists || commentButton.exists || shareButton.exists,
                         "Post should have interaction buttons")
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testToastAppearsAfterPostCreation() async throws {
        // Launch the app with testing configuration
        let app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()

        // Wait for app to fully load
        let homeScreenExists = app.wait(for: .runningForeground, timeout: 2)
        XCTAssertTrue(homeScreenExists)

        // Verify the navigation title exists
        XCTAssertTrue(app.navigationBars["iPosts"].exists)

        // Tap the create post button with gradient design
        let createPostButton = app.buttons["create-post-button"]
        XCTAssertTrue(createPostButton.exists, "Create Post button should exist")
        createPostButton.tap()

        // Wait for navigation title to show we're in create post view
        let createPostNavTitle = app.navigationBars["Create Post"]
        let createPostViewExists = createPostNavTitle.waitForExistence(timeout: 2)
        XCTAssertTrue(createPostViewExists, "Create post view should appear")

        // Enter post text in the TextEditor
        let uniquePostText = "Toast test post created at \(Date().formatted(date: .numeric, time: .standard))"
        let textEditorArea = app.textViews.firstMatch
        XCTAssertTrue(textEditorArea.waitForExistence(timeout: 2), "Post text editor should exist")
        textEditorArea.tap()
        textEditorArea.typeText(uniquePostText)

        // Submit the post using the "Post" button with gradient background
        let submitButton = app.buttons["Post"]
        XCTAssertTrue(submitButton.exists, "Post button should exist")
        submitButton.tap()

        // Verify the toast message appears with the new design
        // The toast now has a gradient background, icon, and dismiss button
        let toastMessage = app.staticTexts["Post created successfully!"]
        let toastExists = toastMessage.waitForExistence(timeout: 3)
        XCTAssertTrue(toastExists, "Toast message should appear after creating a post")

        // Check for the dismiss button (X icon) in the toast
        let dismissButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "xmark")).firstMatch
        XCTAssertTrue(dismissButton.exists, "Toast should have a dismiss button")

        // We can either wait for the toast to disappear automatically or dismiss it manually
        // Option 1: Dismiss manually by tapping the X button
        if dismissButton.exists {
            dismissButton.tap()
            // Verify toast disappears immediately after tapping dismiss
            XCTAssertFalse(toastMessage.waitForExistence(timeout: 1), "Toast should disappear after dismissal")
        } else {
            // Option 2: Wait for automatic dismissal
            try await Task.sleep(nanoseconds: 3_500_000_000) // 3.5 seconds
            XCTAssertFalse(toastMessage.exists, "Toast message should disappear after timeout")
        }
    }

    @MainActor
    func testUserSelectionAndPostFiltering() async throws {
        // Launch the app with testing configuration
        let app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()

        // Wait for app to fully load
        let homeScreenExists = app.wait(for: .runningForeground, timeout: 2)
        XCTAssertTrue(homeScreenExists)

        // Verify the navigation title exists
        XCTAssertTrue(app.navigationBars["iPosts"].exists)

        // Verify user picker exists
        let userPicker = app.otherElements["user-picker"]
        XCTAssertTrue(userPicker.waitForExistence(timeout: 2), "User picker should exist")

        // Tap on the user picker to open the menu
        userPicker.tap()

        // Wait for the menu to appear
        // Since the menu might not have a specific identifier, we'll look for menu items
        // that contain user names or the checkmark icon
        let menuItemExists = app.buttons.firstMatch.waitForExistence(timeout: 2)
        XCTAssertTrue(menuItemExists, "User selection menu should appear")

        // Select a different user if available (tap the first menu item)
        let menuItem = app.buttons.firstMatch
        menuItem.tap()

        // Wait for the posts to refresh with the new user selection
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Verify the posts list updates (either showing posts or empty state)
        let postsExist = app.otherElements["post-item"].firstMatch.exists ||
                        app.staticTexts["No posts yet"].exists
        XCTAssertTrue(postsExist, "Posts list should update after user selection")

        // Create a post with the selected user
        let createPostButton = app.buttons["create-post-button"]
        XCTAssertTrue(createPostButton.exists, "Create Post button should exist")
        createPostButton.tap()

        // Wait for navigation title to show we're in create post view
        let createPostNavTitle = app.navigationBars["Create Post"]
        XCTAssertTrue(createPostNavTitle.waitForExistence(timeout: 2), "Create post view should appear")

        // Verify the selected user appears in the user info card
        let userInfoExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Public")).element.exists
        XCTAssertTrue(userInfoExists, "User info card should show the selected user")

        // Enter post text
        let uniquePostText = "User selection test post created at \(Date().formatted(date: .numeric, time: .standard))"
        let textEditorArea = app.textViews.firstMatch
        XCTAssertTrue(textEditorArea.waitForExistence(timeout: 2), "Post text editor should exist")
        textEditorArea.tap()
        textEditorArea.typeText(uniquePostText)

        // Submit the post
        let submitButton = app.buttons["Post"]
        XCTAssertTrue(submitButton.exists, "Post button should exist")
        submitButton.tap()

        // Verify we return to the main screen
        let postsNavTitle = app.navigationBars["iPosts"]
        XCTAssertTrue(postsNavTitle.waitForExistence(timeout: 2), "Posts screen should reappear")

        // Wait for the list to refresh with the new post
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Verify the new post appears in the list
        let postExists = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", uniquePostText))
            .element.waitForExistence(timeout: 5)
        XCTAssertTrue(postExists, "The newly created post should appear in the list")
    }
}
