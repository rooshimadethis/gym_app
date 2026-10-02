// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isWarmupMeta = const VerificationMeta(
    'isWarmup',
  );
  @override
  late final GeneratedColumn<bool> isWarmup = GeneratedColumn<bool>(
    'is_warmup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_warmup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutPositionMeta = const VerificationMeta(
    'workoutPosition',
  );
  @override
  late final GeneratedColumn<int> workoutPosition = GeneratedColumn<int>(
    'workout_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatigueScoreMeta = const VerificationMeta(
    'fatigueScore',
  );
  @override
  late final GeneratedColumn<int> fatigueScore = GeneratedColumn<int>(
    'fatigue_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseName,
    weight,
    reps,
    isWarmup,
    timestamp,
    workoutPosition,
    fatigueScore,
    sessionId,
    attemptId,
    exerciseId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('is_warmup')) {
      context.handle(
        _isWarmupMeta,
        isWarmup.isAcceptableOrUnknown(data['is_warmup']!, _isWarmupMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('workout_position')) {
      context.handle(
        _workoutPositionMeta,
        workoutPosition.isAcceptableOrUnknown(
          data['workout_position']!,
          _workoutPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutPositionMeta);
    }
    if (data.containsKey('fatigue_score')) {
      context.handle(
        _fatigueScoreMeta,
        fatigueScore.isAcceptableOrUnknown(
          data['fatigue_score']!,
          _fatigueScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fatigueScoreMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      isWarmup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_warmup'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      workoutPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_position'],
      )!,
      fatigueScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fatigue_score'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      ),
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      ),
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryEntry extends DataClass implements Insertable<HistoryEntry> {
  final int id;
  final String exerciseName;
  final double weight;
  final int reps;
  final bool isWarmup;
  final DateTime timestamp;
  final int workoutPosition;
  final int fatigueScore;
  final String sessionId;

  /// Null for legacy history imported before attempts were introduced.
  final String? attemptId;

  /// Null for legacy rows; new rows use the stable exercise UUID.
  final String? exerciseId;
  const HistoryEntry({
    required this.id,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.isWarmup,
    required this.timestamp,
    required this.workoutPosition,
    required this.fatigueScore,
    required this.sessionId,
    this.attemptId,
    this.exerciseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['weight'] = Variable<double>(weight);
    map['reps'] = Variable<int>(reps);
    map['is_warmup'] = Variable<bool>(isWarmup);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['workout_position'] = Variable<int>(workoutPosition);
    map['fatigue_score'] = Variable<int>(fatigueScore);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || attemptId != null) {
      map['attempt_id'] = Variable<String>(attemptId);
    }
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<String>(exerciseId);
    }
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      exerciseName: Value(exerciseName),
      weight: Value(weight),
      reps: Value(reps),
      isWarmup: Value(isWarmup),
      timestamp: Value(timestamp),
      workoutPosition: Value(workoutPosition),
      fatigueScore: Value(fatigueScore),
      sessionId: Value(sessionId),
      attemptId: attemptId == null && nullToAbsent
          ? const Value.absent()
          : Value(attemptId),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
    );
  }

  factory HistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      weight: serializer.fromJson<double>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
      isWarmup: serializer.fromJson<bool>(json['isWarmup']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      workoutPosition: serializer.fromJson<int>(json['workoutPosition']),
      fatigueScore: serializer.fromJson<int>(json['fatigueScore']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      attemptId: serializer.fromJson<String?>(json['attemptId']),
      exerciseId: serializer.fromJson<String?>(json['exerciseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'weight': serializer.toJson<double>(weight),
      'reps': serializer.toJson<int>(reps),
      'isWarmup': serializer.toJson<bool>(isWarmup),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'workoutPosition': serializer.toJson<int>(workoutPosition),
      'fatigueScore': serializer.toJson<int>(fatigueScore),
      'sessionId': serializer.toJson<String>(sessionId),
      'attemptId': serializer.toJson<String?>(attemptId),
      'exerciseId': serializer.toJson<String?>(exerciseId),
    };
  }

  HistoryEntry copyWith({
    int? id,
    String? exerciseName,
    double? weight,
    int? reps,
    bool? isWarmup,
    DateTime? timestamp,
    int? workoutPosition,
    int? fatigueScore,
    String? sessionId,
    Value<String?> attemptId = const Value.absent(),
    Value<String?> exerciseId = const Value.absent(),
  }) => HistoryEntry(
    id: id ?? this.id,
    exerciseName: exerciseName ?? this.exerciseName,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
    isWarmup: isWarmup ?? this.isWarmup,
    timestamp: timestamp ?? this.timestamp,
    workoutPosition: workoutPosition ?? this.workoutPosition,
    fatigueScore: fatigueScore ?? this.fatigueScore,
    sessionId: sessionId ?? this.sessionId,
    attemptId: attemptId.present ? attemptId.value : this.attemptId,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
  );
  HistoryEntry copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      isWarmup: data.isWarmup.present ? data.isWarmup.value : this.isWarmup,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      workoutPosition: data.workoutPosition.present
          ? data.workoutPosition.value
          : this.workoutPosition,
      fatigueScore: data.fatigueScore.present
          ? data.fatigueScore.value
          : this.fatigueScore,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntry(')
          ..write('id: $id, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('timestamp: $timestamp, ')
          ..write('workoutPosition: $workoutPosition, ')
          ..write('fatigueScore: $fatigueScore, ')
          ..write('sessionId: $sessionId, ')
          ..write('attemptId: $attemptId, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseName,
    weight,
    reps,
    isWarmup,
    timestamp,
    workoutPosition,
    fatigueScore,
    sessionId,
    attemptId,
    exerciseId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry &&
          other.id == this.id &&
          other.exerciseName == this.exerciseName &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.isWarmup == this.isWarmup &&
          other.timestamp == this.timestamp &&
          other.workoutPosition == this.workoutPosition &&
          other.fatigueScore == this.fatigueScore &&
          other.sessionId == this.sessionId &&
          other.attemptId == this.attemptId &&
          other.exerciseId == this.exerciseId);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntry> {
  final Value<int> id;
  final Value<String> exerciseName;
  final Value<double> weight;
  final Value<int> reps;
  final Value<bool> isWarmup;
  final Value<DateTime> timestamp;
  final Value<int> workoutPosition;
  final Value<int> fatigueScore;
  final Value<String> sessionId;
  final Value<String?> attemptId;
  final Value<String?> exerciseId;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.workoutPosition = const Value.absent(),
    this.fatigueScore = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.exerciseId = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String exerciseName,
    required double weight,
    required int reps,
    this.isWarmup = const Value.absent(),
    required DateTime timestamp,
    required int workoutPosition,
    required int fatigueScore,
    required String sessionId,
    this.attemptId = const Value.absent(),
    this.exerciseId = const Value.absent(),
  }) : exerciseName = Value(exerciseName),
       weight = Value(weight),
       reps = Value(reps),
       timestamp = Value(timestamp),
       workoutPosition = Value(workoutPosition),
       fatigueScore = Value(fatigueScore),
       sessionId = Value(sessionId);
  static Insertable<HistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? exerciseName,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<bool>? isWarmup,
    Expression<DateTime>? timestamp,
    Expression<int>? workoutPosition,
    Expression<int>? fatigueScore,
    Expression<String>? sessionId,
    Expression<String>? attemptId,
    Expression<String>? exerciseId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (isWarmup != null) 'is_warmup': isWarmup,
      if (timestamp != null) 'timestamp': timestamp,
      if (workoutPosition != null) 'workout_position': workoutPosition,
      if (fatigueScore != null) 'fatigue_score': fatigueScore,
      if (sessionId != null) 'session_id': sessionId,
      if (attemptId != null) 'attempt_id': attemptId,
      if (exerciseId != null) 'exercise_id': exerciseId,
    });
  }

  HistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? exerciseName,
    Value<double>? weight,
    Value<int>? reps,
    Value<bool>? isWarmup,
    Value<DateTime>? timestamp,
    Value<int>? workoutPosition,
    Value<int>? fatigueScore,
    Value<String>? sessionId,
    Value<String?>? attemptId,
    Value<String?>? exerciseId,
  }) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isWarmup: isWarmup ?? this.isWarmup,
      timestamp: timestamp ?? this.timestamp,
      workoutPosition: workoutPosition ?? this.workoutPosition,
      fatigueScore: fatigueScore ?? this.fatigueScore,
      sessionId: sessionId ?? this.sessionId,
      attemptId: attemptId ?? this.attemptId,
      exerciseId: exerciseId ?? this.exerciseId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (isWarmup.present) {
      map['is_warmup'] = Variable<bool>(isWarmup.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (workoutPosition.present) {
      map['workout_position'] = Variable<int>(workoutPosition.value);
    }
    if (fatigueScore.present) {
      map['fatigue_score'] = Variable<int>(fatigueScore.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('timestamp: $timestamp, ')
          ..write('workoutPosition: $workoutPosition, ')
          ..write('fatigueScore: $fatigueScore, ')
          ..write('sessionId: $sessionId, ')
          ..write('attemptId: $attemptId, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endReasonMeta = const VerificationMeta(
    'endReason',
  );
  @override
  late final GeneratedColumn<String> endReason = GeneratedColumn<String>(
    'end_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpRulesVersionMeta = const VerificationMeta(
    'xpRulesVersion',
  );
  @override
  late final GeneratedColumn<int> xpRulesVersion = GeneratedColumn<int>(
    'xp_rules_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _completionSummarySeenAtMeta =
      const VerificationMeta('completionSummarySeenAt');
  @override
  late final GeneratedColumn<DateTime> completionSummarySeenAt =
      GeneratedColumn<DateTime>(
        'completion_summary_seen_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    startedAt,
    endedAt,
    endReason,
    xpRulesVersion,
    completionSummarySeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('end_reason')) {
      context.handle(
        _endReasonMeta,
        endReason.isAcceptableOrUnknown(data['end_reason']!, _endReasonMeta),
      );
    }
    if (data.containsKey('xp_rules_version')) {
      context.handle(
        _xpRulesVersionMeta,
        xpRulesVersion.isAcceptableOrUnknown(
          data['xp_rules_version']!,
          _xpRulesVersionMeta,
        ),
      );
    }
    if (data.containsKey('completion_summary_seen_at')) {
      context.handle(
        _completionSummarySeenAtMeta,
        completionSummarySeenAt.isAcceptableOrUnknown(
          data['completion_summary_seen_at']!,
          _completionSummarySeenAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      endReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_reason'],
      ),
      xpRulesVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_rules_version'],
      )!,
      completionSummarySeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completion_summary_seen_at'],
      ),
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final String sessionId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? endReason;
  final int xpRulesVersion;
  final DateTime? completionSummarySeenAt;
  const WorkoutSession({
    required this.sessionId,
    required this.startedAt,
    this.endedAt,
    this.endReason,
    required this.xpRulesVersion,
    this.completionSummarySeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || endReason != null) {
      map['end_reason'] = Variable<String>(endReason);
    }
    map['xp_rules_version'] = Variable<int>(xpRulesVersion);
    if (!nullToAbsent || completionSummarySeenAt != null) {
      map['completion_summary_seen_at'] = Variable<DateTime>(
        completionSummarySeenAt,
      );
    }
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      sessionId: Value(sessionId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      endReason: endReason == null && nullToAbsent
          ? const Value.absent()
          : Value(endReason),
      xpRulesVersion: Value(xpRulesVersion),
      completionSummarySeenAt: completionSummarySeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completionSummarySeenAt),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      endReason: serializer.fromJson<String?>(json['endReason']),
      xpRulesVersion: serializer.fromJson<int>(json['xpRulesVersion']),
      completionSummarySeenAt: serializer.fromJson<DateTime?>(
        json['completionSummarySeenAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'endReason': serializer.toJson<String?>(endReason),
      'xpRulesVersion': serializer.toJson<int>(xpRulesVersion),
      'completionSummarySeenAt': serializer.toJson<DateTime?>(
        completionSummarySeenAt,
      ),
    };
  }

  WorkoutSession copyWith({
    String? sessionId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> endReason = const Value.absent(),
    int? xpRulesVersion,
    Value<DateTime?> completionSummarySeenAt = const Value.absent(),
  }) => WorkoutSession(
    sessionId: sessionId ?? this.sessionId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    endReason: endReason.present ? endReason.value : this.endReason,
    xpRulesVersion: xpRulesVersion ?? this.xpRulesVersion,
    completionSummarySeenAt: completionSummarySeenAt.present
        ? completionSummarySeenAt.value
        : this.completionSummarySeenAt,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      endReason: data.endReason.present ? data.endReason.value : this.endReason,
      xpRulesVersion: data.xpRulesVersion.present
          ? data.xpRulesVersion.value
          : this.xpRulesVersion,
      completionSummarySeenAt: data.completionSummarySeenAt.present
          ? data.completionSummarySeenAt.value
          : this.completionSummarySeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('sessionId: $sessionId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('endReason: $endReason, ')
          ..write('xpRulesVersion: $xpRulesVersion, ')
          ..write('completionSummarySeenAt: $completionSummarySeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    startedAt,
    endedAt,
    endReason,
    xpRulesVersion,
    completionSummarySeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.sessionId == this.sessionId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.endReason == this.endReason &&
          other.xpRulesVersion == this.xpRulesVersion &&
          other.completionSummarySeenAt == this.completionSummarySeenAt);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<String> sessionId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> endReason;
  final Value<int> xpRulesVersion;
  final Value<DateTime?> completionSummarySeenAt;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.sessionId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.endReason = const Value.absent(),
    this.xpRulesVersion = const Value.absent(),
    this.completionSummarySeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String sessionId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.endReason = const Value.absent(),
    this.xpRulesVersion = const Value.absent(),
    this.completionSummarySeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       startedAt = Value(startedAt);
  static Insertable<WorkoutSession> custom({
    Expression<String>? sessionId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? endReason,
    Expression<int>? xpRulesVersion,
    Expression<DateTime>? completionSummarySeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (endReason != null) 'end_reason': endReason,
      if (xpRulesVersion != null) 'xp_rules_version': xpRulesVersion,
      if (completionSummarySeenAt != null)
        'completion_summary_seen_at': completionSummarySeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? sessionId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? endReason,
    Value<int>? xpRulesVersion,
    Value<DateTime?>? completionSummarySeenAt,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      endReason: endReason ?? this.endReason,
      xpRulesVersion: xpRulesVersion ?? this.xpRulesVersion,
      completionSummarySeenAt:
          completionSummarySeenAt ?? this.completionSummarySeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (endReason.present) {
      map['end_reason'] = Variable<String>(endReason.value);
    }
    if (xpRulesVersion.present) {
      map['xp_rules_version'] = Variable<int>(xpRulesVersion.value);
    }
    if (completionSummarySeenAt.present) {
      map['completion_summary_seen_at'] = Variable<DateTime>(
        completionSummarySeenAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('endReason: $endReason, ')
          ..write('xpRulesVersion: $xpRulesVersion, ')
          ..write('completionSummarySeenAt: $completionSummarySeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseAttemptsTable extends ExerciseAttempts
    with TableInfo<$ExerciseAttemptsTable, ExerciseAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supersetIdMeta = const VerificationMeta(
    'supersetId',
  );
  @override
  late final GeneratedColumn<String> supersetId = GeneratedColumn<String>(
    'superset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attemptId,
    sessionId,
    exerciseId,
    exerciseName,
    groupId,
    supersetId,
    status,
    startedAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('superset_id')) {
      context.handle(
        _supersetIdMeta,
        supersetId.isAcceptableOrUnknown(data['superset_id']!, _supersetIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attemptId};
  @override
  ExerciseAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseAttempt(
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      supersetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superset_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $ExerciseAttemptsTable createAlias(String alias) {
    return $ExerciseAttemptsTable(attachedDatabase, alias);
  }
}

class ExerciseAttempt extends DataClass implements Insertable<ExerciseAttempt> {
  final String attemptId;
  final String sessionId;
  final String exerciseId;
  final String exerciseName;
  final String? groupId;
  final String? supersetId;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  const ExerciseAttempt({
    required this.attemptId,
    required this.sessionId,
    required this.exerciseId,
    required this.exerciseName,
    this.groupId,
    this.supersetId,
    required this.status,
    required this.startedAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attempt_id'] = Variable<String>(attemptId);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['exercise_name'] = Variable<String>(exerciseName);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || supersetId != null) {
      map['superset_id'] = Variable<String>(supersetId);
    }
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  ExerciseAttemptsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseAttemptsCompanion(
      attemptId: Value(attemptId),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      exerciseName: Value(exerciseName),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      supersetId: supersetId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetId),
      status: Value(status),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory ExerciseAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseAttempt(
      attemptId: serializer.fromJson<String>(json['attemptId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      supersetId: serializer.fromJson<String?>(json['supersetId']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attemptId': serializer.toJson<String>(attemptId),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'groupId': serializer.toJson<String?>(groupId),
      'supersetId': serializer.toJson<String?>(supersetId),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  ExerciseAttempt copyWith({
    String? attemptId,
    String? sessionId,
    String? exerciseId,
    String? exerciseName,
    Value<String?> groupId = const Value.absent(),
    Value<String?> supersetId = const Value.absent(),
    String? status,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => ExerciseAttempt(
    attemptId: attemptId ?? this.attemptId,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    exerciseName: exerciseName ?? this.exerciseName,
    groupId: groupId.present ? groupId.value : this.groupId,
    supersetId: supersetId.present ? supersetId.value : this.supersetId,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  ExerciseAttempt copyWithCompanion(ExerciseAttemptsCompanion data) {
    return ExerciseAttempt(
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      supersetId: data.supersetId.present
          ? data.supersetId.value
          : this.supersetId,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseAttempt(')
          ..write('attemptId: $attemptId, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('groupId: $groupId, ')
          ..write('supersetId: $supersetId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attemptId,
    sessionId,
    exerciseId,
    exerciseName,
    groupId,
    supersetId,
    status,
    startedAt,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseAttempt &&
          other.attemptId == this.attemptId &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.exerciseName == this.exerciseName &&
          other.groupId == this.groupId &&
          other.supersetId == this.supersetId &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class ExerciseAttemptsCompanion extends UpdateCompanion<ExerciseAttempt> {
  final Value<String> attemptId;
  final Value<String> sessionId;
  final Value<String> exerciseId;
  final Value<String> exerciseName;
  final Value<String?> groupId;
  final Value<String?> supersetId;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const ExerciseAttemptsCompanion({
    this.attemptId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.groupId = const Value.absent(),
    this.supersetId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseAttemptsCompanion.insert({
    required String attemptId,
    required String sessionId,
    required String exerciseId,
    required String exerciseName,
    this.groupId = const Value.absent(),
    this.supersetId = const Value.absent(),
    required String status,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : attemptId = Value(attemptId),
       sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       exerciseName = Value(exerciseName),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<ExerciseAttempt> custom({
    Expression<String>? attemptId,
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<String>? exerciseName,
    Expression<String>? groupId,
    Expression<String>? supersetId,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attemptId != null) 'attempt_id': attemptId,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (groupId != null) 'group_id': groupId,
      if (supersetId != null) 'superset_id': supersetId,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseAttemptsCompanion copyWith({
    Value<String>? attemptId,
    Value<String>? sessionId,
    Value<String>? exerciseId,
    Value<String>? exerciseName,
    Value<String?>? groupId,
    Value<String?>? supersetId,
    Value<String>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? rowid,
  }) {
    return ExerciseAttemptsCompanion(
      attemptId: attemptId ?? this.attemptId,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      groupId: groupId ?? this.groupId,
      supersetId: supersetId ?? this.supersetId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (supersetId.present) {
      map['superset_id'] = Variable<String>(supersetId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseAttemptsCompanion(')
          ..write('attemptId: $attemptId, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('groupId: $groupId, ')
          ..write('supersetId: $supersetId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetAttemptsTable extends SetAttempts
    with TableInfo<$SetAttemptsTable, SetAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _setAttemptIdMeta = const VerificationMeta(
    'setAttemptId',
  );
  @override
  late final GeneratedColumn<String> setAttemptId = GeneratedColumn<String>(
    'set_attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedSetIndexMeta = const VerificationMeta(
    'plannedSetIndex',
  );
  @override
  late final GeneratedColumn<int> plannedSetIndex = GeneratedColumn<int>(
    'planned_set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _historyEntryIdMeta = const VerificationMeta(
    'historyEntryId',
  );
  @override
  late final GeneratedColumn<int> historyEntryId = GeneratedColumn<int>(
    'history_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    setAttemptId,
    attemptId,
    plannedSetIndex,
    outcome,
    weight,
    reps,
    historyEntryId,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('set_attempt_id')) {
      context.handle(
        _setAttemptIdMeta,
        setAttemptId.isAcceptableOrUnknown(
          data['set_attempt_id']!,
          _setAttemptIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_setAttemptIdMeta);
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('planned_set_index')) {
      context.handle(
        _plannedSetIndexMeta,
        plannedSetIndex.isAcceptableOrUnknown(
          data['planned_set_index']!,
          _plannedSetIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedSetIndexMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('history_entry_id')) {
      context.handle(
        _historyEntryIdMeta,
        historyEntryId.isAcceptableOrUnknown(
          data['history_entry_id']!,
          _historyEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {setAttemptId};
  @override
  SetAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetAttempt(
      setAttemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_attempt_id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      plannedSetIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_set_index'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      historyEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_entry_id'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $SetAttemptsTable createAlias(String alias) {
    return $SetAttemptsTable(attachedDatabase, alias);
  }
}

class SetAttempt extends DataClass implements Insertable<SetAttempt> {
  final String setAttemptId;
  final String attemptId;
  final int plannedSetIndex;
  final String outcome;
  final double weight;
  final int reps;
  final int? historyEntryId;
  final DateTime recordedAt;
  const SetAttempt({
    required this.setAttemptId,
    required this.attemptId,
    required this.plannedSetIndex,
    required this.outcome,
    required this.weight,
    required this.reps,
    this.historyEntryId,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['set_attempt_id'] = Variable<String>(setAttemptId);
    map['attempt_id'] = Variable<String>(attemptId);
    map['planned_set_index'] = Variable<int>(plannedSetIndex);
    map['outcome'] = Variable<String>(outcome);
    map['weight'] = Variable<double>(weight);
    map['reps'] = Variable<int>(reps);
    if (!nullToAbsent || historyEntryId != null) {
      map['history_entry_id'] = Variable<int>(historyEntryId);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  SetAttemptsCompanion toCompanion(bool nullToAbsent) {
    return SetAttemptsCompanion(
      setAttemptId: Value(setAttemptId),
      attemptId: Value(attemptId),
      plannedSetIndex: Value(plannedSetIndex),
      outcome: Value(outcome),
      weight: Value(weight),
      reps: Value(reps),
      historyEntryId: historyEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(historyEntryId),
      recordedAt: Value(recordedAt),
    );
  }

  factory SetAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetAttempt(
      setAttemptId: serializer.fromJson<String>(json['setAttemptId']),
      attemptId: serializer.fromJson<String>(json['attemptId']),
      plannedSetIndex: serializer.fromJson<int>(json['plannedSetIndex']),
      outcome: serializer.fromJson<String>(json['outcome']),
      weight: serializer.fromJson<double>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
      historyEntryId: serializer.fromJson<int?>(json['historyEntryId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'setAttemptId': serializer.toJson<String>(setAttemptId),
      'attemptId': serializer.toJson<String>(attemptId),
      'plannedSetIndex': serializer.toJson<int>(plannedSetIndex),
      'outcome': serializer.toJson<String>(outcome),
      'weight': serializer.toJson<double>(weight),
      'reps': serializer.toJson<int>(reps),
      'historyEntryId': serializer.toJson<int?>(historyEntryId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  SetAttempt copyWith({
    String? setAttemptId,
    String? attemptId,
    int? plannedSetIndex,
    String? outcome,
    double? weight,
    int? reps,
    Value<int?> historyEntryId = const Value.absent(),
    DateTime? recordedAt,
  }) => SetAttempt(
    setAttemptId: setAttemptId ?? this.setAttemptId,
    attemptId: attemptId ?? this.attemptId,
    plannedSetIndex: plannedSetIndex ?? this.plannedSetIndex,
    outcome: outcome ?? this.outcome,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
    historyEntryId: historyEntryId.present
        ? historyEntryId.value
        : this.historyEntryId,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  SetAttempt copyWithCompanion(SetAttemptsCompanion data) {
    return SetAttempt(
      setAttemptId: data.setAttemptId.present
          ? data.setAttemptId.value
          : this.setAttemptId,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      plannedSetIndex: data.plannedSetIndex.present
          ? data.plannedSetIndex.value
          : this.plannedSetIndex,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      historyEntryId: data.historyEntryId.present
          ? data.historyEntryId.value
          : this.historyEntryId,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetAttempt(')
          ..write('setAttemptId: $setAttemptId, ')
          ..write('attemptId: $attemptId, ')
          ..write('plannedSetIndex: $plannedSetIndex, ')
          ..write('outcome: $outcome, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('historyEntryId: $historyEntryId, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    setAttemptId,
    attemptId,
    plannedSetIndex,
    outcome,
    weight,
    reps,
    historyEntryId,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetAttempt &&
          other.setAttemptId == this.setAttemptId &&
          other.attemptId == this.attemptId &&
          other.plannedSetIndex == this.plannedSetIndex &&
          other.outcome == this.outcome &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.historyEntryId == this.historyEntryId &&
          other.recordedAt == this.recordedAt);
}

class SetAttemptsCompanion extends UpdateCompanion<SetAttempt> {
  final Value<String> setAttemptId;
  final Value<String> attemptId;
  final Value<int> plannedSetIndex;
  final Value<String> outcome;
  final Value<double> weight;
  final Value<int> reps;
  final Value<int?> historyEntryId;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const SetAttemptsCompanion({
    this.setAttemptId = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.plannedSetIndex = const Value.absent(),
    this.outcome = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.historyEntryId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetAttemptsCompanion.insert({
    required String setAttemptId,
    required String attemptId,
    required int plannedSetIndex,
    required String outcome,
    required double weight,
    required int reps,
    this.historyEntryId = const Value.absent(),
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : setAttemptId = Value(setAttemptId),
       attemptId = Value(attemptId),
       plannedSetIndex = Value(plannedSetIndex),
       outcome = Value(outcome),
       weight = Value(weight),
       reps = Value(reps),
       recordedAt = Value(recordedAt);
  static Insertable<SetAttempt> custom({
    Expression<String>? setAttemptId,
    Expression<String>? attemptId,
    Expression<int>? plannedSetIndex,
    Expression<String>? outcome,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<int>? historyEntryId,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (setAttemptId != null) 'set_attempt_id': setAttemptId,
      if (attemptId != null) 'attempt_id': attemptId,
      if (plannedSetIndex != null) 'planned_set_index': plannedSetIndex,
      if (outcome != null) 'outcome': outcome,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (historyEntryId != null) 'history_entry_id': historyEntryId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetAttemptsCompanion copyWith({
    Value<String>? setAttemptId,
    Value<String>? attemptId,
    Value<int>? plannedSetIndex,
    Value<String>? outcome,
    Value<double>? weight,
    Value<int>? reps,
    Value<int?>? historyEntryId,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return SetAttemptsCompanion(
      setAttemptId: setAttemptId ?? this.setAttemptId,
      attemptId: attemptId ?? this.attemptId,
      plannedSetIndex: plannedSetIndex ?? this.plannedSetIndex,
      outcome: outcome ?? this.outcome,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      historyEntryId: historyEntryId ?? this.historyEntryId,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (setAttemptId.present) {
      map['set_attempt_id'] = Variable<String>(setAttemptId.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (plannedSetIndex.present) {
      map['planned_set_index'] = Variable<int>(plannedSetIndex.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (historyEntryId.present) {
      map['history_entry_id'] = Variable<int>(historyEntryId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetAttemptsCompanion(')
          ..write('setAttemptId: $setAttemptId, ')
          ..write('attemptId: $attemptId, ')
          ..write('plannedSetIndex: $plannedSetIndex, ')
          ..write('outcome: $outcome, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('historyEntryId: $historyEntryId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $XpEventsTable extends XpEvents with TableInfo<$XpEventsTable, XpEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XpEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventKeyMeta = const VerificationMeta(
    'eventKey',
  );
  @override
  late final GeneratedColumn<String> eventKey = GeneratedColumn<String>(
    'event_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpAmountMeta = const VerificationMeta(
    'xpAmount',
  );
  @override
  late final GeneratedColumn<int> xpAmount = GeneratedColumn<int>(
    'xp_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rulesVersionMeta = const VerificationMeta(
    'rulesVersion',
  );
  @override
  late final GeneratedColumn<int> rulesVersion = GeneratedColumn<int>(
    'rules_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventKey,
    sessionId,
    eventType,
    exerciseId,
    exerciseName,
    xpAmount,
    rulesVersion,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xp_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<XpEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_key')) {
      context.handle(
        _eventKeyMeta,
        eventKey.isAcceptableOrUnknown(data['event_key']!, _eventKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_eventKeyMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    }
    if (data.containsKey('xp_amount')) {
      context.handle(
        _xpAmountMeta,
        xpAmount.isAcceptableOrUnknown(data['xp_amount']!, _xpAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_xpAmountMeta);
    }
    if (data.containsKey('rules_version')) {
      context.handle(
        _rulesVersionMeta,
        rulesVersion.isAcceptableOrUnknown(
          data['rules_version']!,
          _rulesVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rulesVersionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {eventKey},
  ];
  @override
  XpEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XpEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_key'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      ),
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      ),
      xpAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_amount'],
      )!,
      rulesVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rules_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $XpEventsTable createAlias(String alias) {
    return $XpEventsTable(attachedDatabase, alias);
  }
}

class XpEvent extends DataClass implements Insertable<XpEvent> {
  final int id;
  final String eventKey;
  final String sessionId;
  final String eventType;
  final String? exerciseId;
  final String? exerciseName;
  final int xpAmount;
  final int rulesVersion;
  final DateTime createdAt;
  const XpEvent({
    required this.id,
    required this.eventKey,
    required this.sessionId,
    required this.eventType,
    this.exerciseId,
    this.exerciseName,
    required this.xpAmount,
    required this.rulesVersion,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_key'] = Variable<String>(eventKey);
    map['session_id'] = Variable<String>(sessionId);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<String>(exerciseId);
    }
    if (!nullToAbsent || exerciseName != null) {
      map['exercise_name'] = Variable<String>(exerciseName);
    }
    map['xp_amount'] = Variable<int>(xpAmount);
    map['rules_version'] = Variable<int>(rulesVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  XpEventsCompanion toCompanion(bool nullToAbsent) {
    return XpEventsCompanion(
      id: Value(id),
      eventKey: Value(eventKey),
      sessionId: Value(sessionId),
      eventType: Value(eventType),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
      exerciseName: exerciseName == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseName),
      xpAmount: Value(xpAmount),
      rulesVersion: Value(rulesVersion),
      createdAt: Value(createdAt),
    );
  }

  factory XpEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XpEvent(
      id: serializer.fromJson<int>(json['id']),
      eventKey: serializer.fromJson<String>(json['eventKey']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      exerciseId: serializer.fromJson<String?>(json['exerciseId']),
      exerciseName: serializer.fromJson<String?>(json['exerciseName']),
      xpAmount: serializer.fromJson<int>(json['xpAmount']),
      rulesVersion: serializer.fromJson<int>(json['rulesVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventKey': serializer.toJson<String>(eventKey),
      'sessionId': serializer.toJson<String>(sessionId),
      'eventType': serializer.toJson<String>(eventType),
      'exerciseId': serializer.toJson<String?>(exerciseId),
      'exerciseName': serializer.toJson<String?>(exerciseName),
      'xpAmount': serializer.toJson<int>(xpAmount),
      'rulesVersion': serializer.toJson<int>(rulesVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  XpEvent copyWith({
    int? id,
    String? eventKey,
    String? sessionId,
    String? eventType,
    Value<String?> exerciseId = const Value.absent(),
    Value<String?> exerciseName = const Value.absent(),
    int? xpAmount,
    int? rulesVersion,
    DateTime? createdAt,
  }) => XpEvent(
    id: id ?? this.id,
    eventKey: eventKey ?? this.eventKey,
    sessionId: sessionId ?? this.sessionId,
    eventType: eventType ?? this.eventType,
    exerciseId: exerciseId.present ? exerciseId.value : this.exerciseId,
    exerciseName: exerciseName.present ? exerciseName.value : this.exerciseName,
    xpAmount: xpAmount ?? this.xpAmount,
    rulesVersion: rulesVersion ?? this.rulesVersion,
    createdAt: createdAt ?? this.createdAt,
  );
  XpEvent copyWithCompanion(XpEventsCompanion data) {
    return XpEvent(
      id: data.id.present ? data.id.value : this.id,
      eventKey: data.eventKey.present ? data.eventKey.value : this.eventKey,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      xpAmount: data.xpAmount.present ? data.xpAmount.value : this.xpAmount,
      rulesVersion: data.rulesVersion.present
          ? data.rulesVersion.value
          : this.rulesVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XpEvent(')
          ..write('id: $id, ')
          ..write('eventKey: $eventKey, ')
          ..write('sessionId: $sessionId, ')
          ..write('eventType: $eventType, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('xpAmount: $xpAmount, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventKey,
    sessionId,
    eventType,
    exerciseId,
    exerciseName,
    xpAmount,
    rulesVersion,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XpEvent &&
          other.id == this.id &&
          other.eventKey == this.eventKey &&
          other.sessionId == this.sessionId &&
          other.eventType == this.eventType &&
          other.exerciseId == this.exerciseId &&
          other.exerciseName == this.exerciseName &&
          other.xpAmount == this.xpAmount &&
          other.rulesVersion == this.rulesVersion &&
          other.createdAt == this.createdAt);
}

class XpEventsCompanion extends UpdateCompanion<XpEvent> {
  final Value<int> id;
  final Value<String> eventKey;
  final Value<String> sessionId;
  final Value<String> eventType;
  final Value<String?> exerciseId;
  final Value<String?> exerciseName;
  final Value<int> xpAmount;
  final Value<int> rulesVersion;
  final Value<DateTime> createdAt;
  const XpEventsCompanion({
    this.id = const Value.absent(),
    this.eventKey = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.xpAmount = const Value.absent(),
    this.rulesVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  XpEventsCompanion.insert({
    this.id = const Value.absent(),
    required String eventKey,
    required String sessionId,
    required String eventType,
    this.exerciseId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    required int xpAmount,
    required int rulesVersion,
    required DateTime createdAt,
  }) : eventKey = Value(eventKey),
       sessionId = Value(sessionId),
       eventType = Value(eventType),
       xpAmount = Value(xpAmount),
       rulesVersion = Value(rulesVersion),
       createdAt = Value(createdAt);
  static Insertable<XpEvent> custom({
    Expression<int>? id,
    Expression<String>? eventKey,
    Expression<String>? sessionId,
    Expression<String>? eventType,
    Expression<String>? exerciseId,
    Expression<String>? exerciseName,
    Expression<int>? xpAmount,
    Expression<int>? rulesVersion,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventKey != null) 'event_key': eventKey,
      if (sessionId != null) 'session_id': sessionId,
      if (eventType != null) 'event_type': eventType,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (xpAmount != null) 'xp_amount': xpAmount,
      if (rulesVersion != null) 'rules_version': rulesVersion,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  XpEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? eventKey,
    Value<String>? sessionId,
    Value<String>? eventType,
    Value<String?>? exerciseId,
    Value<String?>? exerciseName,
    Value<int>? xpAmount,
    Value<int>? rulesVersion,
    Value<DateTime>? createdAt,
  }) {
    return XpEventsCompanion(
      id: id ?? this.id,
      eventKey: eventKey ?? this.eventKey,
      sessionId: sessionId ?? this.sessionId,
      eventType: eventType ?? this.eventType,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      xpAmount: xpAmount ?? this.xpAmount,
      rulesVersion: rulesVersion ?? this.rulesVersion,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventKey.present) {
      map['event_key'] = Variable<String>(eventKey.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (xpAmount.present) {
      map['xp_amount'] = Variable<int>(xpAmount.value);
    }
    if (rulesVersion.present) {
      map['rules_version'] = Variable<int>(rulesVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XpEventsCompanion(')
          ..write('id: $id, ')
          ..write('eventKey: $eventKey, ')
          ..write('sessionId: $sessionId, ')
          ..write('eventType: $eventType, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('xpAmount: $xpAmount, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $ExerciseAttemptsTable exerciseAttempts = $ExerciseAttemptsTable(
    this,
  );
  late final $SetAttemptsTable setAttempts = $SetAttemptsTable(this);
  late final $XpEventsTable xpEvents = $XpEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    historyEntries,
    workoutSessions,
    exerciseAttempts,
    setAttempts,
    xpEvents,
  ];
}

typedef $$HistoryEntriesTableCreateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      required String exerciseName,
      required double weight,
      required int reps,
      Value<bool> isWarmup,
      required DateTime timestamp,
      required int workoutPosition,
      required int fatigueScore,
      required String sessionId,
      Value<String?> attemptId,
      Value<String?> exerciseId,
    });
typedef $$HistoryEntriesTableUpdateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<String> exerciseName,
      Value<double> weight,
      Value<int> reps,
      Value<bool> isWarmup,
      Value<DateTime> timestamp,
      Value<int> workoutPosition,
      Value<int> fatigueScore,
      Value<String> sessionId,
      Value<String?> attemptId,
      Value<String?> exerciseId,
    });

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workoutPosition => $composableBuilder(
    column: $table.workoutPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatigueScore => $composableBuilder(
    column: $table.fatigueScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workoutPosition => $composableBuilder(
    column: $table.workoutPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatigueScore => $composableBuilder(
    column: $table.fatigueScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<bool> get isWarmup =>
      $composableBuilder(column: $table.isWarmup, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get workoutPosition => $composableBuilder(
    column: $table.workoutPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fatigueScore => $composableBuilder(
    column: $table.fatigueScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryEntriesTable,
          HistoryEntry,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (
            HistoryEntry,
            BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntry>,
          ),
          HistoryEntry,
          PrefetchHooks Function()
        > {
  $$HistoryEntriesTableTableManager(
    _$AppDatabase db,
    $HistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> workoutPosition = const Value.absent(),
                Value<int> fatigueScore = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> attemptId = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
              }) => HistoryEntriesCompanion(
                id: id,
                exerciseName: exerciseName,
                weight: weight,
                reps: reps,
                isWarmup: isWarmup,
                timestamp: timestamp,
                workoutPosition: workoutPosition,
                fatigueScore: fatigueScore,
                sessionId: sessionId,
                attemptId: attemptId,
                exerciseId: exerciseId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String exerciseName,
                required double weight,
                required int reps,
                Value<bool> isWarmup = const Value.absent(),
                required DateTime timestamp,
                required int workoutPosition,
                required int fatigueScore,
                required String sessionId,
                Value<String?> attemptId = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
              }) => HistoryEntriesCompanion.insert(
                id: id,
                exerciseName: exerciseName,
                weight: weight,
                reps: reps,
                isWarmup: isWarmup,
                timestamp: timestamp,
                workoutPosition: workoutPosition,
                fatigueScore: fatigueScore,
                sessionId: sessionId,
                attemptId: attemptId,
                exerciseId: exerciseId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryEntriesTable,
      HistoryEntry,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (
        HistoryEntry,
        BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntry>,
      ),
      HistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      required String sessionId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String?> endReason,
      Value<int> xpRulesVersion,
      Value<DateTime?> completionSummarySeenAt,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> sessionId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> endReason,
      Value<int> xpRulesVersion,
      Value<DateTime?> completionSummarySeenAt,
      Value<int> rowid,
    });

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endReason => $composableBuilder(
    column: $table.endReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpRulesVersion => $composableBuilder(
    column: $table.xpRulesVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completionSummarySeenAt => $composableBuilder(
    column: $table.completionSummarySeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endReason => $composableBuilder(
    column: $table.endReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpRulesVersion => $composableBuilder(
    column: $table.xpRulesVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completionSummarySeenAt => $composableBuilder(
    column: $table.completionSummarySeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get endReason =>
      $composableBuilder(column: $table.endReason, builder: (column) => column);

  GeneratedColumn<int> get xpRulesVersion => $composableBuilder(
    column: $table.xpRulesVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completionSummarySeenAt => $composableBuilder(
    column: $table.completionSummarySeenAt,
    builder: (column) => column,
  );
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (
            WorkoutSession,
            BaseReferences<
              _$AppDatabase,
              $WorkoutSessionsTable,
              WorkoutSession
            >,
          ),
          WorkoutSession,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> endReason = const Value.absent(),
                Value<int> xpRulesVersion = const Value.absent(),
                Value<DateTime?> completionSummarySeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                sessionId: sessionId,
                startedAt: startedAt,
                endedAt: endedAt,
                endReason: endReason,
                xpRulesVersion: xpRulesVersion,
                completionSummarySeenAt: completionSummarySeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> endReason = const Value.absent(),
                Value<int> xpRulesVersion = const Value.absent(),
                Value<DateTime?> completionSummarySeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                sessionId: sessionId,
                startedAt: startedAt,
                endedAt: endedAt,
                endReason: endReason,
                xpRulesVersion: xpRulesVersion,
                completionSummarySeenAt: completionSummarySeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (
        WorkoutSession,
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession>,
      ),
      WorkoutSession,
      PrefetchHooks Function()
    >;
typedef $$ExerciseAttemptsTableCreateCompanionBuilder =
    ExerciseAttemptsCompanion Function({
      required String attemptId,
      required String sessionId,
      required String exerciseId,
      required String exerciseName,
      Value<String?> groupId,
      Value<String?> supersetId,
      required String status,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });
typedef $$ExerciseAttemptsTableUpdateCompanionBuilder =
    ExerciseAttemptsCompanion Function({
      Value<String> attemptId,
      Value<String> sessionId,
      Value<String> exerciseId,
      Value<String> exerciseName,
      Value<String?> groupId,
      Value<String?> supersetId,
      Value<String> status,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });

class $$ExerciseAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseAttemptsTable> {
  $$ExerciseAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersetId => $composableBuilder(
    column: $table.supersetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseAttemptsTable> {
  $$ExerciseAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersetId => $composableBuilder(
    column: $table.supersetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseAttemptsTable> {
  $$ExerciseAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get supersetId => $composableBuilder(
    column: $table.supersetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);
}

class $$ExerciseAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseAttemptsTable,
          ExerciseAttempt,
          $$ExerciseAttemptsTableFilterComposer,
          $$ExerciseAttemptsTableOrderingComposer,
          $$ExerciseAttemptsTableAnnotationComposer,
          $$ExerciseAttemptsTableCreateCompanionBuilder,
          $$ExerciseAttemptsTableUpdateCompanionBuilder,
          (
            ExerciseAttempt,
            BaseReferences<
              _$AppDatabase,
              $ExerciseAttemptsTable,
              ExerciseAttempt
            >,
          ),
          ExerciseAttempt,
          PrefetchHooks Function()
        > {
  $$ExerciseAttemptsTableTableManager(
    _$AppDatabase db,
    $ExerciseAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> attemptId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> supersetId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseAttemptsCompanion(
                attemptId: attemptId,
                sessionId: sessionId,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                groupId: groupId,
                supersetId: supersetId,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attemptId,
                required String sessionId,
                required String exerciseId,
                required String exerciseName,
                Value<String?> groupId = const Value.absent(),
                Value<String?> supersetId = const Value.absent(),
                required String status,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseAttemptsCompanion.insert(
                attemptId: attemptId,
                sessionId: sessionId,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                groupId: groupId,
                supersetId: supersetId,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseAttemptsTable,
      ExerciseAttempt,
      $$ExerciseAttemptsTableFilterComposer,
      $$ExerciseAttemptsTableOrderingComposer,
      $$ExerciseAttemptsTableAnnotationComposer,
      $$ExerciseAttemptsTableCreateCompanionBuilder,
      $$ExerciseAttemptsTableUpdateCompanionBuilder,
      (
        ExerciseAttempt,
        BaseReferences<_$AppDatabase, $ExerciseAttemptsTable, ExerciseAttempt>,
      ),
      ExerciseAttempt,
      PrefetchHooks Function()
    >;
typedef $$SetAttemptsTableCreateCompanionBuilder =
    SetAttemptsCompanion Function({
      required String setAttemptId,
      required String attemptId,
      required int plannedSetIndex,
      required String outcome,
      required double weight,
      required int reps,
      Value<int?> historyEntryId,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$SetAttemptsTableUpdateCompanionBuilder =
    SetAttemptsCompanion Function({
      Value<String> setAttemptId,
      Value<String> attemptId,
      Value<int> plannedSetIndex,
      Value<String> outcome,
      Value<double> weight,
      Value<int> reps,
      Value<int?> historyEntryId,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$SetAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $SetAttemptsTable> {
  $$SetAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get setAttemptId => $composableBuilder(
    column: $table.setAttemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedSetIndex => $composableBuilder(
    column: $table.plannedSetIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get historyEntryId => $composableBuilder(
    column: $table.historyEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SetAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetAttemptsTable> {
  $$SetAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get setAttemptId => $composableBuilder(
    column: $table.setAttemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedSetIndex => $composableBuilder(
    column: $table.plannedSetIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get historyEntryId => $composableBuilder(
    column: $table.historyEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SetAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetAttemptsTable> {
  $$SetAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get setAttemptId => $composableBuilder(
    column: $table.setAttemptId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<int> get plannedSetIndex => $composableBuilder(
    column: $table.plannedSetIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get historyEntryId => $composableBuilder(
    column: $table.historyEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$SetAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetAttemptsTable,
          SetAttempt,
          $$SetAttemptsTableFilterComposer,
          $$SetAttemptsTableOrderingComposer,
          $$SetAttemptsTableAnnotationComposer,
          $$SetAttemptsTableCreateCompanionBuilder,
          $$SetAttemptsTableUpdateCompanionBuilder,
          (
            SetAttempt,
            BaseReferences<_$AppDatabase, $SetAttemptsTable, SetAttempt>,
          ),
          SetAttempt,
          PrefetchHooks Function()
        > {
  $$SetAttemptsTableTableManager(_$AppDatabase db, $SetAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> setAttemptId = const Value.absent(),
                Value<String> attemptId = const Value.absent(),
                Value<int> plannedSetIndex = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int?> historyEntryId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetAttemptsCompanion(
                setAttemptId: setAttemptId,
                attemptId: attemptId,
                plannedSetIndex: plannedSetIndex,
                outcome: outcome,
                weight: weight,
                reps: reps,
                historyEntryId: historyEntryId,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String setAttemptId,
                required String attemptId,
                required int plannedSetIndex,
                required String outcome,
                required double weight,
                required int reps,
                Value<int?> historyEntryId = const Value.absent(),
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => SetAttemptsCompanion.insert(
                setAttemptId: setAttemptId,
                attemptId: attemptId,
                plannedSetIndex: plannedSetIndex,
                outcome: outcome,
                weight: weight,
                reps: reps,
                historyEntryId: historyEntryId,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SetAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetAttemptsTable,
      SetAttempt,
      $$SetAttemptsTableFilterComposer,
      $$SetAttemptsTableOrderingComposer,
      $$SetAttemptsTableAnnotationComposer,
      $$SetAttemptsTableCreateCompanionBuilder,
      $$SetAttemptsTableUpdateCompanionBuilder,
      (
        SetAttempt,
        BaseReferences<_$AppDatabase, $SetAttemptsTable, SetAttempt>,
      ),
      SetAttempt,
      PrefetchHooks Function()
    >;
typedef $$XpEventsTableCreateCompanionBuilder =
    XpEventsCompanion Function({
      Value<int> id,
      required String eventKey,
      required String sessionId,
      required String eventType,
      Value<String?> exerciseId,
      Value<String?> exerciseName,
      required int xpAmount,
      required int rulesVersion,
      required DateTime createdAt,
    });
typedef $$XpEventsTableUpdateCompanionBuilder =
    XpEventsCompanion Function({
      Value<int> id,
      Value<String> eventKey,
      Value<String> sessionId,
      Value<String> eventType,
      Value<String?> exerciseId,
      Value<String?> exerciseName,
      Value<int> xpAmount,
      Value<int> rulesVersion,
      Value<DateTime> createdAt,
    });

class $$XpEventsTableFilterComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventKey => $composableBuilder(
    column: $table.eventKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpAmount => $composableBuilder(
    column: $table.xpAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XpEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventKey => $composableBuilder(
    column: $table.eventKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpAmount => $composableBuilder(
    column: $table.xpAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XpEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventKey =>
      $composableBuilder(column: $table.eventKey, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpAmount =>
      $composableBuilder(column: $table.xpAmount, builder: (column) => column);

  GeneratedColumn<int> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$XpEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $XpEventsTable,
          XpEvent,
          $$XpEventsTableFilterComposer,
          $$XpEventsTableOrderingComposer,
          $$XpEventsTableAnnotationComposer,
          $$XpEventsTableCreateCompanionBuilder,
          $$XpEventsTableUpdateCompanionBuilder,
          (XpEvent, BaseReferences<_$AppDatabase, $XpEventsTable, XpEvent>),
          XpEvent,
          PrefetchHooks Function()
        > {
  $$XpEventsTableTableManager(_$AppDatabase db, $XpEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XpEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XpEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XpEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> eventKey = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> exerciseId = const Value.absent(),
                Value<String?> exerciseName = const Value.absent(),
                Value<int> xpAmount = const Value.absent(),
                Value<int> rulesVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => XpEventsCompanion(
                id: id,
                eventKey: eventKey,
                sessionId: sessionId,
                eventType: eventType,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                xpAmount: xpAmount,
                rulesVersion: rulesVersion,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String eventKey,
                required String sessionId,
                required String eventType,
                Value<String?> exerciseId = const Value.absent(),
                Value<String?> exerciseName = const Value.absent(),
                required int xpAmount,
                required int rulesVersion,
                required DateTime createdAt,
              }) => XpEventsCompanion.insert(
                id: id,
                eventKey: eventKey,
                sessionId: sessionId,
                eventType: eventType,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                xpAmount: xpAmount,
                rulesVersion: rulesVersion,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XpEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $XpEventsTable,
      XpEvent,
      $$XpEventsTableFilterComposer,
      $$XpEventsTableOrderingComposer,
      $$XpEventsTableAnnotationComposer,
      $$XpEventsTableCreateCompanionBuilder,
      $$XpEventsTableUpdateCompanionBuilder,
      (XpEvent, BaseReferences<_$AppDatabase, $XpEventsTable, XpEvent>),
      XpEvent,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$ExerciseAttemptsTableTableManager get exerciseAttempts =>
      $$ExerciseAttemptsTableTableManager(_db, _db.exerciseAttempts);
  $$SetAttemptsTableTableManager get setAttempts =>
      $$SetAttemptsTableTableManager(_db, _db.setAttempts);
  $$XpEventsTableTableManager get xpEvents =>
      $$XpEventsTableTableManager(_db, _db.xpEvents);
}
