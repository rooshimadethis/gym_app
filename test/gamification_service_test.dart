import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_app/database/database.dart';
import 'package:gym_app/domain/gamification.dart';
import 'package:gym_app/services/gamification_service.dart';

void main() {
  late AppDatabase database;
  late GamificationService service;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    service = GamificationService(database);
  });

  tearDown(() => database.close());

  test('unknown or missing XP tiers safely parse as standard', () {
    expect(ExerciseXpTierSerialization.parse(null), ExerciseXpTier.standard);
    expect(
      ExerciseXpTierSerialization.parse('future-tier'),
      ExerciseXpTier.standard,
    );
    expect(
      ExerciseXpTierSerialization.parse('DEMANDING'),
      ExerciseXpTier.demanding,
    );
  });

  test('level curve handles boundaries and multiple level crossings', () {
    expect(levelForXp(0), 1);
    expect(levelForXp(99), 1);
    expect(levelForXp(100), 2);
    expect(levelForXp(224), 2);
    expect(levelForXp(225), 3);
    expect(GamificationService.crossedLevels(0, 375), [2, 3, 4]);
    expect(GamificationService.levelProgressForXp(225).xpIntoLevel, 0);
  });

  test('failed set earns XP but does not enter performance history', () async {
    final session = await service.startSession(sessionId: 'session-1');
    final attempt = await service.beginExerciseAttempt(
      sessionId: session.sessionId,
      exerciseId: 'exercise-1',
      exerciseName: 'Squat',
      attemptId: 'attempt-1',
    );

    final award = await service.recordSet(
      setAttemptId: 'set-1',
      attemptId: attempt.attemptId,
      plannedSetIndex: 0,
      outcome: SetAttemptOutcome.failed,
      weight: 100,
      reps: 0,
      tier: ExerciseXpTier.demanding,
    );
    await service.abandonExercise(attempt.attemptId);

    expect(award.amount, 3);
    expect(await service.sessionXp(session.sessionId), 3);
    expect(await database.getHistoryForExercise('Squat'), isEmpty);
    expect(
      await database.getPerformanceHistoryForExercise('exercise-1'),
      isEmpty,
    );
  });

  test('retrying the same set event is idempotent', () async {
    final session = await service.startSession(sessionId: 'session-2');
    final attempt = await service.beginExerciseAttempt(
      sessionId: session.sessionId,
      exerciseId: 'exercise-2',
      exerciseName: 'Bench press',
      attemptId: 'attempt-2',
    );

    final first = await service.recordSet(
      setAttemptId: 'set-2',
      attemptId: attempt.attemptId,
      plannedSetIndex: 0,
      outcome: SetAttemptOutcome.completed,
      weight: 60,
      reps: 8,
      tier: ExerciseXpTier.standard,
    );
    final retry = await service.recordSet(
      setAttemptId: 'set-2',
      attemptId: attempt.attemptId,
      plannedSetIndex: 0,
      outcome: SetAttemptOutcome.completed,
      weight: 60,
      reps: 8,
      tier: ExerciseXpTier.standard,
    );
    expect(first.amount, 2);
    expect(retry.amount, 2);
    expect(retry.alreadyAwarded, isTrue);
    expect(await service.sessionXp(session.sessionId), 2);
    await service.completeExercise(
      attemptId: attempt.attemptId,
      tier: ExerciseXpTier.standard,
    );
    expect((await database.getHistoryForExercise('Bench press')), hasLength(1));
  });

  test(
    'completed exercise and explicit workout completion are each idempotent',
    () async {
      final session = await service.startSession(sessionId: 'session-3');
      final attempt = await service.beginExerciseAttempt(
        sessionId: session.sessionId,
        exerciseId: 'exercise-3',
        exerciseName: 'Curl',
        attemptId: 'attempt-3',
      );
      await service.recordSet(
        setAttemptId: 'set-3',
        attemptId: attempt.attemptId,
        plannedSetIndex: 0,
        outcome: SetAttemptOutcome.completed,
        weight: 10,
        reps: 10,
        tier: ExerciseXpTier.accessory,
      );

      final exerciseAward = await service.completeExercise(
        attemptId: attempt.attemptId,
        tier: ExerciseXpTier.accessory,
      );
      final exerciseRetry = await service.completeExercise(
        attemptId: attempt.attemptId,
        tier: ExerciseXpTier.accessory,
      );
      final workoutAward = await service.completeWorkout(session.sessionId);
      final workoutRetry = await service.completeWorkout(session.sessionId);

      expect(exerciseAward.amount, 5);
      expect(exerciseRetry.alreadyAwarded, isTrue);
      expect(workoutAward?.amount, 40);
      expect(workoutRetry?.alreadyAwarded, isTrue);
      expect(await service.sessionXp(session.sessionId), 46);
    },
  );

  test('unfinished attempts can be abandoned during recovery', () async {
    final session = await service.startSession(sessionId: 'session-4');
    await service.beginExerciseAttempt(
      sessionId: session.sessionId,
      exerciseId: 'exercise-4',
      exerciseName: 'Row',
      attemptId: 'attempt-4',
    );

    expect(await service.recoverUnfinishedAttempts(), 1);
    final attempts = await database.getAttemptsForSession(session.sessionId);
    expect(attempts.single.status, ExerciseAttemptStatus.abandoned.name);
  });

  test(
    'ending a workout abandons unfinished attempts without completion XP',
    () async {
      final session = await service.startSession(sessionId: 'session-5');
      final attempt = await service.beginExerciseAttempt(
        sessionId: session.sessionId,
        exerciseId: 'exercise-5',
        exerciseName: 'Deadlift',
        attemptId: 'attempt-5',
      );
      await service.recordSuccessfulSet(
        setAttemptId: 'set-5',
        attemptId: attempt.attemptId,
        plannedSetIndex: 0,
        weight: 100,
        reps: 3,
        tier: ExerciseXpTier.demanding,
      );

      final workoutAward = await service.completeWorkout(session.sessionId);
      final attempts = await database.getAttemptsForSession(session.sessionId);

      expect(workoutAward, isNull);
      expect(attempts.single.status, ExerciseAttemptStatus.abandoned.name);
      expect(await service.sessionXp(session.sessionId), 3);
      expect(await database.getHistoryForExercise('Deadlift'), isEmpty);
      expect(await database.getLastFreshDates(), isEmpty);
    },
  );

  test('automatic endings preserve XP and expose one quiet summary', () async {
    final session = await service.startSession(sessionId: 'session-6');
    final attempt = await service.beginExerciseAttempt(
      sessionId: session.sessionId,
      exerciseId: 'exercise-6',
      exerciseName: 'Row',
      attemptId: 'attempt-6',
    );
    await service.recordFailedSet(
      setAttemptId: 'set-6',
      attemptId: attempt.attemptId,
      plannedSetIndex: 0,
      weight: 40,
      reps: 2,
      tier: ExerciseXpTier.standard,
    );

    final award = await service.completeWorkout(
      session.sessionId,
      reason: WorkoutEndReason.automatic,
    );

    expect(award, isNull);
    expect(await service.sessionXp(session.sessionId), 2);
    expect(
      (await service.pendingAutomaticSession)?.sessionId,
      session.sessionId,
    );
    await service.markCompletionSummarySeen(session.sessionId);
    expect(await service.pendingAutomaticSession, isNull);
  });

  test(
    'stable exercise IDs separate new history with duplicate names',
    () async {
      final session = await service.startSession(sessionId: 'session-7');
      for (final id in ['row-a', 'row-b']) {
        final attempt = await service.beginExerciseAttempt(
          sessionId: session.sessionId,
          exerciseId: id,
          exerciseName: 'Row',
          attemptId: 'attempt-$id',
        );
        await service.recordSuccessfulSet(
          setAttemptId: 'set-$id',
          attemptId: attempt.attemptId,
          plannedSetIndex: 0,
          weight: id == 'row-a' ? 40 : 60,
          reps: 8,
          tier: ExerciseXpTier.standard,
        );
        await service.completeExercise(
          attemptId: attempt.attemptId,
          tier: ExerciseXpTier.standard,
        );
      }

      final firstHistory = await database.getPerformanceHistoryForExercise(
        'row-a',
        legacyExerciseName: 'Row',
      );
      expect(firstHistory, hasLength(1));
      expect(firstHistory.single.weight, 40);
    },
  );
}
