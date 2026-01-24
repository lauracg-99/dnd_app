import 'package:flutter/material.dart';
import '../../../models/character_model.dart';

class CharactersPersonalizedTab extends StatefulWidget {
  final List<CharacterPersonalizedSlot> personalizedSlots;
  final Function(List<CharacterPersonalizedSlot>) onPersonalizedSlotsChanged;
  final Function() onAutoSaveCharacter;
  final String characterName;

  const CharactersPersonalizedTab({
    super.key,
    required this.personalizedSlots,
    required this.onPersonalizedSlotsChanged,
    required this.onAutoSaveCharacter,
    required this.characterName,
  });

  @override
  State<CharactersPersonalizedTab> createState() => _CharactersPersonalizedTabState();
}

class _CharactersPersonalizedTabState extends State<CharactersPersonalizedTab> {
  late List<CharacterPersonalizedSlot> _personalizedSlots;

  @override
  void initState() {
    super.initState();
    _personalizedSlots = List.from(widget.personalizedSlots);
  }

  @override
  void didUpdateWidget(CharactersPersonalizedTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.personalizedSlots != widget.personalizedSlots) {
      _personalizedSlots = List.from(widget.personalizedSlots);
    }
  }

  void _updatePersonalizedSlots(List<CharacterPersonalizedSlot> newSlots) {
    setState(() {
      _personalizedSlots = newSlots;
    });
    widget.onPersonalizedSlotsChanged(_personalizedSlots);
    widget.onAutoSaveCharacter();
  }

  void _reorderPersonalizedSlots(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newSlots = List<CharacterPersonalizedSlot>.from(_personalizedSlots);
    final item = newSlots.removeAt(oldIndex);
    newSlots.insert(newIndex, item);
    _updatePersonalizedSlots(newSlots);
  }

  void _updatePersonalizedSlot(int index, CharacterPersonalizedSlot updatedSlot) {
    final newSlots = List<CharacterPersonalizedSlot>.from(_personalizedSlots);
    newSlots[index] = updatedSlot;
    _updatePersonalizedSlots(newSlots);
  }

  void _showAddPersonalizedSlotDialog() {
    final nameController = TextEditingController();
    final maxSlotsController = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Class Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Slot Name',
                hintText: 'e.g., Superiority Dice, Ki Points',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxSlotsController,
              decoration: const InputDecoration(
                labelText: 'Max Slots',
                hintText: 'e.g., 4',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done, // Show "Done" button on keyboard
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final maxSlots = int.tryParse(maxSlotsController.text) ?? 4;

              if (name.isNotEmpty) {
                final newSlots = List<CharacterPersonalizedSlot>.from(_personalizedSlots);
                newSlots.add(
                  CharacterPersonalizedSlot(
                    name: name,
                    maxSlots: maxSlots,
                    usedSlots: 0,
                    diceType: 'd6', // Default value, not shown in UI
                  ),
                );
                _updatePersonalizedSlots(newSlots);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $name to ${widget.characterName}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _togglePersonalizedSlot(int slotIndex, int dotIndex) {
    final slot = _personalizedSlots[slotIndex];
    if (dotIndex < slot.usedSlots) {
      // Restore the slot
      _updatePersonalizedSlot(
        slotIndex,
        slot.copyWith(usedSlots: slot.usedSlots - 1),
      );
    } else {
      // Use the slot
      _updatePersonalizedSlot(
        slotIndex,
        slot.copyWith(usedSlots: slot.usedSlots + 1),
      );
    }
  }

  void _showPersonalizedSlotModifierDialog(
    int slotIndex,
    String type,
    int currentValue,
  ) {
    final slot = _personalizedSlots[slotIndex];
    final textController = TextEditingController(text: currentValue.toString());
    int localValue = currentValue; // Create a mutable local variable

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modify ${slot.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type == 'slots' ? 'Maximum slots:' : 'Used slots:',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done, // Show "Done" button on keyboard
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: type == 'slots' ? 'Max Slots' : 'Used Slots',
              ),
              onChanged: (value) {
                final newValue = int.tryParse(value) ?? localValue;
                if (type == 'slots') {
                  // Ensure used slots don't exceed new max
                  final newUsedSlots =
                      slot.usedSlots > newValue ? newValue : slot.usedSlots;
                  _updatePersonalizedSlot(
                    slotIndex,
                    slot.copyWith(
                      maxSlots: newValue,
                      usedSlots: newUsedSlots,
                    ),
                  );
                } else {
                  // Ensure used slots don't exceed max slots
                  final clampedValue = newValue.clamp(0, slot.maxSlots);
                  _updatePersonalizedSlot(
                    slotIndex,
                    slot.copyWith(usedSlots: clampedValue),
                  );
                  // Only update localValue if it was actually clamped
                  if (clampedValue != newValue) {
                    localValue = clampedValue;
                    textController.text = clampedValue.toString();
                    return;
                  }
                }
                localValue = newValue; // Update local value
                widget.onAutoSaveCharacter(); // Auto-save on text input
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (type == 'slots') ...[
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(
                        slotIndex,
                        slot.copyWith(maxSlots: 4),
                      );
                      localValue = 4;
                      textController.text = '4';
                      widget.onAutoSaveCharacter();
                    },
                    child: const Text('Set 4'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(
                        slotIndex,
                        slot.copyWith(maxSlots: 6),
                      );
                      localValue = 6;
                      textController.text = '6';
                      widget.onAutoSaveCharacter();
                    },
                    child: const Text('Set 6'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(
                        slotIndex,
                        slot.copyWith(maxSlots: 8),
                      );
                      localValue = 8;
                      textController.text = '8';
                      widget.onAutoSaveCharacter();
                    },
                    child: const Text('Set 8'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(
                        slotIndex,
                        slot.copyWith(usedSlots: 0),
                      );
                      localValue = 0;
                      textController.text = '0';
                      widget.onAutoSaveCharacter();
                    },
                    child: const Text('Clear All'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(
                        slotIndex,
                        slot.copyWith(usedSlots: slot.maxSlots),
                      );
                      localValue = slot.maxSlots;
                      textController.text = slot.maxSlots.toString();
                      widget.onAutoSaveCharacter();
                    },
                    child: const Text('Use All'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final halfSlots = (slot.maxSlots / 2).floor();
                      _updatePersonalizedSlot(
                        slotIndex,
                        slot.copyWith(usedSlots: halfSlots),
                      );
                      localValue = halfSlots;
                      textController.text = halfSlots.toString();
                      widget.onAutoSaveCharacter();
                    },
                    child: const Text('Half Used'),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _restoreAllPersonalizedSlots() {
    final newSlots = _personalizedSlots
        .map((slot) => slot.copyWith(usedSlots: 0))
        .toList();
    _updatePersonalizedSlots(newSlots);

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All class slots have been restored!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPersonalizedSlotField({required Key key, required String label, required int slotIndex}) {
    final slot = _personalizedSlots[slotIndex];
    final slots = slot.maxSlots;
    final used = slot.usedSlots;

    return Card(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.drag_handle,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Slots: ', style: const TextStyle(color: Colors.grey)),
                    InkWell(
                      onTap: () => _showPersonalizedSlotModifierDialog(
                        slotIndex,
                        'slots',
                        slots,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$slots',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () {
                        final newSlots = List<CharacterPersonalizedSlot>.from(_personalizedSlots);
                        newSlots.removeAt(slotIndex);
                        _updatePersonalizedSlots(newSlots);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visual slot dots
            if (slots > 0) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Used: ', style: TextStyle(color: Colors.grey)),
                    ...List.generate(slots, (index) {
                      final isUsed = index < used;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: GestureDetector(
                          onTap: () => _togglePersonalizedSlot(slotIndex, index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUsed ? Colors.red : Colors.grey.shade300,
                              border: Border.all(
                                color: isUsed
                                    ? Colors.red.shade300
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isUsed
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$used of $slots slots used',
                style: TextStyle(
                  color: used == slots ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.block, color: Colors.grey.shade400, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'No slots available',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click the slots number to add slots',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const Text(
                  'Personalized Slots',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _restoreAllPersonalizedSlots,
                icon: const Icon(Icons.refresh),
                label: const Text('Restore all'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Personalized slots list
          if (_personalizedSlots.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.casino, color: Colors.grey.shade400, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No class slots configured',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click the + button to add slot types like Superiority Dice, Ki Points, etc.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _personalizedSlots.length,
              onReorder: _reorderPersonalizedSlots,
              itemBuilder: (context, index) {
                final slot = _personalizedSlots[index];
                return _buildPersonalizedSlotField(
                  key: ValueKey('slot_$index'),
                  label: slot.name,
                  slotIndex: index,
                );
              },
            ),

          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: _showAddPersonalizedSlotDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Personalized Slot'),
          ),
        ],
      ),
    );
  }
}

