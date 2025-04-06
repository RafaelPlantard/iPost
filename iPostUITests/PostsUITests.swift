//
//  PostsUITests.swift
//  iPostUITests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftUI
@testable import iPost

final class PostsUITests: XCTestCase {
    func testPostsListDisplaysCorrectly() async throws {
        // Start app for testing
        let app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
        
        // Verify navigation title
        XCTAssertTrue(app.navigationBars["iPosts"].exists)
        
        // Verify create post button exists
        XCTAssertTrue(app.buttons["Create Post"].exists)
        
        // Verify user selector exists
        XCTAssertTrue(app.otherElements["user-picker"].exists)
        
        // Verify posts list shows at least one post
        let postsList = app.otherElements["posts-list"]
        XCTAssertTrue(postsList.exists)
        
        let postItems = app.otherElements.matching(identifier: "post-item")
        XCTAssertGreaterThan(postItems.count, 0)
    }
    
    func testCreateNewPost() async throws {
        // Start app for testing
        let app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
        
        // Tap create post button
        app.buttons["create-post-button"].tap()
        
        // Verify create post modal appears
        XCTAssertTrue(app.otherElements["create-post-view"].exists)
        
        // Enter post text
        let textField = app.textFields["post-text-field"]
        textField.tap()
        textField.typeText("This is a UI test post")
        
        // Tap submit button
        app.buttons["submit-button"].tap()
        
        // Wait for toast to appear
        let toastExists = XCTWaiter.wait(for: [XCTestExpectation(description: "Toast appears")], timeout: 2.0)
        XCTAssertEqual(toastExists, .completed)
        
        // Verify toast shows success message
        XCTAssertTrue(app.staticTexts["Post created successfully!"].exists)
        
        // Verify post appears in the list
        let postExists = XCTWaiter.wait(for: [XCTestExpectation(description: "Post appears")], timeout: 2.0)
        XCTAssertEqual(postExists, .completed)
        XCTAssertTrue(app.staticTexts["This is a UI test post"].exists)
    }
    
    func testChangeUser() async throws {
        // Start app for testing
        let app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
        
        // Get initial user name for comparison
        let initialUserName = app.staticTexts["selected-user-name"].label
        
        // Tap user picker
        app.otherElements["user-picker"].tap()
        
        // Select second user option
        let userOptions = app.buttons.matching(identifier: "user-option")
        if userOptions.count > 1 {
            userOptions.element(boundBy: 1).tap()
        }
        
        // Verify user changed
        let userChanged = XCTWaiter.wait(for: [XCTestExpectation(description: "User changes")], timeout: 1.0)
        XCTAssertEqual(userChanged, .completed)
        
        let newUserName = app.staticTexts["selected-user-name"].label
        XCTAssertNotEqual(newUserName, initialUserName)
    }
}
