import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gym_app/database/database.dart';
import 'package:gym_app/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Parsed once before confirmation; invalid input never reaches persistence.
class WorkoutBackup {
  WorkoutBackup._(
    this.exercises,
    this.settings,
    this.history,
    this.sessions,
    this.attempts,
    this.sets,
    this.events,
    this.isLegacy,
  );

  final List<Exercise> exercises;
  final Map<String, Object> settings;
  final List<HistoryEntry> history;
  final List<WorkoutSession> sessions;
  final List<ExerciseAttempt> attempts;
  final List<SetAttempt> sets;
  final List<XpEvent> events;
  final bool isLegacy;

  static const settingTypes = <String, Type>{
    'timer_duration': int,
    'notifications_enabled': bool,
    'warmup_set_enabled': bool,
    'theme_mode': int,
    'workout_feedback_haptics_enabled': bool,
    'workout_feedback_sound_enabled': bool,
  };

  static WorkoutBackup parse(String content) {
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      final legacy = !data.containsKey('backup_version');
      if (!legacy &&
          (data['backup_version'] != 1 || data['app'] != 'gym_app')) {
        throw const FormatException('Unsupported backup version.');
      }
      List<Map<String, dynamic>> rows(String key, {bool optional = false}) {
        if (optional && data[key] == null) return [];
        return (data[key] as List)
            .map((r) => Map<String, dynamic>.from(r as Map))
            .toList();
      }

      final exerciseJson = rows('exercises_data');
      for (final row in exerciseJson) {
        if (!legacy &&
            (row['id'] is! String ||
                (row['id'] as String).trim().isEmpty ||
                ![
                  'accessory',
                  'standard',
                  'demanding',
                ].contains(row['xpTier']))) {
          throw const FormatException('Invalid exercise metadata.');
        }
        if (row['name'] is! String ||
            (row['name'] as String).trim().isEmpty ||
            row['sets'] is! List) {
          throw const FormatException('Invalid exercise data.');
        }
        if (row.containsKey('warmupSetEnabled') &&
            row['warmupSetEnabled'] is! bool) {
          throw const FormatException('Invalid exercise warmup setting.');
        }
        for (final set in row['sets'] as List) {
          if (set is! Map ||
              set['weight'] is! String ||
              set['reps'] is! String) {
            throw const FormatException('Invalid exercise sets.');
          }
        }
      }
      final rawSettings = Map<String, dynamic>.from(data['settings'] as Map);
      final settings = <String, Object>{};
      for (final entry in settingTypes.entries) {
        final value = rawSettings[entry.key];
        if (value == null) continue;
        if (value.runtimeType != entry.value) {
          throw const FormatException('Invalid setting type.');
        }
        settings[entry.key] = value as Object;
      }
      final exercises = exerciseJson
          .map(
            (row) => Exercise.fromJson(
              row,
              legacyWarmupSetEnabled:
                  settings['warmup_set_enabled'] as bool? ?? false,
            ),
          )
          .toList();
      if ((settings['timer_duration'] as int? ?? 120) <= 0 ||
          (settings['theme_mode'] as int? ?? 2) < 0 ||
          (settings['theme_mode'] as int? ?? 2) > 2) {
        throw const FormatException('Invalid settings.');
      }
      Map<String, dynamic> normalizeDate(
        Map<String, dynamic> row,
        List<String> keys,
      ) {
        for (final key in keys) {
          if (row[key] is String) {
            row[key] = DateTime.parse(row[key]).millisecondsSinceEpoch;
          }
        }
        return row;
      }

      final history = rows('history_data', optional: legacy).map((row) {
        normalizeDate(row, ['timestamp']);
        if (legacy) {
          // Older exports lack the attempt tables: detach stale references.
          row['attemptId'] = null;
        }
        return HistoryEntry.fromJson(row);
      }).toList();
      final sessions = legacy
          ? <WorkoutSession>[]
          : rows('sessions')
                .map(
                  (r) => WorkoutSession.fromJson(
                    normalizeDate(r, [
                      'startedAt',
                      'endedAt',
                      'completionSummarySeenAt',
                    ]),
                  ),
                )
                .toList();
      final attempts = legacy
          ? <ExerciseAttempt>[]
          : rows('exercise_attempts')
                .map(
                  (r) => ExerciseAttempt.fromJson(
                    normalizeDate(r, ['startedAt', 'endedAt']),
                  ),
                )
                .toList();
      final sets = legacy
          ? <SetAttempt>[]
          : rows('set_attempts')
                .map(
                  (r) => SetAttempt.fromJson(normalizeDate(r, ['recordedAt'])),
                )
                .toList();
      final events = legacy
          ? <XpEvent>[]
          : rows('xp_events')
                .map((r) => XpEvent.fromJson(normalizeDate(r, ['createdAt'])))
                .toList();
      void unique(Iterable<Object> keys) {
        final list = keys.toList();
        if (list.toSet().length != list.length) {
          throw const FormatException('Duplicate record IDs.');
        }
      }

      unique(exercises.map((r) => r.id));
      unique(history.map((r) => r.id));
      unique(sessions.map((r) => r.sessionId));
      unique(attempts.map((r) => r.attemptId));
      unique(sets.map((r) => r.setAttemptId));
      unique(sets.map((r) => '${r.attemptId}:${r.plannedSetIndex}'));
      unique(events.map((r) => r.id));
      unique(events.map((r) => r.eventKey));
      final sessionIds = sessions.map((r) => r.sessionId).toSet();
      final attemptById = {for (final r in attempts) r.attemptId: r};
      final setByEventKey = {for (final r in sets) 'set:${r.setAttemptId}': r};
      final attemptByEventKey = {
        for (final r in attempts) 'exercise:${r.attemptId}': r,
      };
      final historyById = {for (final r in history) r.id: r};
      for (final r in history) {
        if (!r.weight.isFinite ||
            r.weight < 0 ||
            r.reps < 0 ||
            r.reps > 999 ||
            (r.attemptId != null &&
                (!attemptById.containsKey(r.attemptId) ||
                    attemptById[r.attemptId]!.sessionId != r.sessionId))) {
          throw const FormatException('Invalid performance history.');
        }
      }
      for (final r in sessions) {
        if (r.sessionId.isEmpty ||
            r.xpRulesVersion < 1 ||
            (r.endedAt != null && r.endedAt!.isBefore(r.startedAt)) ||
            (r.endReason != null &&
                ![
                  'explicit',
                  'automatic',
                  'discarded',
                ].contains(r.endReason))) {
          throw const FormatException('Invalid workout session.');
        }
      }
      for (final r in attempts) {
        if (!sessionIds.contains(r.sessionId) ||
            r.attemptId.isEmpty ||
            r.exerciseId.isEmpty ||
            !['active', 'completed', 'abandoned'].contains(r.status)) {
          throw const FormatException('Invalid exercise attempt.');
        }
      }
      for (final r in sets) {
        final linkedHistory = historyById[r.historyEntryId];
        if (!attemptById.containsKey(r.attemptId) ||
            r.setAttemptId.isEmpty ||
            r.plannedSetIndex < 0 ||
            !r.weight.isFinite ||
            r.weight < 0 ||
            r.reps < 0 ||
            r.reps > 999 ||
            !['completed', 'failed'].contains(r.outcome) ||
            (r.outcome == 'failed' && r.historyEntryId != null) ||
            (r.historyEntryId != null &&
                (linkedHistory == null ||
                    linkedHistory.attemptId != r.attemptId ||
                    linkedHistory.weight != r.weight ||
                    linkedHistory.reps != r.reps))) {
          throw const FormatException('Invalid set or history link.');
        }
      }
      for (final r in events) {
        if (!sessionIds.contains(r.sessionId) ||
            r.xpAmount < 0 ||
            r.rulesVersion < 1 ||
            r.eventKey.isEmpty ||
            ![
              'set_completed',
              'set_failed',
              'exercise_completed',
              'workout_completed',
            ].contains(r.eventType)) {
          throw const FormatException('Invalid XP ledger.');
        }
        final set = setByEventKey[r.eventKey];
        final attempt = attemptByEventKey[r.eventKey];
        final validKey = switch (r.eventType) {
          'set_completed' || 'set_failed' =>
            set != null &&
                attemptById[set.attemptId]!.sessionId == r.sessionId &&
                (r.eventType == 'set_completed') ==
                    (set.outcome == 'completed'),
          'exercise_completed' =>
            attempt != null &&
                attempt.sessionId == r.sessionId &&
                attempt.status == 'completed',
          _ => r.eventKey == 'workout:${r.sessionId}',
        };
        if (!validKey) {
          throw const FormatException('Invalid XP event link.');
        }
      }
      return WorkoutBackup._(
        exercises,
        settings,
        history,
        sessions,
        attempts,
        sets,
        events,
        legacy,
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('This file is not a valid gym app backup.');
    }
  }
}

