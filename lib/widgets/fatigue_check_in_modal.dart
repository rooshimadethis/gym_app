import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FatigueCheckInModal extends StatelessWidget {
  const FatigueCheckInModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('How are you feeling?'),
      content: const Text(
        'This helps adjust your recommended weights for this session.',
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        _FatigueOption(
          label: 'Fresh',
          icon: Icons.battery_full,
          color: Colors.green,
          score: -1,
        ),
        _FatigueOption(
          label: 'Normal',
          icon: Icons.battery_std,
          color: Colors.blue,
          score: 0,
        ),
        _FatigueOption(
          label: 'Fatigued',
          icon: Icons.battery_alert,
          color: Colors.orange,
          score: 1,
        ),
      ],
    );
  }
}

class _FatigueOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int score;

  const _FatigueOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context, score);
          },
          icon: Icon(icon, color: color, size: 32),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: color.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
