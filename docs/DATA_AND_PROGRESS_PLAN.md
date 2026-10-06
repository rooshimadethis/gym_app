# Corrections, backups, and exercise progress

## Scope

- Edit any performance-history set without awarding XP again. Undo a set from an ongoing workout, reopening its exercise attempt and revoking invalid completion bonuses transactionally.
- Export a versioned snapshot of exercises, settings, history, sessions, attempts, sets, and XP. Validate types, values, unique keys, and relationships before showing restore confirmation. Restore replaces data, never silently appends. Accept legacy exports, treating their history as legacy performance rows. Do not resume unfinished attempts from a backup.
- Add an exercise history/progress screen with completed-session best sets, same-weight rep comparisons, and editable set rows. Exclude warmups and ignored/abandoned attempts from progress calculations.

## Verification

- In-memory database tests for corrections, undo/relog deduplication, completion bonuses, backup round trips, legacy restore, invalid-file rejection, and rollback.
- Pure progress-summary tests plus narrow-screen/keyboard widget tests for the new screens.
- Analyzer, full test suite, debug build, and emulator screenshots when available.

## Handoff

Implementation includes logged-set menus, an 8-second final-set undo action that restores list position, settings backup/restore, and a progress screen from the exercise toolbar. No new dependencies or database schema changes.

Undo remains available only during an ongoing workout. Finished-workout history can be corrected, but not undone. Legacy backup restore explicitly resets XP/session tables because old exports do not contain them.

SQLite changes are transactional. SharedPreferences writes have compensating rollback on handled failures; the two stores cannot provide cross-store atomicity if the process terminates mid-restore. Export the current snapshot before replacement.

Implementation remains uncommitted until reviewed and explicitly approved.

Validated with 38 passing tests, Flutter analyzer, normal Android debug build, and emulator inspection of progress, keyboard-open corrections, and undo/XP placement. No personal-phone data was changed.

Export follow-up: existing abandoned attempts had stale pointers to removed history. Export now detaches those links only in the snapshot; it preserves effort XP and all remaining history, without changing storage. Regression tests cover snapshot-only normalization and continued rejection of completed-attempt corruption. All 41 tests (including an opt-in read-only test against an approved personal database copy) and analyzer passed. Device file-picker save still requires confirmation on the phone; database round-trip tests do not establish native export UI success.
