import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym_app/domain/gamification.dart';

class SessionProgressStrip extends StatefulWidget {
  const SessionProgressStrip({
    super.key,
    required this.startedAt,
    required this.sessionXp,
    required this.level,
    this.progress,
  });

  final DateTime startedAt;
  final int sessionXp;
  final int level;
  final XpLevelProgress? progress;

  @override
  State<SessionProgressStrip> createState() => _SessionProgressStripState();
}

class _SessionProgressStripState extends State<SessionProgressStrip> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startedAt);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final elapsedLabel = hours > 0
        ? '$hours:$minutes'
        : '${elapsed.inMinutes}m';
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label:
          'Workout active for $elapsedLabel, ${widget.sessionXp} session XP, level ${widget.level}',
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.primary.withValues(alpha: .28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Text(elapsedLabel),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    '${widget.sessionXp} XP',
                    key: ValueKey(widget.sessionXp),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'LV ${widget.level}',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: .64),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (widget.progress case final progress?) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress.fraction.clamp(0, 1),
                minHeight: 6,
                borderRadius: BorderRadius.circular(99),
                backgroundColor: scheme.primary.withValues(alpha: .15),
              ),
              const SizedBox(height: 5),
              Text(
                '${progress.xpForNextLevel - progress.xpIntoLevel} XP to Level ${progress.level + 1}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withValues(alpha: .65),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
