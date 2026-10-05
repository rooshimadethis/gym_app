import 'package:flutter/material.dart';

Future<bool> showFinishWorkoutDialog(
  BuildContext context, {
  required int bankedXp,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _FinishWorkoutDialog(bankedXp: bankedXp),
  );
  return result ?? false;
}

class _FinishWorkoutDialog extends StatelessWidget {
  const _FinishWorkoutDialog({required this.bankedXp});

  final int bankedXp;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: scheme.primary.withValues(alpha: .32)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.flag_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Finish workout?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Text(
                    '+$bankedXp XP',
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'already banked',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text('Finish workout'),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep going'),
            ),
          ],
        ),
      ),
    );
  }
}
