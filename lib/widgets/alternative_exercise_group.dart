import 'package:flutter/material.dart';
import 'package:gym_app/widgets/exercise_card.dart';
import 'package:gym_app/models/models.dart';
import 'package:gym_app/views/exercise_detail_view.dart';

class AlternativeExerciseGroup extends StatelessWidget {
  final List<Exercise> alternatives;
  final Function(Exercise) onExerciseCompleted;
  final Function(Exercise) onLongPress;
  final VoidCallback onTap;
  final SupersetInfo Function(Exercise)? getSupersetInfo;

  const AlternativeExerciseGroup({
    super.key,
    required this.alternatives,
    required this.onExerciseCompleted,
    required this.onLongPress,
    required this.onTap,
    this.getSupersetInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (alternatives.isNotEmpty && !alternatives[0].isPartOfSuperset)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'ALTERNATIVES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: alternatives.length,
            itemBuilder: (context, index) {
              final exercise = alternatives[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16.0 : 8.0,
                  right: index == alternatives.length - 1 ? 16.0 : 8.0,
                ),
                child: SizedBox(
                  width: 220 * 1.6, // Matching ExerciseCard aspect ratio
                  child: ExerciseCard(
                    exercise: exercise,
                    onExerciseCompleted: () => onExerciseCompleted(exercise),
                    onLongPress: () => onLongPress(exercise),
                    onTap: onTap,
                    getSupersetInfo: getSupersetInfo,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
