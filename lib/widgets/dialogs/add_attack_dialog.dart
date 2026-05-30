import 'package:flutter/material.dart';
import '../../views/characters/WeaponsTab/weapon_selection_dialog.dart';
import '../../models/character_model.dart';

class AddAttackDialog extends StatefulWidget {
  const AddAttackDialog({super.key});

  @override
  State<AddAttackDialog> createState() => _AddAttackDialogState();
}

class _AddAttackDialogState extends State<AddAttackDialog> {
  bool _isCustomAttackMode = false;

  // Controllers for custom attack form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _damageController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

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
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isCustomAttackMode = false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            !_isCustomAttackMode
                                ? Colors.blue.shade100
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              !_isCustomAttackMode
                                  ? Colors.blue.shade300
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Choose from existing weapons',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  !_isCustomAttackMode
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isCustomAttackMode = true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _isCustomAttackMode
                                ? Colors.blue.shade100
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _isCustomAttackMode
                                  ? Colors.blue.shade300
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Make a custom weapon',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  _isCustomAttackMode
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isCustomAttackMode) ...[
              const Text(
                'Browse and select from the available weapons list. Attack bonus and damage will be calculated automatically.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Text(
                'Enter custom attack details manually.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Attack Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bonusController,
                decoration: const InputDecoration(
                  labelText: 'Attack Bonus',
                  border: OutlineInputBorder(),
                ),
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
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_isCustomAttackMode) {
              final selectedResults =
                  await showDialog<List<WeaponSelectionResult>>(
                    context: context,
                    builder: (context) => const WeaponSelectionDialog(),
                  );

              if (selectedResults != null && selectedResults.isNotEmpty) {
                Navigator.pop(context, selectedResults);
              }
            } else {
              if (_nameController.text.trim().isNotEmpty) {
                final attack = CharacterAttack(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text.trim(),
                  attackBonus: _bonusController.text.trim(),
                  damage: _damageController.text.trim(),
                  damageType: _typeController.text.trim(),
                );
                Navigator.pop(context, attack);
              }
            }
          },
          child: Text(_isCustomAttackMode ? 'Create Custom' : 'Choose Weapons'),
        ),
      ],
    );
  }
}
