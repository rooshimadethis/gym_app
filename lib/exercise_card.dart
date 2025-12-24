import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/exercise_detail_view.dart';
import 'package:gym_app/models.dart';

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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              spreadRadius: 1,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 0,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: GestureDetector(
          onLongPress: widget.onLongPress,
          child: OpenContainer(
            tappable: false,
            // Use surface color to match the container background
            closedColor: Colors.transparent,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            closedElevation: 0.0,
            transitionDuration: const Duration(milliseconds: 300),
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
                onTapDown: (_) {
                  _ticker = _controller.forward();
                },
                onTapUp: (_) {
                  _ticker?.whenCompleteOrCancel(() {
                    if (mounted) {
                      _controller.reverse();
                    }
                  });
                },
                onTapCancel: () {
                  _controller.reverse();
                },
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap();
                  Future.delayed(const Duration(milliseconds: 100), action);
                },
                child: AspectRatio(
                  aspectRatio: 2.2 / 1, // Slightly wider for a more cinematic look
                  child: Container(
                     decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Image with gradient overlay
                        widget.exercise.hasLocalImage && widget.exercise.imageUrl != null
                          ? Image.asset(
                              widget.exercise.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: placeHolderImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[900]),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                        // Gradient Overlay for text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                        // Text Content
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              widget.exercise.name,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),
                        ),
                        // Decoration/Icon at top right (optional, maybe type icon?)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.fitness_center, // Placeholder icon
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
