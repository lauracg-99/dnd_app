import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/character_model.dart';
import '../../viewmodels/characters_viewmodel.dart';
import 'character_edit_controllers.dart';
import 'character_edit_state_manager.dart';
import 'character_edit_utils.dart';

/// Service for handling auto-save functionality in character edit screen
class CharacterEditAutoSaveService {
  /// Setup auto-save listeners for all controllers
  static void setupAutoSaveListeners(
    CharacterEditControllers controllers,
    CharacterEditStateManager stateManager,
    VoidCallback onAutoSave,
    VoidCallback onStateChanged,
  ) {
    // Add listeners to all text controllers for auto-save
    controllers.nameController.addListener(onAutoSave);
    controllers.levelController.addListener(() {
      onAutoSave();
      onStateChanged(); // Update proficiency bonus when level changes
    });
    controllers.classController.addListener(onAutoSave);
    controllers.subclassController.addListener(onAutoSave);
    controllers.raceController.addListener(onAutoSave);
    controllers.backgroundController.addListener(onAutoSave);
    controllers.quickGuideController.addListener(onAutoSave);
    controllers.backstoryController.addListener(onAutoSave);
    controllers.featNotesController.addListener(onAutoSave);

    // Appearance controllers
    controllers.heightController.addListener(onAutoSave);
    controllers.ageController.addListener(onAutoSave);
    controllers.eyeColorController.addListener(onAutoSave);
    controllers.additionalDetailsController.addListener(onAutoSave);

    // Pillars controllers
    controllers.gimmickController.addListener(onAutoSave);
    controllers.quirkController.addListener(onAutoSave);
    controllers.wantsController.addListener(onAutoSave);
    controllers.needsController.addListener(onAutoSave);
    controllers.conflictController.addListener(onAutoSave);

    // Stats controllers
    controllers.strengthController.addListener(() {
      onAutoSave();
      stateManager.updateInitiativeIfNotManuallyModified(controllers);
      stateManager.markAbilityChanges();
      onStateChanged();
    });
    controllers.dexterityController.addListener(() {
      onAutoSave();
      stateManager.updateInitiativeIfNotManuallyModified(controllers);
      stateManager.markAbilityChanges();
      onStateChanged();
    });
    controllers.constitutionController.addListener(() {
      onAutoSave();
      stateManager.markAbilityChanges();
      onStateChanged();
    });
    controllers.intelligenceController.addListener(() {
      onAutoSave();
      stateManager.markAbilityChanges();
      onStateChanged();
    });
    controllers.wisdomController.addListener(() {
      onAutoSave();
      stateManager.markAbilityChanges();
      onStateChanged();
    });
    controllers.charismaController.addListener(() {
      onAutoSave();
      stateManager.markAbilityChanges();
      onStateChanged();
    });
    controllers.proficiencyBonusController.addListener(onAutoSave);
    controllers.armorClassController.addListener(onAutoSave);
    controllers.speedController.addListener(onAutoSave);
    controllers.initiativeController.addListener(() {
      onAutoSave();
      stateManager.markInitiativeManuallyModified();
    });

    // Health controllers
    controllers.maxHpController.addListener(onAutoSave);
    controllers.currentHpController.addListener(onAutoSave);
    controllers.tempHpController.addListener(onAutoSave);
    controllers.hitDiceController.addListener(onAutoSave);
    controllers.hitDiceTypeController.addListener(onAutoSave);

    // Languages and items controllers
    controllers.languagesController.addListener(onAutoSave);
    controllers.moneyController.addListener(onAutoSave);
    controllers.itemsController.addListener(onAutoSave);
  }

  /// Auto-save character with current data
  static void autoSaveCharacter(
    BuildContext context,
    Character originalCharacter,
    CharacterEditControllers controllers,
    CharacterEditStateManager stateManager,
  ) {
    final updatedCharacter = originalCharacter.copyWith(
      name: controllers.nameController.text.trim(),
      level: int.tryParse(controllers.levelController.text),
      characterClass: controllers.classController.text.trim(),
      subclass: controllers.subclassController.text.trim(),
      race: controllers.raceController.text.trim(),
      background: controllers.backgroundController.text.trim(),
      quickGuide: controllers.quickGuideController.text.trim(),
      backstory: controllers.backstoryController.text.trim(),
      featNotes: controllers.featNotesController.text.trim(),
      
      // Appearance
      height: controllers.heightController.text.trim(),
      age: int.tryParse(controllers.ageController.text),
      eyeColor: controllers.eyeColorController.text.trim(),
      additionalDetails: controllers.additionalDetailsController.text.trim(),
      
      // Pillars
      gimmick: controllers.gimmickController.text.trim(),
      quirk: controllers.quirkController.text.trim(),
      wants: controllers.wantsController.text.trim(),
      needs: controllers.needsController.text.trim(),
      conflict: controllers.conflictController.text.trim(),
      
      // Stats
      strength: int.tryParse(controllers.strengthController.text),
      dexterity: int.tryParse(controllers.dexterityController.text),
      constitution: int.tryParse(controllers.constitutionController.text),
      intelligence: int.tryParse(controllers.intelligenceController.text),
      wisdom: int.tryParse(controllers.wisdomController.text),
      charisma: int.tryParse(controllers.charismaController.text),
      proficiencyBonus: int.tryParse(controllers.proficiencyBonusController.text),
      armorClass: int.tryParse(controllers.armorClassController.text),
      speed: int.tryParse(controllers.speedController.text),
      initiative: int.tryParse(controllers.initiativeController.text),
      
      // Health
      maxHp: int.tryParse(controllers.maxHpController.text),
      currentHp: int.tryParse(controllers.currentHpController.text),
      tempHp: int.tryParse(controllers.tempHpController.text),
      hitDice: int.tryParse(controllers.hitDiceController.text),
      hitDiceType: controllers.hitDiceTypeController.text.trim(),
      
      // Languages and items
      languages: controllers.languagesController.text.trim(),
      money: controllers.moneyController.text.trim(),
      items: controllers.itemsController.text.trim(),
      
      // Images
      customImagePath: stateManager.customImagePath,
      appearance: originalCharacter.appearance.copyWith(
        appearanceImagePath: stateManager.appearanceImagePath,
      ),
      
      // States
      hasInspiration: stateManager.hasInspiration,
      hasConcentration: stateManager.hasConcentration,
      deathSaveSuccesses: stateManager.deathSaveSuccesses,
      deathSaveFailures: stateManager.deathSaveFailures,
      stats: stateManager.stats,
      savingThrows: stateManager.savingThrows,
      skillChecks: stateManager.skillChecks,
      personalizedSlots: stateManager.personalizedSlots,
    );

    final charactersViewModel = Provider.of<CharactersViewModel>(context, listen: false);
    charactersViewModel.updateCharacter(updatedCharacter);
  }

  /// Save character with feedback message
  static void saveCharacter(
    BuildContext context,
    VoidCallback onAutoSave,
    String message,
  ) {
    onAutoSave();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
