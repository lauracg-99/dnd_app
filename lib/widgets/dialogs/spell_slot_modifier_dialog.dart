import 'package:flutter/material.dart';

typedef UpdateSpellSlotCallback =
    void Function(int level, String type, int value);
typedef GetMaxSlotsCallback = int Function(int level);

class SpellSlotModifierDialog extends StatefulWidget {
  final int level;
  final String type; // 'slots' or 'used'
  final int initialValue;
  final UpdateSpellSlotCallback onUpdate;
  final GetMaxSlotsCallback getMaxSlots;

  const SpellSlotModifierDialog({
    Key? key,
    required this.level,
    required this.type,
    required this.initialValue,
    required this.onUpdate,
    required this.getMaxSlots,
  }) : super(key: key);

  @override
  State<SpellSlotModifierDialog> createState() =>
      _SpellSlotModifierDialogState();
}

class _SpellSlotModifierDialogState extends State<SpellSlotModifierDialog> {
  late int currentValue;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
    textController = TextEditingController(text: currentValue.toString());
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _applyNewValue(int newValue) {
    setState(() {
      currentValue = newValue;
      textController.text = newValue.toString();
    });
    widget.onUpdate(widget.level, widget.type, newValue);
  }

  @override
  Widget build(BuildContext context) {
    final isSlots = widget.type == 'slots';
    return AlertDialog(
      title: Text('Modify ${isSlots ? 'Total Slots' : 'Used Slots'}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSlots
                ? 'Enter the total number of spell slots available for Level ${widget.level}'
                : 'Enter the number of spell slots currently used for Level ${widget.level}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final newValue =
                      isSlots
                          ? (currentValue - 1).clamp(0, 99)
                          : (currentValue - 1).clamp(
                            0,
                            widget.getMaxSlots(widget.level),
                          );
                  _applyNewValue(newValue);
                },
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: textController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    final newValue = int.tryParse(value) ?? 0;
                    if (isSlots) {
                      _applyNewValue(newValue.clamp(0, 99));
                    } else {
                      _applyNewValue(
                        newValue.clamp(0, widget.getMaxSlots(widget.level)),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final maxValue =
                      isSlots ? 99 : widget.getMaxSlots(widget.level);
                  final newValue = (currentValue + 1).clamp(0, maxValue);
                  _applyNewValue(newValue);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const Text(
            'Quick Actions:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                isSlots
                    ? [
                      ElevatedButton(
                        onPressed: () => _applyNewValue(4),
                        child: const Text('Set 4'),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyNewValue(6),
                        child: const Text('Set 6'),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyNewValue(9),
                        child: const Text('Set 9'),
                      ),
                    ]
                    : [
                      ElevatedButton(
                        onPressed: () => _applyNewValue(0),
                        child: const Text('Clear All'),
                      ),
                      ElevatedButton(
                        onPressed:
                            () => _applyNewValue(
                              widget.getMaxSlots(widget.level),
                            ),
                        child: const Text('Use All'),
                      ),
                      ElevatedButton(
                        onPressed:
                            () => _applyNewValue(
                              widget.getMaxSlots(widget.level) ~/ 2,
                            ),
                        child: const Text('Half Used'),
                      ),
                    ],
          ),
          const SizedBox(height: 8),
          Text(
            isSlots
                ? 'Range: 0-99 slots'
                : 'Range: 0-${widget.getMaxSlots(widget.level)} slots',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
