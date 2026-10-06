import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/domain/gamification.dart';
import 'package:gym_app/services/gamification_service.dart';
import 'package:gym_app/services/workout_feedback_settings.dart';

OverlayEntry? _activeXpEntry;
XpLevelProgress? _activeXpBefore;
int _activeXpAmount = 0;

void dismissXpGainFeedback() {
  _activeXpEntry?.remove();
  _activeXpEntry = null;
  _activeXpBefore = null;
  _activeXpAmount = 0;
}

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
  XpLevelProgress? before,
  XpLevelProgress? after,
  String label = 'Set',
}) {
  // A final set and its exercise bonus can arrive together. Combine them
  // rather than stacking two cards or hiding the first award.
  if (_activeXpEntry != null && before != null && _activeXpBefore != null) {
    xp += _activeXpAmount;
    before = _activeXpBefore;
    label = 'Earned';
  }
  _activeXpEntry?.remove();
  _activeXpBefore = before;
  _activeXpAmount = xp;
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
          before: before,
          after: after,
          label: label,
          onDispose: () {
            if (_activeXpEntry == entry) {
              _activeXpEntry = null;
              _activeXpBefore = null;
              _activeXpAmount = 0;
            }
          },
          onComplete: () {
            if (_activeXpEntry == entry) {
              entry.remove();
              _activeXpEntry = null;
              _activeXpBefore = null;
              _activeXpAmount = 0;
            }
          },
        ),
      ),
    ),
  );
  _activeXpEntry = entry;
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
          animationBehavior: AnimationBehavior.preserve,
          duration: const Duration(seconds: 3),
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
    required this.before,
    required this.after,
    required this.label,
    required this.onDispose,
  });

  final int xp;
  final bool effort;
  final bool reduceMotion;
  final VoidCallback onComplete;
  final XpLevelProgress? before;
  final XpLevelProgress? after;
  final String label;
  final VoidCallback onDispose;

  @override
  State<_XpGainOverlay> createState() => _XpGainOverlayState();
}

class _XpGainOverlayState extends State<_XpGainOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _arrivalFeedbackPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            animationBehavior: AnimationBehavior.preserve,
            duration: Duration(
              milliseconds: widget.after == null ? 1800 : 5000,
            ),
          )
          ..addListener(() {
            if (!_arrivalFeedbackPlayed &&
                widget.after != null &&
                (_controller.lastElapsedDuration?.inMilliseconds ?? 0) >=
                    1800) {
              _arrivalFeedbackPlayed = true;
              if (WorkoutFeedbackSettings.instance.hapticsEnabled) {
                HapticFeedback.lightImpact();
              }
            }
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) widget.onComplete();
          });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.onDispose();
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
                final elapsed =
                    _controller.lastElapsedDuration?.inMilliseconds ?? 0;
                // Keep the reward sequence quick; extra time is a readable hold.
                final t = widget.after == null
                    ? _controller.value
                    : (elapsed / 3200).clamp(0.0, 1.0);
                final before = widget.before;
                final after = widget.after;
                final fill = widget.reduceMotion
                    ? 1.0
                    : Curves.easeInOutCubic.transform(
                        ((t - .18) / .38).clamp(0.0, 1.0),
                      );
                final crossesLevel =
                    before != null &&
                    after != null &&
                    after.level > before.level;
                final fillingOldLevel = crossesLevel && fill < .6;
                final animatedXp = before == null || after == null
                    ? 0
                    : fillingOldLevel
                    ? before.lifetimeXp +
                          ((before.xpForNextLevel - before.xpIntoLevel) *
                                  (fill / .45).clamp(0, 1))
                              .round()
                    : crossesLevel
                    ? before.lifetimeXp +
                          before.xpForNextLevel -
                          before.xpIntoLevel +
                          ((after.lifetimeXp -
                                      before.lifetimeXp -
                                      before.xpForNextLevel +
                                      before.xpIntoLevel) *
                                  ((fill - .6) / .4).clamp(0, 1))
                              .round()
                    : before.lifetimeXp +
                          ((after.lifetimeXp - before.lifetimeXp) * fill)
                              .round();
                final progress = fillingOldLevel
                    ? XpLevelProgress(
                        level: before.level,
                        lifetimeXp: animatedXp,
                        xpIntoLevel:
                            (before.xpIntoLevel +
                                    (before.xpForNextLevel -
                                            before.xpIntoLevel) *
                                        (fill / .45).clamp(0, 1))
                                .round(),
                        xpForNextLevel: before.xpForNextLevel,
                      )
                    : after == null
                    ? null
                    : GamificationService.levelProgressForXp(animatedXp);
                final leveledUp =
                    before != null &&
                    progress != null &&
                    progress.level > before.level;
                return Opacity(
                  opacity: widget.after == null
                      ? (t < .85 ? 1 : ((1 - t) / .15).clamp(0.0, 1.0))
                      : (elapsed < 4500
                            ? 1
                            : ((5000 - elapsed) / 500).clamp(0.0, 1.0)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Container(
                      width: progress == null ? null : 360,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: .98),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: .55),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(
                              alpha: .12 * (1 - (fill - .7).abs()).clamp(0, 1),
                            ),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: widget.reduceMotion
                                ? 1
                                : 1 + .12 * (1 - fill),
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                widget.reduceMotion ? 0 : -10 * (1 - fill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    leveledUp
                                        ? Icons.auto_awesome_rounded
                                        : widget.effort
                                        ? Icons.bolt_rounded
                                        : Icons.check_circle_rounded,
                                    color: scheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.effort ? 'Effort' : widget.label} +${widget.xp} XP',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: scheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (progress != null) ...[
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Text(
                                  leveledUp
                                      ? 'LEVEL UP! · ${progress.level}'
                                      : 'Level ${progress.level}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${progress.xpIntoLevel} / ${progress.xpForNextLevel} XP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurface.withValues(
                                      alpha: .7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, constraints) => Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  LinearProgressIndicator(
                                    value: progress.fraction.clamp(0, 1),
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(99),
                                    backgroundColor: scheme.primary.withValues(
                                      alpha: .15,
                                    ),
                                  ),
                                  if (!widget.reduceMotion)
                                    for (var i = 0; i < 3; i++)
                                      Positioned(
                                        left:
                                            constraints.maxWidth *
                                            (.42 + i * .08),
                                        top:
                                            -34 *
                                            (1 -
                                                ((t - .12 - i * .035) / .28)
                                                    .clamp(0, 1)),
                                        child: Opacity(
                                          opacity:
                                              t > .12 + i * .035 &&
                                                  t < .4 + i * .035
                                              ? 1
                                              : 0,
                                          child: ExcludeSemantics(
                                            child: Icon(
                                              Icons.bolt_rounded,
                                              size: 14,
                                              color: scheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${progress.xpForNextLevel - progress.xpIntoLevel} XP to Level ${progress.level + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface.withValues(alpha: .7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
