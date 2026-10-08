import 'package:flutter/material.dart';

class ExerciseWarmupToggle extends StatelessWidget {
  const ExerciseWarmupToggle({
    super.key,
    required this.enabled,
    required this.onChanged,
  });
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    title: const Text('First set is a warmup'),
    subtitle: Text(
      onChanged == null
          ? 'Change before logging this exercise.'
          : 'Saved for this exercise · excluded from volume',
    ),
    value: enabled,
    onChanged: onChanged,
  );
}
