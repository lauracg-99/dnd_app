import 'package:flutter/material.dart';
import '../../../models/character_model.dart';
import '../../../helpers/character_ability_helper.dart';

class StatsTab extends StatefulWidget {
  // Controllers
  final TextEditingController levelController;
  final TextEditingController strengthController;
  final TextEditingController dexterityController;
  final TextEditingController constitutionController;
  final TextEditingController intelligenceController;
  final TextEditingController wisdomController;
  final TextEditingController charismaController;

  // State
  final bool hasUnsavedAbilityChanges;
  final CharacterSavingThrows savingThrows;

  // Callbacks
  final VoidCallback onSaveAbilities;
  final Function(CharacterSavingThrows) onSavingThrowsChanged;
  final Function() onAbilityChanged;

  const StatsTab({
    super.key,
    required this.levelController,
    required this.strengthController,
    required this.dexterityController,
    required this.constitutionController,
    required this.intelligenceController,
    required this.wisdomController,
    required this.charismaController,
    required this.hasUnsavedAbilityChanges,
    required this.savingThrows,
    required this.onSaveAbilities,
    required this.onSavingThrowsChanged,
    required this.onAbilityChanged,
  });

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  @override
  Widget build(BuildContext context) {
    debugPrint('=== StatsTab build ===');
    debugPrint('hasUnsavedAbilityChanges: ${widget.hasUnsavedAbilityChanges}');
    debugPrint('====================');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ability Scores',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ' Level ${widget.levelController.text.isNotEmpty ? widget.levelController.text : '1'} • proficiency bonus: +${CharacterStats.calculateProficiencyBonus(int.tryParse(widget.levelController.text) ?? 1)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (widget.hasUnsavedAbilityChanges)
                ElevatedButton.icon(
                  onPressed: widget.onSaveAbilities,
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Ability scores grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.1, // Slightly taller cards
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildStatField('STRENGTH', widget.strengthController),
              _buildStatField('DEXTERITY', widget.dexterityController),
              _buildStatField('CONSTITUTION', widget.constitutionController),
              _buildStatField('INTELLIGENCE', widget.intelligenceController),
              _buildStatField('WISDOM', widget.wisdomController),
              _buildStatField('CHARISMA', widget.charismaController),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Saving Throws',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Saving throws with calculated modifiers
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildSavingThrowRow('STR', widget.savingThrows.strengthProficiency, (value) {
                _updateSavingThrow('strength', value ?? false);
              }),
              _buildSavingThrowRow('DEX', widget.savingThrows.dexterityProficiency, (value) {
                _updateSavingThrow('dexterity', value ?? false);
              }),
              _buildSavingThrowRow('CON', widget.savingThrows.constitutionProficiency, (value) {
                _updateSavingThrow('constitution', value ?? false);
              }),
              _buildSavingThrowRow('INT', widget.savingThrows.intelligenceProficiency, (value) {
                _updateSavingThrow('intelligence', value ?? false);
              }),
              _buildSavingThrowRow('WIS', widget.savingThrows.wisdomProficiency, (value) {
                _updateSavingThrow('wisdom', value ?? false);
              }),
              _buildSavingThrowRow('CHA', widget.savingThrows.charismaProficiency, (value) {
                _updateSavingThrow('charisma', value ?? false);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatField(String label, TextEditingController controller) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0), // Reduced padding from 8.0 to 6.0
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2), // Reduced height from 4 to 2
            Expanded( // Make the container expand to fit available space
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black54, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded( // Make TextField expand
                      child: Center( // Center the TextField within the Expanded space
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: '10',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero, // Remove content padding for better centering
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            // Mark as having unsaved changes and force rebuild
                            widget.onAbilityChanged();
                            // Force rebuild to update modifier
                            (context as Element).markNeedsBuild();
                          },
                          onSubmitted: (value) {
                            // Dismiss keyboard when Done is pressed
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2, // Reduced vertical padding from 3 to 2
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        _getModifier(controller.text),
                        style: const TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0, 
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingThrowRow(
    String ability,
    bool isProficient,
    Function(bool?) onChanged,
  ) {
    final abilityScore = _getAbilityScore(ability);
    final modifier = ((abilityScore - 10) / 2).floor();
    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(int.tryParse(widget.levelController.text) ?? 1);
    final total = modifier + (isProficient ? proficiencyBonus : 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Ability and modifier
          SizedBox(
            width: 50,
            child: Text(
              '$ability\n${modifier >= 0 ? '+' : ''}$modifier',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          // Proficiency checkbox
          Checkbox(
            value: isProficient,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          // Total bonus
          SizedBox(
            width: 40,
            child: Text(
              '${total >= 0 ? '+' : ''}$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isProficient ? Colors.blue : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getModifier(String scoreText) {
    try {
      final score = int.tryParse(scoreText) ?? 10;
      final modifier = CharacterAbilityHelper.getAbilityModifier(score);
      return CharacterAbilityHelper.formatModifier(modifier);
    } catch (e) {
      return '+0';
    }
  }

  int _getAbilityScore(String ability) {
    return CharacterAbilityHelper.getAbilityScore(
      ability,
      strengthController: widget.strengthController,
      dexterityController: widget.dexterityController,
      constitutionController: widget.constitutionController,
      intelligenceController: widget.intelligenceController,
      wisdomController: widget.wisdomController,
      charismaController: widget.charismaController,
    );
  }

  void _updateSavingThrow(String ability, bool value) {
    CharacterSavingThrows newSavingThrows;
    switch (ability) {
      case 'strength':
        newSavingThrows = CharacterSavingThrows(
          strengthProficiency: value,
          dexterityProficiency: widget.savingThrows.dexterityProficiency,
          constitutionProficiency: widget.savingThrows.constitutionProficiency,
          intelligenceProficiency: widget.savingThrows.intelligenceProficiency,
          wisdomProficiency: widget.savingThrows.wisdomProficiency,
          charismaProficiency: widget.savingThrows.charismaProficiency,
        );
        break;
      case 'dexterity':
        newSavingThrows = CharacterSavingThrows(
          strengthProficiency: widget.savingThrows.strengthProficiency,
          dexterityProficiency: value,
          constitutionProficiency: widget.savingThrows.constitutionProficiency,
          intelligenceProficiency: widget.savingThrows.intelligenceProficiency,
          wisdomProficiency: widget.savingThrows.wisdomProficiency,
          charismaProficiency: widget.savingThrows.charismaProficiency,
        );
        break;
      case 'constitution':
        newSavingThrows = CharacterSavingThrows(
          strengthProficiency: widget.savingThrows.strengthProficiency,
          dexterityProficiency: widget.savingThrows.dexterityProficiency,
          constitutionProficiency: value,
          intelligenceProficiency: widget.savingThrows.intelligenceProficiency,
          wisdomProficiency: widget.savingThrows.wisdomProficiency,
          charismaProficiency: widget.savingThrows.charismaProficiency,
        );
        break;
      case 'intelligence':
        newSavingThrows = CharacterSavingThrows(
          strengthProficiency: widget.savingThrows.strengthProficiency,
          dexterityProficiency: widget.savingThrows.dexterityProficiency,
          constitutionProficiency: widget.savingThrows.constitutionProficiency,
          intelligenceProficiency: value,
          wisdomProficiency: widget.savingThrows.wisdomProficiency,
          charismaProficiency: widget.savingThrows.charismaProficiency,
        );
        break;
      case 'wisdom':
        newSavingThrows = CharacterSavingThrows(
          strengthProficiency: widget.savingThrows.strengthProficiency,
          dexterityProficiency: widget.savingThrows.dexterityProficiency,
          constitutionProficiency: widget.savingThrows.constitutionProficiency,
          intelligenceProficiency: widget.savingThrows.intelligenceProficiency,
          wisdomProficiency: value,
          charismaProficiency: widget.savingThrows.charismaProficiency,
        );
        break;
      case 'charisma':
        newSavingThrows = CharacterSavingThrows(
          strengthProficiency: widget.savingThrows.strengthProficiency,
          dexterityProficiency: widget.savingThrows.dexterityProficiency,
          constitutionProficiency: widget.savingThrows.constitutionProficiency,
          intelligenceProficiency: widget.savingThrows.intelligenceProficiency,
          wisdomProficiency: widget.savingThrows.wisdomProficiency,
          charismaProficiency: value,
        );
        break;
      default:
        return;
    }
    widget.onSavingThrowsChanged(newSavingThrows);
  }
}
