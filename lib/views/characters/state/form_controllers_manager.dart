import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import '../../../models/character_model.dart';
import '../../../utils/logger.dart';

/// Manager for all form controllers in CharacterEditScreen
/// 
/// This class centralizes the management of all TextEditingController and
/// QuillController instances, making it easier to initialize, update, and dispose them.
class FormControllersManager {
  static final _logger = AppLogger.forModule('FormControllers');

  // Basic info controllers (6)
  final nameController = TextEditingController();
  final levelController = TextEditingController();
  final classController = TextEditingController();
  final subclassController = TextEditingController();
  final raceController = TextEditingController();
  final backgroundController = TextEditingController();

  // Stats controllers (9)
  final strengthController = TextEditingController();
  final dexterityController = TextEditingController();
  final constitutionController = TextEditingController();
  final intelligenceController = TextEditingController();
  final wisdomController = TextEditingController();
  final charismaController = TextEditingController();
  final proficiencyBonusController = TextEditingController();
  final armorClassController = TextEditingController();
  final speedController = TextEditingController();
  final initiativeController = TextEditingController();

  // Health controllers (5)
  final maxHpController = TextEditingController();
  final currentHpController = TextEditingController();
  final tempHpController = TextEditingController();
  final hitDiceController = TextEditingController();
  final hitDiceTypeController = TextEditingController();

  // Appearance controllers (4)
  final heightController = TextEditingController();
  final ageController = TextEditingController();
  final eyeColorController = TextEditingController();
  final additionalDetailsController = QuillController.basic();

  // Pillars controllers (5)
  final gimmickController = TextEditingController();
  final quirkController = TextEditingController();
  final wantsController = TextEditingController();
  final needsController = TextEditingController();
  final conflictController = TextEditingController();

  // Other controllers (3)
  final languagesController = TextEditingController();
  final moneyController = TextEditingController();
  final itemsController = QuillController.basic();

  // Quill controllers (5)
  final quickGuideController = QuillController.basic();
  final proficienciesController = QuillController.basic();
  final featuresTraitsController = QuillController.basic();
  final backstoryController = QuillController.basic();
  final featNotesController = QuillController.basic();

  /// Initialize all controllers from a character
  void initializeFromCharacter(Character character) {
    _logger.debug('Initializing controllers for character: ${character.name}');

    // Basic info
    nameController.text = character.name;
    levelController.text = character.level.toString();
    classController.text = character.characterClass;
    subclassController.text = character.subclass ?? '';
    raceController.text = character.race ?? '';
    backgroundController.text = character.background ?? '';

    // Stats
    strengthController.text = character.stats.strength.toString();
    dexterityController.text = character.stats.dexterity.toString();
    constitutionController.text = character.stats.constitution.toString();
    intelligenceController.text = character.stats.intelligence.toString();
    wisdomController.text = character.stats.wisdom.toString();
    charismaController.text = character.stats.charisma.toString();
    proficiencyBonusController.text = character.stats.proficiencyBonus.toString();
    armorClassController.text = character.stats.armorClass.toString();
    speedController.text = character.stats.speed.toString();
    initiativeController.text = character.stats.initiative.toString();

    // Health
    maxHpController.text = character.health.maxHitPoints.toString();
    currentHpController.text = character.health.currentHitPoints.toString();
    tempHpController.text = character.health.temporaryHitPoints.toString();
    hitDiceController.text = character.health.hitDice.toString();
    hitDiceTypeController.text = character.health.hitDiceType.toString();

    // Appearance
    heightController.text = character.appearance.height;
    ageController.text = character.appearance.age;
    eyeColorController.text = character.appearance.eyeColor;
    _initializeQuillController(
      additionalDetailsController,
      character.appearance.additionalDetails ?? '',
    );

    // Pillars
    gimmickController.text = character.pillars.gimmick;
    quirkController.text = character.pillars.quirk;
    wantsController.text = character.pillars.wants;
    needsController.text = character.pillars.needs;
    conflictController.text = character.pillars.conflict;

    // Other
    languagesController.text = character.languages.languages.join(', ');
    moneyController.text = character.moneyItems.money;
    _initializeQuillController(itemsController, character.moneyItems.items.join('\n'));

    // Quill controllers
    _initializeQuillController(quickGuideController, character.quickGuide);
    _initializeQuillController(proficienciesController, character.proficiencies);
    _initializeQuillController(featuresTraitsController, character.featuresTraits);
    _initializeQuillController(backstoryController, character.backstory);
    _initializeQuillController(featNotesController, character.featNotes);

    _logger.debug('Controllers initialized successfully');
  }

