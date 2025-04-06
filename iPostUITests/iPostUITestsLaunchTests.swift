//
//  iPostUITestsLaunchTests.swift
//  iPostUITests
//
//  Created by Rafael da Silva Ferreira on 06/04/25.
//

import XCTest

final class iPostUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() async throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
        
        // Wait for app to fully load
        let homeScreenExists = app.wait(for: .runningForeground, timeout: 2)
        XCTAssertTrue(homeScreenExists)
        
        // Verify the navigation title exists
        XCTAssertTrue(app.navigationBars["iPosts"].exists, "Navigation bar should exist")
        
        // Change user before taking the screenshot
        // Tap user picker
        let userPicker = app.otherElements["user-picker"]
        XCTAssertTrue(userPicker.exists, "User picker should exist")
        userPicker.tap()
        
        // Wait for user options to appear
        let userOptions = app.buttons.matching(identifier: "user-option")
        let optionsExist = userOptions.firstMatch.waitForExistence(timeout: 2)
        XCTAssertTrue(optionsExist, "User options should appear")
        
        // Select the second user (if there are multiple users)
        if userOptions.count > 1 {
            userOptions.element(boundBy: 1).tap()
        } else {
            // If only one option exists, select it
            userOptions.firstMatch.tap()
        }
        
        // Wait for user change to take effect
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Take screenshot with the new user
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Home Screen with Different User"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
