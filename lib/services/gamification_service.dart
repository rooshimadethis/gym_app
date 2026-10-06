import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:gym_app/database/database.dart';
import 'package:gym_app/domain/gamification.dart';

/// Persistence boundary for XP and workout progression.
///
/// UI code should call this service after a domain action has been confirmed;
/// it should never calculate XP or write ledger rows itself. All awards are
/// keyed by a stable event ID and are therefore safe to retry.
class GamificationService extends ChangeNotifier {
  GamificationService(this.database);

  final AppDatabase database;
  static const _uuid = Uuid();

  static int xpRequiredForLevel(int level) {
    if (level < 1) return 0;
    return 100 + 25 * (level - 1);
  }

  static int cumulativeXpForLevel(int level) {
    if (level <= 1) return 0;
    var total = 0;
    for (var current = 1; current < level; current++) {
      total += xpRequiredForLevel(current);
    }
    return total;
  }

  static XpLevelProgress levelProgressForXp(int lifetimeXp) {
    final xp = lifetimeXp < 0 ? 0 : lifetimeXp;
    var level = 1;
    var remaining = xp;
    while (remaining >= xpRequiredForLevel(level)) {
      remaining -= xpRequiredForLevel(level);
      level++;
    }
    return XpLevelProgress(
      level: level,
      lifetimeXp: xp,
      xpIntoLevel: remaining,
      xpForNextLevel: xpRequiredForLevel(level),
    );
  }

  static List<int> crossedLevels(int beforeXp, int afterXp) {
    if (afterXp <= beforeXp) return const [];
    final crossed = <int>[];
    final beforeLevel = levelProgressForXp(beforeXp).level;
    final afterLevel = levelProgressForXp(afterXp).level;
    for (var level = beforeLevel + 1; level <= afterLevel; level++) {
      crossed.add(level);
    }
    return crossed;
  }

  Future<int> get lifetimeXp => database.getLifetimeXp();

  Future<int> sessionXp(String sessionId) => database.getSessionXp(sessionId);

  Future<XpLevelProgress> get levelProgress async =>
      levelProgressForXp(await lifetimeXp);

  Future<WorkoutSession?> get pendingAutomaticSession =>
      database.getLatestUnseenAutomaticSession();

  Future<int> markCompletionSummarySeen(String sessionId) =>
      database.markCompletionSummarySeen(sessionId);

  Future<WorkoutSession> startSession({
    String? sessionId,
    DateTime? startedAt,
  }) async {
    final id = sessionId ?? _uuid.v4();
    final started = startedAt ?? DateTime.now();
    await database.upsertWorkoutSession(
      WorkoutSessionsCompanion.insert(
        sessionId: id,
        startedAt: started,
        xpRulesVersion: const Value(XpRules.version),
      ),
    );
    return (await database.getWorkoutSession(id))!;
  }

  Future<ExerciseAttempt> beginExerciseAttempt({
    required String sessionId,
    required String exerciseId,
    required String exerciseName,
    String? groupId,
    String? supersetId,
    String? attemptId,
    DateTime? startedAt,
  }) async {
    final id = attemptId ?? _uuid.v4();
    final started = startedAt ?? DateTime.now();
    await database
        .into(database.exerciseAttempts)
        .insert(
          ExerciseAttemptsCompanion.insert(
            attemptId: id,
            sessionId: sessionId,
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            groupId: Value(groupId),
            supersetId: Value(supersetId),
            status: ExerciseAttemptStatus.active.serializedValue,
            startedAt: started,
          ),
        );
    return (await (database.select(
      database.exerciseAttempts,
    )..where((row) => row.attemptId.equals(id))).getSingle());
  }

