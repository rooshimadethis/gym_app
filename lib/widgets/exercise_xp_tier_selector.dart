import 'package:flutter/material.dart';
import 'package:gym_app/domain/gamification.dart';

class ExerciseXpTierSelector extends StatelessWidget {
  const ExerciseXpTierSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ExerciseXpTier value;
  final ValueChanged<ExerciseXpTier> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('XP effort tier', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ExerciseXpTier>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ExerciseXpTier.accessory,
                label: Text('Accessory'),
              ),
              ButtonSegment(
                value: ExerciseXpTier.standard,
                label: Text('Standard'),
              ),
              ButtonSegment(
                value: ExerciseXpTier.demanding,
                label: Text('Demanding'),
              ),
            ],
            selected: {value},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Text(
            _description(value),
            key: ValueKey(value),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  static String _description(ExerciseXpTier tier) {
    return switch (tier) {
      ExerciseXpTier.accessory =>
        'Lighter or isolation work, such as rotator-cuff exercises.',
      ExerciseXpTier.standard => 'The default for most exercises.',
      ExerciseXpTier.demanding =>
        'High-effort compound work, such as squats or deadlifts.',
    };
  }
}
