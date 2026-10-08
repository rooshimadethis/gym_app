import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/database/database.dart';
import 'package:gym_app/domain/gamification.dart';
import 'package:gym_app/logic/exercise_progress.dart';
import 'package:gym_app/models/models.dart';
import 'package:gym_app/services/backup_service.dart';
import 'package:gym_app/services/gamification_service.dart';
import 'package:gym_app/views/exercise_history_page.dart';
import 'package:gym_app/widgets/edit_set_dialog.dart';
import 'package:gym_app/widgets/exercise_completion_undo.dart';
import 'package:gym_app/widgets/workout_feedback_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;
  late GamificationService service;
  late SharedPreferences prefs;
  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    service = GamificationService(database);
    SharedPreferences.setMockInitialValues({
      'exercises_data': jsonEncode([
        Exercise(
          id: 'squat',
          name: 'Squat',
          xpTier: ExerciseXpTier.demanding,
        ).toJson(),
      ]),
      'timer_duration': 90,
      'theme_mode': 1,
      'warmup_set_enabled': true,
      'notifications_enabled': false,
      'workout_feedback_haptics_enabled': false,
      'workout_feedback_sound_enabled': true,
    });
    prefs = await SharedPreferences.getInstance();
  });
  tearDown(() => database.close());
  Future<void> seed({bool complete = true}) async {
    await service.startSession(sessionId: 'session');
    await service.beginExerciseAttempt(
      sessionId: 'session',
      exerciseId: 'squat',
      exerciseName: 'Squat',
      attemptId: 'attempt',
    );
    await service.recordSuccessfulSet(
      setAttemptId: 'set',
      attemptId: 'attempt',
      plannedSetIndex: 0,
      weight: 100,
      reps: 8,
      tier: ExerciseXpTier.demanding,
    );
    if (complete) {
      await service.completeExercise(
        attemptId: 'attempt',
        tier: ExerciseXpTier.demanding,
      );
    }
  }

  test('correction updates both records and leaves XP untouched', () async {
    await seed();
    final before = await service.lifetimeXp;
    final history = (await database.getAllHistory()).single;
    await service.editHistorySet(history.id, weight: 105.5, reps: 9);
    expect((await database.getAllHistory()).single.weight, 105.5);
    expect((await database.select(database.setAttempts).get()).single.reps, 9);
    expect(await service.lifetimeXp, before);
    await expectLater(
      service.editHistorySet(history.id, weight: double.nan, reps: 3),
      throwsArgumentError,
    );
    expect((await database.getAllHistory()).single.weight, 105.5);
  });
  test(
    'export detaches missing abandoned history without changing storage',
    () async {
      await seed(complete: false);
      await service.abandonExercise('attempt');
      final original =
          (await database.select(database.setAttempts).get()).single;
      final xp = await service.lifetimeXp;
      await database.customStatement('DELETE FROM history_entries');
      final backup = WorkoutBackup.parse(
        await BackupService(database, prefs).export(),
      );
      expect(backup.sets.single.historyEntryId, isNull);
      expect(backup.attempts.single.status, 'abandoned');
      expect(backup.events.fold<int>(0, (sum, row) => sum + row.xpAmount), xp);
      expect(
        (await database.select(database.setAttempts).get())
            .single
            .historyEntryId,
        original.historyEntryId,
      );
      await BackupService(database, prefs).restore(backup);
      expect(await service.lifetimeXp, xp);
      expect(
        await database.getPerformanceHistoryForExercise(
          'squat',
          legacyExerciseName: 'Squat',
        ),
        isEmpty,
      );
    },
  );
  test('export still rejects missing completed-attempt history', () async {
    await seed();
    await database.customStatement('DELETE FROM history_entries');
    await expectLater(
      BackupService(database, prefs).export(),
      throwsFormatException,
    );
  });
  const diagnosticPath = String.fromEnvironment('BACKUP_DIAGNOSTIC_DB');
  if (diagnosticPath.isNotEmpty) {
    test(
      'approved diagnostic database exports without modifying records',
      () async {
        final diagnostic = AppDatabase.forTesting(
          NativeDatabase(
            File(diagnosticPath),
            setup: (db) => db.execute('PRAGMA query_only = ON'),
          ),
        );
        try {
          final sourceSets = await diagnostic
              .select(diagnostic.setAttempts)
              .get();
          final sourceEvents = await diagnostic
              .select(diagnostic.xpEvents)
              .get();
          final sourceHistory = await diagnostic.getAllHistory();
          final backup = WorkoutBackup.parse(
            await BackupService(diagnostic, prefs).export(),
          );
          expect(backup.sets.length, sourceSets.length);
          expect(backup.history.length, sourceHistory.length);
          expect(
            backup.events.map((row) => row.toJson()).toList(),
            sourceEvents.map((row) => row.toJson()).toList(),
          );
          expect(
            (await diagnostic.select(diagnostic.setAttempts).get())
                .map((row) => row.toJson())
                .toList(),
            sourceSets.map((row) => row.toJson()).toList(),
          );
        } finally {
          await diagnostic.close();
        }
      },
    );
  }
  test(
    'undo reopens completion, removes its bonus, and relog is deduplicated',
    () async {
      await seed();
      expect(await service.lifetimeXp, 18);
      await service.undoSet('set', currentSessionId: 'session');
      await service.undoSet('set', currentSessionId: 'session');
      expect(await service.lifetimeXp, 0);
      expect(await database.getAllHistory(), isEmpty);
      expect(
        (await database.getAttemptsForSession('session')).single.status,
        'active',
      );
      for (var i = 0; i < 2; i++) {
        await service.recordSuccessfulSet(
          setAttemptId: 'set',
          attemptId: 'attempt',
          plannedSetIndex: 0,
          weight: 100,
          reps: 8,
          tier: ExerciseXpTier.demanding,
        );
        await service.completeExercise(
          attemptId: 'attempt',
          tier: ExerciseXpTier.demanding,
        );
      }
      expect(await service.lifetimeXp, 18);
      expect((await database.getAllHistory()).length, 1);
    },
  );
  test(
    'undo leaves other set XP intact and hides incomplete performance',
    () async {
      await seed(complete: false);
      await service.recordSuccessfulSet(
        setAttemptId: 'second',
        attemptId: 'attempt',
        plannedSetIndex: 1,
        weight: 100,
        reps: 7,
        tier: ExerciseXpTier.demanding,
      );
      await service.completeExercise(
        attemptId: 'attempt',
        tier: ExerciseXpTier.demanding,
      );
      await service.undoSet('second', currentSessionId: 'session');
      expect(await service.lifetimeXp, 3);
      expect((await database.getAllHistory()).length, 1);
      expect(await database.getPerformanceHistoryForExercise('squat'), isEmpty);
    },
  );
  test('cannot undo closed, abandoned, or different-session sets', () async {
    await seed();
    await expectLater(
      service.undoSet('set', currentSessionId: 'other'),
      throwsStateError,
    );
    await service.completeWorkout('session');
    final xp = await service.lifetimeXp;
    await expectLater(
      service.undoSet('set', currentSessionId: 'session'),
      throwsStateError,
    );
    expect(await service.lifetimeXp, xp);
    expect((await database.getAllHistory()).length, 1);
  });
  test(
    'complete backup round trip preserves IDs, XP, history, and settings',
    () async {
      await seed();
      await service.completeWorkout('session');
      final backupService = BackupService(database, prefs);
      final content = await backupService.export();
      final backup = WorkoutBackup.parse(content);
      await prefs.setInt('timer_duration', 180);
      await backupService.restore(backup);
      await backupService.restore(backup); // replacement does not duplicate
      expect(await service.lifetimeXp, 58);
      expect(
        (await database.getAllHistory()).single.id,
        backup.history.single.id,
      );
      expect(
        (await database.select(database.setAttempts).get())
            .single
            .historyEntryId,
        backup.history.single.id,
      );
      expect(prefs.getInt('timer_duration'), 90);
      expect(prefs.getBool('workout_feedback_sound_enabled'), true);
      expect(prefs.getInt('theme_mode'), 1);
      expect(
        (await database.getPerformanceHistoryForExercise('squat')).length,
        1,
      );
      expect(
        jsonDecode(prefs.getString('exercises_data')!)[0]['xpTier'],
        'demanding',
      );
    },
  );
  test(
    'unfinished snapshot keeps earned XP but never resumes workout',
    () async {
      await seed(complete: false);
      final backupService = BackupService(database, prefs);
      final backup = WorkoutBackup.parse(await backupService.export());
      await prefs.setString('current_session_id', 'old');
      await backupService.restore(backup);
      expect(await service.lifetimeXp, 3);
      expect(
        (await database.getAttemptsForSession('session')).single.status,
        'abandoned',
      );
      expect(
        (await database.getWorkoutSession('session'))!.endReason,
        'discarded',
      );
      expect(prefs.getString('current_session_id'), isNull);
      expect(await database.getPerformanceHistoryForExercise('squat'), isEmpty);
    },
  );
  test(
    'legacy backup detaches orphan attempt refs and normalizes dates',
    () async {
      await seed();
      final row = (await database.getAllHistory()).single.toJson();
      row['timestamp'] = DateTime(2025).toIso8601String();
      final backup = WorkoutBackup.parse(
        jsonEncode({
          'exercises_data': [Exercise(id: 'squat', name: 'Squat').toJson()],
          'settings': {'timer_duration': 120},
          'history_data': [row],
        }),
      );
      await BackupService(database, prefs).restore(backup);
      expect(await service.lifetimeXp, 0);
      expect((await database.getAllHistory()).single.attemptId, isNull);
      expect(
        (await database.getPerformanceHistoryForExercise('squat')).length,
        1,
      );
      expect(prefs.getBool('legacy_drift_migration_v1'), true);
    },
  );
  test(
    'malformed, future, duplicate, and orphan backups rejected without writes',
    () async {
      await seed();
      final content = await BackupService(database, prefs).export();
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (d) => d['backup_version'] = 999,
        (d) => d['settings']['timer_duration'] = 'bad',
        (d) => d['history_data'][0]['weight'] = -1,
        (d) => d['history_data'].add(d['history_data'][0]),
        (d) => d['set_attempts'][0]['historyEntryId'] = 999,
        (d) => d['exercise_attempts'][0]['sessionId'] = 'missing',
        (d) => d['xp_events'][0]['eventKey'] = 'missing',
      ]) {
        final data = jsonDecode(content) as Map<String, dynamic>;
        mutate(data);
        expect(
          () => WorkoutBackup.parse(jsonEncode(data)),
          throwsFormatException,
        );
      }
      expect(() => WorkoutBackup.parse('{'), throwsFormatException);
      expect(await service.lifetimeXp, 18);
      expect(prefs.getInt('timer_duration'), 90);
    },
  );
  test(
    'database restore failure rolls back original records and settings',
    () async {
      await seed();
      final backupService = BackupService(database, prefs);
      final backup = WorkoutBackup.parse(await backupService.export());
      await prefs.setInt('timer_duration', 200);
      await database.customStatement(
        "CREATE TRIGGER reject_restore BEFORE INSERT ON history_entries BEGIN SELECT RAISE(ABORT, 'test failure'); END;",
      );
      await expectLater(backupService.restore(backup), throwsA(anything));
      expect(await service.lifetimeXp, 18);
      expect((await database.getAllHistory()).length, 1);
      expect(prefs.getInt('timer_duration'), 200);
    },
  );
  HistoryEntry entry(
    int id,
    String session,
    double weight,
    int reps, {
    bool warmup = false,
  }) => HistoryEntry(
    id: id,
    exerciseName: 'Squat',
    weight: weight,
    reps: reps,
    isWarmup: warmup,
    timestamp: DateTime(2025, 1, id),
    workoutPosition: 1,
    fatigueScore: 0,
    sessionId: session,
  );
  test('progress groups sessions and ignores warmups and zero reps', () {
    final sessions = summarizeExerciseProgress([
      entry(1, 'older', 100, 8),
      entry(2, 'newer', 100, 9),
      entry(3, 'newer', 500, 0),
      entry(4, 'newer', 999, 12, warmup: true),
    ]);
    expect(sessions.length, 2);
    expect(sessions.first.bestSet!.weight, 100);
    expect(sessionComparison(sessions), contains('+1 rep at 100 lbs'));
    final different = summarizeExerciseProgress([
      entry(1, 'older', 90, 8),
      entry(2, 'newer', 100, 9),
    ]);
    expect(sessionComparison(different), contains('Different loads'));
  });
  testWidgets('history edits a set and refreshes progress on narrow screen', (
    tester,
  ) async {
    await seed();
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      MaterialApp(
        home: ExerciseHistoryPage(
          exercise: Exercise(id: 'squat', name: 'Squat'),
          database: database,
          service: service,
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.text('1 completed session'), findsOneWidget);
    await tester.scrollUntilVisible(find.byIcon(Icons.edit_outlined), 200);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.text('Save')).bottom, lessThan(440));
    await tester.enterText(find.byType(TextField).first, '110');
    await tester.enterText(find.byType(TextField).last, '10');
    await tester.tap(find.text('Save'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Best recorded set · 110 lbs × 10'),
      findsOneWidget,
    );
    tester.view.viewInsets = const FakeViewPadding();
    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(find.text('1100 lb·reps'), findsOneWidget);
    expect(await service.lifetimeXp, 18);
  });
  testWidgets('edit dialog validates invalid values before closing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showEditSetDialog(context, weight: 20, reps: 8),
            child: const Text('Edit'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '-1');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid weight and rep count.'), findsOneWidget);
  });

  testWidgets('completion undo stays above XP and responds immediately', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var undone = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                showXpGainFeedback(
                  context,
                  xp: 18,
                  before: GamificationService.levelProgressForXp(88),
                  after: GamificationService.levelProgressForXp(106),
                );
                showExerciseCompletionUndo(
                  context,
                  exerciseName: 'Squat',
                  onUndo: () {
                    undone = true;
                    dismissXpGainFeedback();
                  },
                );
              },
              child: const Text('Finish'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Finish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester.getRect(find.text('UNDO')).bottom,
      lessThan(tester.getRect(find.text('Set +18 XP')).top),
    );
    await tester.tap(find.text('UNDO'));
    await tester.pump();
    expect(undone, isTrue);
    expect(find.text('Set +18 XP'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
  });
}
