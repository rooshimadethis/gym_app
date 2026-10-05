import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/services/workout_feedback_settings.dart';

Future<void> showWorkoutStartCelebration(BuildContext context) async {
  final overlay = Overlay.of(context);
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: _WorkoutStartOverlay(
          reduceMotion: reduceMotion,
          onComplete: () => entry.remove(),
        ),
      ),
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
    builder: (_) => IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: _XpGainOverlay(
          xp: xp,
          effort: effort,
          reduceMotion: reduceMotion,
          onComplete: () => entry.remove(),
        ),
      ),
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
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addStatusListener((status) {
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
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          // Enter quickly, hold long enough to read, then fade over 300ms.
          final entrance = (t / .08).clamp(0.0, 1.0);
          final opacity = t < .9 ? entrance : ((1 - t) / .1).clamp(0.0, 1.0);
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -1),
                      radius: .8 + t * .45,
                      colors: [
                        color.withValues(alpha: .16 * opacity),
                        color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          widget.reduceMotion
                              ? 0
                              : -16 *
                                    (1 -
                                        Curves.easeOutCubic.transform(
                                          entrance,
                                        )),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: .96),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withValues(alpha: .36),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .28),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: .16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: color,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Workout started',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text('First set. That\'s the whole job.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
          duration: const Duration(milliseconds: 1800),
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
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Padding(
        // Overlay entries span the screen even when Scaffold resizes for IME.
        // Follow the live inset so the award stays above the opening keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                return Opacity(
                  opacity: t < .75 ? 1 : ((1 - t) / .25).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, widget.reduceMotion ? 0 : -28 * t),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: .96),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: .42),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .24),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.effort
                              ? Icons.bolt_rounded
                              : Icons.check_rounded,
                          size: 18,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          widget.effort
                              ? 'Effort +${widget.xp} XP'
                              : 'Set +${widget.xp} XP',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
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
