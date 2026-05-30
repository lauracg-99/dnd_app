import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttacksTab extends StatelessWidget {
  final List<CharacterAttack> attacks;
  final VoidCallback onAddAttack;
  final void Function(int index) onRemoveAttack;

  const AttacksTab({
    super.key,
    required this.attacks,
    required this.onAddAttack,
    required this.onRemoveAttack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionButton.primary(
              context: context,
              onPressed: onAddAttack,
              label: 'Add Attack',
              icon: Symbols.add_circle,
            ),
          ),
          const SizedBox(height: 6),
          if (attacks.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 205, 205, 205),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'No weapons added yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your character\'s weapons and attacks to track combat abilities',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ...attacks.asMap().entries.map((entry) {
              final index = entry.key;
              final attack = entry.value;
              return Card(
                child: ListTile(
                  title: Text(attack.name),
                  subtitle: Text(
                    'Attack bonus: ${attack.attackBonus} | Damage: ${attack.damage} | Type: ${attack.damageType}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onRemoveAttack(index),
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
