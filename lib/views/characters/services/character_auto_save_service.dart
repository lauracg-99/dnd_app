import 'package:flutter/material.dart';
import '../../../models/character_model.dart';
import '../../../services/character_service.dart';
import '../../../utils/logger.dart';

/// Service for handling character auto-save functionality
/// 
/// This service encapsulates all the logic for automatically saving
/// character changes, making it easier to test and maintain.
class CharacterAutoSaveService {
  static final _logger = AppLogger.forModule('CharacterAutoSave');

  /// Auto-save a character with the current form values
  Future<void> autoSave({
    required Character character,
    required Map<String, dynamic> formData,
    bool showToast = false,
  }) async {
    try {
      final updatedCharacter = _buildUpdatedCharacter(
        character: character,
        formData: formData,
      );

      await CharacterService.saveCharacter(updatedCharacter);
      
      if (showToast) {
        _logger.info('Character auto-saved: ${character.name}');
      } else {
        _logger.debug('Character auto-saved: ${character.name}');
      }
    } catch (e) {
      _logger.error('Auto-save failed for ${character.name}', error: e);
      rethrow;
    }
  }

  /// Build an updated character from form data
  Character _buildUpdatedCharacter({
    required Character character,
    required Map<String, dynamic> formData,
  }) {
    return character.copyWith(
      name: formData['name'] as String?,
      level: formData['level'] as int?,
      characterClass: formData['characterClass'] as String?,
      subclass: formData['subclass'] as String?,
      race: formData['race'] as String?,
      background: formData['background'] as String?,
      customImagePath: formData['customImagePath'] as String?,
      customImageData: formData['customImageData'] as String?,
      stats: formData['stats'] as CharacterStats?,
      savingThrows: formData['savingThrows'] as CharacterSavingThrows?,
      skillChecks: formData['skillChecks'] as CharacterSkillChecks?,
      health: formData['health'] as CharacterHealth?,
      attacks: formData['attacks'] as List<CharacterAttack>?,
      spellSlots: formData['spellSlots'] as CharacterSpellSlots?,
      spells: formData['spells'] as List<String>?,
      feats: formData['feats'] as List<String>?,
      personalizedSlots: formData['personalizedSlots'] as List<CharacterPersonalizedSlot>?,
      spellPreparation: formData['spellPreparation'] as CharacterSpellPreparation?,
      quickGuide: formData['quickGuide'] as String?,
      proficiencies: formData['proficiencies'] as String?,
      featuresTraits: formData['featuresTraits'] as String?,
      backstory: formData['backstory'] as String?,
      pillars: formData['pillars'] as CharacterPillars?,
      appearance: formData['appearance'] as CharacterAppearance?,
      deathSaves: formData['deathSaves'] as CharacterDeathSaves?,
      languages: formData['languages'] as CharacterLanguages?,
      moneyItems: formData['moneyItems'] as CharacterMoneyItems?,
      featNotes: formData['featNotes'] as String?,
    );
  }

  /// Save character with a success message
  Future<void> saveWithMessage({
    required Character character,
    required Map<String, dynamic> formData,
    required String successMessage,
    required BuildContext context,
  }) async {
    try {
      await autoSave(
        character: character,
        formData: formData,
        showToast: true,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _logger.error('Save with message failed', error: e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving character: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
