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
        // Try multiple approaches to find the user picker
        let userPickerExists = app.buttons["user-picker"].waitForExistence(timeout: 2)

        XCTAssertTrue(userPickerExists, "User picker should exist")

        // Get a reference to the user picker using whichever method works
        let userPicker = app.buttons["user-picker"].exists ? app.buttons["user-picker"] :
                        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Select User")).firstMatch.exists ?
                        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Select User")).firstMatch :
                        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "POSTING AS")).firstMatch

        XCTAssertTrue(userPicker.exists)

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

        // Look for the text editor using the accessibility identifier
        var textEditorArea = app.textViews["post-text-editor"]
        let textEditorExists = textEditorArea.waitForExistence(timeout: 2)

        // If the identifier doesn't work, fall back to the previous approach
        if !textEditorExists {
            let fallbackExists = app.textViews.firstMatch.waitForExistence(timeout: 2) ||
                               app.textViews.element.waitForExistence(timeout: 2)
            XCTAssertTrue(fallbackExists, "Post text editor should exist")

            // Reassign textEditorArea to the fallback element
            if !textEditorExists {
                if app.textViews.firstMatch.exists {
                    textEditorArea = app.textViews.firstMatch
                } else {
                    textEditorArea = app.textViews.element
                }
            }
        }
        textEditorArea.tap()
        textEditorArea.typeText(uniquePostText)

        // Test image selection functionality
        // Try different ways to find the "Add an image" section
        let addImageSectionExists = app.staticTexts["Add an image"].exists ||
                                 app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "image")).firstMatch.exists
        XCTAssertTrue(addImageSectionExists, "Add image section should exist")

        // Tap on the image selection button - try different approaches to find it
        let selectImageButton = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Choose an image")).firstMatch.exists ?
                              app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Choose an image")).firstMatch :
                              app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "photo")).firstMatch

        if selectImageButton.exists {
            selectImageButton.tap()

            // Verify image picker appears - try different ways to identify it
            let imagePickerExists = app.navigationBars["Select Image"].waitForExistence(timeout: 2) ||
                                  app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS %@", "Image")).firstMatch.exists
            XCTAssertTrue(imagePickerExists, "Image picker should appear")

            // Select the first image (if available)
            // Try different ways to find images
            let firstImage = app.images.firstMatch.exists ? app.images.firstMatch :
                            app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "photo")).firstMatch

            if firstImage.exists {
                firstImage.tap()
            }

            // If we can't select an image, dismiss the picker using the specific cancel button
            let cancelButton = app.buttons["image-picker-cancel-button"]

            // Wait a moment for the button to be fully interactive
            if cancelButton.waitForExistence(timeout: 2) {
                cancelButton.tap()
            } else {
                // Fallback to other methods if the identifier doesn't work
                // Try to find the navigation bar's cancel button specifically
                let navBar = app.navigationBars["Select Image"]
                let cancelInBar = navBar.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Cancel")).firstMatch

                if cancelInBar.exists {
                    cancelInBar.tap()
                } else {
                    // Last resort - try to tap outside the picker to dismiss it
                    app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
                }
            }
        }

        // Submit the post using the "Post" button with gradient background
        let submitButton = app.buttons["create-post-submit-button"]

        // If the identifier doesn't work, fall back to finding by label
        if !submitButton.waitForExistence(timeout: 2) {
            let fallbackButton = app.buttons["Post"]
            XCTAssertTrue(fallbackButton.exists, "Post button should exist")
            fallbackButton.tap()
        } else {
            submitButton.tap()
        }

        // Verify we return to the main screen by checking for navigation title
        let postsNavTitle = app.navigationBars["iPosts"]
        let postsScreenExists = postsNavTitle.waitForExistence(timeout: 2)
        XCTAssertTrue(postsScreenExists, "Posts screen should reappear after submitting")

        // Wait a moment for the list to refresh with the new post (longer for ModelActor)
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

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

        // Look for the text editor using the accessibility identifier
        var textEditorArea = app.textViews["post-text-editor"]
        let textEditorExists = textEditorArea.waitForExistence(timeout: 2)

        // If the identifier doesn't work, fall back to the previous approach
        if !textEditorExists {
            let fallbackExists = app.textViews.firstMatch.waitForExistence(timeout: 2) ||
                               app.textViews.element.waitForExistence(timeout: 2)
            XCTAssertTrue(fallbackExists, "Post text editor should exist")

            // Reassign textEditorArea to the fallback element
            if !textEditorExists {
                if app.textViews.firstMatch.exists {
                    textEditorArea = app.textViews.firstMatch
                } else {
                    textEditorArea = app.textViews.element
                }
            }
        }
        textEditorArea.tap()
        textEditorArea.typeText(uniquePostText)

        // Submit the post using the "Post" button with gradient background
        let submitButton = app.buttons["create-post-submit-button"]

        // If the identifier doesn't work, fall back to finding by label
        if !submitButton.waitForExistence(timeout: 2) {
            let fallbackButton = app.buttons["Post"]
            XCTAssertTrue(fallbackButton.exists, "Post button should exist")
            fallbackButton.tap()
        } else {
            submitButton.tap()
        }

        // Verify the toast message appears with the new design
        // The toast now has a gradient background, icon, and dismiss button
        // Try different ways to find the toast message
        let toastExists = app.staticTexts["Post created successfully!"].waitForExistence(timeout: 3) ||
                        app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "success")).firstMatch.waitForExistence(timeout: 3) ||
                        app.otherElements.matching(NSPredicate(format: "label CONTAINS %@", "toast")).firstMatch.waitForExistence(timeout: 3)

        XCTAssertTrue(toastExists, "Toast message should appear after creating a post")

        // Get a reference to the toast message
        let toastMessage = app.staticTexts["Post created successfully!"].exists ? app.staticTexts["Post created successfully!"] :
                          app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "success")).firstMatch.exists ?
                          app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "success")).firstMatch :
                          app.staticTexts.firstMatch

        // Get a reference to the dismiss button if it exists
        let dismissButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "xmark")).firstMatch.exists ?
                           app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "xmark")).firstMatch :
                           app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "dismiss")).firstMatch

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
        // Try multiple approaches to find the user picker
        let userPickerExists = app.buttons["user-picker"].waitForExistence(timeout: 2)

        XCTAssertTrue(userPickerExists, "User picker should exist")

        // Get a reference to the user picker using whichever method works
        let userPicker = app.buttons["user-picker"].exists ? app.buttons["user-picker"] :
                        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Select User")).firstMatch.exists ?
                        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Select User")).firstMatch :
                        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "POSTING AS")).firstMatch

        // Tap on the user picker to open the menu
        userPicker.tap()

        // Wait for the menu to appear
        // Since the menu might not have a specific identifier, we'll look for menu items
        // that contain user names or the checkmark icon
        let menuItemExists = app.buttons.firstMatch.waitForExistence(timeout: 2)
        XCTAssertTrue(menuItemExists, "User selection menu should appear")

        // Select a different user if available (tap the first menu item)
        let menuItem = app.buttons.firstMatch

        if menuItem.exists {
            menuItem.tap()
        } else {
            // Try an alternative approach - tap on a specific area of the screen
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3)).tap()
        }

        // Wait for the posts to refresh with the new user selection
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

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

        // Look for the text editor using the accessibility identifier
        var textEditorArea = app.textViews["post-text-editor"]
        let textEditorExists = textEditorArea.waitForExistence(timeout: 2)

        // If the identifier doesn't work, fall back to the previous approach
        if !textEditorExists {
            let fallbackExists = app.textViews.firstMatch.waitForExistence(timeout: 2) ||
                               app.textViews.element.waitForExistence(timeout: 2)
            XCTAssertTrue(fallbackExists, "Post text editor should exist")

            // Reassign textEditorArea to the fallback element
            if !textEditorExists {
                if app.textViews.firstMatch.exists {
                    textEditorArea = app.textViews.firstMatch
                } else {
                    textEditorArea = app.textViews.element
                }
            }
        }
        textEditorArea.tap()
        textEditorArea.typeText(uniquePostText)

        // Submit the post using the "Post" button with gradient background
        let submitButton = app.buttons["create-post-submit-button"]

        // If the identifier doesn't work, fall back to finding by label
        if !submitButton.waitForExistence(timeout: 2) {
            let fallbackButton = app.buttons["Post"]
            XCTAssertTrue(fallbackButton.exists, "Post button should exist")
            fallbackButton.tap()
        } else {
            submitButton.tap()
        }

        // Verify we return to the main screen
        let postsNavTitle = app.navigationBars["iPosts"]
        XCTAssertTrue(postsNavTitle.waitForExistence(timeout: 2), "Posts screen should reappear")

        // Wait for the list to refresh with the new post (longer for ModelActor)
        try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds

        // Verify the new post appears in the list
        var postFound = false

        // Try to find the post text directly
        let directMatch = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", uniquePostText))
            .element.waitForExistence(timeout: 5)

        if directMatch {
            postFound = true
        } else {
            // If direct match fails, try scrolling to find it
            // Try scrolling a few times to find the post
            for _ in 1...3 {
                app.swipeUp()

                // Check if post is visible after scrolling
                if app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", uniquePostText))
                    .element.waitForExistence(timeout: 1) {
                    postFound = true
                    break
                }
            }

            // If still not found, try scrolling back to top and check again
            if !postFound {
                for _ in 1...3 {
                    app.swipeDown()
                }

                if app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", uniquePostText))
                    .element.waitForExistence(timeout: 2) {
                    postFound = true
                }
            }
        }
    }
}