  /// Initialize a QuillController with text or Delta
  void _initializeQuillController(QuillController controller, String content) {
    try {
      if (content.isEmpty) {
        controller.document = Document();
        return;
      }

      // Try to parse as Delta JSON first
      if (content.trim().startsWith('[')) {
        try {
          final delta = Delta.fromJson(
            (jsonDecode(content) as List).cast<Map<String, dynamic>>(),
          );
          controller.document = Document.fromDelta(delta);
          return;
        } catch (e) {
          // If Delta parsing fails, treat as plain text
          _logger.debug('Delta parsing failed, using plain text: $e');
        }
      }

      // Fallback to plain text
      controller.document = Document()..insert(0, content);
    } catch (e) {
      _logger.error('Error initializing Quill controller', error: e);
      controller.document = Document();
    }
  }

  /// Add listeners to controllers
  void addListeners({
    VoidCallback? onBasicInfoChanged,
    VoidCallback? onStatsChanged,
    VoidCallback? onHealthChanged,
    VoidCallback? onAppearanceChanged,
    VoidCallback? onPillarsChanged,
    VoidCallback? onOtherChanged,
    VoidCallback? onQuillChanged,
  }) {
    if (onBasicInfoChanged != null) {
      nameController.addListener(onBasicInfoChanged);
      levelController.addListener(onBasicInfoChanged);
      classController.addListener(onBasicInfoChanged);
      subclassController.addListener(onBasicInfoChanged);
      raceController.addListener(onBasicInfoChanged);
      backgroundController.addListener(onBasicInfoChanged);
    }

    if (onStatsChanged != null) {
      strengthController.addListener(onStatsChanged);
      dexterityController.addListener(onStatsChanged);
      constitutionController.addListener(onStatsChanged);
      intelligenceController.addListener(onStatsChanged);
      wisdomController.addListener(onStatsChanged);
      charismaController.addListener(onStatsChanged);
      proficiencyBonusController.addListener(onStatsChanged);
      armorClassController.addListener(onStatsChanged);
      speedController.addListener(onStatsChanged);
      initiativeController.addListener(onStatsChanged);
    }

    if (onHealthChanged != null) {
      maxHpController.addListener(onHealthChanged);
      currentHpController.addListener(onHealthChanged);
      tempHpController.addListener(onHealthChanged);
      hitDiceController.addListener(onHealthChanged);
      hitDiceTypeController.addListener(onHealthChanged);
    }

    if (onAppearanceChanged != null) {
      heightController.addListener(onAppearanceChanged);
      ageController.addListener(onAppearanceChanged);
      eyeColorController.addListener(onAppearanceChanged);
      additionalDetailsController.document.changes.listen((_) => onAppearanceChanged());
    }

    if (onPillarsChanged != null) {
      gimmickController.addListener(onPillarsChanged);
      quirkController.addListener(onPillarsChanged);
      wantsController.addListener(onPillarsChanged);
      needsController.addListener(onPillarsChanged);
      conflictController.addListener(onPillarsChanged);
    }

    if (onOtherChanged != null) {
      languagesController.addListener(onOtherChanged);
      moneyController.addListener(onOtherChanged);
      itemsController.document.changes.listen((_) => onOtherChanged());
    }

    if (onQuillChanged != null) {
      quickGuideController.document.changes.listen((_) => onQuillChanged());
      proficienciesController.document.changes.listen((_) => onQuillChanged());
      featuresTraitsController.document.changes.listen((_) => onQuillChanged());
      backstoryController.document.changes.listen((_) => onQuillChanged());
      featNotesController.document.changes.listen((_) => onQuillChanged());
    }
  }

  /// Get form data as a map for auto-save
  Map<String, dynamic> getFormData(Character character) {
    return {
      'name': nameController.text,
      'level': int.tryParse(levelController.text) ?? 1,
      'characterClass': classController.text,
      'subclass': subclassController.text.isEmpty ? null : subclassController.text,
      'race': raceController.text.isEmpty ? null : raceController.text,
      'background': backgroundController.text.isEmpty ? null : backgroundController.text,
      'stats': _buildStats(),
      'health': _buildHealth(),
      'appearance': _buildAppearance(character.appearance),
      'pillars': _buildPillars(),
      'languages': _buildLanguages(),
      'moneyItems': _buildMoneyItems(),
      'quickGuide': _getQuillText(quickGuideController),
      'proficiencies': _getQuillText(proficienciesController),
      'featuresTraits': _getQuillText(featuresTraitsController),
      'backstory': _getQuillText(backstoryController),
      'featNotes': _getQuillText(featNotesController),
    };
  }