class BackupService {
  BackupService(this.database, this.preferences);
  final AppDatabase database;
  final SharedPreferences preferences;

  Future<String> export() => database.transaction(() async {
    final history = await database.getAllHistory();
    final historyIds = history.map((row) => row.id).toSet();
    final attempts = await database.select(database.exerciseAttempts).get();
    final abandonedIds = attempts
        .where((row) => row.status == 'abandoned')
        .map((row) => row.attemptId)
        .toSet();
    final sets = await database.select(database.setAttempts).get();
    final data = <String, dynamic>{
      'app': 'gym_app',
      'backup_version': 1,
      'created_at': DateTime.now().toIso8601String(),
      'exercises_data': jsonDecode(
        preferences.getString('exercises_data') ?? '[]',
      ),
      'settings': {
        for (final key in WorkoutBackup.settingTypes.keys)
          if (preferences.get(key) != null) key: preferences.get(key),
      },
      'history_data': history.map((r) => r.toJson()).toList(),
      'sessions': (await database.select(database.workoutSessions).get())
          .map((r) => r.toJson())
          .toList(),
      'exercise_attempts': attempts.map((r) => r.toJson()).toList(),
      'set_attempts': sets.map((r) {
        final row = r.toJson();
        // Older abandoned attempts can retain a pointer to removed history.
        // Detach only this known legacy case in the snapshot, never in storage.
        if (abandonedIds.contains(r.attemptId) &&
            r.historyEntryId != null &&
            !historyIds.contains(r.historyEntryId)) {
          row['historyEntryId'] = null;
        }
        return row;
      }).toList(),
      'xp_events': (await database.select(database.xpEvents).get())
          .map((r) => r.toJson())
          .toList(),
    };
    final content = jsonEncode(data);
    WorkoutBackup.parse(content); // Never save an unusable snapshot.
    return content;
  });

