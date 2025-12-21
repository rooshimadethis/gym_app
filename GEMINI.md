# Project Overview
This is a Flutter gym application ("rooshi's get swole") designed for users in busy gyms. It prioritizes exercises based on available equipment and neglect, rather than rigid day-based splits. Key features include tracking supersets, grouping alternative exercises, and a dynamic list that moves completed exercises to the bottom.

# Tech Stack & Libraries
- **Framework:** Flutter (SDK ^3.9.0)
- **State Management:** Primarily `StatefulWidget` and `setState`.
- **Persistence:** `shared_preferences` (storing JSON data for exercises and progress). `sqflite` is a dependency but `main.dart` relies on SharedPreferences.
- **UI/Styling:** Material 3 with extensive use of Custom Font (`StackSansText`).
- **Key Packages:**
    - `flutter_foreground_task` (Stopwatch/Timer background support)
    - `cached_network_image`
    - `file_saver` / `file_picker` (Import/Export data)

# Architecture & Conventions
- **Folder Structure:** Flat structure in `lib/` (e.g., `main.dart`, `models.dart`, `exercise_card.dart`).
- **Conventions:**
    - **Logic:** logic stays close to the UI (in the `State` class).
    - **Models:** Simple Dart classes with `fromJson`/`toJson` (see `models.dart`).
    - **Linting:** Follows `flutter_lints`.
- **Task Handling:** Uses a foreground task handler for the stopwatch to keep it running when the app is backgrounded.

# Important Commands
- **Run App:** `flutter run`
- **Run Tests:** `flutter test`
- **Analyze Code:** `flutter analyze`

# Known Issues / Context
- The app handles supersets and alternative exercise groups (linked exercises).
- Exercises are loaded from local assets or JSON in SharedPreferences.
- `OpenContainer` animations are used but have been noted as "hard to do" in previous notes.
