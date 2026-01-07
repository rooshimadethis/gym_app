import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gym_app/stopwatch_task_handler.dart';

class StopwatchModal extends StatefulWidget {
  const StopwatchModal({super.key});

  @override
  State<StopwatchModal> createState() => _StopwatchModalState();
}

class _StopwatchModalState extends State<StopwatchModal> {
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
      FlutterForegroundTask.sendDataToTask({
        'elapsedMilliseconds': _stopwatch.elapsedMilliseconds,
      });
    });

    _startForegroundService();
    FlutterForegroundTask.sendDataToTask({
      'elapsedMilliseconds': _stopwatch.elapsedMilliseconds,
    });
  }

  Future<void> _startForegroundService() async {
    await FlutterForegroundTask.startService(
      serviceId: 123, // Unique ID for your service
      notificationTitle: 'Rest Timer',
      notificationText:
          'Elapsed: ${_formatTime(_stopwatch.elapsedMilliseconds)}',
      callback: startStopwatchCallback,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    FlutterForegroundTask.stopService();
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
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'RESTING',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: (_stopwatch.elapsedMilliseconds % 60000) / 60000,
                      strokeWidth: 8,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Colors.white10,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    _formatTime(_stopwatch.elapsedMilliseconds),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'FINISH REST',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
