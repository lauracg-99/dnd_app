import 'package:flutter/material.dart';
import '../../../models/character_model.dart';

/// Widget for displaying and managing character attacks
/// 
/// This widget encapsulates the attacks list UI,
/// making it reusable and easier to test.
class AttacksListWidget extends StatelessWidget {
  final List<CharacterAttack> attacks;
  final Function(int) onRemoveAttack;

  const AttacksListWidget({
    super.key,
    required this.attacks,
    required this.onRemoveAttack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 16),
        
        // Attacks list
        ...attacks.asMap().entries.map((entry) {
          final index = entry.key;
          final attack = entry.value;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
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
        }),
        
        if (attacks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No attacks added yet',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
