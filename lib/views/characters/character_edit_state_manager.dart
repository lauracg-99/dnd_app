import 'package:flutter/material.dart';
import '../../models/character_model.dart';
import 'character_edit_controllers.dart';

/// Manages all state for the character edit screen
class CharacterEditStateManager {
  // Image handling
  String? customImagePath;
  String? appearanceImagePath;
  bool isPickingImage = false;
  
  // State tracking
  bool hasUnsavedAbilityChanges = false;
  bool hasUnsavedClassChanges = false;
  bool initiativeManuallyModified = false;
  
  // Selection states
  String selectedClass = 'Fighter';
  bool useCustomSubclass = false;
  String selectedRace = '';
  String selectedBackground = '';
  
  // Death saves
  List<bool> deathSaveSuccesses = [false, false, false];
  List<bool> deathSaveFailures = [false, false, false];
  
  // Character data
  late CharacterStats stats;
  late CharacterSavingThrows savingThrows;
  late CharacterSkillChecks skillChecks;
  late List<CharacterPersonalizedSlot> personalizedSlots;
  
  // Combat states
  bool hasInspiration = false;
  bool hasConcentration = false;
  
  // Spell filter states
  bool filterByCharacterClass = true;
  String? selectedLevelFilter;
  String? selectedClassFilter;
  String? selectedSchoolFilter;

  /// Initialize state from character data
  void initializeFromCharacter(Character character, CharacterEditControllers controllers) {
    // Initialize profile image
    if (character.customImagePath != null && character.customImagePath!.isNotEmpty) {
      customImagePath = character.customImagePath;
    }

    // Initialize appearance image
    if (character.appearance.appearanceImagePath != null && character.appearance.appearanceImagePath!.isNotEmpty) {
      appearanceImagePath = character.appearance.appearanceImagePath;
    }

    // Initialize selection states
    selectedClass = character.characterClass ?? 'Fighter';
    selectedRace = character.race ?? '';
    selectedBackground = character.background ?? '';
    useCustomSubclass = false; // Will be determined based on available subclasses

    // Initialize character data
    stats = character.stats ?? CharacterStats();
    savingThrows = character.savingThrows ?? CharacterSavingThrows();
    skillChecks = character.skillChecks ?? CharacterSkillChecks();
    personalizedSlots = character.personalizedSlots ?? [];

    // Initialize death saves
    deathSaveSuccesses = List.from(character.deathSaveSuccesses ?? [false, false, false]);
    deathSaveFailures = List.from(character.deathSaveFailures ?? [false, false, false]);

    // Initialize combat states
    hasInspiration = character.hasInspiration ?? false;
    hasConcentration = character.hasConcentration ?? false;

    // Initialize initiative tracking
    final currentInitiative = int.tryParse(controllers.initiativeController.text) ?? 0;
    final currentDexterity = int.tryParse(controllers.dexterityController.text) ?? 10;
    final expectedInitiative = _calculateInitiative(currentDexterity);
    initiativeManuallyModified = (currentInitiative != expectedInitiative);
  }

  /// Calculate initiative based on dexterity score
  int _calculateInitiative(int dexterityScore) {
    return (dexterityScore - 10) ~/ 2;
  }

  /// Update initiative if not manually modified
  void updateInitiativeIfNotManuallyModified(CharacterEditControllers controllers) {
    if (!initiativeManuallyModified) {
      final dexterityScore = int.tryParse(controllers.dexterityController.text) ?? 10;
      final newInitiative = _calculateInitiative(dexterityScore);
      controllers.initiativeController.text = newInitiative.toString();
    }
  }

  /// Update death save state
  void updateDeathSave(int index, bool value) {
    if (index < 3) {
      deathSaveSuccesses[index] = value;
    } else {
      deathSaveFailures[index - 3] = value;
    }
  }

  /// Update skill proficiency
  void updateSkillProficiency(String skill, bool value) {
    skillChecks = CharacterSkillChecks(
      acrobaticsProficiency: skill == 'acrobatics' ? value : skillChecks.acrobaticsProficiency,
      acrobaticsExpertise: skillChecks.acrobaticsExpertise,
      animalHandlingProficiency: skill == 'animal_handling' ? value : skillChecks.animalHandlingProficiency,
      animalHandlingExpertise: skillChecks.animalHandlingExpertise,
      arcanaProficiency: skill == 'arcana' ? value : skillChecks.arcanaProficiency,
      arcanaExpertise: skillChecks.arcanaExpertise,
      athleticsProficiency: skill == 'athletics' ? value : skillChecks.athleticsProficiency,
      athleticsExpertise: skillChecks.athleticsExpertise,
      deceptionProficiency: skill == 'deception' ? value : skillChecks.deceptionProficiency,
      deceptionExpertise: skillChecks.deceptionExpertise,
      historyProficiency: skill == 'history' ? value : skillChecks.historyProficiency,
      historyExpertise: skillChecks.historyExpertise,
      insightProficiency: skill == 'insight' ? value : skillChecks.insightProficiency,
      insightExpertise: skillChecks.insightExpertise,
      intimidationProficiency: skill == 'intimidation' ? value : skillChecks.intimidationProficiency,
      intimidationExpertise: skillChecks.intimidationExpertise,
      investigationProficiency: skill == 'investigation' ? value : skillChecks.investigationProficiency,
      investigationExpertise: skillChecks.investigationExpertise,
      medicineProficiency: skill == 'medicine' ? value : skillChecks.medicineProficiency,
      medicineExpertise: skillChecks.medicineExpertise,
      natureProficiency: skill == 'nature' ? value : skillChecks.natureProficiency,
      natureExpertise: skillChecks.natureExpertise,
      perceptionProficiency: skill == 'perception' ? value : skillChecks.perceptionProficiency,
      perceptionExpertise: skillChecks.perceptionExpertise,
      performanceProficiency: skill == 'performance' ? value : skillChecks.performanceProficiency,
      performanceExpertise: skillChecks.performanceExpertise,
      persuasionProficiency: skill == 'persuasion' ? value : skillChecks.persuasionProficiency,
      persuasionExpertise: skillChecks.persuasionExpertise,
      religionProficiency: skill == 'religion' ? value : skillChecks.religionProficiency,
      religionExpertise: skillChecks.religionExpertise,
      sleightOfHandProficiency: skill == 'sleight_of_hand' ? value : skillChecks.sleightOfHandProficiency,
      sleightOfHandExpertise: skillChecks.sleightOfHandExpertise,
      stealthProficiency: skill == 'stealth' ? value : skillChecks.stealthProficiency,
      stealthExpertise: skillChecks.stealthExpertise,
      survivalProficiency: skill == 'survival' ? value : skillChecks.survivalProficiency,
      survivalExpertise: skillChecks.survivalExpertise,
    );
  }

