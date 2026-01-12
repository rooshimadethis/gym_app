import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/services/rest_timer_manager.dart';

class RestTimerOverlay extends StatefulWidget {
  const RestTimerOverlay({super.key});

  @override
  State<RestTimerOverlay> createState() => _RestTimerOverlayState();
}

class _RestTimerOverlayState extends State<RestTimerOverlay>
    with SingleTickerProviderStateMixin {
  Offset _offset = const Offset(20, 100); // Initial position from bottom-right
  late AnimationController _inertiaController;
  Animation<Offset>? _inertiaAnimation;

  @override
  void initState() {
    super.initState();
    _inertiaController = AnimationController(vsync: this);
    _inertiaController.addListener(() {
      if (_inertiaAnimation != null) {
        setState(() {
          _offset = _inertiaAnimation!.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _inertiaController.dispose();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RestTimerManager.instance,
      builder: (context, _) {
        if (!RestTimerManager.instance.isActive) {
          return const SizedBox.shrink();
        }

        final elapsed = RestTimerManager.instance.elapsedMilliseconds;
        final duration = RestTimerManager.instance.timerDuration * 1000;
        final progress = (elapsed / duration).clamp(0.0, 1.0);
        final isOver = elapsed >= duration;
        final color = isOver
            ? Colors.orangeAccent
            : Theme.of(context).colorScheme.primary;

        return Positioned(
          right: _offset.dx,
          bottom: _offset.dy,
          child: GestureDetector(
            onPanStart: (_) => _inertiaController.stop(),
            onPanUpdate: (details) {
              setState(() {
                final size = MediaQuery.of(context).size;
                _offset = Offset(
                  (_offset.dx - details.delta.dx).clamp(10, size.width - 250),
                  (_offset.dy - details.delta.dy).clamp(10, size.height - 200),
                );
              });
            },
            onPanEnd: (details) {
              final velocity = details.velocity.pixelsPerSecond;
              final magnitude = velocity.distance;

              if (magnitude > 200) {
                final size = MediaQuery.of(context).size;
                // Calculate inertia target based on velocity
                // We multiply by a factor (0.2) to simulate travel distance
                final target =
                    _offset + Offset(-velocity.dx, -velocity.dy) * 0.2;

                final clampedTarget = Offset(
                  target.dx.clamp(10, size.width - 250),
                  target.dy.clamp(10, size.height - 200),
                );

                _inertiaAnimation =
                    Tween<Offset>(begin: _offset, end: clampedTarget).animate(
                      CurvedAnimation(
                        parent: _inertiaController,
                        curve: Curves.easeOutQuart,
                      ),
                    );

                _inertiaController.duration = Duration(
                  milliseconds: (magnitude / 5).clamp(300, 800).toInt(),
                );
                _inertiaController.forward(from: 0);

                // Haptic feedback for flick
                if (clampedTarget.dy > size.height - 250) {
                  HapticFeedback.mediumImpact();
                } else {
                  HapticFeedback.lightImpact();
                }
              }
            },
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.5,
                          ),
                        ),
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Left Side: Progress Circle + Icon
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 58,
                                    height: 58,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 6,
                                      color: color,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  Icon(
                                    isOver
                                        ? Icons.priority_high
                                        : Icons.timer_outlined,
                                    color: color,
                                    size: 28,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              // Middle: Labels + Timer
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withValues(
                                                alpha: 0.5,
                                              ),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isOver ? 'GO TIME' : 'RESTING',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.5,
                                          color: color,
                                          fontFamily: 'StackSansText',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatTime(elapsed),
                                    style: TextStyle(
                                      fontSize: 32,
                                      height: 1.1,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontFamily: 'StackSansText',
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              // Right Side: Close Button
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  RestTimerManager.instance.stop();
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white70,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
