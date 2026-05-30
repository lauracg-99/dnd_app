import 'package:flutter/material.dart';
import 'package:dnd_app/models/spell_model.dart';
import 'package:dnd_app/widgets/detail_row.dart';

class SpellDetailsModal extends StatelessWidget {
  final Spell spell;
  final String characterName;
  final void Function(Spell spell) onRemoveSpell;

  const SpellDetailsModal({
    super.key,
    required this.spell,
    required this.characterName,
    required this.onRemoveSpell,
  });

  String _formatComponents(Spell spell) {
    final components = <String>[];
    if (spell.verbal) components.add('V');
    if (spell.somatic) components.add('S');
    if (spell.material && spell.components != null) {
      components.add('M (${spell.components})');
    }
    return components.join(', ');
  }

  String _formatSchoolAndLevel(Spell spell) {
    final school = spell.schoolName
        .split('_')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
    final levelText =
        spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}';
    return '$school $levelText';
  }

  String _formatClasses(Spell spell) {
    if (spell.classes.isEmpty) return 'None';
    return spell.classes
        .map(
          (c) => c
              .split('_')
              .map(
                (word) =>
                    word.isNotEmpty
                        ? word[0].toUpperCase() + word.substring(1)
                        : '',
              )
              .join(' '),
        )
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        return SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  spell.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatSchoolAndLevel(spell),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Known by: $characterName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                DetailRow(label: 'Casting Time', value: spell.castingTime),
                DetailRow(label: 'Range', value: spell.range),
                DetailRow(label: 'Components', value: _formatComponents(spell)),
                DetailRow(label: 'Duration', value: spell.duration),
                if (spell.ritual) DetailRow(label: 'Ritual', value: 'Yes'),
                DetailRow(label: 'Classes', value: _formatClasses(spell)),
                const Divider(),
                Text(
                  spell.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove Spell'),
                        onPressed: () {
                          Navigator.pop(context);
                          onRemoveSpell(spell);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Removed ${spell.name} from $characterName',
                              ),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
