# Gym app development context

- Flutter app with Drift persistence. XP rules live in `lib/domain/gamification.dart`; awards are persisted through `GamificationService`. UI changes must preserve award deduplication and abandoned-attempt exclusion from performance history.
- Motivation centers on starting a workout and recognizing effort. Preserve automatic focus/keyboard opening for the next set.
- Run `flutter run -d <device> -t lib/ui_preview.dart` for a database-free gallery of production check-in, effort editor, XP feedback, and receipt widgets. The keyboard preview reproduces feedback while the numeric keyboard is open. Default builds use `lib/main.dart`.
- Feedback overlay entries need Material styling and live keyboard insets. Verify screenshots and input focus as well as analyzer/tests; widget tests alone do not establish visual quality.
- For Android installs on a personal phone use `adb install -r` to preserve data. Do not uninstall the app for iteration. Emulator builds of the preview entry point are development tools, not the APK to install on the phone.
- Validation: `flutter analyze --no-fatal-infos`, `flutter test --no-pub -r compact`. Flutter currently auto-adds migration flags to `android/gradle.properties` during Android builds; keep unrelated generated migration changes out of UI work.
