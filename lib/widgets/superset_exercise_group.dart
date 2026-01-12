import 'package:flutter/material.dart';
import 'package:gym_app/widgets/exercise_card.dart';
import 'package:gym_app/widgets/alternative_exercise_group.dart';
import 'package:gym_app/models/models.dart';
import 'package:gym_app/views/exercise_detail_view.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Superset header
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(26.0),
                topRight: Radius.circular(26.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_motion_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'SUPERSET',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Exercises
          ...sortedPositions.map((position) {
            final exercisesAtPosition = positionGroups[position]!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Exercise card(s)
                      Expanded(
                        child: exercisesAtPosition.length > 1
                            ? AlternativeExerciseGroup(
                                alternatives: exercisesAtPosition,
                                onExerciseCompleted: onExerciseCompleted,
                                onLongPress: onLongPress,
                                onTap: onTap,
                                onSupersetProgress: onSupersetProgress,
                                supersetIndex: position + 1,
                                getSupersetInfo: getSupersetInfo,
                              )
                            : ExerciseCard(
                                exercise: exercisesAtPosition[0],
                                onExerciseCompleted: () =>
                                    onExerciseCompleted(exercisesAtPosition[0]),
                                onLongPress: () =>
                                    onLongPress(exercisesAtPosition[0]),
                                onTap: onTap,
                                onSupersetProgress: onSupersetProgress != null
                                    ? () => onSupersetProgress!(
                                        exercisesAtPosition[0],
                                      )
                                    : null,
                                supersetIndex: position + 1,
                                getSupersetInfo: getSupersetInfo,
                              ),
                      ),
                    ],
                  ),
                ),

                // No connecting line needed now that indicators are inside cards
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
