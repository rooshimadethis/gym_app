import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/database/database.dart';
import 'package:gym_app/logic/exercise_progress.dart';
import 'package:gym_app/models/models.dart';
import 'package:gym_app/services/backup_service.dart';
import 'package:gym_app/services/exercise_settings.dart';
import 'package:gym_app/widgets/exercise_volume_chart.dart';
import 'package:gym_app/widgets/exercise_warmup_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

HistoryEntry row(
  int id,
  String session,
  double weight,
  int reps, {
  bool warmup = false,
}) => HistoryEntry(
  id: id,
  exerciseName: 'Press',
  weight: weight,
  reps: reps,
  isWarmup: warmup,
  timestamp: DateTime(2026, 9, id),
  workoutPosition: 1,
  fatigueScore: 0,
  sessionId: session,
);

void main() {
  test(
    'volume sums every working set with decimal loads and ignores warmups',
    () {
      final sessions = summarizeExerciseProgress([
        row(1, 'old', 80, 10),
        row(2, 'new', 100, 8),
        row(3, 'new', 102.5, 6),
        row(4, 'new', 500, 0),
        row(5, 'new', 90, 20, warmup: true),
      ]);
      expect(sessions.first.volume, 1415);
      expect(sessions.last.volume, 800);
    },
  );

  test('warmup preference migrates once and stays independent', () {
    final old = {
      'id': 'old',
      'name': 'Old',
      'xpTier': 'standard',
      'sets': <Object>[],
    };
    final migrated = Exercise.fromJson(old, legacyWarmupSetEnabled: true);
    expect(migrated.warmupSetEnabled, isTrue);
    migrated.warmupSetEnabled = false;
    final saved = migrated.toJson();
    expect(Exercise.metadataNeedsMigration(old), isTrue);
    expect(Exercise.metadataNeedsMigration(saved), isFalse);
    expect(
      Exercise.fromJson(saved, legacyWarmupSetEnabled: true).warmupSetEnabled,
      isFalse,
    );
    expect(Exercise(name: 'New').warmupSetEnabled, isFalse);
  });

  test('saving one exercise preserves other exercises and set data', () async {
    final first = Exercise(id: 'first', name: 'Press', warmupSetEnabled: true);
    final second = Exercise(
      id: 'second',
      name: 'Curl',
      warmupSetEnabled: true,
      sets: [SetData(weight: '25', reps: '12')],
    );
    SharedPreferences.setMockInitialValues({
      'exercises_data': jsonEncode([first.toJson(), second.toJson()]),
    });
    await saveExerciseWarmup(first, false);
    final prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString('exercises_data')!) as List;
    expect(first.warmupSetEnabled, isFalse);
    expect(saved[0]['warmupSetEnabled'], isFalse);
    expect(saved[1], second.toJson());
  });

  test(
    'backup round trip preserves overrides and migrates older backups',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final first = Exercise(id: 'a', name: 'Press', warmupSetEnabled: false);
      final second = Exercise(id: 'b', name: 'Curl', warmupSetEnabled: true);
      SharedPreferences.setMockInitialValues({
        'exercises_data': jsonEncode([first.toJson(), second.toJson()]),
        'warmup_set_enabled': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = BackupService(database, prefs);
      final exported = await service.export();
      await service.restore(WorkoutBackup.parse(exported));
      final saved = jsonDecode(prefs.getString('exercises_data')!) as List;
      expect(saved[0]['warmupSetEnabled'], isFalse);
      expect(saved[1]['warmupSetEnabled'], isTrue);
      final older = jsonDecode(exported) as Map<String, dynamic>;
      older['exercises_data'][0].remove('warmupSetEnabled');
      expect(
        WorkoutBackup.parse(jsonEncode(older)).exercises.first.warmupSetEnabled,
        isTrue,
      );
      older['exercises_data'][0]['warmupSetEnabled'] = 'invalid';
      expect(
        () => WorkoutBackup.parse(jsonEncode(older)),
        throwsFormatException,
      );
    },
  );

  testWidgets(
    'chart shows last six complete sessions on narrow screen with large text',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final sessions = summarizeExerciseProgress([
        for (int i = 1; i <= 8; i++) row(i, 'session-$i', 100, i),
      ]);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ExerciseVolumeChart(sessions: sessions),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('800 lb·reps'), findsOneWidget);
      expect(find.text('+14.3% vs previous session'), findsOneWidget);
      expect(find.text('100'), findsNothing);
      expect(find.text('300'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('chart handles empty and zero-volume sessions', (tester) async {
    Future<void> show(List<ExerciseSessionProgress> sessions) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ExerciseVolumeChart(sessions: sessions)),
          ),
        );
    await show([]);
    expect(find.textContaining('start your volume trend'), findsOneWidget);
    await show(
      summarizeExerciseProgress([row(1, 'old', 0, 10), row(2, 'new', 100, 10)]),
    );
    expect(find.text('1000 lb·reps vs previous session'), findsOneWidget);
    await show(summarizeExerciseProgress([row(1, 'only', 0, 10)]));
    expect(find.text('0 lb·reps'), findsOneWidget);
    expect(find.textContaining('another session'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('warmup toggle changes only the selected exercise and can lock', (
    tester,
  ) async {
    final first = Exercise(name: 'Press', warmupSetEnabled: true);
    final second = Exercise(name: 'Curl', warmupSetEnabled: true);
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: ExerciseWarmupToggle(
              enabled: first.warmupSetEnabled,
              onChanged: (value) =>
                  setState(() => first.warmupSetEnabled = value),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(first.warmupSetEnabled, isFalse);
    expect(second.warmupSetEnabled, isTrue);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseWarmupToggle(enabled: true, onChanged: null),
        ),
      ),
    );
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });
}
