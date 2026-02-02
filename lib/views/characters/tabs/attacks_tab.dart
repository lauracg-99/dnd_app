import 'package:flutter/material.dart';
import '../../../models/character_model.dart';

/// Tab for managing character attacks and displaying spellcasting information
class AttacksTab extends StatelessWidget {
  final List<CharacterAttack> attacks;
  final String? spellcastingAbility;
  final int spellSaveDC;
  final int spellAttackBonus;
  final int abilityModifier;
  final String abilityName;
  final VoidCallback onAddAttack;
  final Function(int) onRemoveAttack;

  const AttacksTab({
    super.key,
    required this.attacks,
    required this.spellcastingAbility,
    required this.spellSaveDC,
    required this.spellAttackBonus,
    required this.abilityModifier,
    required this.abilityName,
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
          const Text(
            'Attacks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your character\'s attacks and weapons',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          _buildAttacksList(),
          const SizedBox(height: 16),
          _buildSpellcastingSection(context),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onAddAttack,
            icon: const Icon(Icons.add),
            label: const Text('Add Attack'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttacksList() {
    return Column(
      children: attacks.asMap().entries.map((entry) {
        final index = entry.key;
        final attack = entry.value;
        return Card(
          child: ListTile(
            title: Text(attack.name),
            subtitle: Text(
              '${attack.attackBonus} | ${attack.damage} ${attack.damageType}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onRemoveAttack(index),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpellcastingSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.purple.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Spellcasting',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (spellcastingAbility != null) ...[
            _buildSpellcastingInfoRow(
              'Spellcasting Ability',
              abilityName,
              '+$abilityModifier',
            ),
            const SizedBox(height: 8),
            _buildSpellcastingInfoRow(
              'Spell Save DC',
              '8 + Proficiency + $abilityModifier',
              spellSaveDC.toString(),
            ),
            const SizedBox(height: 8),
            _buildSpellcastingInfoRow(
              'Spell Attack Bonus',
              'Proficiency + $abilityModifier',
              '+$spellAttackBonus',
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'No spellcasting ability detected for this class/subclass',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpellcastingInfoRow(
    String label,
    String description,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.purple.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
