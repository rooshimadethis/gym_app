import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/models.dart';
import 'package:gym_app/stopwatch_modal.dart';

class ExerciseDetailView extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailView({super.key, required this.exercise});

  @override
  State<ExerciseDetailView> createState() => _ExerciseDetailViewState();
}

class _ExerciseDetailViewState extends State<ExerciseDetailView> {
  int _lastFocusedSet = 0;

  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;
  late List<FocusNode> _weightFocusNodes;
  late List<FocusNode> _repsFocusNodes;

  @override
  void initState() {
    super.initState();
    _initializeControllersAndFocusNodes();
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

      _weightControllers[_lastFocusedSet + 1].text = weight;
      _repsControllers[_lastFocusedSet + 1].text = reps;

      FocusScope.of(context).requestFocus(_repsFocusNodes[_lastFocusedSet + 1]);
    }

    // Show the stopwatch modal after logging the set
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const StopwatchModal();
      },
    );
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Hero(
                    tag: '${widget.exercise.name}_image_hero',
                    child:
                        widget.exercise.hasLocalImage &&
                            widget.exercise.imageUrl != null
                        ? Image.asset(
                            widget.exercise.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: placeHolderImageUrl,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Hero(
                      tag: '${widget.exercise.name}_text_hero',
                      child: Text(
                        widget.exercise.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap:
                        true, // Important: make ListView take only needed space
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable its own scrolling
                    itemCount: widget.exercise.sets.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                '${index + 1}.',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _weightControllers[index],
                                focusNode: _weightFocusNodes[index],
                                decoration: InputDecoration(
                                  labelText: 'Weight',
                                  border: OutlineInputBorder(),
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
                                  LengthLimitingTextInputFormatter(3),
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
                                  border: OutlineInputBorder(),
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
                                    Navigator.pop(context); // Finish exercise
                                  } else {
                                    _logSet(); // Log set and move to next
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
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
