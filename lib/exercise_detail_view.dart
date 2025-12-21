import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/models.dart';
import 'package:gym_app/stopwatch_modal.dart';
import 'package:gym_app/next_exercise_modal.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SupersetInfo {
  final bool isLastInSuperset;
  final List<Exercise> nextExercises;
  final int totalExercises;
  final int currentPosition;

  SupersetInfo({
    required this.isLastInSuperset,
    required this.nextExercises,
    required this.totalExercises,
    required this.currentPosition,
  });
}

class ExerciseDetailView extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onExerciseCompleted;
  final VoidCallback? onSupersetProgress;
  final SupersetInfo Function(Exercise)? getSupersetInfo;

  const ExerciseDetailView({
    super.key,
    required this.exercise,
    required this.onExerciseCompleted,
    this.onSupersetProgress,
    this.getSupersetInfo,
  });

  @override
  State<ExerciseDetailView> createState() => _ExerciseDetailViewState();
}

class _ExerciseDetailViewState extends State<ExerciseDetailView> {
  int _lastFocusedSet = 0;

  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;
  late List<FocusNode> _weightFocusNodes;
  late List<FocusNode> _repsFocusNodes;

  Future<void> _requestPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      if (!await FlutterForegroundTask.canScheduleExactAlarms) {
        await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      }
    }
  }

  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  bool _warmupSetEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeControllersAndFocusNodes();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _warmupSetEnabled = prefs.getBool('warmup_set_enabled') ?? false;
    });
  }

  void _initializeControllersAndFocusNodes() {
    final sets = widget.exercise.sets;
    _weightControllers = List.generate(
      sets.length,
      (i) => TextEditingController(text: sets[i].weight),
    );
    _repsControllers = List.generate(
      sets.length,
      (i) => TextEditingController(text: sets[i].reps),
    );
    _weightFocusNodes = List.generate(sets.length, (i) => FocusNode());
    _repsFocusNodes = List.generate(sets.length, (i) => FocusNode());

    for (int i = 0; i < sets.length; i++) {
      _weightFocusNodes[i].addListener(() {
        if (_weightFocusNodes[i].hasFocus) {
          setState(() {
            _lastFocusedSet = i;
          });
        }
      });
      _repsFocusNodes[i].addListener(() {
        if (_repsFocusNodes[i].hasFocus) {
          setState(() {
            _lastFocusedSet = i;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _saveData();
    for (int i = 0; i < _weightControllers.length; i++) {
      _weightControllers[i].dispose();
      _repsControllers[i].dispose();
      _weightFocusNodes[i].dispose();
      _repsFocusNodes[i].dispose();
    }
    super.dispose();
  }

  void _saveData() {
    for (int i = 0; i < widget.exercise.sets.length; i++) {
      widget.exercise.sets[i].weight = _weightControllers[i].text;
      widget.exercise.sets[i].reps = _repsControllers[i].text;
    }
  }

  void _addSet() {
    HapticFeedback.lightImpact();
    setState(() {
      widget.exercise.sets.add(SetData());
      _weightControllers.add(TextEditingController());
      _repsControllers.add(TextEditingController());
      _weightFocusNodes.add(FocusNode());
      _repsFocusNodes.add(FocusNode());

      final newIndex = widget.exercise.sets.length - 1;
      _weightFocusNodes[newIndex].addListener(() {
        if (_weightFocusNodes[newIndex].hasFocus) {
          setState(() {
            _lastFocusedSet = newIndex;
          });
        }
      });
      _repsFocusNodes[newIndex].addListener(() {
        if (_repsFocusNodes[newIndex].hasFocus) {
          setState(() {
            _lastFocusedSet = newIndex;
          });
        }
      });
    });
  }

  void _removeSet() {
    HapticFeedback.lightImpact();
    if (widget.exercise.sets.length > 1) {
      setState(() {
        widget.exercise.sets.removeLast();
        _weightControllers.removeLast().dispose();
        _repsControllers.removeLast().dispose();
        _weightFocusNodes.removeLast().dispose();
        _repsFocusNodes.removeLast().dispose();
        if (_lastFocusedSet >= widget.exercise.sets.length) {
          _lastFocusedSet = widget.exercise.sets.length - 1;
        }
      });
    }
  }

  void _logSet() {
    final weight = _weightControllers[_lastFocusedSet].text;
    if (weight.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a weight before logging the set.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_lastFocusedSet < widget.exercise.sets.length - 1) {
      final reps = _repsControllers[_lastFocusedSet].text;

      // Only auto-fill if it's NOT a warmup set (first set with warmup enabled)
      if (!(_warmupSetEnabled && _lastFocusedSet == 0)) {
        _weightControllers[_lastFocusedSet + 1].text = weight;
        _repsControllers[_lastFocusedSet + 1].text = reps;
      }

      FocusScope.of(context).requestFocus(_repsFocusNodes[_lastFocusedSet + 1]);
    }

    // Save changes (including prefill) to the model immediately
    _saveData();

    // Check if exercise is part of superset
    if (widget.exercise.isPartOfSuperset && widget.getSupersetInfo != null) {
      _handleSupersetLogSet();
    } else {
      _handleStandardLogSet();
    }
  }

  void _handleSupersetLogSet() {
    final supersetInfo = widget.getSupersetInfo!(widget.exercise);

    if (supersetInfo.isLastInSuperset) {
      // Last exercise in superset -> Show rest timer, THEN "Next Exercise" back to first
      _showRestThenCycleSuperset(supersetInfo);
    } else {
      // Not last exercise -> Show "Next Exercise" modal directly
      _showNextExerciseModal(supersetInfo);
    }
  }

  void _showRestThenCycleSuperset(SupersetInfo info) {
    _requestPermissions();
    _initService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const StopwatchModal(),
    ).then((_) {
      // After rest timer, show next exercise modal pointing to first exercise
      if (!mounted) return;
      showDialog<Exercise>(
        context: context,
        barrierDismissible: false,
        builder: (context) => NextExerciseModal(
          nextExercises: info.nextExercises,
          currentExerciseName: widget.exercise.name,
          currentPosition: info.currentPosition,
          totalExercises: info.totalExercises,
        ),
      ).then((selectedExercise) {
        // NOW call onExerciseCompleted to cycle superset to bottom
        widget.onExerciseCompleted();

        if (mounted && selectedExercise != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailView(
                exercise: selectedExercise,
                onExerciseCompleted: widget.onExerciseCompleted,
                onSupersetProgress: widget.onSupersetProgress,
                getSupersetInfo: widget.getSupersetInfo,
              ),
            ),
          );
        } else if (mounted) {
          Navigator.pop(context);
        }
      });
    });
  }

  void _showNextExerciseModal(SupersetInfo info) {
    showDialog<Exercise>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NextExerciseModal(
        nextExercises: info.nextExercises,
        currentExerciseName: widget.exercise.name,
        currentPosition: info.currentPosition,
        totalExercises: info.totalExercises,
      ),
    ).then((selectedExercise) {
      // Update progress but DON'T call onExerciseCompleted yet
      if (widget.onSupersetProgress != null) {
        widget.onSupersetProgress!();
      }

      if (mounted) {
        if (selectedExercise != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailView(
                exercise: selectedExercise,
                onExerciseCompleted: widget.onExerciseCompleted,
                onSupersetProgress: widget.onSupersetProgress,
                getSupersetInfo: widget.getSupersetInfo,
              ),
            ),
          );
        } else {
          Navigator.pop(context); // Close detail view
        }
      }
    });
  }

  void _handleStandardLogSet() {
    _requestPermissions();
    _initService();

    // Existing behavior for non-superset exercises
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const StopwatchModal();
      },
    ).then((_) => widget.onExerciseCompleted());
  }

  @override
  Widget build(BuildContext context) {
    final placeHolderImageUrl =
        'https://placehold.co/400x200.png?text=${Uri.encodeComponent(widget.exercise.name)}';
    final isLastSetFocused = _lastFocusedSet == widget.exercise.sets.length - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        leading: BackButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _saveData();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      widget.exercise.hasLocalImage &&
                              widget.exercise.imageUrl != null
                          ? Image.asset(
                              widget.exercise.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: placeHolderImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.exercise.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final isWarmupSet = _warmupSetEnabled && index == 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Container(
                        decoration: isWarmupSet
                            ? BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              )
                            : null,
                        padding: isWarmupSet
                            ? const EdgeInsets.all(8.0)
                            : EdgeInsets.zero,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                isWarmupSet
                                    ? 'W.'
                                    : _warmupSetEnabled
                                    ? '$index.'
                                    : '${index + 1}.',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: isWarmupSet ? Colors.orange : null,
                                      fontWeight: isWarmupSet
                                          ? FontWeight.bold
                                          : null,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _weightControllers[index],
                                focusNode: _weightFocusNodes[index],
                                decoration: InputDecoration(
                                  labelText: 'Weight',
                                  border: const OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,1}'),
                                  ),
                                  LengthLimitingTextInputFormatter(5),
                                ],
                                onSubmitted: (_) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_repsFocusNodes[index]);
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'x',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: TextField(
                                controller: _repsControllers[index],
                                focusNode: _repsFocusNodes[index],
                                decoration: InputDecoration(
                                  labelText: 'Reps',
                                  border: const OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                onSubmitted: (_) {
                                  HapticFeedback.mediumImpact();
                                  _saveData(); // Save current data
                                  if (index ==
                                      widget.exercise.sets.length - 1) {
                                    widget.onExerciseCompleted();
                                    Navigator.pop(context); // Finish exercise
                                  } else {
                                    _logSet(); // Log set and move to next
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: widget.exercise.sets.length),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _removeSet,
                  icon: const Icon(Icons.remove),
                  label: const Text('Remove Set'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _addSet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Set'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _saveData();
                if (isLastSetFocused) {
                  widget.onExerciseCompleted();
                  Navigator.pop(context);
                } else {
                  _logSet();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isLastSetFocused ? 'Finish Exercise' : 'Log Set'),
            ),
          ),
        ],
      ),
    );
  }
}
