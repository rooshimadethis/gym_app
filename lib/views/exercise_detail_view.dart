import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/models/models.dart';
import 'package:gym_app/services/rest_timer_manager.dart';
import 'package:gym_app/widgets/next_exercise_modal.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import 'package:gym_app/database/database.dart';
import 'package:gym_app/main.dart'; // to access global 'db'
import 'package:gym_app/widgets/fatigue_check_in_modal.dart';
import 'package:gym_app/services/workout_session_manager.dart';
import 'package:gym_app/logic/suggestion_engine.dart';
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

class _ExerciseDetailViewState extends State<ExerciseDetailView>
    with WidgetsBindingObserver {
  int _lastFocusedSet = 0;
  int? _fatigueScore;

  List<HistoryEntry> _history = [];
  Suggestion? _suggestion;

  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;
  late List<FocusNode> _weightFocusNodes;
  late List<FocusNode> _repsFocusNodes;
  late List<GlobalKey> _setKeys;

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
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _loadHistory();
    _initializeControllersAndFocusNodes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (WorkoutSessionManager.instance.isWorkoutActive &&
          _fatigueScore == null) {
        _triggerFatigueCheckIn();
      }
    });
  }

  @override
  void didChangeMetrics() {
    // If keyboard height changes and we have a focused set, ensure it's centered
    if (View.of(context).viewInsets.bottom > 0) {
      _scrollToSet(_lastFocusedSet, delayMs: 100);
    }
  }

  Future<void> _triggerFatigueCheckIn() async {
    final score = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FatigueCheckInModal(),
    );
    if (!mounted) return;

    setState(() {
      _fatigueScore = score ?? 0;
    });
    _generateSuggestion(); // Regenerate based on actual fatigue check-in
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _warmupSetEnabled = prefs.getBool('warmup_set_enabled') ?? false;
    });
  }

  Future<void> _loadHistory() async {
    final history = await db.getHistoryForExercise(
      widget.exercise.name,
      limit: 40, // Fetch more to ensure we cover multiple past sessions
    );
    if (mounted) {
      setState(() {
        _history = history;
      });
      _generateSuggestion();
    }
  }

  Future<void> _generateSuggestion() async {
    final sessionManager = WorkoutSessionManager.instance;
    int currentPosition = 1; // Default

    if (sessionManager.isWorkoutActive &&
        sessionManager.currentSessionId != null) {
      currentPosition = await db.getExerciseSessionPosition(
        sessionManager.currentSessionId!,
        widget.exercise.name,
      );
    }

    final suggestion = SuggestionEngine.generateSuggestion(
      history: _history,
      currentPosition: currentPosition,
      currentFatigueCheckIn: _fatigueScore ?? 0,
      currentSessionId: sessionManager.currentSessionId,
    );

    if (mounted) {
      setState(() {
        _suggestion = suggestion;
      });
    }
  }

  void _scrollToSet(int index, {int delayMs = 500}) {
    // Small delay to allow keyboard animation to finish/progress
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      if (index < 0 || index >= _setKeys.length) return;
      final key = _setKeys[index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.5, // Target center of the viewport
        );
      }
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
    _setKeys = List.generate(sets.length, (i) => GlobalKey());

    for (int i = 0; i < sets.length; i++) {
      _weightFocusNodes[i].addListener(() {
        if (_weightFocusNodes[i].hasFocus) {
          setState(() => _lastFocusedSet = i);
          _scrollToSet(i);
        }
      });
      _repsFocusNodes[i].addListener(() {
        if (_repsFocusNodes[i].hasFocus) {
          setState(() => _lastFocusedSet = i);
          _scrollToSet(i);
        }
      });
    }
  }

  List<HistoryEntry> _getRecentSessions() {
    final sessions = <HistoryEntry>[];
    final seen = <String>{};
    for (var h in _history) {
      if (!seen.contains(h.sessionId)) {
        sessions.add(h);
        seen.add(h.sessionId);
      }
      if (sessions.length >= 3) break;
    }
    return sessions;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      _setKeys.add(GlobalKey());

      final newIndex = widget.exercise.sets.length - 1;
      _weightFocusNodes[newIndex].addListener(() {
        if (_weightFocusNodes[newIndex].hasFocus) {
          setState(() => _lastFocusedSet = newIndex);
          _scrollToSet(newIndex);
        }
      });
      _repsFocusNodes[newIndex].addListener(() {
        if (_repsFocusNodes[newIndex].hasFocus) {
          setState(() => _lastFocusedSet = newIndex);
          _scrollToSet(newIndex);
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
        _setKeys.removeLast();
        if (_lastFocusedSet >= widget.exercise.sets.length) {
          _lastFocusedSet = widget.exercise.sets.length - 1;
        }
      });
    }
  }

  Future<void> _logSet({bool finish = false}) async {
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

    if (!finish && _lastFocusedSet < widget.exercise.sets.length - 1) {
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
    await _logHistory(
      double.tryParse(weight) ?? 0,
      int.tryParse(_repsControllers[_lastFocusedSet].text) ?? 0,
    );

    // Refresh history so the "Last:" widget and Suggestion Engine update
    await _loadHistory();

    if (!mounted) return;

    if (finish) {
      widget.onExerciseCompleted();
      Navigator.pop(context);
      return;
    }

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

    RestTimerManager.instance.start();

    // Show next exercise modal pointing to first exercise immediately
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

    RestTimerManager.instance.start();
  }

  Future<void> _logHistory(double weight, int reps) async {
    final sessionManager = WorkoutSessionManager.instance;
    final sessionId =
        sessionManager.currentSessionId ??
        'standalone_${DateTime.now().toIso8601String()}';

    int workoutPosition = 0;
    if (sessionManager.isWorkoutActive &&
        sessionManager.currentSessionId != null) {
      workoutPosition = await db.getExerciseSessionPosition(
        sessionId,
        widget.exercise.name,
      );
    }

    final entry = HistoryEntriesCompanion.insert(
      exerciseName: widget.exercise.name,
      weight: weight,
      reps: reps,
      isWarmup: drift.Value(_warmupSetEnabled && _lastFocusedSet == 0),
      timestamp: DateTime.now(),
      workoutPosition: workoutPosition,
      fatigueScore: _fatigueScore ?? 0,
      sessionId: sessionId,
    );
    await db.addHistoryEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    final placeHolderImageUrl =
        'https://placehold.co/400x200.png?text=${Uri.encodeComponent(widget.exercise.name)}';
    final isLastSetFocused = _lastFocusedSet == widget.exercise.sets.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 170,
                pinned: true,
                stretch: true,
                backgroundColor: const Color(0xFF0A0A0A),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.exercise.hasLocalImage &&
                              widget.exercise.imageUrl != null
                          ? Image.asset(
                              widget.exercise.imageUrl!,
                              fit: BoxFit.contain,
                            )
                          : CachedNetworkImage(
                              imageUrl: placeHolderImageUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0A0A0A).withValues(alpha: 0.0),
                              const Color(0xFF0A0A0A).withValues(alpha: 0.2),
                              const Color(0xFF0A0A0A).withValues(alpha: 0.7),
                              const Color(0xFF0A0A0A),
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 16,
                        child: Text(
                          widget.exercise.name,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 0.95,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    child: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _saveData();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_suggestion != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'RECOMMENDED',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_suggestion!.weightChange != 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (_suggestion!.weightChange! > 0
                                                    ? Colors.green
                                                    : Colors.orange)
                                                .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _suggestion!.weightChange! > 0
                                            ? '+${_suggestion!.weightChange}'
                                            : '${_suggestion!.weightChange}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: _suggestion!.weightChange! > 0
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_suggestion!.weight}'.replaceAll(
                                      RegExp(r'\.0$'),
                                      '',
                                    ),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'lbs',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      '×',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${_suggestion!.reps}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _suggestion!.reasoning.replaceAll(
                                    RegExp(r'\.0'),
                                    '',
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer
                                        .withValues(alpha: 0.9),
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_history.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiary.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary
                                        .withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'RECENT HISTORY',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary
                                          .withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: _getRecentSessions().asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    final h = entry.value;
                                    final weightStr = h.weight
                                        .toStringAsFixed(1)
                                        .replaceAll(RegExp(r'\.0$'), '');
                                    final date = h.timestamp;
                                    final months = [
                                      'Jan',
                                      'Feb',
                                      'Mar',
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                      'Oct',
                                      'Nov',
                                      'Dec',
                                    ];
                                    final dateStr =
                                        '${months[date.month - 1]} ${date.day}';
                                    final label = index == 0
                                        ? 'LATEST'
                                        : (index == 1
                                              ? 'PREV'
                                              : (index == 2
                                                    ? '3RD'
                                                    : '${index + 1}TH'));

                                    return Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: index == 0 ? 0.08 : 0.04,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: index == 0 ? 0.15 : 0.05,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$label • ${dateStr.toUpperCase()}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'StackSansText',
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: weightStr,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 22,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' lbs ',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '× ${h.reps}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 220),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final isWarmupSet = _warmupSetEnabled && index == 0;
                    final isCurrentSet = index == _lastFocusedSet;
                    return Padding(
                      key: _setKeys[index],
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCurrentSet
                              ? (isWarmupSet
                                    ? Colors.orange.withValues(alpha: 0.2)
                                    : Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.15))
                              : (isWarmupSet
                                    ? Colors.orange.withValues(alpha: 0.1)
                                    : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isCurrentSet
                                ? (isWarmupSet
                                      ? Colors.orange.withValues(alpha: 0.6)
                                      : Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.5))
                                : (isWarmupSet
                                      ? Colors.orange.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.05)),
                            width: isCurrentSet ? 2 : 1,
                          ),
                          boxShadow: isCurrentSet
                              ? [
                                  BoxShadow(
                                    color:
                                        (isWarmupSet
                                                ? Colors.orange
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary)
                                            .withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isWarmupSet
                                    ? Colors.orange
                                    : Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                isWarmupSet
                                    ? 'W'
                                    : '${index + (_warmupSetEnabled ? 0 : 1)}',
                                style: TextStyle(
                                  color: isWarmupSet
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'WEIGHT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  TextField(
                                    controller: _weightControllers[index],
                                    focusNode: _weightFocusNodes[index],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: '0',
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
                                    onSubmitted: (_) => FocusScope.of(
                                      context,
                                    ).requestFocus(_repsFocusNodes[index]),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              '×',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'REPS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  TextField(
                                    controller: _repsControllers[index],
                                    focusNode: _repsFocusNodes[index],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: '0',
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    onSubmitted: (_) {
                                      HapticFeedback.mediumImpact();
                                      _logSet(
                                        finish:
                                            index ==
                                            widget.exercise.sets.length - 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: widget.exercise.sets.length),
                ),
              ),
            ],
          ),
          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0A0A).withValues(alpha: 0.0),
                    const Color(0xFF0A0A0A),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _removeSet,
                          icon: const Icon(Icons.remove, size: 18),
                          label: const Text('REMOVE SET'),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF2C2C2C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _addSet,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('ADD SET'),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF3B562D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();

                        final sessionManager = WorkoutSessionManager.instance;

                        // If no workout is active, start one first
                        if (!sessionManager.isWorkoutActive) {
                          // Capture context-dependent values before async gap
                          final messenger = ScaffoldMessenger.of(context);
                          final primaryColor = Theme.of(
                            context,
                          ).colorScheme.primary;

                          await sessionManager.startWorkout();
                          if (!mounted) return;

                          // Show a brief confirmation
                          messenger.showSnackBar(
                            SnackBar(
                              content: const Text('Workout started! 💪'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: primaryColor,
                            ),
                          );

                          // Regenerate suggestion now that workout is active
                          await _generateSuggestion();
                          return;
                        }

                        // Normal flow when workout is active
                        _logSet(finish: isLastSetFocused);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: ListenableBuilder(
                        listenable: WorkoutSessionManager.instance,
                        builder: (context, _) {
                          final sessionManager = WorkoutSessionManager.instance;

                          if (!sessionManager.isWorkoutActive) {
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'START WORKOUT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            );
                          }

                          return Text(
                            isLastSetFocused ? 'FINISH EXERCISE' : 'LOG SET',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
