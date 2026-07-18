import 'package:dnd_app/helpers/character_ability_helper.dart';
import 'package:dnd_app/models/character_model.dart';
import 'package:flutter/material.dart';

class SkillsTab extends StatelessWidget {
  final CharacterSkillChecks skillChecks;
  final TextEditingController levelController;
  final TextEditingController athleticsBonusController;
  final TextEditingController acrobaticsBonusController;
  final TextEditingController sleightOfHandBonusController;
  final TextEditingController stealthBonusController;
  final TextEditingController arcanaBonusController;
  final TextEditingController historyBonusController;
  final TextEditingController investigationBonusController;
  final TextEditingController natureBonusController;
  final TextEditingController religionBonusController;
  final TextEditingController animalHandlingBonusController;
  final TextEditingController insightBonusController;
  final TextEditingController medicineBonusController;
  final TextEditingController perceptionBonusController;
  final TextEditingController survivalBonusController;
  final TextEditingController deceptionBonusController;
  final TextEditingController intimidationBonusController;
  final TextEditingController performanceBonusController;
  final TextEditingController persuasionBonusController;
  final void Function(String skillKey, bool isProficient) onUpdateSkillCheck;
  final void Function(String skillKey, bool hasExpertise)
  onUpdateSkillExpertise;
  final void Function(String skillKey, bool hasDisadvantage)
  onUpdateSkillDisadvantage;
  final int Function(String ability) getAbilityScore;

  const SkillsTab({
    super.key,
    required this.skillChecks,
    required this.levelController,
    required this.athleticsBonusController,
    required this.acrobaticsBonusController,
    required this.sleightOfHandBonusController,
    required this.stealthBonusController,
    required this.arcanaBonusController,
    required this.historyBonusController,
    required this.investigationBonusController,
    required this.natureBonusController,
    required this.religionBonusController,
    required this.animalHandlingBonusController,
    required this.insightBonusController,
    required this.medicineBonusController,
    required this.perceptionBonusController,
    required this.survivalBonusController,
    required this.deceptionBonusController,
    required this.intimidationBonusController,
    required this.performanceBonusController,
    required this.persuasionBonusController,
    required this.onUpdateSkillCheck,
    required this.onUpdateSkillExpertise,
    required this.onUpdateSkillDisadvantage,
    required this.getAbilityScore,
  });

