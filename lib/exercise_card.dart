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

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onExerciseCompleted,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Matrix4> _transformAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _transformAnimation = Matrix4Tween(
      begin: Matrix4.identity(),
      end: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(-0.1),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              transform: _transformAnimation.value,
              alignment: FractionalOffset.center,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.3).round()),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: GestureDetector(
              onLongPress: widget.onLongPress,
              child: OpenContainer(
                tappable: false,
                closedColor: Theme.of(context).colorScheme.primary,
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                closedElevation: 0.0,
                transitionDuration: const Duration(milliseconds: 300),
                openBuilder: (context, action) {
                  return ExerciseDetailView(
                    exercise: widget.exercise,
                    onExerciseCompleted: widget.onExerciseCompleted,
                  );
                },
                closedBuilder: (context, action) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onTap();
                      action();
                    },
                    child: AspectRatio(
                      aspectRatio: 2 / 1,
                      child: Card(
                        elevation: 0,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Expanded(
                              child: widget.exercise.hasLocalImage &&
                                      widget.exercise.imageUrl != null
                                  ? Image.asset(
                                      widget.exercise.imageUrl!,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: placeHolderImageUrl,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      placeholder: (context, url) =>
                                          Container(color: Colors.grey[300]),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                widget.exercise.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
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
        ),
      ),
    );
  }
}