  /// Records one set, its optional performance-history row, and its XP event
  /// in one transaction. Failed sets intentionally have no history row.
  Future<XpAward> recordSet({
    required String setAttemptId,
    required String attemptId,
    required int plannedSetIndex,
    required SetAttemptOutcome outcome,
    required double weight,
    required int reps,
    required ExerciseXpTier tier,
    int? historyEntryId,
    bool isWarmup = false,
    int workoutPosition = 1,
    int fatigueScore = 0,
    DateTime? recordedAt,
  }) async {
    final eventKey = 'set:$setAttemptId';
    final eventType = outcome == SetAttemptOutcome.completed
        ? XpEventType.setCompleted
        : XpEventType.setFailed;
    final amount = XpRules.setXp(tier);
    final award = await database.transaction(() async {
      final existingEvent = await database.getXpEvent(eventKey);
      if (existingEvent != null) {
        return XpAward(
          eventKey: eventKey,
          amount: existingEvent.xpAmount,
          alreadyAwarded: true,
        );
      }

      final existingSet =
          await (database.select(database.setAttempts)
                ..where((row) => row.setAttemptId.equals(setAttemptId)))
              .getSingleOrNull();
      if (existingSet != null) {
        final retryEvent = await database.getXpEvent(eventKey);
        return XpAward(
          eventKey: eventKey,
          amount: retryEvent?.xpAmount ?? 0,
          alreadyAwarded: retryEvent != null,
        );
      }

      final attempt = await (database.select(
        database.exerciseAttempts,
      )..where((row) => row.attemptId.equals(attemptId))).getSingle();
      if (attempt.status != ExerciseAttemptStatus.active.serializedValue) {
        throw StateError(
          'Cannot record a set for ${attempt.status} attempt $attemptId',
        );
      }

      int? persistedHistoryId = historyEntryId;
      if (outcome == SetAttemptOutcome.completed &&
          persistedHistoryId == null) {
        persistedHistoryId = await database
            .into(database.historyEntries)
            .insert(
              HistoryEntriesCompanion.insert(
                exerciseName: attempt.exerciseName,
                weight: weight,
                reps: reps,
                isWarmup: Value(isWarmup),
                timestamp: recordedAt ?? DateTime.now(),
                workoutPosition: workoutPosition,
                fatigueScore: fatigueScore,
                sessionId: attempt.sessionId,
                attemptId: Value(attemptId),
                exerciseId: Value(attempt.exerciseId),
              ),
            );
      }

      await database
          .into(database.setAttempts)
          .insert(
            SetAttemptsCompanion.insert(
              setAttemptId: setAttemptId,
              attemptId: attemptId,
              plannedSetIndex: plannedSetIndex,
              outcome: outcome.serializedValue,
              weight: weight,
              reps: reps,
              historyEntryId: Value(persistedHistoryId),
              recordedAt: recordedAt ?? DateTime.now(),
            ),
          );
      await database
          .into(database.xpEvents)
          .insert(
            XpEventsCompanion.insert(
              eventKey: eventKey,
              sessionId: attempt.sessionId,
              eventType: eventType.serializedValue,
              exerciseId: Value(attempt.exerciseId),
              exerciseName: Value(attempt.exerciseName),
              xpAmount: amount,
              rulesVersion: XpRules.version,
              createdAt: recordedAt ?? DateTime.now(),
            ),
          );
      return XpAward(eventKey: eventKey, amount: amount, alreadyAwarded: false);
    });
    if (!award.alreadyAwarded) notifyListeners();
    return award;
  }

  Future<XpAward> recordSuccessfulSet({
    required String setAttemptId,
    required String attemptId,
    required int plannedSetIndex,
    required double weight,
    required int reps,
    required ExerciseXpTier tier,
    int? historyEntryId,
    bool isWarmup = false,
    int workoutPosition = 1,
    int fatigueScore = 0,
    DateTime? recordedAt,
  }) => recordSet(
    setAttemptId: setAttemptId,
    attemptId: attemptId,
    plannedSetIndex: plannedSetIndex,
    outcome: SetAttemptOutcome.completed,
    weight: weight,
    reps: reps,
    tier: tier,
    historyEntryId: historyEntryId,
    isWarmup: isWarmup,
    workoutPosition: workoutPosition,
    fatigueScore: fatigueScore,
    recordedAt: recordedAt,
  );

  Future<XpAward> recordFailedSet({
    required String setAttemptId,
    required String attemptId,
    required int plannedSetIndex,
    required double weight,
    required int reps,
    required ExerciseXpTier tier,
    DateTime? recordedAt,
  }) => recordSet(
    setAttemptId: setAttemptId,
    attemptId: attemptId,
    plannedSetIndex: plannedSetIndex,
    outcome: SetAttemptOutcome.failed,
    weight: weight,
    reps: reps,
    tier: tier,
    recordedAt: recordedAt,
  );