  int _getAbilityScore(String ability) {
    return getAbilityScore(ability);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkillGroup('Strength', [
            _buildSkillRow(
              'Athletics',
              'STR',
              skillChecks.athleticsProficiency,
              skillChecks.athleticsExpertise,
              skillChecks.athleticsDisadvantage,
              'athletics',
              athleticsBonusController,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSkillGroup('Dexterity', [
            _buildSkillRow(
              'Acrobatics',
              'DEX',
              skillChecks.acrobaticsProficiency,
              skillChecks.acrobaticsExpertise,
              skillChecks.acrobaticsDisadvantage,
              'acrobatics',
              acrobaticsBonusController,
            ),
            _buildSkillRow(
              'Sleight of Hand',
              'DEX',
              skillChecks.sleightOfHandProficiency,
              skillChecks.sleightOfHandExpertise,
              skillChecks.sleightOfHandDisadvantage,
              'sleight_of_hand',
              sleightOfHandBonusController,
            ),
            _buildSkillRow(
              'Stealth',
              'DEX',
              skillChecks.stealthProficiency,
              skillChecks.stealthExpertise,
              skillChecks.stealthDisadvantage,
              'stealth',
              stealthBonusController,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSkillGroup('Intelligence', [
            _buildSkillRow(
              'Arcana',
              'INT',
              skillChecks.arcanaProficiency,
              skillChecks.arcanaExpertise,
              skillChecks.arcanaDisadvantage,
              'arcana',
              arcanaBonusController,
            ),
            _buildSkillRow(
              'History',
              'INT',
              skillChecks.historyProficiency,
              skillChecks.historyExpertise,
              skillChecks.historyDisadvantage,
              'history',
              historyBonusController,
            ),
            _buildSkillRow(
              'Investigation',
              'INT',
              skillChecks.investigationProficiency,
              skillChecks.investigationExpertise,
              skillChecks.investigationDisadvantage,
              'investigation',
              investigationBonusController,
            ),
            _buildSkillRow(
              'Nature',
              'INT',
              skillChecks.natureProficiency,
              skillChecks.natureExpertise,
              skillChecks.natureDisadvantage,
              'nature',
              natureBonusController,
            ),
            _buildSkillRow(
              'Religion',
              'INT',
              skillChecks.religionProficiency,
              skillChecks.religionExpertise,
              skillChecks.religionDisadvantage,
              'religion',
              religionBonusController,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSkillGroup('Wisdom', [
            _buildSkillRow(
              'Animal Handling',
              'WIS',
              skillChecks.animalHandlingProficiency,
              skillChecks.animalHandlingExpertise,
              skillChecks.animalHandlingDisadvantage,
              'animal_handling',
              animalHandlingBonusController,
            ),
            _buildSkillRow(
              'Insight',
              'WIS',
              skillChecks.insightProficiency,
              skillChecks.insightExpertise,
              skillChecks.insightDisadvantage,
              'insight',
              insightBonusController,
            ),
            _buildSkillRow(
              'Medicine',
              'WIS',
              skillChecks.medicineProficiency,
              skillChecks.medicineExpertise,
              skillChecks.medicineDisadvantage,
              'medicine',
              medicineBonusController,
            ),
            _buildSkillRow(
              'Perception',
              'WIS',
              skillChecks.perceptionProficiency,
              skillChecks.perceptionExpertise,
              skillChecks.perceptionDisadvantage,
              'perception',
              perceptionBonusController,
            ),
            _buildSkillRow(
              'Survival',
              'WIS',
              skillChecks.survivalProficiency,
              skillChecks.survivalExpertise,
              skillChecks.survivalDisadvantage,
              'survival',
              survivalBonusController,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSkillGroup('Charisma', [
            _buildSkillRow(
              'Deception',
              'CHA',
              skillChecks.deceptionProficiency,
              skillChecks.deceptionExpertise,
              skillChecks.deceptionDisadvantage,
              'deception',
              deceptionBonusController,
            ),
            _buildSkillRow(
              'Intimidation',
              'CHA',
              skillChecks.intimidationProficiency,
              skillChecks.intimidationExpertise,
              skillChecks.intimidationDisadvantage,
              'intimidation',
              intimidationBonusController,
            ),
            _buildSkillRow(
              'Performance',
              'CHA',
              skillChecks.performanceProficiency,
              skillChecks.performanceExpertise,
              skillChecks.performanceDisadvantage,
              'performance',
              performanceBonusController,
            ),
            _buildSkillRow(
              'Persuasion',
              'CHA',
              skillChecks.persuasionProficiency,
              skillChecks.persuasionExpertise,
              skillChecks.persuasionDisadvantage,
              'persuasion',
              persuasionBonusController,
            ),
          ]),
          const SizedBox(height: 45),
        ],
      ),
    );
  }

  Widget _buildSkillGroup(String abilityName, List<Widget> skills) {
    final abilityAbbreviation = CharacterAbilityHelper.getAbilityAbbreviation(
      abilityName,
    );
    final abilityScore = _getAbilityScore(abilityAbbreviation);
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
    bool isProficient,
    bool hasExpertise,
    bool hasDisadvantage,
    String skillKey,
    TextEditingController bonusController,
  ) {
    final abilityScore = _getAbilityScore(ability);
    final modifier = ((abilityScore - 10) / 2).floor();
    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(
      int.tryParse(levelController.text) ?? 1,
    );
    final customBonus = int.tryParse(bonusController.text) ?? 0;
    final total = CharacterSkillChecks.calculateSkillBonus(
      abilityScore,
      isProficient,
      hasExpertise,
      proficiencyBonus,
      customBonus,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color:
            hasDisadvantage
                ? Colors.red.shade50
                : (hasExpertise
                    ? Colors.purple.shade50
                    : (isProficient ? Colors.green.shade50 : Colors.white)),
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
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () => onUpdateSkillDisadvantage(skillKey, !hasDisadvantage),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasDisadvantage ? Colors.red : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(4),
                color: hasDisadvantage ? Colors.red : Colors.transparent,
              ),
              child:
                  hasDisadvantage
                      ? const Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 16,
                      )
                      : null,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 50,
            child: Text(
              '$ability\n${modifier >= 0 ? '+' : ''}$modifier',
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(width: 4),
          Container(
            width: 40,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(6),
              color:
                  (int.tryParse(bonusController.text) ?? 0) != 0
                      ? Colors.blue.shade50
                      : (isProficient && hasExpertise)
                      ? Colors.purple.shade50
                      : (isProficient)
                      ? Colors.green.shade50
                      : Colors.white,
            ),
            child: TextField(
              controller: bonusController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              cursorHeight: 14,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                leadingDistribution: TextLeadingDistribution.even,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 2),
                hintText: '0',
                hintStyle: TextStyle(
                  color: Colors.blue.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onChanged: (value) {
                String formattedValue = value;
                if (value.isNotEmpty && value != '0' && value.startsWith('0')) {
                  formattedValue = value.replaceFirst(RegExp(r'^0+'), '');
                  if (formattedValue.isEmpty) formattedValue = '0';
                  bonusController.value = TextEditingValue(
                    text: formattedValue,
                    selection: TextSelection.collapsed(
                      offset: formattedValue.length,
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onUpdateSkillCheck(skillKey, !isProficient),
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
              child:
                  isProficient
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onUpdateSkillExpertise(skillKey, !hasExpertise),
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
              child:
                  hasExpertise
                      ? const Icon(Icons.star, color: Colors.white, size: 16)
                      : null,
            ),
          ),
          const SizedBox(width: 4),

          SizedBox(
            width: 40,
            child: Text(
              '${total >= 0 ? '+' : ''}$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color:
                    hasExpertise
                        ? Colors.purple
                        : (isProficient ? Colors.green : Colors.black),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
