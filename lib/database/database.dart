import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:gym_app/domain/gamification.dart';

part 'database.g.dart';

class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseName => text()();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get workoutPosition => integer()(); // 1st, 2nd, 3rd...
  IntColumn get fatigueScore =>
      integer()(); // -1 (Fresh), 0 (Normal), 1 (Fatigued)
  TextColumn get sessionId => text()();

  /// Null for legacy history imported before attempts were introduced.
  TextColumn get attemptId => text().nullable()();

  /// Null for legacy rows; new rows use the stable exercise UUID.
  TextColumn get exerciseId => text().nullable()();
}

class WorkoutSessions extends Table {
  TextColumn get sessionId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get endReason => text().nullable()();
  IntColumn get xpRulesVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get completionSummarySeenAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {sessionId};
}

class ExerciseAttempts extends Table {
  TextColumn get attemptId => text()();
  TextColumn get sessionId => text()();
  TextColumn get exerciseId => text()();
  TextColumn get exerciseName => text()();
  TextColumn get groupId => text().nullable()();
  TextColumn get supersetId => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {attemptId};
}

class SetAttempts extends Table {
  TextColumn get setAttemptId => text()();
  TextColumn get attemptId => text()();
  IntColumn get plannedSetIndex => integer()();
  TextColumn get outcome => text()();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  IntColumn get historyEntryId => integer().nullable()();
  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {setAttemptId};
}

class XpEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventKey => text()();
  TextColumn get sessionId => text()();
  TextColumn get eventType => text()();
  TextColumn get exerciseId => text().nullable()();
  TextColumn get exerciseName => text().nullable()();
  IntColumn get xpAmount => integer()();
  IntColumn get rulesVersion => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {eventKey},
  ];
}

