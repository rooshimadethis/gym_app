import 'package:flutter/material.dart';
import 'package:gym_app/exercise_card.dart';
import 'package:gym_app/alternative_exercise_group.dart';
import 'package:gym_app/models.dart';
import 'package:gym_app/exercise_detail_view.dart';

class SupersetExerciseGroup extends StatelessWidget {
  final List<Exercise> supersetExercises; // Sorted by supersetOrder
  final Function(Exercise) onExerciseCompleted;
  final Function(Exercise) onLongPress;
  final VoidCallback onTap;
  final int? currentExerciseIndex; // For highlighting active exercise
  final Function(Exercise)? onSupersetProgress;
  final SupersetInfo Function(Exercise)? getSupersetInfo;

  const SupersetExerciseGroup({
    super.key,
    required this.supersetExercises,
    required this.onExerciseCompleted,
    required this.onLongPress,
    required this.onTap,
    this.currentExerciseIndex,
    this.onSupersetProgress,
    this.getSupersetInfo,
  });

  @override
  Widget build(BuildContext context) {
    // Group exercises by supersetOrder (to handle alternatives at same position)
    final Map<int, List<Exercise>> positionGroups = {};
    for (var exercise in supersetExercises) {
      final order = exercise.supersetOrder ?? 0;
      positionGroups.putIfAbsent(order, () => []).add(exercise);
    }

    final sortedPositions = positionGroups.keys.toList()..sort();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Superset header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13.0),
                topRight: Radius.circular(13.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.link,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'SUPERSET',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Exercises
          ...sortedPositions.asMap().entries.map((entry) {
            final index = entry.key;
            final position = entry.value;
            final exercisesAtPosition = positionGroups[position]!;
            final isLast = index == sortedPositions.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Position indicator
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentExerciseIndex == position
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        child: Center(
                          child: Text(
                            '${position + 1}',
                            style: TextStyle(
                              color: currentExerciseIndex == position
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Exercise card(s)
                      Expanded(
                        child: exercisesAtPosition.length > 1
                            ? AlternativeExerciseGroup(
                                alternatives: exercisesAtPosition,
                                onExerciseCompleted: onExerciseCompleted,
                                onLongPress: onLongPress,
                                onTap: onTap,
                              )
                            : ExerciseCard(
                                exercise: exercisesAtPosition[0],
                                onExerciseCompleted: () =>
                                    onExerciseCompleted(exercisesAtPosition[0]),
                                onLongPress: () => onLongPress(exercisesAtPosition[0]),
                                onTap: onTap,
                                onSupersetProgress: onSupersetProgress != null
                                    ? () => onSupersetProgress!(exercisesAtPosition[0])
                                    : null,
                                getSupersetInfo: getSupersetInfo != null
                                    ? () => getSupersetInfo!(exercisesAtPosition[0])
                                    : null,
                              ),
                      ),
                    ],
                  ),
                ),

                // Connecting line (except for last exercise)
                if (!isLast)
                  Container(
                    margin: const EdgeInsets.only(left: 27),
                    width: 2,
                    height: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