  Future<XpAward> completeExercise({
    required String attemptId,
    required ExerciseXpTier tier,
    DateTime? endedAt,
  }) async {
    final eventKey = 'exercise:$attemptId';
    final amount = XpRules.exerciseXp(tier);
    final award = await database.transaction(() async {
      final existingEvent = await database.getXpEvent(eventKey);
      if (existingEvent != null) {
        return XpAward(
          eventKey: eventKey,
          amount: existingEvent.xpAmount,
          alreadyAwarded: true,
        );
      }
      final attempt = await (database.select(
        database.exerciseAttempts,
      )..where((row) => row.attemptId.equals(attemptId))).getSingle();
      if (attempt.status == ExerciseAttemptStatus.abandoned.serializedValue) {
        throw StateError('An abandoned exercise attempt cannot be completed');
      }
      final now = endedAt ?? DateTime.now();
      await (database.update(
        database.exerciseAttempts,
      )..where((row) => row.attemptId.equals(attemptId))).write(
        ExerciseAttemptsCompanion(
          status: const Value('completed'),
          endedAt: Value(now),
        ),
      );
      await database
          .into(database.xpEvents)
          .insert(
            XpEventsCompanion.insert(
              eventKey: eventKey,
              sessionId: attempt.sessionId,
              eventType: XpEventType.exerciseCompleted.serializedValue,
              exerciseId: Value(attempt.exerciseId),
              exerciseName: Value(attempt.exerciseName),
              xpAmount: amount,
              rulesVersion: XpRules.version,
              createdAt: now,
            ),
          );
      return XpAward(eventKey: eventKey, amount: amount, alreadyAwarded: false);
    });
    if (!award.alreadyAwarded) notifyListeners();
    return award;
  }

  Future<int> abandonExercise(String attemptId, {DateTime? endedAt}) async {
    return (database.update(database.exerciseAttempts)
          ..where((row) => row.attemptId.equals(attemptId))
          ..where((row) => row.status.equals('active')))
        .write(
          ExerciseAttemptsCompanion(
            status: const Value('abandoned'),
            endedAt: Value(endedAt ?? DateTime.now()),
          ),
        );
  }

  /// A correction changes performance only, never the reward ledger.
  Future<void> editHistorySet(
    int historyId, {
    required double weight,
    required int reps,
  }) async {
    if (!weight.isFinite || weight < 0 || reps < 0 || reps > 999) {
      throw ArgumentError('Enter a valid non-negative weight and rep count.');
    }
    await database.transaction(() async {
      final row = await (database.select(
        database.historyEntries,
      )..where((t) => t.id.equals(historyId))).getSingle();
      await (database.update(
        database.historyEntries,
      )..where((t) => t.id.equals(historyId))).write(
        HistoryEntriesCompanion(weight: Value(weight), reps: Value(reps)),
      );
      if (row.attemptId != null) {
        await (database.update(
          database.setAttempts,
        )..where((t) => t.historyEntryId.equals(historyId))).write(
          SetAttemptsCompanion(weight: Value(weight), reps: Value(reps)),
        );
      }
    });
    notifyListeners();
  }

  /// Undo is limited to the current, open workout. Relogging the stable set ID
  /// then awards exactly once again. All linked writes roll back together.
  Future<void> undoSet(
    String setAttemptId, {
    required String currentSessionId,
  }) async {
    await database.transaction(() async {
      final set = await (database.select(
        database.setAttempts,
      )..where((t) => t.setAttemptId.equals(setAttemptId))).getSingleOrNull();
      if (set == null) return; // Repeated undo is harmless.
      final attempt = await (database.select(
        database.exerciseAttempts,
      )..where((t) => t.attemptId.equals(set.attemptId))).getSingle();
      final session = await database.getWorkoutSession(attempt.sessionId);
      if (attempt.sessionId != currentSessionId ||
          session == null ||
          session.endedAt != null ||
          attempt.status == 'abandoned') {
        throw StateError(
          'Only sets in an ongoing exercise/workout can be undone.',
        );
      }
      if (set.historyEntryId != null) {
        await (database.delete(
          database.historyEntries,
        )..where((t) => t.id.equals(set.historyEntryId!))).go();
      }
      await (database.delete(
        database.setAttempts,
      )..where((t) => t.setAttemptId.equals(setAttemptId))).go();
      await (database.delete(database.xpEvents)..where(
            (t) => t.eventKey.isIn([
              'set:$setAttemptId',
              'exercise:${attempt.attemptId}',
              'workout:${attempt.sessionId}',
            ]),
          ))
          .go();
      await (database.update(
        database.exerciseAttempts,
      )..where((t) => t.attemptId.equals(attempt.attemptId))).write(
        const ExerciseAttemptsCompanion(
          status: Value('active'),
          endedAt: Value(null),
        ),
      );
    });
    notifyListeners();
  }

