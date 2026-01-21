import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../models/character_model.dart';

/// Helper class for managing character edit controllers
class CharacterEditControllers {
  // Death saves controllers
  final List<bool> deathSaveSuccesses = [false, false, false];
  final List<bool> deathSaveFailures = [false, false, false];

  // Languages controller
  final languagesController = TextEditingController();

  // Money and items controllers
  final moneyController = TextEditingController();
  final itemsController = TextEditingController();

  // Form controllers
  final nameController = TextEditingController();
  final levelController = TextEditingController();
  final classController = TextEditingController();
  final subclassController = TextEditingController();
  final raceController = TextEditingController();
  final backgroundController = TextEditingController();
  final quickGuideController = TextEditingController();
  final backstoryController = TextEditingController();
  final featNotesController = TextEditingController();

  // Appearance controllers
  final heightController = TextEditingController();
  final ageController = TextEditingController();
  final eyeColorController = TextEditingController();
  final additionalDetailsController = TextEditingController();

  // Pillars controllers
  final gimmickController = TextEditingController();
  final quirkController = TextEditingController();
  final wantsController = TextEditingController();
  final needsController = TextEditingController();
  final conflictController = TextEditingController();

  // Stats controllers
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

  // Health controllers
  final maxHpController = TextEditingController();
  final currentHpController = TextEditingController();
  final tempHpController = TextEditingController();
  final hitDiceController = TextEditingController();
  final hitDiceTypeController = TextEditingController();

  /// Initialize all controllers from character data
  void initializeFromCharacter(Character character) {
    // Basic info
    nameController.text = character.name ?? '';
    levelController.text = character.level?.toString() ?? '';
    classController.text = character.characterClass ?? '';
    subclassController.text = character.subclass ?? '';
    raceController.text = character.race ?? '';
    backgroundController.text = character.background ?? '';
    quickGuideController.text = character.quickGuide ?? '';
    backstoryController.text = character.backstory ?? '';
    featNotesController.text = character.featNotes ?? '';

    // Appearance
    heightController.text = character.height ?? '';
    ageController.text = character.age?.toString() ?? '';
    eyeColorController.text = character.eyeColor ?? '';
    additionalDetailsController.text = character.additionalDetails ?? '';

    // Pillars
    gimmickController.text = character.gimmick ?? '';
    quirkController.text = character.quirk ?? '';
    wantsController.text = character.wants ?? '';
    needsController.text = character.needs ?? '';
    conflictController.text = character.conflict ?? '';

    // Stats
    strengthController.text = character.strength?.toString() ?? '';
    dexterityController.text = character.dexterity?.toString() ?? '';
    constitutionController.text = character.constitution?.toString() ?? '';
    intelligenceController.text = character.intelligence?.toString() ?? '';
    wisdomController.text = character.wisdom?.toString() ?? '';
    charismaController.text = character.charisma?.toString() ?? '';
    proficiencyBonusController.text = character.proficiencyBonus?.toString() ?? '';
    armorClassController.text = character.armorClass?.toString() ?? '';
    speedController.text = character.speed?.toString() ?? '';
    initiativeController.text = character.initiative?.toString() ?? '';

    // Health
    maxHpController.text = character.maxHp?.toString() ?? '';
    currentHpController.text = character.currentHp?.toString() ?? '';
    tempHpController.text = character.tempHp?.toString() ?? '';
    hitDiceController.text = character.hitDice?.toString() ?? '';
    hitDiceTypeController.text = character.hitDiceType ?? '';

    // Languages and items
    languagesController.text = character.languages ?? '';
    moneyController.text = character.money ?? '';
    itemsController.text = character.items ?? '';
  }

  /// Dispose all controllers
  void disposeAll() {
    // Form controllers
    nameController.dispose();
    levelController.dispose();
    classController.dispose();
    subclassController.dispose();
    raceController.dispose();
    backgroundController.dispose();
    quickGuideController.dispose();
    backstoryController.dispose();
    featNotesController.dispose();

    // Appearance controllers
    heightController.dispose();
    ageController.dispose();
    eyeColorController.dispose();
    additionalDetailsController.dispose();

    // Pillars controllers
    gimmickController.dispose();
    quirkController.dispose();
    wantsController.dispose();
    needsController.dispose();
    conflictController.dispose();

    // Stats controllers
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

    // Health controllers
    maxHpController.dispose();
    currentHpController.dispose();
    tempHpController.dispose();
    hitDiceController.dispose();
    hitDiceTypeController.dispose();

    // Languages and items controllers
    languagesController.dispose();
    moneyController.dispose();
    itemsController.dispose();
  }
}

/// Helper class for character edit state management
class CharacterEditState {
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
  
  // Character data
  late CharacterStats stats;
  late CharacterSavingThrows savingThrows;
  late CharacterSkillChecks skillChecks;
  late List<CharacterPersonalizedSlot> personalizedSlots;
  
  // Combat states
  bool hasInspiration = false;
  bool hasConcentration = false;

  /// Initialize state from character data
  void initializeFromCharacter(Character character) {
    // Initialize profile image
    if (character.profileImagePath != null && character.profileImagePath!.isNotEmpty) {
      customImagePath = character.profileImagePath;
    }

    // Initialize appearance image
    if (character.appearanceImagePath != null && character.appearanceImagePath!.isNotEmpty) {
      appearanceImagePath = character.appearanceImagePath;
    }

    // Initialize selection states
    selectedClass = character.characterClass ?? 'Fighter';
    selectedRace = character.race ?? '';
    selectedBackground = character.background ?? '';
    useCustomSubclass = false;

    // Initialize character data
    stats = character.stats ?? CharacterStats();
    savingThrows = character.savingThrows ?? CharacterSavingThrows();
    skillChecks = character.skillChecks ?? CharacterSkillChecks();
    personalizedSlots = character.personalizedSlots ?? [];

    // Initialize combat states
    hasInspiration = character.hasInspiration ?? false;
    hasConcentration = character.hasConcentration ?? false;
  }

  /// Calculate initiative based on dexterity score
  int calculateInitiative(int dexterityScore) {
    return (dexterityScore - 10) ~/ 2;
  }

  /// Update initiative if not manually modified
  void updateInitiativeIfNotManuallyModified(TextEditingController dexterityController, TextEditingController initiativeController) {
    if (!initiativeManuallyModified) {
      final dexterityScore = int.tryParse(dexterityController.text) ?? 10;
      final newInitiative = calculateInitiative(dexterityScore);
      initiativeController.text = newInitiative.toString();
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
      perceptionExpertise: skill == 'perception' ? value : skillChecks.perceptionExpertise,
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
}

/// Mixin for image handling functionality
mixin CharacterImageHandling {
  /// Show image options dialog
  void showImageOptionsDialog(
    BuildContext context, {
    required VoidCallback onTakePhoto,
    required VoidCallback onChooseFromGallery,
    VoidCallback? onRemoveImage,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  onTakePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  onChooseFromGallery();
                },
              ),
              if (onRemoveImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Image'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onRemoveImage!();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Pick and save image
  Future<String?> pickAndSaveImage(
    ImageSource source,
    String characterId, {
    String imageType = 'character',
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        // Save image to app's documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${imageType}_${characterId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImagePath = path.join(appDir.path, fileName);
        
        final File sourceFile = File(pickedFile.path);
        await sourceFile.copy(savedImagePath);

        return savedImagePath;
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }

  /// Show error message for image operations
  void showImageError(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error picking image: $error')),
    );
  }
}
