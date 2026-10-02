/// The effort classification selected by the user for an exercise.
///
/// Keep the serialized values stable: these names are part of the backup
/// format and are deliberately not inferred from an exercise's name or load.
enum ExerciseXpTier { accessory, standard, demanding }

extension ExerciseXpTierSerialization on ExerciseXpTier {
  String get serializedValue => name;

  static ExerciseXpTier parse(Object? value) {
    final serialized = value is String ? value.toLowerCase() : null;
    return ExerciseXpTier.values.firstWhere(
      (tier) => tier.name == serialized,
      orElse: () => ExerciseXpTier.standard,
    );
  }
}

enum XpEventType {
  setCompleted,
  setFailed,
  exerciseCompleted,
  workoutCompleted,
}

extension XpEventTypeSerialization on XpEventType {
  String get serializedValue {
    switch (this) {
      case XpEventType.setCompleted:
        return 'set_completed';
      case XpEventType.setFailed:
        return 'set_failed';
      case XpEventType.exerciseCompleted:
        return 'exercise_completed';
      case XpEventType.workoutCompleted:
        return 'workout_completed';
    }
  }

  static XpEventType parse(String value) => XpEventType.values.firstWhere(
    (event) => event.serializedValue == value,
    orElse: () => XpEventType.setCompleted,
  );
}

enum WorkoutEndReason { explicit, automatic, discarded }

extension WorkoutEndReasonSerialization on WorkoutEndReason {
  String get serializedValue => name;

  static WorkoutEndReason parse(String value) =>
      WorkoutEndReason.values.firstWhere(
        (reason) => reason.name == value,
        orElse: () => WorkoutEndReason.explicit,
      );
}

enum ExerciseAttemptStatus { active, completed, abandoned }

extension ExerciseAttemptStatusSerialization on ExerciseAttemptStatus {
  String get serializedValue => name;

  static ExerciseAttemptStatus parse(String value) =>
      ExerciseAttemptStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => ExerciseAttemptStatus.active,
      );
}

enum SetAttemptOutcome { completed, failed }

extension SetAttemptOutcomeSerialization on SetAttemptOutcome {
  String get serializedValue => name;

  static SetAttemptOutcome parse(String value) =>
      SetAttemptOutcome.values.firstWhere(
        (outcome) => outcome.name == value,
        orElse: () => SetAttemptOutcome.completed,
      );
}

/// Versioned, centralized XP values. Changing these values affects only new
/// ledger events; old rows retain their original rules version and amount.
class XpRules {
  const XpRules._();

  static const int version = 1;
  static const int accessorySetXp = 1;
  static const int standardSetXp = 2;
  static const int demandingSetXp = 3;
  static const int accessoryExerciseXp = 5;
  static const int standardExerciseXp = 10;
  static const int demandingExerciseXp = 15;
  static const int workoutCompletionXp = 40;

  static int setXp(ExerciseXpTier tier) {
    switch (tier) {
      case ExerciseXpTier.accessory:
        return accessorySetXp;
      case ExerciseXpTier.standard:
        return standardSetXp;
      case ExerciseXpTier.demanding:
        return demandingSetXp;
    }
  }

  static int exerciseXp(ExerciseXpTier tier) {
    switch (tier) {
      case ExerciseXpTier.accessory:
        return accessoryExerciseXp;
      case ExerciseXpTier.standard:
        return standardExerciseXp;
      case ExerciseXpTier.demanding:
        return demandingExerciseXp;
    }
  }
}

class XpLevelProgress {
  const XpLevelProgress({
    required this.level,
    required this.lifetimeXp,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  final int level;
  final int lifetimeXp;
  final int xpIntoLevel;
  final int xpForNextLevel;

  double get fraction => xpForNextLevel == 0 ? 0 : xpIntoLevel / xpForNextLevel;
}

class XpBreakdown {
  const XpBreakdown({
    this.setCompletedXp = 0,
    this.setFailedXp = 0,
    this.exerciseCompletedXp = 0,
    this.workoutCompletedXp = 0,
  });

  final int setCompletedXp;
  final int setFailedXp;
  final int exerciseCompletedXp;
  final int workoutCompletedXp;

  int get total =>
      setCompletedXp + setFailedXp + exerciseCompletedXp + workoutCompletedXp;
}

class XpAward {
  const XpAward({
    required this.eventKey,
    required this.amount,
    required this.alreadyAwarded,
  });

  final String eventKey;
  final int amount;
  final bool alreadyAwarded;
}
