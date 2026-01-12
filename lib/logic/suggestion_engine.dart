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
  }) {
    if (history.isEmpty) {
      return Suggestion(
        weight: 45.0, // Default starting weight (standard barbell)
        reps: _targetReps,
        reasoning: "No history found. Start light and find your baseline.",
        weightChange: 0,
      );
    }

    // Get the most recent set - the LAST set indicates true capacity
    final lastSession = history.first; // Assumes history is sorted desc

    // 1. Calculate Fatigue Scores
    final lastFatigueScore = _calculateFatigueScore(
      position: lastSession.workoutPosition,
      userRating: lastSession.fatigueScore,
    );

    final currentFatigueScore = _calculateFatigueScore(
      position: currentPosition,
      userRating: currentFatigueCheckIn,
    );

    // 2. Base Comparison Logic (Fatigue-First Heuristic)
    bool shouldIncrease = false;
    String fatigueReason = "";

    if (currentFatigueScore <= lastFatigueScore) {
      // Current conditions are equal or better (lower score = less fatigue)
      shouldIncrease = true;
      fatigueReason =
          "Conditions are similar or better than last time (Score: $currentFatigueScore vs $lastFatigueScore).";
    } else {
      // Current conditions are worse (higher score = more fatigue)
      shouldIncrease = false;
      fatigueReason =
          "More fatigue expected today (Score: $currentFatigueScore vs $lastFatigueScore).";
    }

    // 3. RIR / Reps Override
    // Use the LAST set's reps - if they can hit 12+ on their last set, they have capacity
    final lastReps = lastSession.reps;

    String performanceReason = "";
    if (lastReps >= 15) {
      shouldIncrease = true;
      performanceReason =
          "Great performance last session ($lastReps reps) overrides fatigue.";
    } else if (lastReps == 14) {
      final diff = currentFatigueScore - lastFatigueScore;
      if (diff <= 2) {
        shouldIncrease = true;
        performanceReason =
            "Strong session last time ($lastReps reps) suggests capacity.";
      }
    } else if (lastReps == 13) {
      final diff = currentFatigueScore - lastFatigueScore;
      if (diff <= 1) {
        shouldIncrease = true;
        performanceReason =
            "Solid progress last time ($lastReps reps) allows increase.";
      }
    }

    // 4. Construct Final Suggestion
    double suggestedWeight = lastSession.weight;
    double change = 0;
    String finalReason = performanceReason.isNotEmpty
        ? performanceReason
        : fatigueReason;

    if (shouldIncrease) {
      if (lastReps >= 12) {
        suggestedWeight += _defaultIncrement;
        change = _defaultIncrement;
        finalReason += " Increasing weight.";
      } else {
        suggestedWeight = lastSession.weight;
        change = 0;
        finalReason =
            "Hit $_targetReps reps (Last: $lastReps) before adding weight. $fatigueReason";
      }
    } else {
      if (!finalReason.contains("Maintain")) {
        finalReason += " Maintain weight.";
      }
    }

    return Suggestion(
      weight: suggestedWeight,
      reps: _targetReps,
      reasoning: finalReason,
      weightChange: change,
    );
  }

  /// Calculates the Fatigue Score based on position and user rating
  /// Position 1-2: +0
  /// Position 3+: +1
  /// User Fresh (-1): -1
  /// User Fatigued (1): +1
  static int _calculateFatigueScore({
    required int position,
    required int userRating,
  }) {
    int positionScore = (position <= 2) ? 0 : 1;
    return positionScore + userRating;
  }
}
