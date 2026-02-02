import 'package:flutter/material.dart';
import '../../../models/spell_model.dart';

/// Dialog for displaying detailed information about a spell
/// 
/// Shows:
/// - Spell name, level, and school
/// - Casting time, range, components, duration
/// - Classes that can use the spell
/// - Full description
/// - Option to remove spell from character
class SpellDetailsDialog extends StatelessWidget {
  final Spell spell;
  final String characterName;
  final VoidCallback onRemoveSpell;

  const SpellDetailsDialog({
    super.key,
    required this.spell,
    required this.characterName,
    required this.onRemoveSpell,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        try {
          return SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHandle(),
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildCharacterInfo(context),
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildSpellDetails(context),
                  const Divider(),
                  _buildDescription(context),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                ],
              ),
            ),
          );
        } catch (e) {
          return _buildErrorState(context);
        }
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          spell.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          '${_formatSchoolName(spell.schoolName)} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildCharacterInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
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
    );
  }

  Widget _buildSpellDetails(BuildContext context) {
    return Column(
      children: [
        _buildDetailRow('Casting Time', spell.castingTime),
        _buildDetailRow('Range', spell.range),
        _buildDetailRow('Components', _formatComponents()),
        _buildDetailRow('Duration', spell.duration),
        if (spell.ritual) _buildDetailRow('Ritual', 'Yes'),
        _buildDetailRow('Classes', _formatClasses()),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      spell.description,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Remove Spell'),
            onPressed: () {
              Navigator.pop(context);
              onRemoveSpell();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed ${spell.name} from $characterName'),
                  backgroundColor: Colors.orange,
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error displaying spell details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'There was an error loading the spell details for "${spell.name}".',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatSchoolName(String schoolName) {
    return schoolName
        .split('_')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1)
            : '')
        .join(' ');
  }

  String _formatComponents() {
    final components = <String>[];
    if (spell.verbal) components.add('V');
    if (spell.somatic) components.add('S');
    if (spell.material && spell.components != null) {
      components.add('M (${spell.components})');
    }
    return components.isEmpty ? 'None' : components.join(', ');
  }

  String _formatClasses() {
    if (spell.classes.isEmpty) return 'None';
    
    return spell.classes
        .map((c) => c
            .split('_')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '')
            .join(' '))
        .join(', ');
  }
}
