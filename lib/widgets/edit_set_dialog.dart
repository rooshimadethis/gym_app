import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/logic/exercise_progress.dart';

Future<({double weight, int reps})?> showEditSetDialog(
  BuildContext context, {
  required double weight,
  required int reps,
}) {
  return showDialog<({double weight, int reps})>(
    context: context,
    builder: (_) => _EditSetDialog(weight: weight, reps: reps),
  );
}

class _EditSetDialog extends StatefulWidget {
  const _EditSetDialog({required this.weight, required this.reps});
  final double weight;
  final int reps;
  @override
  State<_EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<_EditSetDialog> {
  late final _weight = TextEditingController(text: formatWeight(widget.weight));
  late final _reps = TextEditingController(text: '${widget.reps}');
  String? _error;
  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  void _save() {
    final weight = double.tryParse(_weight.text);
    final reps = int.tryParse(_reps.text);
    if (weight == null ||
        !weight.isFinite ||
        weight < 0 ||
        reps == null ||
        reps < 0 ||
        reps > 999) {
      setState(() => _error = 'Enter a valid weight and rep count.');
      return;
    }
    Navigator.pop(context, (weight: weight, reps: reps));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Correct set'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Updates your history and progress. XP stays unchanged.'),
        const SizedBox(height: 16),
        TextField(
          controller: _weight,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Weight (lbs)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
        ),
        TextField(
          controller: _reps,
          decoration: const InputDecoration(labelText: 'Reps'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => _save(),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );
}
