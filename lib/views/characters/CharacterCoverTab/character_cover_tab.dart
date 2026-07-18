import 'package:dnd_app/helpers/character_class_helper.dart';
import 'package:dnd_app/models/background_model.dart';
import 'package:dnd_app/models/race_model.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/character_header_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/combat_stats_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/concentration_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/death_saving_throws_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/features_traits_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/health_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/initiative_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/languages_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/long_rest_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/money_and_items_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/other_proficiencies_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CharacterCoverTab extends StatelessWidget {
  final bool isEditingCharacterCover;
  final bool hasUnsavedClassChanges;
  final void Function(bool) onEditToggle;
  final TextEditingController nameController;
  final TextEditingController levelController;
  final TextEditingController classController;
  final TextEditingController subclassController;
  final TextEditingController raceController;
  final TextEditingController backgroundController;
  final String? customImagePath;
  final String? customImageData;
  final VoidCallback onPickImage;
  final VoidCallback onSave;
  final ValueChanged<String> onClassChanged;
  final ValueChanged<String> onSubclassChanged;
  final ValueChanged<String> onRaceChanged;
  final ValueChanged<String> onBackgroundChanged;
  final Widget Function() buildPickImageButton;
  final void Function(Race) showRaceDetailsModal;
  final void Function(Background) showBackgroundDetailsModal;
  final String selectedBackground;
  final String? currentGroup;
  final VoidCallback? onEditGroup;
  final VoidCallback? onRemoveGroup;
  final Widget Function() buildInspiration;
  final Widget Function() buildArmorClass;
  final Widget Function() buildSpeed;
  final TextEditingController initiativeController;
  final TextEditingController dexterityController;
  final ValueChanged<String> onInitiativeChanged;
  final VoidCallback showInitiativeDialog;
  final bool hasConcentration;
  final VoidCallback onConcentrationToggle;
  final TextEditingController maxHpController;
  final TextEditingController currentHpController;
  final TextEditingController tempHpController;
  final TextEditingController hitDiceController;
  final TextEditingController hitDiceTypeController;
  final int exhaustionLevel;
  final ValueChanged<int> onExhaustionChanged;
  final List<bool> deathSaveSuccesses;
  final List<bool> deathSaveFailures;
  final void Function(int) onToggleSuccess;
  final void Function(int) onToggleFailure;
  final VoidCallback onClearDeathSaves;
  final QuillController featuresTraitsController;
  final ValueChanged<String> onFeaturesTraitsChanged;
  final QuillController proficienciesController;
  final VoidCallback onProficienciesChanged;
  final TextEditingController languagesController;
  final ValueChanged<String> onLanguagesChanged;
  final TextEditingController moneyController;
  final QuillController itemsController;
  final ValueChanged<String> onMoneyChanged;
  final VoidCallback onItemsChanged;
  final VoidCallback takeComprehensiveLongRest;

  const CharacterCoverTab({
    super.key,
    required this.isEditingCharacterCover,
    required this.hasUnsavedClassChanges,
    required this.onEditToggle,
    required this.nameController,
    required this.levelController,
    required this.classController,
    required this.subclassController,
    required this.raceController,
    required this.backgroundController,
    required this.customImagePath,
    required this.customImageData,
    required this.onPickImage,
    required this.onSave,
    required this.onClassChanged,
    required this.onSubclassChanged,
    required this.onRaceChanged,
    required this.onBackgroundChanged,
    required this.buildPickImageButton,
    required this.showRaceDetailsModal,
    required this.showBackgroundDetailsModal,
    required this.selectedBackground,
    this.currentGroup,
    this.onEditGroup,
    this.onRemoveGroup,
    required this.buildInspiration,
    required this.buildArmorClass,
    required this.buildSpeed,
    required this.initiativeController,
    required this.dexterityController,
    required this.onInitiativeChanged,
    required this.showInitiativeDialog,
    required this.hasConcentration,
    required this.onConcentrationToggle,
    required this.maxHpController,
    required this.currentHpController,
    required this.tempHpController,
    required this.hitDiceController,
    required this.hitDiceTypeController,
    required this.exhaustionLevel,
    required this.onExhaustionChanged,
    required this.deathSaveSuccesses,
    required this.deathSaveFailures,
    required this.onToggleSuccess,
    required this.onToggleFailure,
    required this.onClearDeathSaves,
    required this.featuresTraitsController,
    required this.onFeaturesTraitsChanged,
    required this.proficienciesController,
    required this.onProficienciesChanged,
    required this.languagesController,
    required this.onLanguagesChanged,
    required this.moneyController,
    required this.itemsController,
    required this.onMoneyChanged,
    required this.onItemsChanged,
    required this.takeComprehensiveLongRest,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CharacterHeaderSection(
            isEditing: isEditingCharacterCover,
            hasUnsavedClassChanges: hasUnsavedClassChanges,
            onEditToggle: onEditToggle,
            nameController: nameController,
            levelController: levelController,
            classController: classController,
            subclassController: subclassController,
            raceController: raceController,
            backgroundController: backgroundController,
            customImagePath: customImagePath,
            customImageData: customImageData,
            onPickImage: onPickImage,
            onSave: onSave,
            getSubclassesForClass: CharacterClassHelper.getSubclassesForClass,
            onClassChanged: onClassChanged,
            onSubclassChanged: onSubclassChanged,
            onRaceChanged: onRaceChanged,
            onBackgroundChanged: onBackgroundChanged,
            buildPickImageButton: buildPickImageButton,
            showRaceDetailsModal: showRaceDetailsModal,
            showBackgroundDetailsModal: showBackgroundDetailsModal,
            selectedBackground: selectedBackground,
            currentGroup: currentGroup,
            onEditGroup: onEditGroup,
            onRemoveGroup: onRemoveGroup,
          ),

          const SizedBox(height: 16),

          CombatStatsSection(
            buildInspiration: buildInspiration,
            buildArmorClass: buildArmorClass,
            buildSpeed: buildSpeed,
          ),

          const SizedBox(height: 16),

          InitiativeSection(
            controller: initiativeController,
            dexterityController: dexterityController,
            onChanged: onInitiativeChanged,
            showInitiativeDialog: showInitiativeDialog,
          ),

          ConcentrationSection(
            hasConcentration: hasConcentration,
            onToggle: onConcentrationToggle,
          ),

          HealthSection(
            maxHpController: maxHpController,
            currentHpController: currentHpController,
            tempHpController: tempHpController,
            hitDiceController: hitDiceController,
            hitDiceTypeController: hitDiceTypeController,
            exhaustionLevel: exhaustionLevel,
            onExhaustionChanged: onExhaustionChanged,
          ),

          const SizedBox(height: 24),

          DeathSavingThrowsSection(
            deathSaveSuccesses: deathSaveSuccesses,
            deathSaveFailures: deathSaveFailures,
            onToggleSuccess: onToggleSuccess,
            onToggleFailure: onToggleFailure,
            onClear: onClearDeathSaves,
          ),

          const SizedBox(height: 16),

          FeaturesTraitsSection(
            controller: featuresTraitsController,
            onChanged: onFeaturesTraitsChanged,
          ),

          const SizedBox(height: 16),

          OtherProficienciesSection(
            controller: proficienciesController,
            onChanged: onProficienciesChanged,
          ),

          const SizedBox(height: 16),

          LanguagesSection(
            onChanged: onLanguagesChanged,
            languagesController: languagesController,
          ),

          const SizedBox(height: 16),

          MoneyItemsSection(
            moneyController: moneyController,
            itemsController: itemsController,
            onMoneyChanged: onMoneyChanged,
            onItemsChanged: onItemsChanged,
          ),

          const SizedBox(height: 30),

          LongRestSection(takeComprehensiveLongRest: takeComprehensiveLongRest),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
