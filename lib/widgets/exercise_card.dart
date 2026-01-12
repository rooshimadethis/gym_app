import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/views/exercise_detail_view.dart';
import 'package:gym_app/models/models.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onExerciseCompleted;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final VoidCallback? onSupersetProgress;
  final SupersetInfo Function(Exercise)? getSupersetInfo;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onExerciseCompleted,
    required this.onLongPress,
    required this.onTap,
    this.onSupersetProgress,
    this.getSupersetInfo,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  TickerFuture? _ticker;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeHolderImageUrl =
        'https://placehold.co/400x200.png?text=${Uri.encodeComponent(widget.exercise.name)}';

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        child: OpenContainer(
          tappable: false,
          closedColor:
              Theme.of(context).cardTheme.color ?? const Color(0xFF1A1A1A),
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          closedElevation: 0.0,
          transitionDuration: const Duration(milliseconds: 400),
          openBuilder: (context, action) {
            return ExerciseDetailView(
              exercise: widget.exercise,
              onExerciseCompleted: widget.onExerciseCompleted,
              onSupersetProgress: widget.onSupersetProgress,
              getSupersetInfo: widget.getSupersetInfo,
            );
          },
          closedBuilder: (context, action) {
            return GestureDetector(
              onTapDown: (_) => _ticker = _controller.forward(),
              onTapUp: (_) => _ticker?.whenCompleteOrCancel(() {
                if (mounted) _controller.reverse();
              }),
              onTapCancel: () => _controller.reverse(),
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
                Future.delayed(const Duration(milliseconds: 100), action);
              },
              child: AspectRatio(
                aspectRatio: 1.6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image with Gradient Overlay
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24.0),
                      child:
                          widget.exercise.hasLocalImage &&
                              widget.exercise.imageUrl != null
                          ? Image.asset(
                              widget.exercise.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: placeHolderImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.fitness_center),
                            ),
                    ),
                    // Gradient
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    widget.exercise.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (widget.exercise.sets.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${widget.exercise.sets.length} sets',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.exercise.isHighPriority)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.priority_high,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'PRIORITY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
