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
          ..write('sessionId: $sessionId')
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
          other.sessionId == this.sessionId);
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
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [historyEntries];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
}
