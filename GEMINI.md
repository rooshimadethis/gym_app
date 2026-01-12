# Project Overview
This is a Flutter gym application ("rooshi's get swole") designed for users in busy gyms. It prioritizes exercises based on available equipment and neglect, rather than rigid day-based splits. Key features include tracking supersets, grouping alternative exercises, and a dynamic list that moves completed exercises to the bottom.

# Tech Stack & Libraries
- **Framework:** Flutter (SDK ^3.9.0)
- **State Management:** Primarily `StatefulWidget` and `setState`.
- **Persistence:** 
    - `shared_preferences` (Session state, legacy JSON data).
    - `drift` & `sqflite` (Exercise history, Priority tracking).
- **UI/Styling:** Material 3 with extensive use of Custom Font (`StackSansText`).
- **Key Packages:**
    - `drift`, `sqlite3_flutter_libs` (Database)
    - `flutter_foreground_task` (Stopwatch/Timer background support)
    - `cached_network_image`
    - `file_saver` / `file_picker` (Import/Export data)

# Architecture & Conventions
- **Folder Structure:** Organized into logical directories:
    - `lib/models/` - Data models (`models.dart`)
    - `lib/views/` - Full-page views (`exercise_detail_view.dart`, `settings_page.dart`)
    - `lib/widgets/` - Reusable UI components (cards, modals, groups)
    - `lib/services/` - Background services (`WorkoutSessionManager`, `StopwatchTaskHandler`)
    - `lib/database/` - Drift database definitions and generated code
    - `lib/logic/` - Business logic (`SuggestionEngine`, `PriorityManager`)
    - `lib/main.dart` - App entry point and main dashboard
- **Conventions:**
    - **Logic:** `State` classes handle UI logic. Complex business logic moved to helper classes (`SuggestionEngine`, `PriorityManager`, `WorkoutSessionManager`).
    - **Models:** Simple Dart classes with `fromJson`/`toJson` (see `models/models.dart`).
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

# Recent Additions (Phase 3 & 4)
- **Session Management:** `WorkoutSessionManager` handles active workout state.
- **Fatigue Tracking:** `FatigueCheckInModal` captures user "freshness" (-1, 0, 1) per exercise.
- **Context-Aware Suggestions:** `SuggestionEngine` recommends weights based on history and fatigue.
- **Priority System:** `PriorityManager` flags exercises not performed "fresh" in >7 days.