  /// Update skill expertise
  void updateSkillExpertise(String skill, bool value) {
    // If setting expertise to true, also set proficiency to true
    if (value) {
      updateSkillProficiency(skill, true);
    }
    
    skillChecks = CharacterSkillChecks(
      acrobaticsProficiency: skillChecks.acrobaticsProficiency,
      acrobaticsExpertise: skill == 'acrobatics' ? value : skillChecks.acrobaticsExpertise,
      animalHandlingProficiency: skillChecks.animalHandlingProficiency,
      animalHandlingExpertise: skill == 'animal_handling' ? value : skillChecks.animalHandlingExpertise,
      arcanaProficiency: skillChecks.arcanaProficiency,
      arcanaExpertise: skill == 'arcana' ? value : skillChecks.arcanaExpertise,
      athleticsProficiency: skillChecks.athleticsProficiency,
      athleticsExpertise: skill == 'athletics' ? value : skillChecks.athleticsExpertise,
      deceptionProficiency: skillChecks.deceptionProficiency,
      deceptionExpertise: skill == 'deception' ? value : skillChecks.deceptionExpertise,
      historyProficiency: skillChecks.historyProficiency,
      historyExpertise: skill == 'history' ? value : skillChecks.historyExpertise,
      insightProficiency: skillChecks.insightProficiency,
      insightExpertise: skill == 'insight' ? value : skillChecks.insightExpertise,
      intimidationProficiency: skillChecks.intimidationProficiency,
      intimidationExpertise: skill == 'intimidation' ? value : skillChecks.intimidationExpertise,
      investigationProficiency: skillChecks.investigationProficiency,
      investigationExpertise: skill == 'investigation' ? value : skillChecks.investigationExpertise,
      medicineProficiency: skillChecks.medicineProficiency,
      medicineExpertise: skill == 'medicine' ? value : skillChecks.medicineExpertise,
      natureProficiency: skillChecks.natureProficiency,
      natureExpertise: skill == 'nature' ? value : skillChecks.natureExpertise,
      perceptionProficiency: skillChecks.perceptionProficiency,
      perceptionExpertise: skill == 'perceptionExpertise,
      performanceProficiency: skillChecks.performanceProficiency,
      performanceExpertise: skill == 'performance' ? value : skillChecks.performanceExpertise,
      persuasionProficiency: skillChecks.persuasionProficiency,
      persuasionExpertise: skill == 'persuasion' ? value : skillChecks.persuasionExpertise,
      religionProficiency: skillChecks.religionProficiency,
      religionExpertise: skill == 'religion' ? value : skillChecks.religionExpertise,
      sleightOfHandProficiency: skillChecks.sleightOfHandProficiency,
      sleightOfHandExpertise: skill == 'sleight_of_hand' ? value : skillChecks.sleightOfHandExpertise,
      stealthProficiency: skillChecks.stealthProficiency,
      stealthExpertise: skill == 'stealth' ? value : skillChecks.stealthExpertise,
      survivalProficiency: skillChecks.survivalProficiency,
      survivalExpertise: skill == 'survival' ? value : skillChecks.survivalExpertise,
    );
  }

  /// Set custom image path
  void setCustomImagePath(String? path) {
    customImagePath = path;
  }

  /// Set appearance image path
  void setAppearanceImagePath(String? path) {
    appearanceImagePath = path;
  }

  /// Set image picking state
  void setPickingImageState(bool isPicking) {
    isPickingImage = isPicking;
  }

  /// Mark initiative as manually modified
  void markInitiativeManuallyModified() {
    initiativeManuallyModified = true;
  }

  /// Reset ability changes flag
  void resetAbilityChangesFlag() {
    hasUnsavedAbilityChanges = false;
  }

  /// Set class selection
  void setClassSelection(String className) {
    selectedClass = className;
    hasUnsavedClassChanges = true;
  }

  /// Set race selection
  void setRaceSelection(String race) {
    selectedRace = race;
  }

  /// Set background selection
  void setBackgroundSelection(String background) {
    selectedBackground = background;
  }

  /// Set custom subclass flag
  void setCustomSubclassFlag(bool useCustom) {
    useCustomSubclass = useCustom;
  }

  /// Set inspiration state
  void setInspirationState(bool hasInspiration) {
    this.hasInspiration = hasInspiration;
  }

  /// Set concentration state
  void setConcentrationState(bool hasConcentration) {
    this.hasConcentration = hasConcentration;
  }

  /// Set saving throws
  void setSavingThrows(CharacterSavingThrows newSavingThrows) {
    savingThrows = newSavingThrows;
  }

  /// Mark ability changes
  void markAbilityChanges() {
    hasUnsavedAbilityChanges = true;
  }
}