  Future<void> restore(WorkoutBackup backup) async {
    final keys = [
      ...WorkoutBackup.settingTypes.keys,
      'exercises_data',
      'legacy_drift_migration_v1',
      'superset_progress',
      'current_session_id',
      'current_session_start_time',
    ];
    final previous = {for (final key in keys) key: preferences.get(key)};
    Future<void> write(String key, Object? value) async {
      final success = switch (value) {
        int v => await preferences.setInt(key, v),
        bool v => await preferences.setBool(key, v),
        String v => await preferences.setString(key, v),
        null => await preferences.remove(key),
        _ => throw StateError('Unsupported preference'),
      };
      if (!success) throw StateError('Could not save restored settings.');
    }

    try {
      await database.transaction(() async {
        await database.delete(database.setAttempts).go();
        await database.delete(database.xpEvents).go();
        await database.delete(database.historyEntries).go();
        await database.delete(database.exerciseAttempts).go();
        await database.delete(database.workoutSessions).go();
        final now = DateTime.now();
        await database.batch((b) {
          b.insertAll(database.historyEntries, backup.history);
          b.insertAll(
            database.workoutSessions,
            backup.sessions.map(
              (r) => r.endedAt == null
                  ? r.copyWith(
                      endedAt: Value(now),
                      endReason: const Value('discarded'),
                    )
                  : r,
            ),
          );
          b.insertAll(
            database.exerciseAttempts,
            backup.attempts.map(
              (r) => r.status == 'active'
                  ? r.copyWith(status: 'abandoned', endedAt: Value(now))
                  : r,
            ),
          );
          b.insertAll(database.setAttempts, backup.sets);
          b.insertAll(database.xpEvents, backup.events);
        });
        for (final key in keys) {
          await write(key, null);
        }
        for (final entry in backup.settings.entries) {
          await write(entry.key, entry.value);
        }
        await write(
          'exercises_data',
          jsonEncode(backup.exercises.map((r) => r.toJson()).toList()),
        );
        await write('legacy_drift_migration_v1', true);
      });
    } catch (_) {
      // SharedPreferences is separate from SQLite. Compensate if either side
      // fails so a recoverable error does not leave a mismatched exercise list.
      for (final entry in previous.entries) {
        await write(entry.key, entry.value);
      }
      rethrow;
    }
  }
}
