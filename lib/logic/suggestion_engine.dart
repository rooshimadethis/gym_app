import 'package:gym_app/database/database.dart';

class Suggestion {
  final double weight;
  final int reps; // Target reps (usually 12)
  final String reasoning;
  final double? weightChange; // +2.5, 0, -2.5

  Suggestion({
    required this.weight,
    required this.reps,
    required this.reasoning,
    this.weightChange,
  });
}

class SuggestionEngine {
  static const double _defaultIncrement = 5.0; // lbs (standard plate increment)
  static const int _targetReps = 12;

  /// Main method to generate a suggestion based on history and current context
  static Suggestion generateSuggestion({
    required List<HistoryEntry> history,
    required int currentPosition,
    required int currentFatigueCheckIn, // -1 (Fresh), 0 (Normal), 1 (Fatigued)
    String? currentSessionId,
  }) {
    if (history.isEmpty) {
      return Suggestion(
        weight: 45.0,
        reps: _targetReps,
        reasoning: "No history found. Start light and find your baseline.",
        weightChange: 0,
      );
    }

    // Identify entries from previous sessions only
    final previousEntries = currentSessionId != null
        ? history.where((e) => e.sessionId != currentSessionId).toList()
        : history;

    if (previousEntries.isEmpty) {
      return Suggestion(
        weight: 45.0,
        reps: _targetReps,
        reasoning: "First session for this exercise. Aim for baseline.",
        weightChange: 0,
      );
    }

    // 1. Identify the most recent session and its entries from the remaining history
    // History is sorted by timestamp DESC, so previousEntries.first is the most recent set ever logged.
    final lastSessionId = previousEntries.first.sessionId;
    final lastSessionEntries = previousEntries
        .where((e) => e.sessionId == lastSessionId)
        .toList();

    // 2. Sort by ID or Timestamp ascending to find the true FINAL set of that session
    final sessionByTime = List<HistoryEntry>.from(lastSessionEntries)
      ..sort(
        (a, b) => a.id.compareTo(b.id),
      ); // Using ID is safer for insertion order

    final lastSetInSession = sessionByTime.last;
    final lastReps = lastSetInSession.reps;
    final lastWeight = lastSetInSession.weight;

    final isSessionIncomplete = lastReps == 0;

    // 3. Calculate Fatigue Scores for the Final Set vs Current Context
    final lastFatigueScore = _calculateFatigueScore(
      position: lastSetInSession.workoutPosition,
      userRating: lastSetInSession.fatigueScore,
    );

    final currentFatigueScore = _calculateFatigueScore(
      position: currentPosition,
      userRating: currentFatigueCheckIn,
    );

    // 4. Logic Decision
    double suggestedWeight = lastWeight;
    double change = 0;
    String reasoning = "";

    bool conditionsAllowIncrease = currentFatigueScore <= lastFatigueScore;

    if (isSessionIncomplete) {
      suggestedWeight = lastWeight;
      change = 0;
      reasoning =
          "Last session was cut short (0 reps). Maintain ${lastWeight}lbs to build stamina.";
    } else if (lastReps >= 15) {
      // High rep performance on the LAST set is a clear signal
      suggestedWeight += _defaultIncrement;
      change = _defaultIncrement;
      reasoning =
          "Exceptional finish ($lastReps reps @ ${lastWeight}lbs). Increasing weight.";
    } else if (lastReps >= _targetReps) {
      if (conditionsAllowIncrease) {
        suggestedWeight += _defaultIncrement;
        change = _defaultIncrement;
        reasoning =
            "Hit $_targetReps+ reps on your final set last session. Conditions allow increase.";
      } else {
        suggestedWeight = lastWeight;
        change = 0;
        reasoning =
            "Hit target reps last time, but today's fatigue/position suggests maintaining.";
      }
    } else {
      // This is the "philosophy" part: if lastReps < 12, NO INCREASE.
      suggestedWeight = lastWeight;
      change = 0;
      reasoning =
          "Last set was $lastReps reps. Master $lastWeight lbs for $_targetReps reps before increasing.";
    }

    return Suggestion(
      weight: suggestedWeight,
      reps: _targetReps,
      reasoning: reasoning,
      weightChange: change,
    );
  }

  /// Calculates the Fatigue Score based on position and user rating
  static int _calculateFatigueScore({
    required int position,
    required int userRating,
  }) {
    int positionScore = (position <= 2) ? 0 : 1;
    return positionScore + userRating;
  }
}
