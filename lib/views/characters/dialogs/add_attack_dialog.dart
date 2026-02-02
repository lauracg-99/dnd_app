import 'package:flutter/material.dart';
import '../../../models/character_model.dart';

/// Dialog for adding a new attack to a character
/// 
/// Allows entering:
/// - Attack name
/// - Attack bonus
/// - Damage
/// - Damage type
class AddAttackDialog extends StatefulWidget {
  final Function(CharacterAttack) onAttackAdded;

  const AddAttackDialog({
    super.key,
    required this.onAttackAdded,
  });

  @override
  State<AddAttackDialog> createState() => _AddAttackDialogState();
}

class _AddAttackDialogState extends State<AddAttackDialog> {
  final _nameController = TextEditingController();
  final _bonusController = TextEditingController();
  final _damageController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bonusController.dispose();
    _damageController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Attack'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Attack Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bonusController,
              decoration: const InputDecoration(
                labelText: 'Attack Bonus',
                border: OutlineInputBorder(),
                hintText: 'e.g., +5',
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _damageController,
                    decoration: const InputDecoration(
                      labelText: 'Damage',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 1d8+3',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Slashing',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleAdd,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _handleAdd() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an attack name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final attack = CharacterAttack(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      attackBonus: _bonusController.text.trim(),
      damage: _damageController.text.trim(),
      damageType: _typeController.text.trim(),
    );

    widget.onAttackAdded(attack);
    Navigator.pop(context);
  }
}