@DriftDatabase(
  tables: [
    HistoryEntries,
    WorkoutSessions,
    ExerciseAttempts,
    SetAttempts,
    XpEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(historyEntries, historyEntries.attemptId);
        await m.addColumn(historyEntries, historyEntries.exerciseId);
        await m.createTable(workoutSessions);
        await m.createTable(exerciseAttempts);
        await m.createTable(setAttempts);
        await m.createTable(xpEvents);
      }
    },
  );

  // --- CRUD Operations ---

  Future<int> addHistoryEntry(HistoryEntriesCompanion entry) {
    return into(historyEntries).insert(entry);
  }

  Future<List<HistoryEntry>> getAllHistory() {
    return select(historyEntries).get();
  }

  // Find most recent sessions for a specific exercise
  Future<List<HistoryEntry>> getHistoryForExercise(
    String name, {
    int limit = 10,
  }) {
    return (select(historyEntries)
          ..where((tbl) => tbl.exerciseName.equals(name))
          ..where(_completedOrLegacyHistory)
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.timestamp,
              mode: OrderingMode.desc,
            ),
            (tbl) => OrderingTerm(expression: tbl.id, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Expression<bool> _completedOrLegacyHistory(HistoryEntries tbl) {
    final completedAttemptIds = selectOnly(exerciseAttempts)
      ..addColumns([exerciseAttempts.attemptId])
      ..where(exerciseAttempts.status.equals('completed'));
    return tbl.attemptId.isNull() |
        tbl.attemptId.isInQuery(completedAttemptIds);
  }

  Future<List<HistoryEntry>> getPerformanceHistoryForExercise(
    String exerciseId, {
    String? legacyExerciseName,
    int limit = 10,
  }) {
    return (select(historyEntries)
          ..where(
            (tbl) =>
                tbl.exerciseId.equals(exerciseId) |
                (legacyExerciseName == null
                    ? const Constant(false)
                    : tbl.exerciseId.isNull() &
                          tbl.exerciseName.equals(legacyExerciseName)),
          )
          ..where(_completedOrLegacyHistory)
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.timestamp,
              mode: OrderingMode.desc,
            ),
            (tbl) => OrderingTerm(expression: tbl.id, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Future<int> getExerciseSessionPosition(
    String sessionId,
    String exerciseName,
  ) async {
    // Check if this exercise already has a position in this session
    final existingEntry =
        await (select(historyEntries)
              ..where((t) => t.sessionId.equals(sessionId))
              ..where((t) => t.exerciseName.equals(exerciseName))
              ..limit(1))
            .getSingleOrNull();

    if (existingEntry != null) {
      return existingEntry.workoutPosition;
    }

    // If new to session, calculate next position
    final query = selectOnly(historyEntries)
      ..addColumns([historyEntries.exerciseName])
      ..where(historyEntries.sessionId.equals(sessionId));

    final results = await query.get();
    final uniqueExercises = results
        .map((r) => r.read(historyEntries.exerciseName))
        .toSet();
    return uniqueExercises.length + 1;
  }

  Future<Map<String, DateTime>> getLastFreshDates() async {
    final query = selectOnly(historyEntries)
      ..addColumns([
        historyEntries.exerciseName,
        historyEntries.timestamp.max(),
      ])
      ..where(historyEntries.workoutPosition.isSmallerOrEqualValue(2))
      ..where(historyEntries.fatigueScore.isSmallerOrEqualValue(0))
      ..where(_completedOrLegacyHistory(historyEntries))
      ..groupBy([historyEntries.exerciseName]);

    final results = await query.get();

    return {
      for (final row in results)
        if (row.read(historyEntries.exerciseName) != null &&
            row.read(historyEntries.timestamp.max()) != null)
          row.read(historyEntries.exerciseName)!: row.read(
            historyEntries.timestamp.max(),
          )!,
    };
  }

  Future<DateTime?> getLastFreshDateForExercise(
    String exerciseId,
    String legacyExerciseName,
  ) async {
    final query = selectOnly(historyEntries)
      ..addColumns([historyEntries.timestamp.max()])
      ..where(
        historyEntries.exerciseId.equals(exerciseId) |
            (historyEntries.exerciseId.isNull() &
                historyEntries.exerciseName.equals(legacyExerciseName)),
      )
      ..where(historyEntries.workoutPosition.isSmallerOrEqualValue(2))
      ..where(historyEntries.fatigueScore.isSmallerOrEqualValue(0))
      ..where(_completedOrLegacyHistory(historyEntries));
    final row = await query.getSingle();
    return row.read(historyEntries.timestamp.max());
  }

  Future<void> deleteAllHistory() {
    return delete(historyEntries).go();
  }

  Future<void> batchImportHistory(List<Map<String, dynamic>> jsonList) async {
    await batch((batch) {
      for (final json in jsonList) {
        // Handle DateTime conversion if stored as String in JSON
        final timestamp = json['timestamp'] is int
            ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
            : DateTime.parse(json['timestamp'].toString());

        batch.insert(
          historyEntries,
          HistoryEntriesCompanion.insert(
            exerciseName: json['exerciseName'],
            weight: (json['weight'] as num).toDouble(),
            reps: json['reps'] as int,
            isWarmup: Value(json['isWarmup'] as bool? ?? false),
            timestamp: timestamp,
            workoutPosition: json['workoutPosition'] as int,
            fatigueScore: json['fatigueScore'] as int,
            sessionId: json['sessionId'],
            attemptId: Value(json['attemptId'] as String?),
            exerciseId: Value(json['exerciseId'] as String?),
          ),
        );
      }
    });
  }

  Future<void> upsertWorkoutSession(WorkoutSessionsCompanion session) async {
    await into(workoutSessions).insertOnConflictUpdate(session);
  }

  Future<WorkoutSession?> getWorkoutSession(String sessionId) {
    return (select(
      workoutSessions,
    )..where((row) => row.sessionId.equals(sessionId))).getSingleOrNull();
  }

  Future<WorkoutSession?> getLatestUnseenAutomaticSession() {
    return (select(workoutSessions)
          ..where((row) => row.endReason.equals('automatic'))
          ..where((row) => row.completionSummarySeenAt.isNull())
          ..orderBy([
            (row) =>
                OrderingTerm(expression: row.endedAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> markCompletionSummarySeen(String sessionId, {DateTime? seenAt}) {
    return (update(
      workoutSessions,
    )..where((row) => row.sessionId.equals(sessionId))).write(
      WorkoutSessionsCompanion(
        completionSummarySeenAt: Value(seenAt ?? DateTime.now()),
      ),
    );
  }

  Future<void> endWorkoutSession(
    String sessionId,
    WorkoutEndReason endReason,
    DateTime endedAt,
  ) async {
    await (update(
      workoutSessions,
    )..where((row) => row.sessionId.equals(sessionId))).write(
      WorkoutSessionsCompanion(
        endedAt: Value(endedAt),
        endReason: Value(endReason.serializedValue),
      ),
    );
  }

  Future<int> markUnfinishedAttemptsAbandoned({DateTime? endedAt}) async {
    final now = endedAt ?? DateTime.now();
    return (update(
      exerciseAttempts,
    )..where((row) => row.status.equals('active'))).write(
      ExerciseAttemptsCompanion(
        status: const Value('abandoned'),
        endedAt: Value(now),
      ),
    );
  }

  Future<List<ExerciseAttempt>> getAttemptsForSession(String sessionId) {
    return (select(exerciseAttempts)
          ..where((row) => row.sessionId.equals(sessionId))
          ..orderBy([(row) => OrderingTerm(expression: row.startedAt)]))
        .get();
  }

  Future<XpEvent?> getXpEvent(String eventKey) {
    return (select(
      xpEvents,
    )..where((row) => row.eventKey.equals(eventKey))).getSingleOrNull();
  }

  Future<int> getSessionXp(String sessionId) async {
    final result =
        await (selectOnly(xpEvents)
              ..addColumns([xpEvents.xpAmount.sum()])
              ..where(xpEvents.sessionId.equals(sessionId)))
            .getSingle();
    return result.read(xpEvents.xpAmount.sum()) ?? 0;
  }

  Future<int> getLifetimeXp() async {
    final result = await (selectOnly(
      xpEvents,
    )..addColumns([xpEvents.xpAmount.sum()])).getSingle();
    return result.read(xpEvents.xpAmount.sum()) ?? 0;
  }

  Future<List<XpEvent>> getXpEventsForSession(String sessionId) {
    return (select(xpEvents)
          ..where((row) => row.sessionId.equals(sessionId))
          ..orderBy([(row) => OrderingTerm(expression: row.createdAt)]))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