  CharacterStats _buildStats() {
    return CharacterStats(
      strength: int.tryParse(strengthController.text) ?? 10,
      dexterity: int.tryParse(dexterityController.text) ?? 10,
      constitution: int.tryParse(constitutionController.text) ?? 10,
      intelligence: int.tryParse(intelligenceController.text) ?? 10,
      wisdom: int.tryParse(wisdomController.text) ?? 10,
      charisma: int.tryParse(charismaController.text) ?? 10,
      proficiencyBonus: int.tryParse(proficiencyBonusController.text) ?? 2,
      armorClass: int.tryParse(armorClassController.text) ?? 10,
      speed: int.tryParse(speedController.text) ?? 30,
      initiative: int.tryParse(initiativeController.text) ?? 0,
    );
  }

  CharacterHealth _buildHealth() {
    return CharacterHealth(
      maxHitPoints: int.tryParse(maxHpController.text) ?? 10,
      currentHitPoints: int.tryParse(currentHpController.text) ?? 10,
      temporaryHitPoints: int.tryParse(tempHpController.text) ?? 0,
      hitDice: int.tryParse(hitDiceController.text) ?? 1,
      hitDiceType: hitDiceTypeController.text,
    );
  }

  CharacterAppearance _buildAppearance(CharacterAppearance current) {
    return current.copyWith(
      height: heightController.text,
      age: ageController.text,
      eyeColor: eyeColorController.text,
      additionalDetails: _getQuillText(additionalDetailsController),
    );
  }

  CharacterPillars _buildPillars() {
    return CharacterPillars(
      gimmick: gimmickController.text,
      quirk: quirkController.text,
      wants: wantsController.text,
      needs: needsController.text,
      conflict: conflictController.text,
    );
  }

  CharacterLanguages _buildLanguages() {
    return CharacterLanguages(
      languages: languagesController.text.isEmpty 
          ? [] 
          : languagesController.text.split(',').map((e) => e.trim()).toList(),
    );
  }

  CharacterMoneyItems _buildMoneyItems() {
    final itemsText = _getQuillText(itemsController);
    return CharacterMoneyItems(
      money: moneyController.text,
      items: itemsText.isEmpty 
          ? [] 
          : itemsText.split('\n').where((e) => e.trim().isNotEmpty).toList(),
    );
  }

  String _getQuillText(QuillController controller) {
    try {
      return jsonEncode(controller.document.toDelta().toJson());
    } catch (e) {
      _logger.error('Error getting Quill text', error: e);
      return '';
    }
  }

  /// Dispose all controllers
  void dispose() {
    _logger.debug('Disposing all form controllers');

    // Basic info
    nameController.dispose();
    levelController.dispose();
    classController.dispose();
    subclassController.dispose();
    raceController.dispose();
    backgroundController.dispose();

    // Stats
    strengthController.dispose();
    dexterityController.dispose();
    constitutionController.dispose();
    intelligenceController.dispose();
    wisdomController.dispose();
    charismaController.dispose();
    proficiencyBonusController.dispose();
    armorClassController.dispose();
    speedController.dispose();
    initiativeController.dispose();

    // Health
    maxHpController.dispose();
    currentHpController.dispose();
    tempHpController.dispose();
    hitDiceController.dispose();
    hitDiceTypeController.dispose();

    // Appearance
    heightController.dispose();
    ageController.dispose();
    eyeColorController.dispose();
    additionalDetailsController.dispose();

    // Pillars
    gimmickController.dispose();
    quirkController.dispose();
    wantsController.dispose();
    needsController.dispose();
    conflictController.dispose();

    // Other
    languagesController.dispose();
    moneyController.dispose();
    itemsController.dispose();

    // Quill controllers
    quickGuideController.dispose();
    proficienciesController.dispose();
    featuresTraitsController.dispose();
    backstoryController.dispose();
    featNotesController.dispose();

    _logger.debug('All form controllers disposed');
  }
}
