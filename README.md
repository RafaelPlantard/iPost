# iPost - Social Media Post Application

A simple Swift iOS application for a social media posting platform using VIPER architecture.

## Technology Stack

- iOS 
- Swift
- SwiftUI 
- SwiftData (for local persistence)

## Architecture

This application is built using the VIPER architecture:

- **V**iew: SwiftUI views that display the interface to the user
- **I**nteractor: Business logic handlers 
- **P**resenter: Mediator between View and Interactor
- **E**ntity: Data models
- **R**outer: Navigation handling

## Features

- View a feed of posts from all users
- Switch between 3 dummy users via dropdown menu
- Create new posts with text and optional images
- Posts include user info, content, and timestamp
- Local persistence using SwiftData

## Implementation Details

### Entity Layer
- `User.swift`: Model for user data
- `Post.swift`: Model for post data

### Interactor Layer
- `PostsInteractor.swift`: Handles business logic for posts and users

### Presenter Layer
- `PostsPresenter.swift`: Mediates between views and interactor

### View Layer
- `PostsView.swift`: Main post list view
- `CreatePostView.swift`: Form for creating new posts

### Router Layer
- `PostsRouter.swift`: Handles navigation between views

## Getting Started

1. Clone the repository
2. Open the project in Xcode
3. Build and run the application on an iOS simulator or device
