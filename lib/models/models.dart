import 'package:gym_app/domain/gamification.dart';
import 'package:uuid/uuid.dart';

String _stableExerciseId(String? value) {
  if (value != null && value.trim().isNotEmpty) return value;
  return const Uuid().v4();
}

class SetData {
  String weight;
  String reps;

  SetData({this.weight = '', this.reps = ''});

  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps};

  factory SetData.fromJson(Map<String, dynamic> json) =>
      SetData(weight: json['weight'], reps: json['reps']);
}

class Exercise {
  final String id;
  String name;
  List<SetData> sets;
  String? imageUrl;
  bool hasLocalImage;
  String? groupId;
  String? supersetId;
  int? supersetOrder;
  bool isHighPriority;
  int? sessionFatigueScore;
  int currentSetIndex;
  Set<int> sessionCompletedSetIndices;
  String? sessionAttemptId;
  ExerciseXpTier xpTier;
  bool warmupSetEnabled;

  Exercise({
    String? id,
    required this.name,
    this.imageUrl,
    List<SetData>? sets,
    this.hasLocalImage = false,
    this.groupId,
    this.supersetId,
    this.supersetOrder,
    this.isHighPriority = false,
    this.sessionFatigueScore,
    this.currentSetIndex = 0,
    Set<int>? sessionCompletedSetIndices,
    this.sessionAttemptId,
    this.xpTier = ExerciseXpTier.standard,
    this.warmupSetEnabled = false,
  }) : id = _stableExerciseId(id),
       sets = sets ?? [SetData(), SetData(), SetData()],
       sessionCompletedSetIndices = sessionCompletedSetIndices ?? <int>{};

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sets': sets.map((set) => set.toJson()).toList(),
    'imageUrl': imageUrl,
    'hasLocalImage': hasLocalImage,
    'groupId': groupId,
    'supersetId': supersetId,
    'supersetOrder': supersetOrder,
    'xpTier': xpTier.name,
    'warmupSetEnabled': warmupSetEnabled,
  };

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    bool legacyWarmupSetEnabled = false,
  }) => Exercise(
    id: _nonEmptyString(json['id']),
    name: json['name'] as String? ?? 'Unnamed Exercise',
    imageUrl: json['imageUrl'] as String?,
    hasLocalImage: json['hasLocalImage'] as bool? ?? false,
    groupId: json['groupId'] as String?,
    supersetId: json['supersetId'] as String?,
    supersetOrder: json['supersetOrder'] as int?,
    xpTier: _xpTierFromJson(json['xpTier']),
    warmupSetEnabled:
        json['warmupSetEnabled'] as bool? ?? legacyWarmupSetEnabled,
    sets:
        (json['sets'] as List?)
            ?.map((setJson) => SetData.fromJson(setJson))
            .toList() ??
        [],
  );

  static ExerciseXpTier _xpTierFromJson(Object? value) {
    return ExerciseXpTierSerialization.parse(value);
  }

  /// Returns true when loading this record should be followed by a save.
  /// Old JSON acquires a stable ID, explicit tier, and warmup preference once.
  static bool metadataNeedsMigration(Map<String, dynamic> json) {
    final id = _nonEmptyString(json['id']);
    final tier = json['xpTier'];
    final hasKnownTier = ExerciseXpTier.values.any((item) => item.name == tier);
    return id == null || !hasKnownTier || json['warmupSetEnabled'] is! bool;
  }

  static String? _nonEmptyString(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }

  bool get isPartOfGroup => groupId != null && groupId!.isNotEmpty;
  bool get isPartOfSuperset => supersetId != null && supersetId!.isNotEmpty;

  bool get isSessionComplete =>
      sets.isNotEmpty && sessionCompletedSetIndices.length >= sets.length;

  void markSetCompleted(int index) {
    if (index >= 0 && index < sets.length) {
      sessionCompletedSetIndices.add(index);
    }
  }

  void resetSessionProgress() {
    currentSetIndex = 0;
    sessionFatigueScore = null;
    sessionCompletedSetIndices.clear();
    sessionAttemptId = null;
  }
}
