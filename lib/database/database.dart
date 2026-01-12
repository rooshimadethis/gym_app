import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

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
}

@DriftDatabase(tables: [HistoryEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
          ),
        );
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
