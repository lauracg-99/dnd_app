import 'package:flutter/material.dart';

typedef MaxPreparedSaveCallback = void Function(int newMax);

class MaxPreparedDialog extends StatefulWidget {
  final int initialMax;
  final int calculatedMax;
  final int currentPreparedCount;
  final String className;
  final int level;
  final MaxPreparedSaveCallback onSave;

  const MaxPreparedDialog({
    super.key,
    required this.initialMax,
    required this.calculatedMax,
    required this.currentPreparedCount,
    required this.className,
    required this.level,
    required this.onSave,
  });

  @override
  State<MaxPreparedDialog> createState() => _MaxPreparedDialogState();
}

class _MaxPreparedDialogState extends State<MaxPreparedDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMax.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final newMax = int.tryParse(_controller.text);
    if (newMax == null || newMax < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    widget.onSave(newMax);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modify Maximum Prepared Spells'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter the maximum number of spells this character can prepare:',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Maximum Prepared Spells',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calculated maximum: ${widget.calculatedMax}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Currently prepared: ${widget.currentPreparedCount}/${widget.initialMax}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on ${widget.className} level ${widget.level}.',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
