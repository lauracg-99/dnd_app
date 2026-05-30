import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttacksTab extends StatefulWidget {
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
              label: 'Add Attack',
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
            ...widget.attacks.asMap().entries.map((entry) {
              final index = entry.key;
              final attack = entry.value;
              return _buildAttackCard(context, index, attack);
            }),
          ],
          const SizedBox(height: 16),
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
      child: ListTile(
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
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              attack.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailSection(
                                'Attack Bonus',
                                attack.attackBonus,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailSection('Damage', attack.damage),
                              const SizedBox(height: 16),
                              _buildDetailSection(
                                'Damage Type',
                                attack.damageType,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(content, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
