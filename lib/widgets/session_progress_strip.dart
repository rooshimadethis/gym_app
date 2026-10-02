import 'dart:async';

import 'package:flutter/material.dart';

class SessionProgressStrip extends StatefulWidget {
  const SessionProgressStrip({
    super.key,
    required this.startedAt,
    required this.sessionXp,
    required this.level,
  });

  final DateTime startedAt;
  final int sessionXp;
  final int level;

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 18,
              color: scheme.onPrimaryContainer,
            ),
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
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
