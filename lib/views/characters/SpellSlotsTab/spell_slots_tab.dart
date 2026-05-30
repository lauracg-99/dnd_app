import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/viewmodels/characters_viewmodel.dart';
import 'package:dnd_app/widgets/summary_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpellSlotsTab extends StatelessWidget {
  final CharacterSpellSlots spellSlots;
  final VoidCallback onRestoreSlots;
  final void Function(int level, String type, int value)
  onShowSlotModifierDialog;
  final void Function(int level, int index) onToggleSpellSlot;

  const SpellSlotsTab({
    super.key,
    required this.spellSlots,
    required this.onRestoreSlots,
    required this.onShowSlotModifierDialog,
    required this.onToggleSpellSlot,
  });

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
              const Text(
                'Spell Slots',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: onRestoreSlots,
                icon: const Icon(Icons.refresh),
                label: const Text('Restore all slots'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spell Slot Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Consumer<CharactersViewModel>(
                    builder: (context, viewModel, child) {
                      final totalSlots =
                          spellSlots.level1Slots +
                          spellSlots.level2Slots +
                          spellSlots.level3Slots +
                          spellSlots.level4Slots +
                          spellSlots.level5Slots +
                          spellSlots.level6Slots +
                          spellSlots.level7Slots +
                          spellSlots.level8Slots +
                          spellSlots.level9Slots;
                      final totalUsed =
                          spellSlots.level1Used +
                          spellSlots.level2Used +
                          spellSlots.level3Used +
                          spellSlots.level4Used +
                          spellSlots.level5Used +
                          spellSlots.level6Used +
                          spellSlots.level7Used +
                          spellSlots.level8Used +
                          spellSlots.level9Used;
                      final availableSlots = totalSlots - totalUsed;

                      return Column(
                        children: [
                          SummaryRow(
                            label: 'Total Slots',
                            value: totalSlots.toString(),
                          ),
                          SummaryRow(
                            label: 'Used Slots',
                            value: totalUsed.toString(),
                          ),
                          SummaryRow(
                            label: 'Available Slots',
                            value: availableSlots.toString(),
                            valueColor:
                                availableSlots > 0 ? Colors.green : Colors.red,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...[
            for (int level = 1; level <= 9; level++)
              _buildSpellSlotField('Level $level', level),
          ],
          const SizedBox(height: 32),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSpellSlotField(String label, int level) {
    int slots = 0;
    int used = 0;
    switch (level) {
      case 1:
        slots = spellSlots.level1Slots;
        used = spellSlots.level1Used;
        break;
      case 2:
        slots = spellSlots.level2Slots;
        used = spellSlots.level2Used;
        break;
      case 3:
        slots = spellSlots.level3Slots;
        used = spellSlots.level3Used;
        break;
      case 4:
        slots = spellSlots.level4Slots;
        used = spellSlots.level4Used;
        break;
      case 5:
        slots = spellSlots.level5Slots;
        used = spellSlots.level5Used;
        break;
      case 6:
        slots = spellSlots.level6Slots;
        used = spellSlots.level6Used;
        break;
      case 7:
        slots = spellSlots.level7Slots;
        used = spellSlots.level7Used;
        break;
      case 8:
        slots = spellSlots.level8Slots;
        used = spellSlots.level8Used;
        break;
      case 9:
        slots = spellSlots.level9Slots;
        used = spellSlots.level9Used;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label),
                Row(
                  children: [
                    const Text('Slots: ', style: TextStyle(color: Colors.grey)),
                    InkWell(
                      onTap:
                          () => onShowSlotModifierDialog(level, 'slots', slots),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
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
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                          onTap: () => onToggleSpellSlot(level, index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUsed ? Colors.red : Colors.grey.shade300,
                              border: Border.all(
                                color:
                                    isUsed
                                        ? Colors.red.shade300
                                        : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child:
                                isUsed
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        used > 0
                            ? () => onToggleSpellSlot(level, used - 1)
                            : null,
                    icon: const Icon(Icons.arrow_left),
                    iconSize: 28,
                    color: used > 0 ? Colors.blue : Colors.grey,
                    tooltip: 'Decrease used slots',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: (slots - used) == 0 ? Colors.red : Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color:
                          (slots - used) == 0
                              ? Colors.red.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${slots - used}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                (slots - used) == 0 ? Colors.red : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed:
                        used < slots
                            ? () => onToggleSpellSlot(level, used)
                            : null,
                    icon: const Icon(Icons.arrow_right),
                    iconSize: 28,
                    color: used < slots ? Colors.blue : Colors.grey,
                    tooltip: 'Increase used slots',
                  ),
                ],
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
                        'No spell slots available',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Increase spell slots to use this feature',
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
}
