import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/views/characters/SpellsTab/spell_by_level.dart';
import 'package:dnd_app/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SpellsTab extends StatelessWidget {
  final List<String> spells;
  final CharacterSpellPreparation spellPreparation;
  final Character character;
  final TextEditingController classController;
  final TextEditingController levelController;
  final int currentModifier;
  final int calculatedMax;
  final int maxPreparedSpells;
  final bool isMaxPreparedModified;
  final bool canPrepare;
  final String? spellcastingAbility;
  final int spellSaveDC;
  final int spellAttackBonus;
  final String Function(String ability) getAbilityName;
  final String Function(int modifier) getModifierName;
  final VoidCallback onShowAddSpellDialog;
  final VoidCallback onShowMaxPreparedDialog;
  final VoidCallback onResetMaxPrepared;
  final void Function(String spellName) onShowSpellDetails;
  final void Function(String spellId, bool prepare) onToggleSpellPreparation;
  final void Function(String spellId) onToggleAlwaysPrepared;
  final void Function(String spellId) onToggleFreeUse;
  final VoidCallback onAutoSaveCharacter;
  final void Function(int index) onRemoveSpell;

  const SpellsTab({
    super.key,
    required this.spells,
    required this.spellPreparation,
    required this.character,
    required this.classController,
    required this.levelController,
    required this.currentModifier,
    required this.calculatedMax,
    required this.maxPreparedSpells,
    required this.isMaxPreparedModified,
    required this.canPrepare,
    required this.spellcastingAbility,
    required this.spellSaveDC,
    required this.spellAttackBonus,
    required this.getAbilityName,
    required this.getModifierName,
    required this.onShowAddSpellDialog,
    required this.onShowMaxPreparedDialog,
    required this.onResetMaxPrepared,
    required this.onShowSpellDetails,
    required this.onToggleSpellPreparation,
    required this.onToggleAlwaysPrepared,
    required this.onToggleFreeUse,
    required this.onAutoSaveCharacter,
    required this.onRemoveSpell,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Container(
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
                    getAbilityName(spellcastingAbility!),
                    '+$currentModifier',
                  ),
                  const SizedBox(height: 8),
                  _buildSpellcastingInfoRow(
                    'Spell Save DC',
                    '8 + Proficiency + $currentModifier',
                    spellSaveDC.toString(),
                  ),
                  const SizedBox(height: 8),
                  _buildSpellcastingInfoRow(
                    'Spell Attack Bonus',
                    'Proficiency + $currentModifier',
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
          ),
          const SizedBox(height: 16),
          ActionButton.primary(
            context: context,
            onPressed: onShowAddSpellDialog,
            label: 'Add Spell',
            icon: Symbols.add_circle,
          ),
          const SizedBox(height: 14),
          if (canPrepare) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade50, Colors.indigo.shade100],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: Colors.indigo.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Spell Preparation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Spell Preparation Info'),
                                  content: const Text(
                                    'You can establish if a spell is always prepared or you can cast it for free. Always prepared spells don\'t count against your maximum prepared spells limit.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Got it'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 16),
                        color: Colors.indigo.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Maximum prepared spells: $maxPreparedSpells (${classController.text.trim()} level ${levelController.text.trim()} + ${getModifierName(currentModifier)} $currentModifier modifier = $calculatedMax)${maxPreparedSpells != calculatedMax ? ' (modified: +${(maxPreparedSpells - calculatedMax).abs()})' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.indigo.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Currently prepared: ${spellPreparation.currentPreparedCount}/$maxPreparedSpells',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                spellPreparation.currentPreparedCount <
                                        maxPreparedSpells
                                    ? Colors.green.shade700
                                    : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onShowMaxPreparedDialog,
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text(
                          'Modify',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo.shade700,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                      if (isMaxPreparedModified) ...[
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: onResetMaxPrepared,
                            icon: const Icon(Icons.refresh, size: 16),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.indigo.shade700,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SpellByLevel(
            spells: spells,
            spellPreparation: spellPreparation,
            character: character,
            classController: classController,
            levelController: levelController,
            onShowSpellDetails: onShowSpellDetails,
            onToggleSpellPreparation: onToggleSpellPreparation,
            onToggleAlwaysPrepared: onToggleAlwaysPrepared,
            onToggleFreeUse: onToggleFreeUse,
            onAutoSaveCharacter: onAutoSaveCharacter,
            onRemoveSpell: onRemoveSpell,
          ),
          const SizedBox(height: 70),
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
        border: Border.all(color: Colors.purple.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
