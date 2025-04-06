//
//  ToastViewSnapshotTests.swift
//  iPostTests
//
//  Created on 06/04/25.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import iPosts

@MainActor
final class ToastViewSnapshotTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Configure SnapshotTesting settings if needed
        // For example, we could set a different tolerance for pixel differences
        // diffTool = "ksdiff"
        // isRecording = false
    }
    
    // MARK: - Snapshot Tests
    
    func testSuccessToast() {
        let toast = ToastMessage(
            message: "Post created successfully!",
            type: .success
        )
        
        let toastView = ToastView(toast: toast)
        
        // Wrap in a ZStack with frame to ensure proper sizing
        let wrappedView = ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            toastView
                .padding()
        }
        
        // Test light mode
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
        
        // Test dark mode
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)),
            named: "dark_mode"
        )
    }
    
    func testErrorToast() {
        let toast = ToastMessage(
            message: "Failed to create post. Please try again.",
            type: .error
        )
        
        let toastView = ToastView(toast: toast)
        
        // Wrap in a ZStack with frame to ensure proper sizing
        let wrappedView = ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            toastView
                .padding()
        }
        
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testInfoToast() {
        let toast = ToastMessage(
            message: "Creating post...",
            type: .info
        )
        
        let toastView = ToastView(toast: toast)
        
        // Wrap in a ZStack with frame to ensure proper sizing
        let wrappedView = ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            toastView
                .padding()
        }
        
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testWarningToast() {
        let toast = ToastMessage(
            message: "Warning: You're about to delete your post",
            type: .warning
        )
        
        let toastView = ToastView(toast: toast)
        
        // Wrap in a ZStack with frame to ensure proper sizing
        let wrappedView = ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            toastView
                .padding()
        }
        
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    func testLongMessageToast() {
        let toast = ToastMessage(
            message: "This is a very long toast message that should wrap to multiple lines and be truncated if it becomes too long for the available space.",
            type: .info
        )
        
        let toastView = ToastView(toast: toast)
        
        // Wrap in a ZStack with frame to ensure proper sizing
        let wrappedView = ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            toastView
                .padding()
        }
        
        assertSnapshot(
            of: UIHostingController(rootView: wrappedView),
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }
}
