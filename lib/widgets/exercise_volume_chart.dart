import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/logic/exercise_progress.dart';

/// Sessions arrive newest first; the line reads oldest to newest.
class ExerciseVolumeChart extends StatelessWidget {
  const ExerciseVolumeChart({super.key, required this.sessions});
  final List<ExerciseSessionProgress> sessions;

  @override
  Widget build(BuildContext context) {
    final recent = sessions.take(6).toList();
    final colors = Theme.of(context).colorScheme;
    final latest = recent.isEmpty ? null : recent.first;
    final previous = recent.length < 2 ? null : recent[1];
    final maxVolume = recent.fold<double>(
      0,
      (largest, session) => session.volume > largest ? session.volume : largest,
    );
    final delta = previous == null ? null : latest!.volume - previous.volume;
    final comparison = previous == null
        ? 'Complete another session to compare.'
        : previous.volume == 0
        ? '${formatWeight(delta!)} lb·reps vs previous session'
        : '${delta! > 0 ? '+' : ''}${(delta / previous.volume * 100).toStringAsFixed(1)}% vs previous session';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: .15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WORKING VOLUME',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 6),
          if (latest == null)
            const Text('Complete this exercise to start your volume trend.')
          else ...[
            Text(
              '${formatWeight(latest.volume)} lb·reps',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(comparison, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final session in recent.reversed)
                  Expanded(
                    child: Semantics(
                      label:
                          '${session.date.month}/${session.date.day}/${session.date.year}: ${formatWeight(session.volume)} pound reps',
                      child: ExcludeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatWeight(session.volume),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 72,
              width: double.infinity,
              child: CustomPaint(
                painter: _VolumeLinePainter(
                  volumes: [
                    for (final session in recent.reversed) session.volume,
                  ],
                  maxVolume: maxVolume,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final session in recent.reversed)
                  Expanded(
                    child: ExcludeSemantics(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${session.date.month}/${session.date.day}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Sum of weight × reps · last ${recent.length} sessions',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _VolumeLinePainter extends CustomPainter {
  _VolumeLinePainter({
    required this.volumes,
    required this.maxVolume,
    required this.color,
  });

  final List<double> volumes;
  final double maxVolume;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 6.0;
    final bottom = size.height - inset;
    final plotHeight = size.height - inset * 2;
    final columnWidth = size.width / volumes.length;
    final points = [
      for (var i = 0; i < volumes.length; i++)
        Offset(
          columnWidth * (i + .5),
          bottom - (maxVolume == 0 ? 0 : volumes[i] / maxVolume * plotHeight),
        ),
    ];
    final gridPaint = Paint()
      ..color = color.withValues(alpha: .12)
      ..strokeWidth = 1;
    for (var step = 0; step <= 2; step++) {
      final y = bottom - plotHeight * step / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (points.length > 1) {
      final line = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        line.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        i == points.length - 1 ? 4.5 : 3,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VolumeLinePainter oldDelegate) =>
      !listEquals(volumes, oldDelegate.volumes) ||
      maxVolume != oldDelegate.maxVolume ||
      color != oldDelegate.color;
}
