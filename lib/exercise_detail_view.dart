import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseDetailView extends StatefulWidget {
  final String exerciseName;

  const ExerciseDetailView({
    super.key,
    required this.exerciseName,
  });

  @override
  State<ExerciseDetailView> createState() => _ExerciseDetailViewState();
}

class _ExerciseDetailViewState extends State<ExerciseDetailView> {
  int _sets = 3;
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
    _weightControllers = List.generate(_sets, (i) => TextEditingController());
    _repsControllers = List.generate(_sets, (i) => TextEditingController());
    _weightFocusNodes = List.generate(_sets, (i) => FocusNode());
    _repsFocusNodes = List.generate(_sets, (i) => FocusNode());

    for (int i = 0; i < _sets; i++) {
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
    for (int i = 0; i < _sets; i++) {
      _weightControllers[i].dispose();
      _repsControllers[i].dispose();
      _weightFocusNodes[i].dispose();
      _repsFocusNodes[i].dispose();
    }
    super.dispose();
  }

  void _addSet() {
    setState(() {
      _sets++;
      _weightControllers.add(TextEditingController());
      _repsControllers.add(TextEditingController());
      _weightFocusNodes.add(FocusNode());
      _repsFocusNodes.add(FocusNode());

      final newIndex = _sets - 1;
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
    if (_sets > 1) {
      setState(() {
        _sets--;
        _weightControllers.removeLast().dispose();
        _repsControllers.removeLast().dispose();
        _weightFocusNodes.removeLast().dispose();
        _repsFocusNodes.removeLast().dispose();
        if (_lastFocusedSet >= _sets) {
          _lastFocusedSet = _sets - 1;
        }
      });
    }
  }

  void _logSet() {
    if (_lastFocusedSet < _sets - 1) {
      final weight = _weightControllers[_lastFocusedSet].text;
      final reps = _repsControllers[_lastFocusedSet].text;

      _weightControllers[_lastFocusedSet + 1].text = weight;
      _repsControllers[_lastFocusedSet + 1].text = reps;

      FocusScope.of(context).requestFocus(_repsFocusNodes[_lastFocusedSet + 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'https://placehold.co/400x200.png?text=${widget.exerciseName}';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: Column(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.exerciseName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sets,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
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
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              onPressed: _logSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Log Set'),
            ),
          ),
        ],
      ),
    );
  }
}
