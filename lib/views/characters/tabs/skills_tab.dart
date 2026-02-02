import 'package:flutter/material.dart';
import '../../../models/character_model.dart';
import '../../../helpers/character_ability_helper.dart';

/// Tab for managing character skills with proficiency and expertise
class SkillsTab extends StatelessWidget {
  final CharacterSkillChecks skillChecks;
  final int level;
  final int strengthScore;
  final int dexterityScore;
  final int constitutionScore;
  final int intelligenceScore;
  final int wisdomScore;
  final int charismaScore;
  final Function(String skillKey, bool value) onUpdateProficiency;
  final Function(String skillKey, bool value) onUpdateExpertise;

  const SkillsTab({
    super.key,
    required this.skillChecks,
    required this.level,
    required this.strengthScore,
    required this.dexterityScore,
    required this.constitutionScore,
    required this.intelligenceScore,
    required this.wisdomScore,
    required this.charismaScore,
    required this.onUpdateProficiency,
    required this.onUpdateExpertise,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkillGroup('Strength', strengthScore, [
            _buildSkillRow(
              'Athletics',
              'STR',
              strengthScore,
              skillChecks.athleticsProficiency,
              skillChecks.athleticsExpertise,
              'athletics',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSkillGroup('Dexterity', dexterityScore, [
            _buildSkillRow(
              'Acrobatics',
              'DEX',
              dexterityScore,
              skillChecks.acrobaticsProficiency,
              skillChecks.acrobaticsExpertise,
              'acrobatics',
            ),
            _buildSkillRow(
              'Sleight of Hand',
              'DEX',
              dexterityScore,
              skillChecks.sleightOfHandProficiency,
              skillChecks.sleightOfHandExpertise,
              'sleight_of_hand',
            ),
            _buildSkillRow(
              'Stealth',
              'DEX',
              dexterityScore,
              skillChecks.stealthProficiency,
              skillChecks.stealthExpertise,
              'stealth',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSkillGroup('Intelligence', intelligenceScore, [
            _buildSkillRow(
              'Arcana',
              'INT',
              intelligenceScore,
              skillChecks.arcanaProficiency,
              skillChecks.arcanaExpertise,
              'arcana',
            ),
            _buildSkillRow(
              'History',
              'INT',
              intelligenceScore,
              skillChecks.historyProficiency,
              skillChecks.historyExpertise,
              'history',
            ),
            _buildSkillRow(
              'Investigation',
              'INT',
              intelligenceScore,
              skillChecks.investigationProficiency,
              skillChecks.investigationExpertise,
              'investigation',
            ),
            _buildSkillRow(
              'Nature',
              'INT',
              intelligenceScore,
              skillChecks.natureProficiency,
              skillChecks.natureExpertise,
              'nature',
            ),
            _buildSkillRow(
              'Religion',
              'INT',
              intelligenceScore,
              skillChecks.religionProficiency,
              skillChecks.religionExpertise,
              'religion',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSkillGroup('Wisdom', wisdomScore, [
            _buildSkillRow(
              'Animal Handling',
              'WIS',
              wisdomScore,
              skillChecks.animalHandlingProficiency,
              skillChecks.animalHandlingExpertise,
              'animal_handling',
            ),
            _buildSkillRow(
              'Insight',
              'WIS',
              wisdomScore,
              skillChecks.insightProficiency,
              skillChecks.insightExpertise,
              'insight',
            ),
            _buildSkillRow(
              'Medicine',
              'WIS',
              wisdomScore,
              skillChecks.medicineProficiency,
              skillChecks.medicineExpertise,
              'medicine',
            ),
            _buildSkillRow(
              'Perception',
              'WIS',
              wisdomScore,
              skillChecks.perceptionProficiency,
              skillChecks.perceptionExpertise,
              'perception',
            ),
            _buildSkillRow(
              'Survival',
              'WIS',
              wisdomScore,
              skillChecks.survivalProficiency,
              skillChecks.survivalExpertise,
              'survival',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSkillGroup('Charisma', charismaScore, [
            _buildSkillRow(
              'Deception',
              'CHA',
              charismaScore,
              skillChecks.deceptionProficiency,
              skillChecks.deceptionExpertise,
              'deception',
            ),
            _buildSkillRow(
              'Intimidation',
              'CHA',
              charismaScore,
              skillChecks.intimidationProficiency,
              skillChecks.intimidationExpertise,
              'intimidation',
            ),
            _buildSkillRow(
              'Performance',
              'CHA',
              charismaScore,
              skillChecks.performanceProficiency,
              skillChecks.performanceExpertise,
              'performance',
            ),
            _buildSkillRow(
              'Persuasion',
              'CHA',
              charismaScore,
              skillChecks.persuasionProficiency,
              skillChecks.persuasionExpertise,
              'persuasion',
            ),
          ]),
          const SizedBox(height: 45),
        ],
      ),
    );
  }

  Widget _buildSkillGroup(String abilityName, int abilityScore, List<Widget> skills) {
    final modifier = ((abilityScore - 10) / 2).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                abilityName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  '${modifier >= 0 ? '+' : ''}$modifier',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...skills,
      ],
    );
  }

  Widget _buildSkillRow(
    String skillName,
    String ability,
    int abilityScore,
    bool isProficient,
    bool hasExpertise,
    String skillKey,
  ) {
    final modifier = ((abilityScore - 10) / 2).floor();
    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(level);

    int total = modifier;
    if (hasExpertise) {
      total += proficiencyBonus * 2;
    } else if (isProficient) {
      total += proficiencyBonus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: hasExpertise
            ? Colors.purple.shade50
            : (isProficient ? Colors.green.shade50 : Colors.white),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              skillName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '$ability\n${modifier >= 0 ? '+' : ''}$modifier',
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onUpdateProficiency(skillKey, !isProficient),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isProficient ? Colors.green : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(4),
                color: isProficient ? Colors.green : Colors.transparent,
              ),
              child: isProficient
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onUpdateExpertise(skillKey, !hasExpertise),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasExpertise ? Colors.purple : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(4),
                color: hasExpertise ? Colors.purple : Colors.transparent,
              ),
              child: hasExpertise
                  ? const Icon(Icons.star, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${total >= 0 ? '+' : ''}$total',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