  Future<int> recoverUnfinishedAttempts({DateTime? endedAt}) =>
      database.markUnfinishedAttemptsAbandoned(endedAt: endedAt);

  Future<XpAward?> completeWorkout(
    String sessionId, {
    WorkoutEndReason reason = WorkoutEndReason.explicit,
    DateTime? endedAt,
  }) async {
    final award = await database.transaction(() async {
      final now = endedAt ?? DateTime.now();
      await (database.update(database.exerciseAttempts)
            ..where((row) => row.sessionId.equals(sessionId))
            ..where(
              (row) => row.status.equals(
                ExerciseAttemptStatus.active.serializedValue,
              ),
            ))
          .write(
            ExerciseAttemptsCompanion(
              status: Value(ExerciseAttemptStatus.abandoned.serializedValue),
              endedAt: Value(now),
            ),
          );
      final attempts = await database.getAttemptsForSession(sessionId);
      final hasCompletedExercise = attempts.any(
        (attempt) =>
            attempt.status == ExerciseAttemptStatus.completed.serializedValue,
      );
      XpAward? award;
      if (reason == WorkoutEndReason.explicit && hasCompletedExercise) {
        final eventKey = 'workout:$sessionId';
        final existingEvent = await database.getXpEvent(eventKey);
        if (existingEvent != null) {
          award = XpAward(
            eventKey: eventKey,
            amount: existingEvent.xpAmount,
            alreadyAwarded: true,
          );
        } else {
          await database
              .into(database.xpEvents)
              .insert(
                XpEventsCompanion.insert(
                  eventKey: eventKey,
                  sessionId: sessionId,
                  eventType: XpEventType.workoutCompleted.serializedValue,
                  xpAmount: XpRules.workoutCompletionXp,
                  rulesVersion: XpRules.version,
                  createdAt: now,
                ),
              );
          award = XpAward(
            eventKey: eventKey,
            amount: XpRules.workoutCompletionXp,
            alreadyAwarded: false,
          );
        }
      }
      await database.endWorkoutSession(sessionId, reason, now);
      return award;
    });
    if (award != null && !award.alreadyAwarded) notifyListeners();
    return award;
  }

  Future<XpAward?> endSession(
    String sessionId, {
    WorkoutEndReason reason = WorkoutEndReason.explicit,
    DateTime? endedAt,
  }) => completeWorkout(sessionId, reason: reason, endedAt: endedAt);

  Future<XpBreakdown> breakdownForSession(String sessionId) async {
    final events = await database.getXpEventsForSession(sessionId);
    var completed = 0;
    var failed = 0;
    var exercises = 0;
    var workout = 0;
    for (final event in events) {
      switch (event.eventType) {
        case 'set_completed':
          completed += event.xpAmount;
        case 'set_failed':
          failed += event.xpAmount;
        case 'exercise_completed':
          exercises += event.xpAmount;
        case 'workout_completed':
          workout += event.xpAmount;
      }
    }
    return XpBreakdown(
      setCompletedXp: completed,
      setFailedXp: failed,
      exerciseCompletedXp: exercises,
      workoutCompletedXp: workout,
    );
  }
}

/// Convenience aliases for callers that only need pure level math.
int levelForXp(int lifetimeXp) =>
    GamificationService.levelProgressForXp(lifetimeXp).level;

int xpRequiredForLevel(int level) =>
    GamificationService.xpRequiredForLevel(level);
