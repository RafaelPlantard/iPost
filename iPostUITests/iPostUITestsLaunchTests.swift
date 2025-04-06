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
        
        // First verify we have the main iPosts navigation bar
        XCTAssertTrue(app.navigationBars["iPosts"].exists, "Navigation bar should exist")
        
        // Wait for content to load
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Take screenshot of initial screen
        let initialScreenshot = XCTAttachment(screenshot: app.screenshot())
        initialScreenshot.name = "Initial Home Screen"
        initialScreenshot.lifetime = .keepAlways
        add(initialScreenshot)
        
        // Look for any menu or picker that might contain user info
        // Since we don't have the exact identifier, we'll try to find UI elements that match
        // a user selector pattern
        let userMenu = app.menus.firstMatch

        if userMenu.exists {
            userMenu.tap()
            
            // Wait for menu to appear
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Tap any button that might be a user option
            let menuButtons = app.buttons.allElementsBoundByIndex
            if menuButtons.count > 1 {
                // Tap the second button if available
                menuButtons[1].tap()
            }
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
