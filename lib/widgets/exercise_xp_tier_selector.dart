import 'package:flutter/material.dart';
import 'package:gym_app/domain/gamification.dart';

Future<ExerciseXpTier?> showExerciseXpTierDialog(
  BuildContext context, {
  required String exerciseName,
  required ExerciseXpTier initialTier,
}) {
  var selectedTier = initialTier;
  return showDialog<ExerciseXpTier>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Set the effort',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  exerciseName,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .6),
                  ),
                ),
                const SizedBox(height: 20),
                ExerciseXpTierSelector(
                  value: selectedTier,
                  onChanged: (tier) =>
                      setDialogState(() => selectedTier = tier),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pop(context, selectedTier),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Save effort'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

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
        for (final tier in ExerciseXpTier.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TierOption(
              tier: tier,
              selected: value == tier,
              onTap: () => onChanged(tier),
            ),
          ),
      ],
    );
  }

  static String _description(ExerciseXpTier tier) {
    return switch (tier) {
      ExerciseXpTier.accessory =>
        'Isolation work, such as curls or rotator cuff.',
      ExerciseXpTier.standard => 'Most exercises fit here.',
      ExerciseXpTier.demanding =>
        'Compound lifts, such as squats or deadlifts.',
    };
  }
}

class _TierOption extends StatelessWidget {
  const _TierOption({
    required this.tier,
    required this.selected,
    required this.onTap,
  });
  final ExerciseXpTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = switch (tier) {
      ExerciseXpTier.accessory => 'Accessory',
      ExerciseXpTier.standard => 'Standard',
      ExerciseXpTier.demanding => 'Demanding',
    };
    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: .1)
          : scheme.onSurface.withValues(alpha: .035),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: .12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: .4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${XpRules.setXp(tier)} XP / set · ${XpRules.exerciseXp(tier)} XP / exercise',
                      style: TextStyle(fontSize: 11, color: scheme.primary),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ExerciseXpTierSelector._description(tier),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: scheme.onSurface.withValues(alpha: .6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
