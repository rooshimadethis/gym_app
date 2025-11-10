# Project Overview

This is a Flutter project for a gym application. The app helps users in busy gyms by suggesting exercises based on available equipment. The main feature is a list of exercises that prioritizes important and recently-neglected workouts. As exercises are completed, they are moved to the bottom of the list.

The project is a standard Flutter application, with support for Android, iOS, Linux, macOS, web, and Windows.

# Building and Running

To build and run this project, you will need to have the Flutter SDK installed.

1.  **Get dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Run the app:**
    ```bash
    flutter run
    ```

3.  **Run tests:**
    ```bash
    flutter test
    ```

# Development Conventions

*   **Code Style:** The project uses the `flutter_lints` package to enforce good coding practices. It is recommended to follow the guidelines provided by the linter.
*   **State Management:** The current `lib/main.dart` uses `StatefulWidget` for state management. For more complex state, consider using a state management solution like Provider or BLoC.
*   **Testing:** The project includes a `test` directory with a default widget test. It is recommended to add more tests to ensure the quality of the application.
