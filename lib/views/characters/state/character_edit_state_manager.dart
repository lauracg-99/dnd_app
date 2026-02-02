import 'package:flutter/material.dart';
import '../../../models/character_model.dart';
import '../../../utils/logger.dart';

/// State manager for CharacterEditScreen
/// 
/// This class centralizes all the state management for the character edit screen,
/// reducing the complexity of the main widget and making it easier to test.
class CharacterEditStateManager extends ChangeNotifier {
  static final _logger = AppLogger.forModule('CharacterEditState');

  // Character being edited
  Character _character;
  Character get character => _character;

  // Image paths
  String? _customImagePath;
  String? _appearanceImagePath;
  String? _customImageData;
  String? _appearanceImageData;

  String? get customImagePath => _customImagePath;
  String? get appearanceImagePath => _appearanceImagePath;
  String? get customImageData => _customImageData;
  String? get appearanceImageData => _appearanceImageData;

  // UI state
  bool _isPickingImage = false;
  bool _hasUnsavedAbilityChanges = false;
  bool _hasUnsavedClassChanges = false;
  bool _isLoading = false;
  bool _toolbarExpanded = false;
  bool _isEditingCharacterCover = false;

  bool get isPickingImage => _isPickingImage;
  bool get hasUnsavedAbilityChanges => _hasUnsavedAbilityChanges;
  bool get hasUnsavedClassChanges => _hasUnsavedClassChanges;
  bool get isLoading => _isLoading;
  bool get toolbarExpanded => _toolbarExpanded;
  bool get isEditingCharacterCover => _isEditingCharacterCover;

  // Class and background
  String _selectedClass;
  String _selectedBackground;
  bool _useCustomSubclass = false;

  String get selectedClass => _selectedClass;
  String get selectedBackground => _selectedBackground;
  bool get useCustomSubclass => _useCustomSubclass;

  // Death saves
  List<bool> _deathSaveSuccesses = [false, false, false];
  List<bool> _deathSaveFailures = [false, false, false];

  List<bool> get deathSaveSuccesses => List.unmodifiable(_deathSaveSuccesses);
  List<bool> get deathSaveFailures => List.unmodifiable(_deathSaveFailures);

  // Other state
  bool _hasConcentration = false;
  bool _hasInspiration = false;

  bool get hasConcentration => _hasConcentration;
  bool get hasInspiration => _hasInspiration;

  CharacterEditStateManager({
    required Character character,
  })  : _character = character,
        _selectedClass = character.characterClass,
        _selectedBackground = character.background ?? '' {
    _initializeFromCharacter();
  }

  void _initializeFromCharacter() {
    _customImagePath = _character.customImagePath;
    _customImageData = _character.customImageData;
    _appearanceImagePath = _character.appearance.appearanceImagePath;
    _appearanceImageData = _character.appearance.appearanceImageData;
    
    _deathSaveSuccesses = List.from(_character.deathSaves.successes);
    _deathSaveFailures = List.from(_character.deathSaves.failures);
    
    _logger.debug('State manager initialized for character: ${_character.name}');
  }

  // Image management
  void setCustomImagePath(String? path) {
    _customImagePath = path;
    notifyListeners();
  }

  void setCustomImageData(String? data) {
    _customImageData = data;
    notifyListeners();
  }

  void setAppearanceImagePath(String? path) {
    _appearanceImagePath = path;
    notifyListeners();
  }

  void setAppearanceImageData(String? data) {
    _appearanceImageData = data;
    notifyListeners();
  }

  void setIsPickingImage(bool value) {
    _isPickingImage = value;
    notifyListeners();
  }

  // UI state management
  void setHasUnsavedAbilityChanges(bool value) {
    _hasUnsavedAbilityChanges = value;
    notifyListeners();
  }

  void setHasUnsavedClassChanges(bool value) {
    _hasUnsavedClassChanges = value;
    notifyListeners();
  }

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setToolbarExpanded(bool value) {
    _toolbarExpanded = value;
    notifyListeners();
  }

  void setIsEditingCharacterCover(bool value) {
    _isEditingCharacterCover = value;
    notifyListeners();
  }

  // Class and background
  void setSelectedClass(String value) {
    _selectedClass = value;
    _hasUnsavedClassChanges = true;
    notifyListeners();
  }

  void setSelectedBackground(String value) {
    _selectedBackground = value;
    _hasUnsavedClassChanges = true;
    notifyListeners();
  }

  void setUseCustomSubclass(bool value) {
    _useCustomSubclass = value;
    notifyListeners();
  }

  // Death saves
  void toggleDeathSaveSuccess(int index) {
    if (index >= 0 && index < 3) {
      _deathSaveSuccesses[index] = !_deathSaveSuccesses[index];
      notifyListeners();
    }
  }

  void toggleDeathSaveFailure(int index) {
    if (index >= 0 && index < 3) {
      _deathSaveFailures[index] = !_deathSaveFailures[index];
      notifyListeners();
    }
  }

  void clearDeathSaves() {
    _deathSaveSuccesses = [false, false, false];
    _deathSaveFailures = [false, false, false];
    notifyListeners();
  }

  // Other state
  void toggleConcentration() {
    _hasConcentration = !_hasConcentration;
    notifyListeners();
  }

  void toggleInspiration() {
    _hasInspiration = !_hasInspiration;
    notifyListeners();
  }

  // Character updates
  void updateCharacter(Character newCharacter) {
    _character = newCharacter;
    _initializeFromCharacter();
    notifyListeners();
  }

  // Reset unsaved changes flags
  void resetUnsavedChanges() {
    _hasUnsavedAbilityChanges = false;
    _hasUnsavedClassChanges = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _logger.debug('State manager disposed');
    super.dispose();
  }
}
