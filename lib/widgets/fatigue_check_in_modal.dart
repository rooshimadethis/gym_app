import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FatigueCheckInModal extends StatelessWidget {
  const FatigueCheckInModal({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'BEFORE YOU START',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'How’s your energy?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We’ll adjust your suggested weights.',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: .65),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            const _FatigueOption(
              label: 'Fresh',
              detail: 'Ready to push',
              icon: Icons.battery_full_rounded,
              score: -1,
            ),
            const SizedBox(height: 10),
            const _FatigueOption(
              label: 'Normal',
              detail: 'My usual energy',
              icon: Icons.battery_5_bar_rounded,
              score: 0,
            ),
            const SizedBox(height: 10),
            const _FatigueOption(
              label: 'Fatigued',
              detail: 'Taking it easier today',
              icon: Icons.battery_2_bar_rounded,
              score: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _FatigueOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String detail;
  final int score;

  const _FatigueOption({
    required this.label,
    required this.icon,
    required this.detail,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.onSurface.withValues(alpha: .045),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.onSurface.withValues(alpha: .1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pop(context, score);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: .6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: .4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
