# iPost - Social Media Post Application

A modern Swift iOS application for a social media posting platform implementing VIPER architecture with SwiftUI.

## Technology Stack

- iOS 17+
- Swift 5.9+
- SwiftUI
- SwiftData (for local persistence)

## Architecture

This application is built using the VIPER architecture pattern with SwiftUI:

- **V**iew: SwiftUI views that display the interface to the user
- **I**nteractor: Business logic handlers that manage data operations
- **P**resenter: Mediator between View and Interactor that processes and formats data
- **E**ntity: Data models representing the core business objects
- **R**outer: Navigation handling between different modules

Additionally, the app implements a **ViewState** pattern to maintain a clean separation between the View and Presenter layers, following best practices for SwiftUI with VIPER.

## Features

- View a feed of posts from all users with pull-to-refresh functionality
- Switch between 3 dummy users via dropdown menu
- Create new posts with text and optional images
- Posts include user profile images, names, usernames, text content, and timestamps
- Toast notifications for user feedback
- Error handling with dedicated error views
- Local persistence using SwiftData
- User preferences saved between app launches

## Implementation Details

### Entity Layer
- `User.swift`: Model for user data with relationships to posts
- `Post.swift`: Model for post data with author relationship
- `ToastMessage.swift`: Model for toast notification data
- `AppError.swift`: Enumeration of possible application errors

### Interactor Layer
- `PostsInteractor.swift`: Handles business logic for posts and users
- `UserPreferencesInteractor.swift`: Manages user preferences persistence

### Presenter Layer
- `PostsPresenter.swift`: Mediates between views and interactor for post-related operations
- `ErrorPresenter.swift`: Handles error presentation logic
- Various protocol files defining the communication contracts between layers

### View Layer
- `PostsView.swift`: Main post list view with user selection
- `CreatePostView.swift`: Form for creating new posts with text and images
- `ToastView.swift` & `ToastContainerView.swift`: Toast notification system
- `ErrorView.swift`: Error presentation view

### ViewState Layer
- `PostsViewState.swift`: Maintains UI state for the posts view
- `CreatePostViewState.swift`: Maintains UI state for the create post view

### Router Layer
- `PostsRouter.swift`: Handles navigation for post-related views
- `ErrorRouter.swift`: Handles navigation for error views

## Testing

The application includes both unit tests and UI tests:

- Unit tests for the Interactor and Presenter layers
- UI tests for key user interactions

## Getting Started

1. Clone the repository
2. Open the project in Xcode 15 or later
3. Build and run the application on an iOS 17+ simulator or device
