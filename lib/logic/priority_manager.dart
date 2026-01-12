class PriorityManager {
  static const int priorityThresholdDays = 7;

  /// Returns true if the exercise is considered High Priority
  /// (i.e., hasn't been done fresh in > 7 days)
  static bool isHighPriority(DateTime? lastFreshDate) {
    if (lastFreshDate == null) return true; // Never done fresh -> Priority

    final difference = DateTime.now().difference(lastFreshDate).inDays;
    return difference >= priorityThresholdDays;
  }
}
