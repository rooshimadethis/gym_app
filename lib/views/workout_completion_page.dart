import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/domain/gamification.dart';
import 'package:gym_app/services/workout_feedback_settings.dart';

class WorkoutCompletionPage extends StatefulWidget {
  const WorkoutCompletionPage({
    super.key,
    required this.breakdown,
    required this.levelProgress,
    required this.completedWorkout,
    this.levelsCrossed = const [],
  });

  final XpBreakdown breakdown;
  final XpLevelProgress levelProgress;
  final bool completedWorkout;
  final List<int> levelsCrossed;

  @override
  State<WorkoutCompletionPage> createState() => _WorkoutCompletionPageState();
}

class _WorkoutCompletionPageState extends State<WorkoutCompletionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    if (WorkoutFeedbackSettings.instance.hapticsEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.levelsCrossed.isNotEmpty) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      });
    }
    if (WorkoutFeedbackSettings.instance.soundEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SystemSound.play(SystemSoundType.alert);
      });
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.levelProgress;
    final scheme = Theme.of(context).colorScheme;
    final title = widget.levelsCrossed.isNotEmpty
        ? 'LEVEL UP'
        : widget.completedWorkout
        ? 'WORKOUT COMPLETE'
        : 'EFFORT BANKED';
    final subtitle = widget.completedWorkout
        ? 'You showed up. That\'s the win.'
        : 'Not every session needs a finish.';

    return Scaffold(
      body: Stack(
        children: [
          if (widget.completedWorkout &&
              !MediaQuery.disableAnimationsOf(context))
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, _) => CustomPaint(
                    painter: _CompletionConfettiPainter(
                      progress: _celebrationController.value,
                      primary: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SESSION RECEIPT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: .5),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: .14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: .38),
                        ),
                      ),
                      child: Icon(
                        widget.completedWorkout
                            ? Icons.check_rounded
                            : Icons.bolt_rounded,
                        size: 34,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: .68),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '+${widget.breakdown.total}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: scheme.primary,
                    ),
                  ),
                  Text(
                    'XP EARNED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: .42,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: scheme.onSurface.withValues(alpha: .09),
                      ),
                    ),
                    child: Column(
                      children: [
                        _BreakdownRow(
                          label: 'Completed sets',
                          xp: widget.breakdown.setCompletedXp,
                        ),
                        _BreakdownRow(
                          label: 'Failed-set effort',
                          xp: widget.breakdown.setFailedXp,
                        ),
                        _BreakdownRow(
                          label: 'Exercises completed',
                          xp: widget.breakdown.exerciseCompletedXp,
                        ),
                        _BreakdownRow(
                          label: 'Workout completed',
                          xp: widget.breakdown.workoutCompletedXp,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            height: 1,
                            color: scheme.onSurface.withValues(alpha: .12),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Level ${progress.level}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${progress.xpIntoLevel} / ${progress.xpForNextLevel} XP',
                              style: TextStyle(
                                color: scheme.onSurface.withValues(alpha: .62),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progress.fraction.clamp(0, 1),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: scheme.onSurface.withValues(
                            alpha: .1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionConfettiPainter extends CustomPainter {
  const _CompletionConfettiPainter({
    required this.progress,
    required this.primary,
  });

  final double progress;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [primary, Colors.amber, Colors.lightGreen, Colors.white];
    for (var i = 0; i < 42; i++) {
      final seed = math.Random(i * 7919);
      final startX = seed.nextDouble() * size.width;
      final delay = seed.nextDouble() * .28;
      final local = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      final drift =
          math.sin(local * math.pi * 3 + i) * (10 + seed.nextDouble() * 22);
      final y = -20 + local * (size.height * .72 + seed.nextDouble() * 130);
      final opacity = local > .76 ? (1 - local) / .24 : 1.0;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: opacity);
      canvas.save();
      canvas.translate(startX + drift, y);
      canvas.rotate(local * math.pi * (2 + seed.nextDouble() * 3));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 5 + seed.nextDouble() * 5,
            height: 10 + seed.nextDouble() * 7,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CompletionConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.primary != primary;
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.xp});

  final String label;
  final int xp;

  @override
  Widget build(BuildContext context) {
    if (xp == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .72),
              ),
            ),
          ),
          Text('+$xp XP', style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
