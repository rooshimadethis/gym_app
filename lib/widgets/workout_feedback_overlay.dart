import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/services/workout_feedback_settings.dart';

Future<void> showWorkoutStartCelebration(BuildContext context) async {
  final overlay = Overlay.of(context);
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _WorkoutStartOverlay(
      reduceMotion: reduceMotion,
      onComplete: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
  if (WorkoutFeedbackSettings.instance.hapticsEnabled) {
    await HapticFeedback.mediumImpact();
  }
  if (WorkoutFeedbackSettings.instance.soundEnabled) {
    await SystemSound.play(SystemSoundType.click);
  }
}

void showXpGainFeedback(
  BuildContext context, {
  required int xp,
  bool effort = false,
}) {
  final overlay = Overlay.of(context);
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _XpGainOverlay(
      xp: xp,
      effort: effort,
      reduceMotion: reduceMotion,
      onComplete: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _WorkoutStartOverlay extends StatefulWidget {
  const _WorkoutStartOverlay({
    required this.reduceMotion,
    required this.onComplete,
  });

  final bool reduceMotion;
  final VoidCallback onComplete;

  @override
  State<_WorkoutStartOverlay> createState() => _WorkoutStartOverlayState();
}

class _WorkoutStartOverlayState extends State<_WorkoutStartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.reduceMotion ? 650 : 900),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onComplete();
        });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final fade = t < .18 ? t / .18 : (1 - t).clamp(0.0, 1.0) / .3;
          final opacity = t < .7 ? 1.0 : fade;
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.1 + t * .35,
                      colors: [
                        color.withValues(alpha: .22 * opacity),
                        color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              if (!widget.reduceMotion)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BurstPainter(
                      progress: Curves.easeOutCubic.transform(t),
                      color: color,
                    ),
                  ),
                ),
              Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: widget.reduceMotion
                        ? 1
                        : .88 + Curves.elasticOut.transform(t) * .12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: .25),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 34),
                            SizedBox(height: 6),
                            Text(
                              'WORKOUT STARTED',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('First set is all that matters'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _XpGainOverlay extends StatefulWidget {
  const _XpGainOverlay({
    required this.xp,
    required this.effort,
    required this.reduceMotion,
    required this.onComplete,
  });

  final int xp;
  final bool effort;
  final bool reduceMotion;
  final VoidCallback onComplete;

  @override
  State<_XpGainOverlay> createState() => _XpGainOverlayState();
}

class _XpGainOverlayState extends State<_XpGainOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.reduceMotion ? 700 : 500),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onComplete();
        });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: const Alignment(0, .58),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              return Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, widget.reduceMotion ? 0 : -28 * t),
                  child: child,
                ),
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                child: Text(
                  widget.effort
                      ? 'Effort counted · +${widget.xp} XP'
                      : '+${widget.xp} XP',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < 18; i++) {
      final angle = (math.pi * 2 * i / 18) + .15;
      final distance = 44 + progress * math.min(size.width, size.height) * .34;
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      paint.color = color.withValues(alpha: (1 - progress) * .75);
      paint.strokeWidth = i.isEven ? 5 : 3;
      canvas.drawCircle(point, i.isEven ? 3.5 : 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
