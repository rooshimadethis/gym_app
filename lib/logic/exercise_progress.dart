import 'package:gym_app/database/database.dart';

String formatWeight(double value) =>
    value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

class ExerciseSessionProgress {
  ExerciseSessionProgress(this.sessionId, this.sets);
  final String sessionId;
  final List<HistoryEntry> sets;
  DateTime get date => sets.first.timestamp;
  List<HistoryEntry> get workingSets =>
      sets.where((s) => !s.isWarmup && s.reps > 0).toList();
  HistoryEntry? get bestSet {
    final eligible = workingSets
      ..sort((a, b) {
        final byWeight = b.weight.compareTo(a.weight);
        return byWeight != 0 ? byWeight : b.reps.compareTo(a.reps);
      });
    return eligible.isEmpty ? null : eligible.first;
  }
}

List<ExerciseSessionProgress> summarizeExerciseProgress(
  List<HistoryEntry> history,
) {
  final groups = <String, List<HistoryEntry>>{};
  final sorted = List<HistoryEntry>.from(history)
    ..sort((a, b) {
      final time = b.timestamp.compareTo(a.timestamp);
      return time != 0 ? time : b.id.compareTo(a.id);
    });
  for (final row in sorted) {
    groups.putIfAbsent(row.sessionId, () => []).add(row);
  }
  return groups.entries
      .map((e) => ExerciseSessionProgress(e.key, e.value))
      .toList();
}

String sessionComparison(List<ExerciseSessionProgress> sessions) {
  final eligible = sessions.where((s) => s.bestSet != null).toList();
  if (eligible.length < 2) {
    return 'Log another completed session to compare progress.';
  }
  final latest = eligible[0].bestSet!;
  final previous = eligible[1].workingSets
      .where((s) => s.weight == latest.weight)
      .toList();
  if (previous.isEmpty) {
    return 'Latest best: ${formatWeight(latest.weight)} lbs × ${latest.reps}. Different loads last time—no direct rep comparison.';
  }
  final previousReps = previous
      .map((s) => s.reps)
      .reduce((a, b) => a > b ? a : b);
  final delta = latest.reps - previousReps;
  return '${delta > 0 ? '+' : ''}$delta ${delta.abs() == 1 ? 'rep' : 'reps'} at ${formatWeight(latest.weight)} lbs vs previous completed session.';
}
