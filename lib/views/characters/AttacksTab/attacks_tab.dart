import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'attack_detail_sheet.dart';

class AttacksTab extends StatefulWidget {
  final List<CharacterAttack> attacks;
  final VoidCallback onAddAttack;
  final void Function(int index) onRemoveAttack;
  final void Function(int oldIndex, int newIndex) onReorderAttack;

  const AttacksTab({
    super.key,
    required this.attacks,
    required this.onAddAttack,
    required this.onRemoveAttack,
    required this.onReorderAttack,
  });

  @override
  State<AttacksTab> createState() => _AttacksTabState();
}

class _AttacksTabState extends State<AttacksTab> {
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
              onPressed: widget.onAddAttack,
              label: 'Add Weapon',
              icon: Symbols.add_circle,
            ),
          ),
          const SizedBox(height: 6),
          if (widget.attacks.isEmpty) ...[
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
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.attacks.length,
              onReorder: widget.onReorderAttack,
              itemBuilder: (context, index) {
                final attack = widget.attacks[index];
                return _buildAttackCard(context, index, attack);
              },
            ),
          ],
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildAttackCard(
    BuildContext context,
    int index,
    CharacterAttack attack,
  ) {
    return Card(
      key: ValueKey(attack.id),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.drag_handle),
          ),
        ),
        title: Text(attack.name),
        subtitle: Text(
          'Attack bonus: ${attack.attackBonus} | Damage: ${attack.damage} | Type: ${attack.damageType}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => widget.onRemoveAttack(index),
        ),
        onTap: () => _showAttackDetailSheet(context, attack),
      ),
    );
  }

  void _showAttackDetailSheet(BuildContext context, CharacterAttack attack) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AttackDetailSheet(attack: attack),
    );
  }
}
