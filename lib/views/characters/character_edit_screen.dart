import 'package:dnd_app/views/characters/CharacterCoverTab/character_header_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/features_traits_section.dart';
import 'package:dnd_app/views/characters/QuickGuide/characters_quick_guide.dart';
import 'package:dnd_app/views/characters/StatsTab/stats_tab.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/combat_stats_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/concentration_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/death_saving_throws_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/health_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/initiative_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/languages_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/long_rest_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/money_and_items_section.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/other_proficiencies_section.dart';
import 'package:dnd_app/views/characters/AppeareanceTab/characters_appereance.dart';
import 'package:dnd_app/views/characters/NotesTab/characters_notes.dart';
import 'package:dnd_app/views/characters/PersonalizedSlotsTab/characters_personalized_tab.dart';
import 'package:dnd_app/views/characters/FeatsTab/characters_feats_tab.dart';
import 'package:dnd_app/views/characters/TabReorderDialog/tab_reorder_dialog.dart';
import 'package:dnd_app/utils/source_mapper.dart';
import 'package:dnd_app/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import '../../models/character_model.dart';
import '../../models/spell_model.dart';
import '../../models/race_model.dart';
import '../../models/background_model.dart';
import '../../models/weapon_model.dart';
import '../../models/tab_config_model.dart';
import '../../services/user_preferences_service.dart';
import '../../helpers/character_ability_helper.dart';
import '../../helpers/character_class_helper.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../viewmodels/spells_viewmodel.dart';
import '../../viewmodels/races_viewmodel.dart';
import '../../viewmodels/backgrounds_viewmodel.dart';
import '../../utils/image_utils.dart';
import '../../widgets/image_crop_widget.dart';
import 'SpellsTab/spell_by_level.dart';
import 'WeaponsTab/weapon_selection_dialog.dart';
import 'WeaponsTab/weapon_attack_mapper.dart';
import '../diaries/diary_list_screen.dart';

class CharacterEditScreen extends StatefulWidget {
  final Character character;

  const CharacterEditScreen({super.key, required this.character});

  @override
  State<CharacterEditScreen> createState() => _CharacterEditScreenState();
}

class _CharacterEditScreenState extends State<CharacterEditScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _customImagePath;
  String? _appearanceImagePath;
  String? _customImageData;
  String? _appearanceImageData;
  bool _isPickingImage = false;
  bool _hasUnsavedAbilityChanges = false;
  bool _hasUnsavedClassChanges = false;
  bool _isSaving = false;
  String _selectedClass = 'Fighter';
  bool _useCustomSubclass = false;
  String _selectedBackground = '';
  bool _toolbarExpanded = false;
  bool _isCustomAttackMode = false;
  
  // Baseline character data for change detection
  late Character _baselineCharacter;

  // Death saves controllers
  List<bool> _deathSaveSuccesses = [false, false, false];
  List<bool> _deathSaveFailures = [false, false, false];
  int _exhaustionLevel = 0;

  // Languages controller
  final _languagesController = TextEditingController();

  // Money and items controllers
  final _moneyController = TextEditingController();
  final _itemsController = QuillController.basic();

  // Form controllers
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  final _classController = TextEditingController();
  final _subclassController = TextEditingController();
  final _raceController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _quickGuideController = QuillController.basic();
  final _proficienciesController = QuillController.basic();
  final _featuresTraitsController = QuillController.basic();
  final _backstoryController = QuillController.basic();
  final _featNotesController = QuillController.basic();

  // Appearance controllers
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _eyeColorController = TextEditingController();
  final _additionalDetailsController = QuillController.basic();

  // Pillars controllers
  final _gimmickController = TextEditingController();
  final _quirkController = TextEditingController();
  final _wantsController = TextEditingController();
  final _needsController = TextEditingController();
  final _conflictController = TextEditingController();

  // Stats controllers
  final _strengthController = TextEditingController();
  final _dexterityController = TextEditingController();
  final _constitutionController = TextEditingController();
  final _intelligenceController = TextEditingController();
  final _wisdomController = TextEditingController();
  final _charismaController = TextEditingController();
  final _proficiencyBonusController = TextEditingController();
  final _armorClassController = TextEditingController();
  final _speedController = TextEditingController();
  final _initiativeController = TextEditingController();

  // Health controllers
  final _maxHpController = TextEditingController();
  final _currentHpController = TextEditingController();
  final _tempHpController = TextEditingController();
  final _hitDiceController = TextEditingController();
  final _hitDiceTypeController = TextEditingController();

  // Character data
  late CharacterStats _stats;
  late CharacterSavingThrows _savingThrows;
  late CharacterSkillChecks _skillChecks;
  late CharacterHealth _health;
  late CharacterSpellSlots _spellSlots;
  late CharacterSpellPreparation _spellPreparation;
  late CharacterPillars _pillars;
  late List<CharacterAttack> _attacks;
  late List<String> _spells;
  late List<String> _feats;
  late List<CharacterPersonalizedSlot> _personalizedSlots;

  // Character Cover tab edit state
  bool _isEditingCharacterCover = false;

  // Inspiration state
  bool _hasInspiration = false;

  // Concentration state
  bool _hasConcentration = false;

  // Shield state
  bool _hasShield = false;

  // Spell filter states
  bool _filterByCharacterClass = true;
  String? _selectedLevelFilter;
  String? _selectedClassFilter;
  String? _selectedSchoolFilter;
  String _searchQuery = '';

  // Tab customization
  List<String> _tabOrder = [];
  List<CharacterTabConfig> _orderedTabs = [];

  @override
  void initState() {
    super.initState();

    // Initialize with default tabs immediately to prevent empty TabBar
    _initializeDefaultTabs();

    // Initialize tab controller with default length first to prevent LateInitializationError
    _tabController = TabController(length: _orderedTabs.length, vsync: this);
    _initializeTabOrder();
    _initializeCharacterData();

    // Load races and backgrounds data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RacesViewModel>().loadRaces();
      context.read<BackgroundsViewModel>().loadBackgrounds();
    });
  }

  /// Initialize default tabs synchronously to prevent empty TabBar during initial build
  void _initializeDefaultTabs() {
    _tabOrder = CharacterTabManager.getDefaultTabOrder();

    final Map<String, Widget Function()> tabBuilders = {
      'character': () => _buildCharacterCoverTab(),
      'quick_guide': () => _buildQuickGuideTab(),
      'stats': () => _buildStatsTab(),
      'skills': () => _buildSkillsTab(),
      'attacks': () => _buildAttacksTab(),
      'spell_slots': () => _buildSpellSlotsTab(),
      'spells': () => _buildSpellsTab(),
      'feats': () => _buildFeatsTab(),
      'class_slots': () => _buildPersonalizedSlotsTab(),
      'appearance': () => _buildAppearanceTab(),
      'notes': () => _buildNotesTab(),
    };

    _orderedTabs = CharacterTabManager.getOrderedTabs(_tabOrder, tabBuilders);
  }

  void _initializeCharacterData() {
    final character = widget.character;
    
    // Set baseline character for change detection
    _baselineCharacter = character;

    // Initialize profile image
    _customImagePath = character.customImagePath;
    _appearanceImagePath = character.appearance.appearanceImagePath;

    // Initialize base64 image data
    _customImageData = character.customImageData;
    _appearanceImageData = character.appearance.appearanceImageData;

    // Initialize controllers
    _nameController.text = character.name;
    _levelController.text = character.level.toString();
    _levelController.addListener(() {
      setState(() {}); // Rebuild to update proficiency bonus display
    });
    _selectedClass = character.characterClass;
    _classController.text = character.characterClass;
    _subclassController.text = character.subclass ?? '';
    _raceController.text = character.race ?? '';
    _backgroundController.text = character.background ?? '';
    _selectedBackground = character.background ?? '';

    // Check if current subclass is custom (not in preset list)
    final availableSubclasses = CharacterClassHelper.getSubclassesForClass(
      character.characterClass,
    );
    _useCustomSubclass =
        character.subclass != null &&
        !availableSubclasses.contains(character.subclass);

    // Initialize quick guide with Delta format from plain text
    if (character.quickGuide.isNotEmpty) {
      try {
        // Try to parse as JSON (new format with rich text)
        final List<dynamic> jsonDelta = jsonDecode(character.quickGuide);
        _quickGuideController.document = Document.fromJson(jsonDelta);
      } catch (e) {
        // Fallback to plain text (old format)
        String text = character.quickGuide;
        // Ensure text ends with newline as required by flutter_quill
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        _quickGuideController.document = Document.fromDelta(delta);
      }
    }
    // Initialize proficiencies with rich text support
    if (character.proficiencies.isNotEmpty) {
      try {
        // Try to parse as JSON (new format with rich text)
        final List<dynamic> jsonDelta = jsonDecode(character.proficiencies);
        _proficienciesController.document = Document.fromJson(jsonDelta);
      } catch (e) {
        // Fallback to plain text (old format)
        String text = character.proficiencies;
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        _proficienciesController.document = Document.fromDelta(delta);
      }
    }

    if (character.featuresTraits.isNotEmpty) {
      try {
        // Try to parse as JSON (new format with rich text)
        final List<dynamic> jsonDelta = jsonDecode(character.featuresTraits);
        _featuresTraitsController.document = Document.fromJson(jsonDelta);
      } catch (e) {
        // Fallback to plain text (old format)
        String text = character.featuresTraits;
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        _featuresTraitsController.document = Document.fromDelta(delta);
      }
    }
    // Initialize backstory with rich text support
    if (character.backstory.isNotEmpty) {
      try {
        // Try to parse as JSON (new format with rich text)
        final List<dynamic> jsonDelta = jsonDecode(character.backstory);
        _backstoryController.document = Document.fromJson(jsonDelta);
      } catch (e) {
        // Fallback to plain text (old format)
        String text = character.backstory;
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        _backstoryController.document = Document.fromDelta(delta);
      }
    }

    // Initialize death saves
    _deathSaveSuccesses = List.from(character.deathSaves.successes);
    _deathSaveFailures = List.from(character.deathSaves.failures);
    _exhaustionLevel = character.deathSaves.exhaustionLevel;

    // Initialize languages and money/items
    _languagesController.text = character.languages.languages.join(', ');
    _moneyController.text = character.moneyItems.money;

    // Initialize items with rich text support
    if (character.moneyItems.items.isNotEmpty) {
      try {
        // Try to parse as JSON (new format with rich text)
        final List<dynamic> jsonDelta = jsonDecode(
          character.moneyItems.items.first,
        );
        _itemsController.document = Document.fromJson(jsonDelta);
      } catch (e) {
        // Fallback to plain text (old format)
        String text = character.moneyItems.items.join('\n');
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        _itemsController.document = Document.fromDelta(delta);
      }
    }

    // Add listeners for class changes
    _classController.addListener(() {
      if (_classController.text != character.characterClass) {
        setState(() {
          _hasUnsavedClassChanges = true;
        });
      }
    });

    _subclassController.addListener(() {
      if (_subclassController.text != (character.subclass ?? '')) {
        setState(() {
          _hasUnsavedClassChanges = true;
        });
      }
    });

    _raceController.addListener(() {
      if (_raceController.text != (character.race ?? '')) {
        setState(() {
          _hasUnsavedClassChanges = true;
        });
      }
    });
    _backgroundController.addListener(() {
      if (_backgroundController.text != (character.background ?? '')) {
        setState(() {
          _hasUnsavedClassChanges = true;
        });
      }
    });

    // Initialize stats
    _stats = character.stats;
    _strengthController.text = _stats.strength.toString();
    _dexterityController.text = _stats.dexterity.toString();
    _constitutionController.text = _stats.constitution.toString();
    _intelligenceController.text = _stats.intelligence.toString();
    _wisdomController.text = _stats.wisdom.toString();
    _charismaController.text = _stats.charisma.toString();
    _proficiencyBonusController.text = _stats.proficiencyBonus.toString();
    _armorClassController.text = _stats.armorClass.toString();
    _speedController.text = _stats.speed.toString();
    // Initialize initiative - check if it matches dexterity modifier to determine if manually modified
    final dexterityModifier = _stats.getModifier(_stats.dexterity);
    if (_stats.initiative == dexterityModifier) {
      _initiativeController.text = dexterityModifier.toString();
    } else {
      _initiativeController.text = _stats.initiative.toString();
    }
    _hasInspiration = _stats.inspiration;
    _hasConcentration = _stats.hasConcentration;
    _hasShield = _stats.hasShield;

    // Initialize saving throws and skill checks
    _savingThrows = character.savingThrows;
    _skillChecks = character.skillChecks;

    // Initialize health
    _health = character.health;
    _maxHpController.text = _health.maxHitPoints.toString();
    _currentHpController.text = _health.currentHitPoints.toString();
    _tempHpController.text = _health.temporaryHitPoints.toString();
    _hitDiceController.text = _health.hitDice.toString();
    _hitDiceTypeController.text = _health.hitDiceType;

    // Initialize attacks
    _attacks = List.from(character.attacks);

    // Initialize spell slots and spells
    _spellSlots = character.spellSlots;
    _spellPreparation = character.spellPreparation;
    _spells = List.from(character.spells);
    _feats = List.from(character.feats);
    _personalizedSlots = List.from(character.personalizedSlots);

    // Initialize pillars
    _pillars = character.pillars;
    _gimmickController.text = _pillars.gimmick;
    _quirkController.text = _pillars.quirk;
    _wantsController.text = _pillars.wants;
    _needsController.text = _pillars.needs;
    _conflictController.text = _pillars.conflict;

    // Initialize feat notes
    if (character.featNotes.isNotEmpty) {
      try {
        // Try to parse as JSON (new format with rich text)
        final List<dynamic> jsonDelta = jsonDecode(character.featNotes);
        _featNotesController.document = Document.fromJson(jsonDelta);
      } catch (e) {
        // Fallback to plain text (old format)
        String text = character.featNotes;
        // Ensure text ends with newline as required by flutter_quill
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        _featNotesController.document = Document.fromDelta(delta);
      }
    }
    // Initialize appearance
    _heightController.text = character.appearance.height;
    _ageController.text = character.appearance.age;
    _eyeColorController.text = character.appearance.eyeColor;
    // Initialize appearance additional details with rich text support
    if (character.appearance.additionalDetails.isNotEmpty) {
      try {
        // Try to parse as JSON (new format with rich text)
        final List<dynamic> jsonDelta = jsonDecode(character.appearance.additionalDetails);
        _additionalDetailsController.document = Document.fromJson(jsonDelta);
      } catch (e) {
        // Fallback to plain text (old format)
        String text = character.appearance.additionalDetails;
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        _additionalDetailsController.document = Document.fromDelta(delta);
      }
    }

    // Set up manual save (no auto-save listeners)
  }

  // Manual save - no auto-save listeners

  /// Initialize tab order from user preferences
  Future<void> _initializeTabOrder() async {
    try {
      // Initialize user preferences service
      await UserPreferencesService.initializeStorage();

      // Load user preferences
      final preferences = await UserPreferencesService.loadPreferences();
      _tabOrder = preferences.characterTabOrder;

      // Create tab builders map
      final Map<String, Widget Function()> tabBuilders = {
        'character': () => _buildCharacterCoverTab(),
        'quick_guide': () => _buildQuickGuideTab(),
        'stats': () => _buildStatsTab(),
        'skills': () => _buildSkillsTab(),
        'attacks': () => _buildAttacksTab(),
        'spell_slots': () => _buildSpellSlotsTab(),
        'spells': () => _buildSpellsTab(),
        'feats': () => _buildFeatsTab(),
        'class_slots': () => _buildPersonalizedSlotsTab(),
        'appearance': () => _buildAppearanceTab(),
        'notes': () => _buildNotesTab(),
      };

      // Get ordered tabs
      _orderedTabs = CharacterTabManager.getOrderedTabs(_tabOrder, tabBuilders);

      // Only recreate controller if length changed
      if (_tabController.length != _orderedTabs.length) {
        _tabController.dispose();
        _tabController = TabController(
          length: _orderedTabs.length,
          vsync: this,
        );
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing tab order: $e');
      // Fallback to default order
      _tabOrder = CharacterTabManager.getDefaultTabOrder();
      final Map<String, Widget Function()> tabBuilders = {
        'character': () => _buildCharacterCoverTab(),
        'quick_guide': () => _buildQuickGuideTab(),
        'stats': () => _buildStatsTab(),
        'skills': () => _buildSkillsTab(),
        'attacks': () => _buildAttacksTab(),
        'spell_slots': () => _buildSpellSlotsTab(),
        'spells': () => _buildSpellsTab(),
        'feats': () => _buildFeatsTab(),
        'class_slots': () => _buildPersonalizedSlotsTab(),
        'appearance': () => _buildAppearanceTab(),
        'notes': () => _buildNotesTab(),
      };
      _orderedTabs = CharacterTabManager.getOrderedTabs(_tabOrder, tabBuilders);

      // Only recreate controller if length changed
      if (_tabController.length != _orderedTabs.length) {
        _tabController.dispose();
        _tabController = TabController(
          length: _orderedTabs.length,
          vsync: this,
        );
      }

      setState(() {});
    }
  }

  /// Save tab order to user preferences
  Future<void> _saveTabOrder(List<String> newOrder) async {
    try {
      final preferences = await UserPreferencesService.loadPreferences();
      final updatedPreferences = preferences.copyWith(
        characterTabOrder: newOrder,
      );
      await UserPreferencesService.savePreferences(updatedPreferences);

      _tabOrder = newOrder;
      debugPrint('Tab order saved: $newOrder');
    } catch (e) {
      debugPrint('Error saving tab order: $e');
    }
  }

  /// Show dialog to reorder tabs
  void _showTabReorderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TabReorderDialog(
          currentOrder: _tabOrder,
          onOrderChanged: (newOrder) async {
            await _saveTabOrder(newOrder);
            await _initializeTabOrder(); // Refresh the tabs
          },
        );
      },
    );
  }

  /// Navigate to the character's diary list
  void _navigateToDiaries() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiaryListScreen(character: widget.character),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    // Dispose all controllers
    _nameController.dispose();
    _levelController.dispose();
    _classController.dispose();
    _subclassController.dispose();
    _raceController.dispose();
    _backgroundController.dispose();
    _quickGuideController.dispose();
    _proficienciesController.dispose();
    _featuresTraitsController.dispose();
    _backstoryController.dispose();
    _featNotesController.dispose();
    _additionalDetailsController.dispose();
    _moneyController.dispose();
    _itemsController.dispose();
    _gimmickController.dispose();
    _quirkController.dispose();
    _wantsController.dispose();
    _needsController.dispose();
    _conflictController.dispose();
    _strengthController.dispose();
    _dexterityController.dispose();
    _constitutionController.dispose();
    _intelligenceController.dispose();
    _wisdomController.dispose();
    _charismaController.dispose();
    _proficiencyBonusController.dispose();
    _armorClassController.dispose();
    _speedController.dispose();
    _initiativeController.dispose();
    _maxHpController.dispose();
    _currentHpController.dispose();
    _tempHpController.dispose();
    _hitDiceController.dispose();
    _hitDiceTypeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.character.name}'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs:
              _orderedTabs
                  .map((tab) => Tab(text: tab.label, icon: Icon(tab.icon)))
                  .toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: _navigateToDiaries,
            tooltip: "Character's Diary",
          ),
          IconButton(
            icon: const Icon(Icons.reorder),
            onPressed: _showTabReorderDialog,
            tooltip: 'Reorder Tabs',
          ),
          _isSaving
              ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.save,
                      color: hasUnsavedChanges ? Colors.purple : null,
                    ),
                    onPressed: _saveCharacter,
                  ),
                  if (hasUnsavedChanges)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // Dismiss keyboard when tapping anywhere on screen
              FocusScope.of(context).unfocus();
            },
            child: TabBarView(
              controller: _tabController,
              children: _orderedTabs.map((tab) => tab.builder()).toList(),
            ),
          ),
          // Blocking save overlay
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Saving...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharacterCoverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CharacterHeaderSection(
            isEditing: _isEditingCharacterCover,
            hasUnsavedClassChanges: _hasUnsavedClassChanges,
            onEditToggle: (bool isEditing) {
              setState(() {
                _isEditingCharacterCover = isEditing;
              });
            },
            nameController: _nameController,
            levelController: _levelController,
            classController: _classController,
            subclassController: _subclassController,
            raceController: _raceController,
            backgroundController: _backgroundController,
            customImagePath: _customImagePath,
            customImageData: _customImageData,
            onPickImage: _showImageOptionsDialog,
            onSave: () => _saveCharacter(successMessage: 'Character updated!'),
            getSubclassesForClass: CharacterClassHelper.getSubclassesForClass,
            onClassChanged: (value) {
              setState(() {
                _selectedClass = value;
                _hasUnsavedClassChanges = true;
              });
            },
            onSubclassChanged: (value) {
              setState(() {
                _hasUnsavedClassChanges = true;
              });
            },
            onRaceChanged: (value) {
              setState(() {
                _hasUnsavedClassChanges = true;
              });
            },
            onBackgroundChanged: (value) {
              debugPrint('Background changed to: $value');
              setState(() {
                _selectedBackground = value;
                _hasUnsavedClassChanges = true;
              });
            },
            buildPickImageButton: _buildPickImageButton,
            showRaceDetailsModal: _showRaceDetailsModal,
            showBackgroundDetailsModal: _showBackgroundDetailsModal,
            selectedBackground: _selectedBackground,
          ),

          const SizedBox(height: 16),

          CombatStatsSection(
            buildInspiration: _buildInspirationField,
            buildArmorClass: _buildArmorClassField,
            buildSpeed: _buildSpeedField,
          ),

          const SizedBox(height: 16),

          InitiativeSection(
            controller: _initiativeController,
            dexterityController: _dexterityController,
            onChanged: (value) {
              // Manual save only - no auto-save
            },
            showInitiativeDialog: _showInitiativeDialog,
          ),

          if (_canCastSpells())
            ConcentrationSection(
              hasConcentration: _hasConcentration,
              onToggle: () {
                setState(() {
                  _hasConcentration = !_hasConcentration;
                });
                // Manual save only - no auto-save
              },
            ),

          HealthSection(
            maxHpController: _maxHpController,
            currentHpController: _currentHpController,
            tempHpController: _tempHpController,
            hitDiceController: _hitDiceController,
            hitDiceTypeController: _hitDiceTypeController,
            exhaustionLevel: _exhaustionLevel,
            onExhaustionChanged: (level) {
              setState(() {
                _exhaustionLevel = level;
              });
              // Manual save only - no auto-save
            },
          ),

          const SizedBox(height: 24),

          DeathSavingThrowsSection(
            deathSaveSuccesses: _deathSaveSuccesses,
            deathSaveFailures: _deathSaveFailures,
            onToggleSuccess: (index) {
              setState(() {
                _deathSaveSuccesses[index] = !_deathSaveSuccesses[index];
              });
              // Manual save only - no auto-save
            },
            onToggleFailure: (index) {
              setState(() {
                _deathSaveFailures[index] = !_deathSaveFailures[index];
              });
              // Manual save only - no auto-save
            },
            onClear: () {
              setState(() {
                _deathSaveSuccesses = [false, false, false];
                _deathSaveFailures = [false, false, false];
              });
              // Manual save only - no auto-save
            },
          ),

          const SizedBox(height: 16),

          FeaturesTraitsSection(
            controller: _featuresTraitsController,
            onChanged: (value) {
              // Manual save only - no auto-save
            },
          ),

          const SizedBox(height: 16),

          OtherProficienciesSection(
            controller: _proficienciesController,
            onChanged: () {
              // Manual save only - no auto-save
            },
          ),

          const SizedBox(height: 16),

          LanguagesSection(
            onChanged: (value) {
              // Manual save only - no auto-save
            },
            languagesController: _languagesController,
          ),

          const SizedBox(height: 16),

          MoneyItemsSection(
            moneyController: _moneyController,
            itemsController: _itemsController,
            onMoneyChanged: (value) {
              // Manual save only - no auto-save
            },
            onItemsChanged: () {
              // Manual save only - no auto-save
            },
          ),

          const SizedBox(height: 30),

          LongRestSection(
            takeComprehensiveLongRest: _takeComprehensiveLongRest,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAttacksTab() {
    final spellcastingAbility = _getSpellcastingAbility();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionButton.primary(
              context: context,
              onPressed: _showAddAttackDialog,
              label: 'Add Attack',
              icon: Symbols.add_circle,
            ),
          ),

          const SizedBox(height: 6),

          // Attacks list
          if (_attacks.isEmpty) ...[
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromARGB(255, 205, 205, 205)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'No weapons added yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your character\'s weapons and attacks to track combat abilities',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ] else ...[
            ..._attacks.asMap().entries.map((entry) {
              final index = entry.key;
              final attack = entry.value;
              return Card(
                child: ListTile(
                  title: Text(attack.name),
                  subtitle: Text(
                    'Attack bonus: ${attack.attackBonus} | Damage: ${attack.damage} | Type: ${attack.damageType}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _attacks.removeAt(index);
                      });
                      // Remove attack without auto-save
                    },
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 16),
                  
        ],
      ),
    );
  }

  Widget _buildQuickGuideTab() {
    return CharactersQuickGuide(
      controller: _quickGuideController,
      onSaveCharacter: () {
        // Manual save only - no auto-save
      },
    );
  }

  Widget _buildStatsTab() {
    return StatsTab(
      levelController: _levelController,
      strengthController: _strengthController,
      dexterityController: _dexterityController,
      constitutionController: _constitutionController,
      intelligenceController: _intelligenceController,
      wisdomController: _wisdomController,
      charismaController: _charismaController,
      hasUnsavedAbilityChanges: _hasUnsavedAbilityChanges,
      savingThrows: _savingThrows,
      onSaveAbilities: () {
        // Update saving throws to reflect new ability scores
        _updateSavingThrowsFromAbilityScores();
        
        // Save the character with updated ability scores and saving throws
        _saveCharacter(successMessage: 'Ability scores and saving throws updated!');
        setState(() {
          _hasUnsavedAbilityChanges = false;
        });
      },
      onSavingThrowsChanged: (newSavingThrows) {
        debugPrint('=== onSavingThrowsChanged CHANGED ===');
        setState(() {
          _savingThrows = newSavingThrows;
          _saveCharacter(showToast: false);
        });
      },
      onAbilityChanged: () {
        debugPrint('=== ABILITY CHANGED ===');
        debugPrint(
          '_hasUnsavedAbilityChanges before: $_hasUnsavedAbilityChanges',
        );
        setState(() {
          _hasUnsavedAbilityChanges = true;
        });
        debugPrint(
          '_hasUnsavedAbilityChanges after: $_hasUnsavedAbilityChanges',
        );
        debugPrint('======================');
      },
    );
  }

  Widget _buildInspirationField() {
    final isActiveColor = _hasInspiration ? Colors.green : Colors.blue;

    return Container(
      decoration: BoxDecoration(
        color: _hasInspiration ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasInspiration ? Colors.green.shade200 : Colors.blue.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: (_hasInspiration ? Colors.green : Colors.blue).withOpacity(
              0.1,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(
              _hasInspiration ? Icons.lightbulb : Icons.lightbulb_outline,
              color: isActiveColor.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Inspiration',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActiveColor.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isActiveColor.shade100),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _hasInspiration = !_hasInspiration;
                  });
                  // Manual save only - no auto-save
                },
                borderRadius: BorderRadius.circular(8),
                child: Icon(
                  _hasInspiration ? Icons.check_circle : Icons.circle_outlined,
                  color:
                      _hasInspiration
                          ? Colors.green.shade800
                          : Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills grouped by ability scores
          _buildSkillGroup('Strength', [
            _buildSkillRow(
              'Athletics',
              'STR',
              _skillChecks.athleticsProficiency,
              _skillChecks.athleticsExpertise,
              'athletics',
            ),
          ]),

          const SizedBox(height: 24),
          _buildSkillGroup('Dexterity', [
            _buildSkillRow(
              'Acrobatics',
              'DEX',
              _skillChecks.acrobaticsProficiency,
              _skillChecks.acrobaticsExpertise,
              'acrobatics',
            ),
            _buildSkillRow(
              'Sleight of Hand',
              'DEX',
              _skillChecks.sleightOfHandProficiency,
              _skillChecks.sleightOfHandExpertise,
              'sleight_of_hand',
            ),
            _buildSkillRow(
              'Stealth',
              'DEX',
              _skillChecks.stealthProficiency,
              _skillChecks.stealthExpertise,
              'stealth',
            ),
          ]),

          const SizedBox(height: 24),
          _buildSkillGroup('Intelligence', [
            _buildSkillRow(
              'Arcana',
              'INT',
              _skillChecks.arcanaProficiency,
              _skillChecks.arcanaExpertise,
              'arcana',
            ),
            _buildSkillRow(
              'History',
              'INT',
              _skillChecks.historyProficiency,
              _skillChecks.historyExpertise,
              'history',
            ),
            _buildSkillRow(
              'Investigation',
              'INT',
              _skillChecks.investigationProficiency,
              _skillChecks.investigationExpertise,
              'investigation',
            ),
            _buildSkillRow(
              'Nature',
              'INT',
              _skillChecks.natureProficiency,
              _skillChecks.natureExpertise,
              'nature',
            ),
            _buildSkillRow(
              'Religion',
              'INT',
              _skillChecks.religionProficiency,
              _skillChecks.religionExpertise,
              'religion',
            ),
          ]),

          const SizedBox(height: 24),
          _buildSkillGroup('Wisdom', [
            _buildSkillRow(
              'Animal Handling',
              'WIS',
              _skillChecks.animalHandlingProficiency,
              _skillChecks.animalHandlingExpertise,
              'animal_handling',
            ),
            _buildSkillRow(
              'Insight',
              'WIS',
              _skillChecks.insightProficiency,
              _skillChecks.insightExpertise,
              'insight',
            ),
            _buildSkillRow(
              'Medicine',
              'WIS',
              _skillChecks.medicineProficiency,
              _skillChecks.medicineExpertise,
              'medicine',
            ),
            _buildSkillRow(
              'Perception',
              'WIS',
              _skillChecks.perceptionProficiency,
              _skillChecks.perceptionExpertise,
              'perception',
            ),
            _buildSkillRow(
              'Survival',
              'WIS',
              _skillChecks.survivalProficiency,
              _skillChecks.survivalExpertise,
              'survival',
            ),
          ]),

          const SizedBox(height: 24),
          _buildSkillGroup('Charisma', [
            _buildSkillRow(
              'Deception',
              'CHA',
              _skillChecks.deceptionProficiency,
              _skillChecks.deceptionExpertise,
              'deception',
            ),
            _buildSkillRow(
              'Intimidation',
              'CHA',
              _skillChecks.intimidationProficiency,
              _skillChecks.intimidationExpertise,
              'intimidation',
            ),
            _buildSkillRow(
              'Performance',
              'CHA',
              _skillChecks.performanceProficiency,
              _skillChecks.performanceExpertise,
              'performance',
            ),
            _buildSkillRow(
              'Persuasion',
              'CHA',
              _skillChecks.persuasionProficiency,
              _skillChecks.persuasionExpertise,
              'persuasion',
            ),
          ]),
          const SizedBox(height: 45), // Extra space at bottom of screen
        ],
      ),
    );
  }

  Widget _buildSpellSlotsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Spell Slots',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _takeLongRest,
                icon: const Icon(Icons.refresh),
                label: const Text('Restore all slots'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Summary section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spell Slot Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Calculate total slots and used
                  Consumer<CharactersViewModel>(
                    builder: (context, viewModel, child) {
                      final totalSlots =
                          _spellSlots.level1Slots +
                          _spellSlots.level2Slots +
                          _spellSlots.level3Slots +
                          _spellSlots.level4Slots +
                          _spellSlots.level5Slots +
                          _spellSlots.level6Slots +
                          _spellSlots.level7Slots +
                          _spellSlots.level8Slots +
                          _spellSlots.level9Slots;

                      final totalUsed =
                          _spellSlots.level1Used +
                          _spellSlots.level2Used +
                          _spellSlots.level3Used +
                          _spellSlots.level4Used +
                          _spellSlots.level5Used +
                          _spellSlots.level6Used +
                          _spellSlots.level7Used +
                          _spellSlots.level8Used +
                          _spellSlots.level9Used;

                      final availableSlots = totalSlots - totalUsed;

                      return Column(
                        children: [
                          _buildSummaryRow(
                            'Total Slots',
                            totalSlots.toString(),
                          ),
                          _buildSummaryRow('Used Slots', totalUsed.toString()),
                          _buildSummaryRow(
                            'Available Slots',
                            availableSlots.toString(),
                            availableSlots > 0 ? Colors.green : Colors.red,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Spell slots grid
          ...[
            for (int level = 1; level <= 9; level++)
              _buildSpellSlotField('Level $level', level),
          ],

          const SizedBox(height: 32),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSpellsTab() {
    final spellcastingAbility = _getSpellcastingAbility();
    
    // Calculate maximum prepared spells using current state from controllers
    final modifier = _getCurrentSpellcastingModifier();
    final calculatedMax = CharacterSpellPreparation.calculateMaxPreparedSpells(
      _classController.text.trim(), // Use current class from controller
      int.tryParse(_levelController.text) ??
          1, // Use current level from controller
      modifier,
    );

    // Use the stored max if it's different from calculated (user modified it)
    final maxPrepared =
        _spellPreparation.maxPreparedSpells == 0
            ? calculatedMax
            : _spellPreparation.maxPreparedSpells;

    // Check if user has modified the max (for visual indicator)
    final isModified =
        _spellPreparation.maxPreparedSpells != 0 &&
        _spellPreparation.maxPreparedSpells != calculatedMax;

    final canPrepare = maxPrepared > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),          


          // Spellcasting info section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.purple.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Spellcasting',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Only show spellcasting details if ability is detected
                if (spellcastingAbility != null) ...[
                  // Spellcasting Ability
                  _buildSpellcastingInfoRow(
                    'Spellcasting Ability',
                    _getAbilityName(spellcastingAbility),
                    '+${_getAbilityModifier(spellcastingAbility)}',
                  ),

                  const SizedBox(height: 8),

                  // Spell Save DC
                  _buildSpellcastingInfoRow(
                    'Spell Save DC',
                    '8 + Proficiency + ${_getAbilityModifier(spellcastingAbility)}',
                    _getSpellSaveDC().toString(),
                  ),

                  const SizedBox(height: 8),

                  // Spell Attack Bonus
                  _buildSpellcastingInfoRow(
                    'Spell Attack Bonus',
                    'Proficiency + ${_getAbilityModifier(spellcastingAbility)}',
                    '+${_getSpellAttackBonus()}',
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'No spellcasting ability detected for this class/subclass',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          ActionButton.primary(
            context: context,
            onPressed: _showAddSpellDialog,
            label: 'Add Spell',
            icon: Symbols.add_circle,
          ),
          
          const SizedBox(height: 14),
          // Spell preparation section - only show for classes that prepare spells
          if (canPrepare) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade50, Colors.indigo.shade100],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: Colors.indigo.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Spell Preparation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Spell Preparation Info'),
                                  content: const Text(
                                    'You can establish if a spell is always prepared or you can cast it for free. Always prepared spells don\'t count against your maximum prepared spells limit.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Got it'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 16),
                        color: Colors.indigo.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Maximum prepared spells: $maxPrepared (${_classController.text.trim()} level ${int.tryParse(_levelController.text) ?? 1} + ${_getModifierName(modifier)} $modifier modifier = $calculatedMax)${maxPrepared != calculatedMax ? ' (modified: +${(maxPrepared - calculatedMax).abs()})' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.indigo.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Currently prepared: ${_spellPreparation.currentPreparedCount}/$maxPrepared',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                _spellPreparation.currentPreparedCount <
                                        maxPrepared
                                    ? Colors.green.shade700
                                    : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _showMaxPreparedDialog,
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text(
                          'Modify',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo.shade700,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                      if (isModified) ...[
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                // Calculate the new max (calculated value)
                                final newMax = calculatedMax;

                                // Get current prepared spells (excluding always prepared)
                                final currentPrepared =
                                    _spellPreparation.preparedSpells;

                                // If we have more prepared spells than the new max, uncheck excess
                                if (currentPrepared.length > newMax) {
                                  final spellsToKeep =
                                      currentPrepared.take(newMax).toList();
                                  _spellPreparation = _spellPreparation.copyWith(
                                    maxPreparedSpells: 0, // Reset to calculated
                                    preparedSpells:
                                        spellsToKeep, // Keep only up to new max
                                  );
                                } else {
                                  // Just reset max, keep current prepared spells
                                  _spellPreparation = _spellPreparation
                                      .copyWith(maxPreparedSpells: 0);
                                }
                              });
                              // Manual save only - no auto-save
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.indigo.shade700,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Group spells by level
          SpellByLevel(
            spells: _spells,
            spellPreparation: _spellPreparation,
            character: widget.character,
            classController: _classController,
            levelController: _levelController,
            onShowSpellDetails: _showSpellDetails,
            onToggleSpellPreparation: _toggleSpellPreparation,
            onToggleAlwaysPrepared: _toggleAlwaysPrepared,
            onToggleFreeUse: _toggleFreeUse,
            onAutoSaveCharacter: () {
              // Manual save only - no auto-save
            },
            onRemoveSpell: (index) {
              setState(() {
                _spells.removeAt(index);
              });
            },
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _buildFeatsTab() {
    return CharactersFeatsTab(
      feats: _feats,
      featNotesController: _featNotesController,
      onFeatsChanged: (newFeats) {
        setState(() {
          _feats = newFeats;
        });
      },
      onAutoSaveCharacter: () {
        // Manual save only - no auto-save
      },
      characterName: widget.character.name,
    );
  }

  // Helper methods for spellcasting information
  String? _getSpellcastingAbility() {
    final className = _classController.text.toLowerCase();
    final subclass = _subclassController.text.toLowerCase();

    // Define spellcasting abilities for different classes
    final Map<String, String> classSpellcasting = {
      'wizard': 'INT',
      'sorcerer': 'CHA',
      'warlock': 'CHA',
      'bard': 'CHA',
      'cleric': 'WIS',
      'druid': 'WIS',
      'paladin': 'CHA',
      'ranger': 'WIS',
      'artificer': 'INT',
    };

    // Check main class first
    if (classSpellcasting.containsKey(className)) {
      return classSpellcasting[className];
    }

    // Check subclasses that grant spellcasting
    final Map<String, String> subclassSpellcasting = {
      'eldritch knight': 'INT',
      'arcane trickster': 'INT',
      'divine soul': 'CHA',
      'favored soul': 'CHA',
      'shadow monk': 'WIS',
      'four elements monk': 'WIS',
      'way of mercy monk': 'WIS',
    };

    if (subclassSpellcasting.containsKey(subclass)) {
      return subclassSpellcasting[subclass];
    }

    return null;
  }

  int _getAbilityScore(String ability) {
    return CharacterAbilityHelper.getAbilityScore(
      ability,
      strengthController: _strengthController,
      dexterityController: _dexterityController,
      constitutionController: _constitutionController,
      intelligenceController: _intelligenceController,
      wisdomController: _wisdomController,
      charismaController: _charismaController,
    );
  }

  int _getAbilityModifier(String ability) {
    return CharacterAbilityHelper.getAbilityModifierFromControllers(
      ability,
      strengthController: _strengthController,
      dexterityController: _dexterityController,
      constitutionController: _constitutionController,
      intelligenceController: _intelligenceController,
      wisdomController: _wisdomController,
      charismaController: _charismaController,
    );
  }

  /// Updates saving throws to reflect current ability scores
  /// This should be called when ability scores are saved
  void _updateSavingThrowsFromAbilityScores() {
    // Create new saving throws with current proficiency settings
    // The proficiency values remain the same, but the modifiers will be
    // recalculated in the UI based on the updated ability scores
    final updatedSavingThrows = CharacterSavingThrows(
      strengthProficiency: _savingThrows.strengthProficiency,
      dexterityProficiency: _savingThrows.dexterityProficiency,
      constitutionProficiency: _savingThrows.constitutionProficiency,
      intelligenceProficiency: _savingThrows.intelligenceProficiency,
      wisdomProficiency: _savingThrows.wisdomProficiency,
      charismaProficiency: _savingThrows.charismaProficiency,
    );
    
    setState(() {
      _savingThrows = updatedSavingThrows;
    });
    
    debugPrint('=== Saving throws updated based on new ability scores ===');
    debugPrint('STR modifier: ${_getAbilityModifier('strength')} (prof: ${updatedSavingThrows.strengthProficiency})');
    debugPrint('DEX modifier: ${_getAbilityModifier('dexterity')} (prof: ${updatedSavingThrows.dexterityProficiency})');
    debugPrint('CON modifier: ${_getAbilityModifier('constitution')} (prof: ${updatedSavingThrows.constitutionProficiency})');
    debugPrint('INT modifier: ${_getAbilityModifier('intelligence')} (prof: ${updatedSavingThrows.intelligenceProficiency})');
    debugPrint('WIS modifier: ${_getAbilityModifier('wisdom')} (prof: ${updatedSavingThrows.wisdomProficiency})');
    debugPrint('CHA modifier: ${_getAbilityModifier('charisma')} (prof: ${updatedSavingThrows.charismaProficiency})');
  }

  int _getSpellSaveDC() {
    final spellcastingAbility = _getSpellcastingAbility();
    if (spellcastingAbility == null) return 0;

    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(
      int.tryParse(_levelController.text) ?? 1,
    );
    final abilityModifier = _getAbilityModifier(spellcastingAbility);

    return 8 + proficiencyBonus + abilityModifier;
  }

  int _getSpellAttackBonus() {
    final spellcastingAbility = _getSpellcastingAbility();
    if (spellcastingAbility == null) return 0;

    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(
      int.tryParse(_levelController.text) ?? 1,
    );
    final abilityModifier = _getAbilityModifier(spellcastingAbility);

    return proficiencyBonus + abilityModifier;
  }

  /// Get the current spellcasting modifier from controllers (not saved character data)
  int _getCurrentSpellcastingModifier() {
    final spellcastingAbility = _getSpellcastingAbility();
    if (spellcastingAbility == null) return 0;

    return _getAbilityModifier(spellcastingAbility);
  }

  Widget _buildSpellcastingInfoRow(
    String label,
    String description,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.shade600,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAbilityName(String ability) {
    return CharacterAbilityHelper.getAbilityName(ability);
  }

  // Check if the current class or subclass can cast spells
  bool _canCastSpells() {
    final characterClass = _classController.text.trim().toLowerCase();
    final subclass = _subclassController.text.trim().toLowerCase();

    // Debug log to track spellcasting detection
    debugPrint(
      'Checking spellcasting for class: "$characterClass", subclass: "$subclass"',
    );

    // Full spellcasting classes
    final spellcastingClasses = {
      'wizard',
      'sorcerer',
      'warlock',
      'bard',
      'cleric',
      'druid',
      'artificer',
      'blood hunter',
      'mystic',
    };

    // Partial spellcasting classes (subclasses that grant spellcasting)
    final spellcastingSubclasses = {
      'eldritch knight', // Fighter subclass
      'arcane trickster', // Rogue subclass
    };

    // Check if main class is a spellcasting class
    if (spellcastingClasses.contains(characterClass)) {
      debugPrint('Class "$characterClass" is a spellcasting class');
      return true;
    }

    // Check if subclass grants spellcasting
    if (spellcastingSubclasses.contains(subclass)) {
      debugPrint('Subclass "$subclass" grants spellcasting');
      return true;
    }

    // Special case: Ranger and Paladin are spellcasting classes
    if (characterClass == 'ranger' || characterClass == 'paladin') {
      debugPrint(
        'Class "$characterClass" is a spellcasting class (special case)',
      );
      return true;
    }

    debugPrint(
      'Class "$characterClass" with subclass "$subclass" cannot cast spells',
    );
    return false;
  }

  Widget _buildArmorClassField() {
    final isActiveColor = _hasShield ? Colors.red : Colors.blue;
    return Container(
      decoration: BoxDecoration(
        color: isActiveColor.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActiveColor.shade200),
        boxShadow: [
          BoxShadow(
            color: isActiveColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(Icons.shield, color: isActiveColor.shade600, size: 24),
            const SizedBox(height: 8),
            Text(
              'Armor Class',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActiveColor.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isActiveColor.shade100),
              ),
              child: TextField(
                controller: _armorClassController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActiveColor.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Shield checkbox row
            Container(
              width: double.infinity,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isActiveColor.shade100),
              ),
              padding: EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 2),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _hasShield = !_hasShield;
                        });
                        // Manual save only - no auto-save
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        _hasShield ? Icons.check_circle : Icons.circle_outlined,
                        color:
                            _hasShield
                                ? isActiveColor.shade800
                                : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Shield',
                      style: TextStyle(
                        fontSize: 14,
                        color: isActiveColor.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(Icons.directions_run, color: Colors.blue.shade600, size: 24),
            const SizedBox(height: 8),
            Text(
              'Speed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: TextField(
                controller: _speedController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                textInputAction:
                    TextInputAction.done, // Show "Done" button on keyboard
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillGroup(String abilityName, List<Widget> skills) {
    // Get the ability modifier for this group
    final abilityAbbreviation = _getAbilityAbbreviation(abilityName);
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
                color: Colors.blue.withOpacity(0.15),
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

  String _getAbilityAbbreviation(String abilityName) {
    return CharacterAbilityHelper.getAbilityAbbreviation(abilityName);
  }

  Widget _buildSkillRow(
    String skillName,
    String ability,
    bool isProficient,
    bool hasExpertise,
    String skillKey,
  ) {
    final abilityScore = _getAbilityScore(ability);
    final modifier = ((abilityScore - 10) / 2).floor();
    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(
      int.tryParse(_levelController.text) ?? 1,
    );

    // Calculate total bonus directly instead of using old _stats object
    int total = modifier;
    if (hasExpertise) {
      total += proficiencyBonus * 2; // Expertise adds double proficiency bonus
    } else if (isProficient) {
      total += proficiencyBonus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color:
            hasExpertise
                ? Colors.purple.shade50
                : (isProficient ? Colors.green.shade50 : Colors.white),
      ),
      child: Row(
        children: [
          // Skill name
          Expanded(
            flex: 3,
            child: Text(
              skillName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          // Ability and modifier
          SizedBox(
            width: 50,
            child: Text(
              '$ability\n${modifier >= 0 ? '+' : ''}$modifier',
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          // Proficiency checkbox
          GestureDetector(
            onTap: () => _updateSkillCheck(skillKey, !isProficient),
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
          // Expertise checkbox
          GestureDetector(
            onTap: () => _updateSkillExpertise(skillKey, !hasExpertise),
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
          const SizedBox(width: 8),
          // Total bonus
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

  Widget _buildPickImageButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon:
            _isPickingImage
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
        onPressed: _showImageOptionsDialog,
        tooltip: 'Change image',
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Profile Image'),
          content: const Text(
            'Are you sure you want to remove this character\'s profile image?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeImage();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showImageOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_camera,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Profile Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Choose an option below',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Options
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Choose new image option
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage();
                        },
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Choose New Image',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.blue.shade300,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (_customImagePath != null) ...[
                        // Divider
                        Divider(height: 1, color: Colors.grey.shade200),

                        // Remove image option
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            _showDeleteConfirmation();
                          },
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Remove Image',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.red.shade300,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateSkillCheck(String skill, bool value) {
    setState(() {
      _skillChecks = CharacterSkillChecks(
        acrobaticsProficiency:
            skill == 'acrobatics' ? value : _skillChecks.acrobaticsProficiency,
        acrobaticsExpertise:
            skill == 'acrobatics'
                ? (value ? _skillChecks.acrobaticsExpertise : false)
                : _skillChecks.acrobaticsExpertise,
        animalHandlingProficiency:
            skill == 'animal_handling'
                ? value
                : _skillChecks.animalHandlingProficiency,
        animalHandlingExpertise:
            skill == 'animal_handling'
                ? (value ? _skillChecks.animalHandlingExpertise : false)
                : _skillChecks.animalHandlingExpertise,
        arcanaProficiency:
            skill == 'arcana' ? value : _skillChecks.arcanaProficiency,
        arcanaExpertise:
            skill == 'arcana'
                ? (value ? _skillChecks.arcanaExpertise : false)
                : _skillChecks.arcanaExpertise,
        athleticsProficiency:
            skill == 'athletics' ? value : _skillChecks.athleticsProficiency,
        athleticsExpertise:
            skill == 'athletics'
                ? (value ? _skillChecks.athleticsExpertise : false)
                : _skillChecks.athleticsExpertise,
        deceptionProficiency:
            skill == 'deception' ? value : _skillChecks.deceptionProficiency,
        deceptionExpertise:
            skill == 'deception'
                ? (value ? _skillChecks.deceptionExpertise : false)
                : _skillChecks.deceptionExpertise,
        historyProficiency:
            skill == 'history' ? value : _skillChecks.historyProficiency,
        historyExpertise:
            skill == 'history'
                ? (value ? _skillChecks.historyExpertise : false)
                : _skillChecks.historyExpertise,
        insightProficiency:
            skill == 'insight' ? value : _skillChecks.insightProficiency,
        insightExpertise:
            skill == 'insight'
                ? (value ? _skillChecks.insightExpertise : false)
                : _skillChecks.insightExpertise,
        intimidationProficiency:
            skill == 'intimidation'
                ? value
                : _skillChecks.intimidationProficiency,
        intimidationExpertise:
            skill == 'intimidation'
                ? (value ? _skillChecks.intimidationExpertise : false)
                : _skillChecks.intimidationExpertise,
        investigationProficiency:
            skill == 'investigation'
                ? value
                : _skillChecks.investigationProficiency,
        investigationExpertise:
            skill == 'investigation'
                ? (value ? _skillChecks.investigationExpertise : false)
                : _skillChecks.investigationExpertise,
        medicineProficiency:
            skill == 'medicine' ? value : _skillChecks.medicineProficiency,
        medicineExpertise:
            skill == 'medicine'
                ? (value ? _skillChecks.medicineExpertise : false)
                : _skillChecks.medicineExpertise,
        natureProficiency:
            skill == 'nature' ? value : _skillChecks.natureProficiency,
        natureExpertise:
            skill == 'nature'
                ? (value ? _skillChecks.natureExpertise : false)
                : _skillChecks.natureExpertise,
        perceptionProficiency:
            skill == 'perception' ? value : _skillChecks.perceptionProficiency,
        perceptionExpertise:
            skill == 'perception'
                ? (value ? _skillChecks.perceptionExpertise : false)
                : _skillChecks.perceptionExpertise,
        performanceProficiency:
            skill == 'performance'
                ? value
                : _skillChecks.performanceProficiency,
        performanceExpertise:
            skill == 'performance'
                ? (value ? _skillChecks.performanceExpertise : false)
                : _skillChecks.performanceExpertise,
        persuasionProficiency:
            skill == 'persuasion' ? value : _skillChecks.persuasionProficiency,
        persuasionExpertise:
            skill == 'persuasion'
                ? (value ? _skillChecks.persuasionExpertise : false)
                : _skillChecks.persuasionExpertise,
        religionProficiency:
            skill == 'religion' ? value : _skillChecks.religionProficiency,
        religionExpertise:
            skill == 'religion'
                ? (value ? _skillChecks.religionExpertise : false)
                : _skillChecks.religionExpertise,
        sleightOfHandProficiency:
            skill == 'sleight_of_hand'
                ? value
                : _skillChecks.sleightOfHandProficiency,
        sleightOfHandExpertise:
            skill == 'sleight_of_hand'
                ? (value ? _skillChecks.sleightOfHandExpertise : false)
                : _skillChecks.sleightOfHandExpertise,
        stealthProficiency:
            skill == 'stealth' ? value : _skillChecks.stealthProficiency,
        stealthExpertise:
            skill == 'stealth'
                ? (value ? _skillChecks.stealthExpertise : false)
                : _skillChecks.stealthExpertise,
        survivalProficiency:
            skill == 'survival' ? value : _skillChecks.survivalProficiency,
        survivalExpertise:
            skill == 'survival'
                ? (value ? _skillChecks.survivalExpertise : false)
                : _skillChecks.survivalExpertise,
      );
      // Manual save only - no auto-save for skill changes
    });
  }

  void _updateSkillExpertise(String skill, bool value) {
    setState(() {
      // If setting expertise to true, also set proficiency to true
      if (value) {
        _updateSkillCheck(skill, true);
      }

      _skillChecks = CharacterSkillChecks(
        acrobaticsProficiency: _skillChecks.acrobaticsProficiency,
        acrobaticsExpertise:
            skill == 'acrobatics' ? value : _skillChecks.acrobaticsExpertise,
        animalHandlingProficiency: _skillChecks.animalHandlingProficiency,
        animalHandlingExpertise:
            skill == 'animal_handling'
                ? value
                : _skillChecks.animalHandlingExpertise,
        arcanaProficiency: _skillChecks.arcanaProficiency,
        arcanaExpertise:
            skill == 'arcana' ? value : _skillChecks.arcanaExpertise,
        athleticsProficiency: _skillChecks.athleticsProficiency,
        athleticsExpertise:
            skill == 'athletics' ? value : _skillChecks.athleticsExpertise,
        deceptionProficiency: _skillChecks.deceptionProficiency,
        deceptionExpertise:
            skill == 'deception' ? value : _skillChecks.deceptionExpertise,
        historyProficiency: _skillChecks.historyProficiency,
        historyExpertise:
            skill == 'history' ? value : _skillChecks.historyExpertise,
        insightProficiency: _skillChecks.insightProficiency,
        insightExpertise:
            skill == 'insight' ? value : _skillChecks.insightExpertise,
        intimidationProficiency: _skillChecks.intimidationProficiency,
        intimidationExpertise:
            skill == 'intimidation'
                ? value
                : _skillChecks.intimidationExpertise,
        investigationProficiency: _skillChecks.investigationProficiency,
        investigationExpertise:
            skill == 'investigation'
                ? value
                : _skillChecks.investigationExpertise,
        medicineProficiency: _skillChecks.medicineProficiency,
        medicineExpertise:
            skill == 'medicine' ? value : _skillChecks.medicineExpertise,
        natureProficiency: _skillChecks.natureProficiency,
        natureExpertise:
            skill == 'nature' ? value : _skillChecks.natureExpertise,
        perceptionProficiency: _skillChecks.perceptionProficiency,
        perceptionExpertise:
            skill == 'perception' ? value : _skillChecks.perceptionExpertise,
        performanceProficiency: _skillChecks.performanceProficiency,
        performanceExpertise:
            skill == 'performance' ? value : _skillChecks.performanceExpertise,
        persuasionProficiency: _skillChecks.persuasionProficiency,
        persuasionExpertise:
            skill == 'persuasion' ? value : _skillChecks.persuasionExpertise,
        religionProficiency: _skillChecks.religionProficiency,
        religionExpertise:
            skill == 'religion' ? value : _skillChecks.religionExpertise,
        sleightOfHandProficiency: _skillChecks.sleightOfHandProficiency,
        sleightOfHandExpertise:
            skill == 'sleight_of_hand'
                ? value
                : _skillChecks.sleightOfHandExpertise,
        stealthProficiency: _skillChecks.stealthProficiency,
        stealthExpertise:
            skill == 'stealth' ? value : _skillChecks.stealthExpertise,
        survivalProficiency: _skillChecks.survivalProficiency,
        survivalExpertise:
            skill == 'survival' ? value : _skillChecks.survivalExpertise,
      );
      // Manual save only - no auto-save for skill expertise changes
    });
  }

  Widget _buildSummaryRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellSlotField(String label, int level) {
    int slots = 0;
    int used = 0;

    switch (level) {
      case 1:
        slots = _spellSlots.level1Slots;
        used = _spellSlots.level1Used;
        break;
      case 2:
        slots = _spellSlots.level2Slots;
        used = _spellSlots.level2Used;
        break;
      case 3:
        slots = _spellSlots.level3Slots;
        used = _spellSlots.level3Used;
        break;
      case 4:
        slots = _spellSlots.level4Slots;
        used = _spellSlots.level4Used;
        break;
      case 5:
        slots = _spellSlots.level5Slots;
        used = _spellSlots.level5Used;
        break;
      case 6:
        slots = _spellSlots.level6Slots;
        used = _spellSlots.level6Used;
        break;
      case 7:
        slots = _spellSlots.level7Slots;
        used = _spellSlots.level7Used;
        break;
      case 8:
        slots = _spellSlots.level8Slots;
        used = _spellSlots.level8Used;
        break;
      case 9:
        slots = _spellSlots.level9Slots;
        used = _spellSlots.level9Used;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text('Slots: ', style: const TextStyle(color: Colors.grey)),
                    InkWell(
                      onTap:
                          () => _showSlotModifierDialog(level, 'slots', slots),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$slots',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visual spell slot dots
            if (slots > 0) ...[
              Row(
                children: [
                  const Text('Used: ', style: TextStyle(color: Colors.grey)),
                  ...List.generate(slots, (index) {
                    final isUsed = index < used;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: GestureDetector(
                        onTap: () => _toggleSpellSlot(level, index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isUsed ? Colors.red : Colors.grey.shade300,
                            border: Border.all(
                              color:
                                  isUsed
                                      ? Colors.red.shade300
                                      : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child:
                              isUsed
                                  ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  )
                                  : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$used of $slots slots used',
                style: TextStyle(
                  color: used == slots ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.block, color: Colors.grey.shade400, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'No spell slots available',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Increase spell slots to use this feature',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateSpellSlot(int level, String type, int value) {
    setState(() {
      switch (level) {
        case 1:
          _spellSlots = CharacterSpellSlots(
            level1Slots: type == 'slots' ? value : _spellSlots.level1Slots,
            level1Used: type == 'used' ? value : _spellSlots.level1Used,
            level2Slots: _spellSlots.level2Slots,
            level2Used: _spellSlots.level2Used,
            level3Slots: _spellSlots.level3Slots,
            level3Used: _spellSlots.level3Used,
            level4Slots: _spellSlots.level4Slots,
            level4Used: _spellSlots.level4Used,
            level5Slots: _spellSlots.level5Slots,
            level5Used: _spellSlots.level5Used,
            level6Slots: _spellSlots.level6Slots,
            level6Used: _spellSlots.level6Used,
            level7Slots: _spellSlots.level7Slots,
            level7Used: _spellSlots.level7Used,
            level8Slots: _spellSlots.level8Slots,
            level8Used: _spellSlots.level8Used,
            level9Slots: _spellSlots.level9Slots,
            level9Used: _spellSlots.level9Used,
          );
          break;
        case 2:
          _spellSlots = CharacterSpellSlots(
            level1Slots: _spellSlots.level1Slots,
            level1Used: _spellSlots.level1Used,
            level2Slots: type == 'slots' ? value : _spellSlots.level2Slots,
            level2Used: type == 'used' ? value : _spellSlots.level2Used,
            level3Slots: _spellSlots.level3Slots,
            level3Used: _spellSlots.level3Used,
            level4Slots: _spellSlots.level4Slots,
            level4Used: _spellSlots.level4Used,
            level5Slots: _spellSlots.level5Slots,
            level5Used: _spellSlots.level5Used,
            level6Slots: _spellSlots.level6Slots,
            level6Used: _spellSlots.level6Used,
            level7Slots: _spellSlots.level7Slots,
            level7Used: _spellSlots.level7Used,
            level8Slots: _spellSlots.level8Slots,
            level8Used: _spellSlots.level8Used,
            level9Slots: _spellSlots.level9Slots,
            level9Used: _spellSlots.level9Used,
          );
          break;
        case 3:
          _spellSlots = CharacterSpellSlots(
            level1Slots: _spellSlots.level1Slots,
            level1Used: _spellSlots.level1Used,
            level2Slots: _spellSlots.level2Slots,
            level2Used: _spellSlots.level2Used,
            level3Slots: type == 'slots' ? value : _spellSlots.level3Slots,
            level3Used: type == 'used' ? value : _spellSlots.level3Used,
            level4Slots: _spellSlots.level4Slots,
            level4Used: _spellSlots.level4Used,
            level5Slots: _spellSlots.level5Slots,
            level5Used: _spellSlots.level5Used,
            level6Slots: _spellSlots.level6Slots,
            level6Used: _spellSlots.level6Used,
            level7Slots: _spellSlots.level7Slots,
            level7Used: _spellSlots.level7Used,
            level8Slots: _spellSlots.level8Slots,
            level8Used: _spellSlots.level8Used,
            level9Slots: _spellSlots.level9Slots,
            level9Used: _spellSlots.level9Used,
          );
          break;
        case 4:
          _spellSlots = CharacterSpellSlots(
            level1Slots: _spellSlots.level1Slots,
            level1Used: _spellSlots.level1Used,
            level2Slots: _spellSlots.level2Slots,
            level2Used: _spellSlots.level2Used,
            level3Slots: _spellSlots.level3Slots,
            level3Used: _spellSlots.level3Used,
            level4Slots: type == 'slots' ? value : _spellSlots.level4Slots,
            level4Used: type == 'used' ? value : _spellSlots.level4Used,
            level5Slots: _spellSlots.level5Slots,
            level5Used: _spellSlots.level5Used,
            level6Slots: _spellSlots.level6Slots,
            level6Used: _spellSlots.level6Used,
            level7Slots: _spellSlots.level7Slots,
            level7Used: _spellSlots.level7Used,
            level8Slots: _spellSlots.level8Slots,
            level8Used: _spellSlots.level8Used,
            level9Slots: _spellSlots.level9Slots,
            level9Used: _spellSlots.level9Used,
          );
          break;
        case 5:
          _spellSlots = CharacterSpellSlots(
            level1Slots: _spellSlots.level1Slots,
            level1Used: _spellSlots.level1Used,
            level2Slots: _spellSlots.level2Slots,
            level2Used: _spellSlots.level2Used,
            level3Slots: _spellSlots.level3Slots,
            level3Used: _spellSlots.level3Used,
            level4Slots: _spellSlots.level4Slots,
            level4Used: _spellSlots.level4Used,
            level5Slots: type == 'slots' ? value : _spellSlots.level5Slots,
            level5Used: type == 'used' ? value : _spellSlots.level5Used,
            level6Slots: _spellSlots.level6Slots,
            level6Used: _spellSlots.level6Used,
            level7Slots: _spellSlots.level7Slots,
            level7Used: _spellSlots.level7Used,
            level8Slots: _spellSlots.level8Slots,
            level8Used: _spellSlots.level8Used,
            level9Slots: _spellSlots.level9Slots,
            level9Used: _spellSlots.level9Used,
          );
          break;
        case 6:
          _spellSlots = CharacterSpellSlots(
            level1Slots: _spellSlots.level1Slots,
            level1Used: _spellSlots.level1Used,
            level2Slots: _spellSlots.level2Slots,
            level2Used: _spellSlots.level2Used,
            level3Slots: _spellSlots.level3Slots,
            level3Used: _spellSlots.level3Used,
            level4Slots: _spellSlots.level4Slots,
            level4Used: _spellSlots.level4Used,
            level5Slots: _spellSlots.level5Slots,
            level5Used: _spellSlots.level5Used,
            level6Slots: type == 'slots' ? value : _spellSlots.level6Slots,
            level6Used: type == 'used' ? value : _spellSlots.level6Used,
            level7Slots: _spellSlots.level7Slots,
            level7Used: _spellSlots.level7Used,
            level8Slots: _spellSlots.level8Slots,
            level8Used: _spellSlots.level8Used,
            level9Slots: _spellSlots.level9Slots,
            level9Used: _spellSlots.level9Used,
          );
          break;
        case 7:
          _spellSlots = CharacterSpellSlots(
            level1Slots: _spellSlots.level1Slots,
            level1Used: _spellSlots.level1Used,
            level2Slots: _spellSlots.level2Slots,
            level2Used: _spellSlots.level2Used,
            level3Slots: _spellSlots.level3Slots,
            level3Used: _spellSlots.level3Used,
            level4Slots: _spellSlots.level4Slots,
            level4Used: _spellSlots.level4Used,
            level5Slots: _spellSlots.level5Slots,
            level5Used: _spellSlots.level5Used,
            level6Slots: _spellSlots.level6Slots,
            level6Used: _spellSlots.level6Used,
            level7Slots: type == 'slots' ? value : _spellSlots.level7Slots,
            level7Used: type == 'used' ? value : _spellSlots.level7Used,
            level8Slots: _spellSlots.level8Slots,
            level8Used: _spellSlots.level8Used,
            level9Slots: _spellSlots.level9Slots,
            level9Used: _spellSlots.level9Used,
          );
          break;
        case 8:
          _spellSlots = CharacterSpellSlots(
            level1Slots: _spellSlots.level1Slots,
            level1Used: _spellSlots.level1Used,
            level2Slots: _spellSlots.level2Slots,
            level2Used: _spellSlots.level2Used,
            level3Slots: _spellSlots.level3Slots,
            level3Used: _spellSlots.level3Used,
            level4Slots: _spellSlots.level4Slots,
            level4Used: _spellSlots.level4Used,
            level5Slots: _spellSlots.level5Slots,
            level5Used: _spellSlots.level5Used,
            level6Slots: _spellSlots.level6Slots,
            level6Used: _spellSlots.level6Used,
            level7Slots: _spellSlots.level7Slots,
            level7Used: _spellSlots.level7Used,
            level8Slots: type == 'slots' ? value : _spellSlots.level8Slots,
            level8Used: type == 'used' ? value : _spellSlots.level8Used,
            level9Slots: _spellSlots.level9Slots,
            level9Used: _spellSlots.level9Used,
          );
          break;
        case 9:
          _spellSlots = CharacterSpellSlots(
            level1Slots: _spellSlots.level1Slots,
            level1Used: _spellSlots.level1Used,
            level2Slots: _spellSlots.level2Slots,
            level2Used: _spellSlots.level2Used,
            level3Slots: _spellSlots.level3Slots,
            level3Used: _spellSlots.level3Used,
            level4Slots: _spellSlots.level4Slots,
            level4Used: _spellSlots.level4Used,
            level5Slots: _spellSlots.level5Slots,
            level5Used: _spellSlots.level5Used,
            level6Slots: _spellSlots.level6Slots,
            level6Used: _spellSlots.level6Used,
            level7Slots: _spellSlots.level7Slots,
            level7Used: _spellSlots.level7Used,
            level8Slots: _spellSlots.level8Slots,
            level8Used: _spellSlots.level8Used,
            level9Slots: type == 'slots' ? value : _spellSlots.level9Slots,
            level9Used: type == 'used' ? value : _spellSlots.level9Used,
          );
          break;
      }
    });
  }

  void _toggleSpellSlot(int level, int slotIndex) {
    setState(() {
      int currentUsed = 0;

      switch (level) {
        case 1:
          currentUsed = _spellSlots.level1Used;
          break;
        case 2:
          currentUsed = _spellSlots.level2Used;
          break;
        case 3:
          currentUsed = _spellSlots.level3Used;
          break;
        case 4:
          currentUsed = _spellSlots.level4Used;
          break;
        case 5:
          currentUsed = _spellSlots.level5Used;
          break;
        case 6:
          currentUsed = _spellSlots.level6Used;
          break;
        case 7:
          currentUsed = _spellSlots.level7Used;
          break;
        case 8:
          currentUsed = _spellSlots.level8Used;
          break;
        case 9:
          currentUsed = _spellSlots.level9Used;
          break;
      }

      // Toggle the slot: if it was used, make it unused; if it was unused, make it used
      final newUsed =
          slotIndex < currentUsed ? currentUsed - 1 : currentUsed + 1;

      _updateSpellSlot(level, 'used', newUsed);
    });

    // Manual save only - no auto-save for spell slot changes
  }

  void _showSlotModifierDialog(int level, String type, int currentValue) {
    // Create a controller that we can update
    final textController = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Modify ${type == 'slots' ? 'Total Slots' : 'Used Slots'}',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type == 'slots'
                      ? 'Enter the total number of spell slots available for Level $level'
                      : 'Enter the number of spell slots currently used for Level $level',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        final newValue =
                            type == 'slots'
                                ? (currentValue - 1).clamp(0, 99)
                                : (currentValue - 1).clamp(
                                  0,
                                  _getMaxSlots(level),
                                );
                        _updateSpellSlot(level, type, newValue);
                        currentValue = newValue; // Update local value
                        textController.text =
                            newValue.toString(); // Update text field
                        // Manual save only - no auto-save
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      child: TextField(
                        controller: textController, // Use the controller
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        textInputAction:
                            TextInputAction
                                .done, // Show "Done" button on keyboard
                        onChanged: (value) {
                          final newValue = int.tryParse(value) ?? 0;
                          if (type == 'slots') {
                            if (currentValue >= 0 && currentValue <= 99) {
                              _updateSpellSlot(level, type, currentValue);
                              // Manual save only - no auto-save
                            } else {
                              _updateSpellSlot(
                                level,
                                type,
                                newValue.clamp(0, 99),
                              );
                              // Manual save only - no auto-save
                            }
                          } else {
                            _updateSpellSlot(
                              level,
                              type,
                              newValue.clamp(0, _getMaxSlots(level)),
                            );
                            // Manual save only - no auto-save
                          }
                          currentValue = newValue; // Update local value
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final maxValue =
                            type == 'slots' ? 99 : _getMaxSlots(level);
                        final newValue = (currentValue + 1).clamp(0, maxValue);
                        _updateSpellSlot(level, type, newValue);
                        currentValue = newValue; // Update local value
                        textController.text =
                            newValue.toString(); // Update text field
                        // Manual save only - no auto-save
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick action buttons
                if (type == 'slots') ...[
                  const Divider(),
                  const Text(
                    'Quick Actions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _updateSpellSlot(level, 'slots', 4);
                          currentValue = 4;
                          textController.text = '4';
                          // Manual save only - no auto-save
                        },
                        child: const Text('Set 4'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _updateSpellSlot(level, 'slots', 6);
                          currentValue = 6;
                          textController.text = '6';
                          // Manual save only - no auto-save
                        },
                        child: const Text('Set 6'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _updateSpellSlot(level, 'slots', 9);
                          currentValue = 9;
                          textController.text = '9';
                          // Manual save only - no auto-save
                        },
                        child: const Text('Set 9'),
                      ),
                    ],
                  ),
                ] else ...[
                  const Divider(),
                  const Text(
                    'Quick Actions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _updateSpellSlot(level, 'used', 0);
                          currentValue = 0;
                          textController.text = '0';
                          // Manual save only - no auto-save
                        },
                        child: const Text('Clear All'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final maxSlots = _getMaxSlots(level);
                          _updateSpellSlot(level, 'used', maxSlots);
                          currentValue = maxSlots;
                          textController.text = maxSlots.toString();
                          // Manual save only - no auto-save
                        },
                        child: const Text('Use All'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final halfSlots = _getMaxSlots(level) ~/ 2;
                          _updateSpellSlot(level, 'used', halfSlots);
                          currentValue = halfSlots;
                          textController.text = halfSlots.toString();
                          // Manual save only - no auto-save
                        },
                        child: const Text('Half Used'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),
                Text(
                  type == 'slots'
                      ? 'Range: 0-99 slots'
                      : 'Range: 0-${_getMaxSlots(level)} slots',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  int _getMaxSlots(int level) {
    switch (level) {
      case 1:
        return _spellSlots.level1Slots;
      case 2:
        return _spellSlots.level2Slots;
      case 3:
        return _spellSlots.level3Slots;
      case 4:
        return _spellSlots.level4Slots;
      case 5:
        return _spellSlots.level5Slots;
      case 6:
        return _spellSlots.level6Slots;
      case 7:
        return _spellSlots.level7Slots;
      case 8:
        return _spellSlots.level8Slots;
      case 9:
        return _spellSlots.level9Slots;
      default:
        return 0;
    }
  }

  Widget _buildPersonalizedSlotsTab() {
    return CharactersPersonalizedTab(
      personalizedSlots: _personalizedSlots,
      onPersonalizedSlotsChanged: (newSlots) {
        setState(() {
          _personalizedSlots = newSlots;
        });
      },
      onAutoSaveCharacter: () {
        // Manual save only - no auto-save
      },
      characterName: widget.character.name,
    );
  }

  Widget _buildNotesTab() {
    return CharactersNotes(
      backstoryController: _backstoryController,
      gimmickController: _gimmickController,
      quirkController: _quirkController,
      wantsController: _wantsController,
      needsController: _needsController,
      conflictController: _conflictController,
      onSaveCharacter: () {
        // Manual save only - no auto-save
      },
    );
  }

  void _showAddAttackDialog() {
    // Reset mode when dialog opens
    setState(() {
      _isCustomAttackMode = false;
    });
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Add Attack'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode selection
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              dialogSetState(() {
                                _isCustomAttackMode = false;
                              });
                              // Also update main widget state
                              setState(() {
                                _isCustomAttackMode = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: !_isCustomAttackMode ? Colors.blue.shade100 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: !_isCustomAttackMode ? Colors.blue.shade300 : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Choose from existing weapons',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: !_isCustomAttackMode ? Colors.blue.shade700 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              dialogSetState(() {
                                _isCustomAttackMode = true;
                              });
                              // Also update main widget state
                              setState(() {
                                _isCustomAttackMode = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isCustomAttackMode ? Colors.blue.shade100 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isCustomAttackMode ? Colors.blue.shade300 : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Make a custom weapon',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isCustomAttackMode ? Colors.blue.shade700 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Content based on mode
                    if (!_isCustomAttackMode) ...[
                      const Text(
                        'Browse and select from the available weapons list. Attack bonus and damage will be calculated automatically.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const Text(
                        'Enter custom attack details manually.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!_isCustomAttackMode) {
                      // Show weapon selection dialog
                      final selectedResults = await showDialog<List<WeaponSelectionResult>>(
                        context: context,
                        builder: (context) => const WeaponSelectionDialog(),
                      );
                      
                      if (selectedResults != null && selectedResults.isNotEmpty) {
                        // Map each result to character attack with custom values
                        final attacks = selectedResults.map((result) {
                          return WeaponAttackMapper.mapWeaponToAttack(
                            result.weapon, 
                            widget.character,
                            customAttackBonus: result.customAttackBonus,
                            customDamage: result.customDamage,
                          );
                        }).toList();
                        
                        // Use main widget setState to update the attacks list
                        setState(() {
                          _attacks.addAll(attacks);
                        });
                        
                        // Close the add attack dialog (weapon selection dialog already closed)
                        Navigator.of(context).pop();
                      }
                    } else {
                      // Show custom attack dialog and wait for result
                      final customAttack = await showDialog<CharacterAttack>(
                        context: context,
                        builder: (context) => _showCustomAttackDialog(),
                      );
                      
                      if (customAttack != null) {
                        // Add the custom attack to the list
                        setState(() {
                          _attacks.add(customAttack);
                        });
                        
                        // Close the add attack dialog
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text(_isCustomAttackMode ? 'Create Custom' : 'Choose Weapons'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _showCustomAttackDialog() {
    final nameController = TextEditingController();
    final bonusController = TextEditingController();
    final damageController = TextEditingController();
    final typeController = TextEditingController();
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          minWidth: 300,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          minHeight: 300,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.edit),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Custom Attack',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Form fields
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Attack Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bonusController,
              decoration: const InputDecoration(
                labelText: 'Attack Bonus',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: damageController,
                    decoration: const InputDecoration(
                      labelText: 'Damage',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty) {
                        final attack = CharacterAttack(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          attackBonus: bonusController.text.trim(),
                          damage: damageController.text.trim(),
                          damageType: typeController.text.trim(),
                        );
                        
                        // Return the created attack
                        Navigator.pop(context, attack);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Add Attack'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSpellDialog() {
    // Load spells if not already loaded
    context.read<SpellsViewModel>().loadSpells();

    final Set<String> selectedSpells = <String>{};

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent automatic dismissal to ensure we handle cleanup
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.95,
                      minWidth: 350,
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                      minHeight: 400,
                    ),
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Add Spells to ${widget.character.name}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (selectedSpells.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${selectedSpells.length} selected',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  // Reset all filter states when dialog is closed
                                  this.setState(() {
                                    _searchQuery = '';
                                    _selectedLevelFilter = null;
                                    _selectedClassFilter = null;
                                    _selectedSchoolFilter = null;
                                  });
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Filters section
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Colors.grey.shade50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Filter by character class toggle
                              Row(
                                children: [
                                  Switch(
                                    value: _filterByCharacterClass,
                                    onChanged: (value) {
                                      this.setState(() {
                                        _filterByCharacterClass = value;
                                      });
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Only show ${widget.character.characterClass} spells',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Filter dropdowns
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Consumer<SpellsViewModel>(
                                          builder: (
                                            context,
                                            spellsViewModel,
                                            child,
                                          ) {
                                            final levels = [
                                              'All',
                                              'Cantrips',
                                              'Level 1',
                                              'Level 2',
                                              'Level 3',
                                              'Level 4',
                                              'Level 5',
                                              'Level 6',
                                              'Level 7',
                                              'Level 8',
                                              'Level 9',
                                            ];
                                            return DropdownButtonFormField<
                                              String
                                            >(
                                              value:
                                                  _selectedLevelFilter ?? 'All',
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                labelText: 'Level',
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                              ),
                                              items:
                                                  levels.map((level) {
                                                    return DropdownMenuItem(
                                                      value: level,
                                                      child: Text(
                                                        level,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged: (value) {
                                                this.setState(() {
                                                  _selectedLevelFilter =
                                                      value == 'All'
                                                          ? null
                                                          : value;
                                                });
                                                setState(() {});
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Consumer<SpellsViewModel>(
                                          builder: (
                                            context,
                                            spellsViewModel,
                                            child,
                                          ) {
                                            final classes = [
                                              'All',
                                              ...spellsViewModel.spells
                                                  .map((s) => s.classes)
                                                  .expand((c) => c)
                                                  .toSet()
                                                  .toList()
                                                ..sort(),
                                            ];
                                            return DropdownButtonFormField<
                                              String
                                            >(
                                              value:
                                                  _selectedClassFilter ?? 'All',
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                labelText: 'Class',
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                              ),
                                              items:
                                                  classes.map((className) {
                                                    final displayName =
                                                        className == 'All'
                                                            ? 'All'
                                                            : className
                                                                .split('_')
                                                                .map(
                                                                  (word) =>
                                                                      word.isNotEmpty
                                                                          ? word[0].toUpperCase() +
                                                                              word.substring(1)
                                                                          : '',
                                                                )
                                                                .join(' ');
                                                    return DropdownMenuItem(
                                                      value: className,
                                                      child: Text(
                                                        displayName.length > 15
                                                            ? '${displayName.substring(0, 15)}...'
                                                            : displayName,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged: (value) {
                                                this.setState(() {
                                                  _selectedClassFilter =
                                                      value == 'All'
                                                          ? null
                                                          : value;
                                                });
                                                setState(() {});
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Consumer<SpellsViewModel>(
                                          builder: (
                                            context,
                                            spellsViewModel,
                                            child,
                                          ) {
                                            final schools = [
                                              'All',
                                              ...spellsViewModel.spells
                                                  .map((s) => s.schoolName)
                                                  .toSet()
                                                  .toList()
                                                ..sort(),
                                            ];
                                            return DropdownButtonFormField<
                                              String
                                            >(
                                              value:
                                                  _selectedSchoolFilter ??
                                                  'All',
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                labelText: 'School',
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                              ),
                                              items:
                                                  schools.map((school) {
                                                    return DropdownMenuItem(
                                                      value: school,
                                                      child: Text(
                                                        school
                                                            .split('_')
                                                            .map(
                                                              (word) =>
                                                                  word.isNotEmpty
                                                                      ? word[0]
                                                                              .toUpperCase() +
                                                                          word.substring(
                                                                            1,
                                                                          )
                                                                      : '',
                                                            )
                                                            .join(' '),
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged: (value) {
                                                this.setState(() {
                                                  _selectedSchoolFilter =
                                                      value == 'All'
                                                          ? null
                                                          : value;
                                                });
                                                setState(() {});
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search spells by name...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (query) {
                          setState(() {
                            _searchQuery = query.toLowerCase();
                          });
                        },
                      ),
                    ),

                        // Spells list
                        Expanded(
                          child: Consumer<SpellsViewModel>(
                            builder: (context, spellsViewModel, child) {
                              if (spellsViewModel.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (spellsViewModel.error != null) {
                                return Center(
                                  child: Text(
                                    'Error: ${spellsViewModel.error}',
                                  ),
                                );
                              }

                              // Apply filters
                              List<Spell> filteredSpells =
                                  spellsViewModel.spells.where((spell) {
                                    // Search by name
                                    if (_searchQuery.isNotEmpty) {
                                      if (!spell.name.toLowerCase().contains(_searchQuery)) {
                                        return false;
                                      }
                                    }

                                    // Filter by character class if enabled
                                    if (_filterByCharacterClass) {
                                      final characterClass =
                                          widget.character.characterClass
                                              .toLowerCase();
                                      if (!spell.classes.any(
                                        (className) =>
                                            className.toLowerCase() ==
                                            characterClass,
                                      )) {
                                        return false;
                                      }
                                    }

                                    // Filter by level
                                    if (_selectedLevelFilter != null) {
                                      if (_selectedLevelFilter == 'Cantrips') {
                                        if (spell.levelNumber != 0)
                                          return false;
                                      } else if (_selectedLevelFilter!
                                          .startsWith('Level')) {
                                        final level = int.tryParse(
                                          _selectedLevelFilter!.split(' ')[1],
                                        );
                                        if (spell.levelNumber != level)
                                          return false;
                                      }
                                    }

                                    // Filter by class
                                    if (_selectedClassFilter != null) {
                                      if (!spell.classes.contains(
                                        _selectedClassFilter,
                                      ))
                                        return false;
                                    }

                                    // Filter by school
                                    if (_selectedSchoolFilter != null) {
                                      if (spell.schoolName !=
                                          _selectedSchoolFilter)
                                        return false;
                                    }

                                    return true;
                                  }).toList();

                              if (filteredSpells.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No spells found with current filters',
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: filteredSpells.length,
                                itemBuilder: (context, index) {
                                  final spell = filteredSpells[index];
                                  final isKnown = _spells.contains(spell.name);
                                  final isSelected = selectedSpells.contains(
                                    spell.name,
                                  );

                                  return CheckboxListTile(
                                    value: isSelected,
                                    onChanged:
                                        isKnown
                                            ? null
                                            : (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  selectedSpells.add(
                                                    spell.name,
                                                  );
                                                } else {
                                                  selectedSpells.remove(
                                                    spell.name,
                                                  );
                                                }
                                              });
                                            },
                                    title: Text(
                                      spell.name,
                                      style: TextStyle(
                                        color: isKnown ? Colors.grey : null,
                                        decoration:
                                            isKnown
                                                ? TextDecoration.lineThrough
                                                : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${spell.schoolName.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    secondary:
                                        isKnown
                                            ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                            : Icon(
                                              isSelected
                                                  ? Icons.check_circle
                                                  : Icons.check_circle_outline,
                                              color:
                                                  isSelected
                                                      ? Colors.blue
                                                      : Colors.grey,
                                            ),
                                    enabled: !isKnown,
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        // Footer
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  // Reset all filter states when dialog is closed
                                  this.setState(() {
                                    _searchQuery = '';
                                    _selectedLevelFilter = null;
                                    _selectedClassFilter = null;
                                    _selectedSchoolFilter = null;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              Expanded(
                                child: Text(
                                  '${_spells.length} spells known',
                                  style: const TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              ElevatedButton(
                                onPressed:
                                    selectedSpells.isEmpty
                                        ? null
                                        : () {
                                          // Update the parent state first
                                          this.setState(() {
                                            _spells.addAll(selectedSpells);
                                            // Reset all filter states when dialog is closed
                                            _searchQuery = '';
                                            _selectedLevelFilter = null;
                                            _selectedClassFilter = null;
                                            _selectedSchoolFilter = null;
                                          });
                                          Navigator.pop(context);

                                          // Manual save only - no auto-save

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Added ${selectedSpells.length} spell${selectedSpells.length == 1 ? '' : 's'} to ${widget.character.name}',
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                child: Text(
                                  'Add ${selectedSpells.isEmpty ? 'Spells' : '${selectedSpells.length} Spell${selectedSpells.length == 1 ? '' : 's'}'}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _showSpellDetails(String spellName) {
    // Load spells if not already loaded
    context.read<SpellsViewModel>().loadSpells();

    // Find the spell by name with proper error handling
    final spellsViewModel = context.read<SpellsViewModel>();
    Spell? spell;

    try {
      final spells = spellsViewModel.spells;
      if (spells.isNotEmpty) {
        spell = spells.firstWhere(
          (s) => s.name.toLowerCase() == spellName.toLowerCase(),
        );
      } else {
        // Create fallback spell if no spells are loaded
        spell = _createFallbackSpell(spellName);
      }
    } catch (e) {
      // Handle case where spell is not found or other errors
      spell = _createFallbackSpell(spellName);
    }

    // Show spell details using the same modal as the spell list
    _showSpellDetailsModal(spell);
  }

  Spell _createFallbackSpell(String spellName) {
    return Spell(
      id: 'unknown',
      name: spellName,
      castingTime: 'Unknown',
      range: 'Unknown',
      duration: 'Unknown',
      description:
          'This spell details are not available in the spell database. It may be a custom spell or homebrew content.',
      classes: [],
      dice: [],
      updatedAt: DateTime.now(),
    );
  }

  void _showRaceDetailsModal(Race race) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, controller) {
              return SingleChildScrollView(
                controller: controller,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        race.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Source: ${SourceMapper.getFullBookName(race.source)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // Race info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Race Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  if (race.flySpeed != null)
                                    Text(
                                      'Flying Speed: ${race.flySpeed} ft',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Description:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        race.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showBackgroundDetailsModal(Background background) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, controller) {
              return SingleChildScrollView(
                controller: controller,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        background.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Source: ${SourceMapper.getFullBookName(background.source)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // Background info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_edu,
                              color: Colors.purple.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Background Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                  if (background.goldPieces != null)
                                    Text(
                                      'Starting Gold: ${background.goldPieces} gp',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.purple.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Features
                      if (background.features.isNotEmpty) ...[
                        Text(
                          'Features:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...background.features.map(
                          (feature) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feature.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  feature.description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description (if available from features)
                      if (background.features.isNotEmpty &&
                          background.features.first.description.isNotEmpty) ...[
                        Text(
                          'Description:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          background.features.first.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showSpellDetailsModal(Spell spell) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, controller) {
              try {
                return SingleChildScrollView(
                  controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Text(
                          spell.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${spell.schoolName.split('_').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ')} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),

                        // Character info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Known by: ${widget.character.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),

                        // Casting Time
                        _buildDetailRow('Casting Time', spell.castingTime),

                        // Range
                        _buildDetailRow('Range', spell.range),

                        // Components
                        _buildDetailRow('Components', _formatComponents(spell)),

                        // Duration
                        _buildDetailRow('Duration', spell.duration),

                        // Ritual
                        if (spell.ritual) _buildDetailRow('Ritual', 'Yes'),

                        // Classes
                        _buildDetailRow(
                          'Classes',
                          spell.classes.isNotEmpty
                              ? spell.classes
                                  .map(
                                    (c) => c
                                        .split('_')
                                        .map(
                                          (word) =>
                                              word.isNotEmpty
                                                  ? word[0].toUpperCase() +
                                                      word.substring(1)
                                                  : '',
                                        )
                                        .join(' '),
                                  )
                                  .join(', ')
                              : 'None',
                        ),

                        const Divider(),

                        // Description
                        Text(
                          spell.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('Remove Spell'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _spells.remove(spell.name);
                                  });

                                  // Manual save only - no auto-save

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Removed ${spell.name} from ${widget.character.name}',
                                      ),
                                      backgroundColor: Colors.orange,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.close),
                                label: const Text('Close'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                // Fallback UI in case of any errors
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error displaying spell details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'There was an error loading the spell details for "${spell.name}".',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatComponents(Spell spell) {
    final components = <String>[];
    if (spell.verbal) components.add('V');
    if (spell.somatic) components.add('S');
    if (spell.material && spell.components != null) {
      components.add('M (${spell.components})');
    }
    return components.join(', ');
  }

  void _takeComprehensiveLongRest() {
    final hadExhaustion = _exhaustionLevel > 0;
    final previousLevel = _exhaustionLevel;
    
    setState(() {
      // Restore hit points to maximum
      _currentHpController.text = _maxHpController.text;
      _tempHpController.text = '0';

      // Update health object
      _health = CharacterHealth(
        maxHitPoints: int.tryParse(_maxHpController.text) ?? 10,
        currentHitPoints: int.tryParse(_maxHpController.text) ?? 10,
        temporaryHitPoints: 0,
        hitDice: _health.hitDice,
        hitDiceType: _health.hitDiceType,
      );

      // Reset all used spell slots to 0 (restore all slots)
      _spellSlots = CharacterSpellSlots(
        level1Slots: _spellSlots.level1Slots,
        level1Used: 0,
        level2Slots: _spellSlots.level2Slots,
        level2Used: 0,
        level3Slots: _spellSlots.level3Slots,
        level3Used: 0,
        level4Slots: _spellSlots.level4Slots,
        level4Used: 0,
        level5Slots: _spellSlots.level5Slots,
        level5Used: 0,
        level6Slots: _spellSlots.level6Slots,
        level6Used: 0,
        level7Slots: _spellSlots.level7Slots,
        level7Used: 0,
        level8Slots: _spellSlots.level8Slots,
        level8Used: 0,
        level9Slots: _spellSlots.level9Slots,
        level9Used: 0,
      );

      // Reset all personalized slots to 0 (restore all slots)
      _personalizedSlots =
          _personalizedSlots
              .map((slot) => slot.copyWith(usedSlots: 0))
              .toList();

      // Reduce exhaustion level by 1 (minimum 0)
      if (_exhaustionLevel > 0) {
        _exhaustionLevel--;
      }
    });

    // Manual save only - no auto-save for comprehensive long rest

    // Show confirmation message
    String message = 'Long rest completed! HP, spell slots, and all class resources restored!';
    if (hadExhaustion && _exhaustionLevel < previousLevel) {
      message += ' Exhaustion reduced by 1.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _takeLongRest() {
    setState(() {
      // Reset all used spell slots to 0 (restore all slots)
      _spellSlots = CharacterSpellSlots(
        level1Slots: _spellSlots.level1Slots,
        level1Used: 0,
        level2Slots: _spellSlots.level2Slots,
        level2Used: 0,
        level3Slots: _spellSlots.level3Slots,
        level3Used: 0,
        level4Slots: _spellSlots.level4Slots,
        level4Used: 0,
        level5Slots: _spellSlots.level5Slots,
        level5Used: 0,
        level6Slots: _spellSlots.level6Slots,
        level6Used: 0,
        level7Slots: _spellSlots.level7Slots,
        level7Used: 0,
        level8Slots: _spellSlots.level8Slots,
        level8Used: 0,
        level9Slots: _spellSlots.level9Slots,
        level9Used: 0,
      );
    });

    // Manual save only - no auto-save for long rest

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All spell slots have been restored!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevent multiple calls

    setState(() {
      _isPickingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Don't compress here, let crop handle it
      );

      if (image != null && mounted) {
        final File imageFile = File(image.path);
        
        // Navigate to crop screen
        final result = await Navigator.of(context).push<Uint8List>(
          MaterialPageRoute(
            builder: (context) => ImageCropWidget(
              imageFile: imageFile,
              title: 'Crop Profile Image',
              isCircleCrop: true, // Profile images are typically circular
              aspectRatio: 1.0, // Square aspect ratio for profile
              onCropped: (croppedBytes) {
                // Let parent handle navigation with result
                Navigator.of(context).pop(croppedBytes);
              },
              onCancelled: () {
                // Let parent handle navigation with null result
                Navigator.of(context).pop(null);
              },
            ),
          ),
        );

        if (result != null && mounted) {
          // Create a permanent directory for character images
          final directory = await getApplicationDocumentsDirectory();
          final characterImagesDir = Directory(
            path.join(directory.path, 'character_images'),
          );

          // Create directory if it doesn't exist
          if (!await characterImagesDir.exists()) {
            await characterImagesDir.create(recursive: true);
          }

          // Generate unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = '${widget.character.id}_$timestamp.jpg';
          final savedImagePath = path.join(characterImagesDir.path, fileName);

          // Save cropped image
          final File savedFile = File(savedImagePath);
          await savedFile.writeAsBytes(result);

          // Clean up old image if exists
          if (_customImagePath != null &&
              _customImagePath!.startsWith(characterImagesDir.path)) {
            try {
              await File(_customImagePath!).delete();
            } catch (e) {
              // Error deleting old image: $e
            }
          }

          setState(() {
            _customImagePath = savedFile.path;
            // Convert image to base64 for JSON persistence
            _customImageData = ImageUtils.imageFileToBase64(savedFile.path);
            debugPrint(
              'Profile image cropped and saved: ${_customImageData?.length ?? 0} characters',
            );
          });

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _removeImage() async {
    try {
      // Delete the image file if it exists in our character_images directory
      if (_customImagePath != null) {
        final directory = await getApplicationDocumentsDirectory();
        final characterImagesDir = Directory(
          path.join(directory.path, 'character_images'),
        );

        if (_customImagePath!.startsWith(characterImagesDir.path)) {
          try {
            await File(_customImagePath!).delete();
          } catch (e) {
            // Error deleting image file: $e
          }
        }
      }

      setState(() {
        _customImagePath = null;
        _customImageData = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image removed'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Manual save only - no auto-save after profile image removal
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickAppearanceImage() async {
    if (_isPickingImage) return; // Prevent multiple calls

    setState(() {
      _isPickingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Don't compress here, let crop handle it
      );

      if (image != null) {
        final File imageFile = File(image.path);
        
        // Navigate to crop screen
        final result = await Navigator.of(context).push<Uint8List>(
          MaterialPageRoute(
            builder: (context) => ImageCropWidget(
              imageFile: imageFile,
              title: 'Crop Appearance Image',
              isCircleCrop: false, // Appearance images can be rectangular
              aspectRatio: null, // Free aspect ratio for appearance images
              onCropped: (croppedBytes) {
                // Let parent handle navigation with result
                Navigator.of(context).pop(croppedBytes);
              },
              onCancelled: () {
                // Let parent handle navigation with null result
                Navigator.of(context).pop(null);
              },
            ),
          ),
        );

        if (result != null && mounted) {
          final directory = await getApplicationDocumentsDirectory();
          final appearanceImagesDir = Directory(
            path.join(directory.path, 'appearance_images'),
          );
          if (!await appearanceImagesDir.exists()) {
            await appearanceImagesDir.create(recursive: true);
          }

          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final String fileName = '${widget.character.id}_appearance_$timestamp.jpg';
          final String savedImagePath = path.join(
            appearanceImagesDir.path,
            fileName,
          );
          
          // Save cropped image
          final File savedFile = File(savedImagePath);
          await savedFile.writeAsBytes(result);

          // Clean up old appearance image if exists
          if (_appearanceImagePath != null &&
              _appearanceImagePath!.startsWith(appearanceImagesDir.path)) {
            try {
              await File(_appearanceImagePath!).delete();
            } catch (e) {
              debugPrint('Error deleting old appearance image: $e');
            }
          }

          setState(() {
            _appearanceImagePath = savedFile.path;
            // Convert appearance image to base64 for JSON persistence
            _appearanceImageData = ImageUtils.imageFileToBase64(savedFile.path);
            debugPrint(
              'Appearance image cropped and converted to base64: ${_appearanceImageData?.length ?? 0} characters',
            );
          });

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appearance image updated successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking appearance image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking appearance image: $e'), duration: const Duration(seconds: 3)),
        );
      }
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  void _removeAppearanceImage() async {
    try {
      // Delete the appearance image file if it exists in our appearance_images directory
      if (_appearanceImagePath != null) {
        final directory = await getApplicationDocumentsDirectory();
        final appearanceImagesDir = Directory(
          path.join(directory.path, 'appearance_images'),
        );

        if (_appearanceImagePath!.startsWith(appearanceImagesDir.path)) {
          try {
            await File(_appearanceImagePath!).delete();
          } catch (e) {
            debugPrint('Error deleting appearance image file: $e');
          }
        }
      }

      setState(() {
        _appearanceImagePath = null;
        _appearanceImageData = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appearance image removed'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Manual save only - no auto-save after appearance image removal
    } catch (e) {
      debugPrint('Error removing appearance image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing appearance image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Check if there are any unsaved changes in the character data
  bool get hasUnsavedChanges {
    final character = _baselineCharacter;
    
    // Check basic info changes
    if (_nameController.text.trim() != character.name) return true;
    if ((int.tryParse(_levelController.text) ?? 1) != character.level) return true;
    if (_classController.text.trim() != character.characterClass) return true;
    if ((_subclassController.text.trim().isEmpty ? null : _subclassController.text.trim()) != character.subclass) return true;
    if ((_raceController.text.trim().isEmpty ? null : _raceController.text.trim()) != character.race) return true;
    if ((_backgroundController.text.trim().isEmpty ? null : _backgroundController.text.trim()) != character.background) return true;
    
    // Check image changes
    if (_customImagePath != character.customImagePath) return true;
    if (_appearanceImagePath != character.appearance.appearanceImagePath) return true;
    
    // Check stats changes
    if ((int.tryParse(_strengthController.text) ?? 10) != character.stats.strength) return true;
    if ((int.tryParse(_dexterityController.text) ?? 10) != character.stats.dexterity) return true;
    if ((int.tryParse(_constitutionController.text) ?? 10) != character.stats.constitution) return true;
    if ((int.tryParse(_intelligenceController.text) ?? 10) != character.stats.intelligence) return true;
    if ((int.tryParse(_wisdomController.text) ?? 10) != character.stats.wisdom) return true;
    if ((int.tryParse(_charismaController.text) ?? 10) != character.stats.charisma) return true;
    if ((int.tryParse(_armorClassController.text) ?? 10) != character.stats.armorClass) return true;
    if ((int.tryParse(_speedController.text) ?? 30) != character.stats.speed) return true;
    if ((int.tryParse(_initiativeController.text) ?? 0) != character.stats.initiative) return true;
    if (_hasInspiration != character.stats.inspiration) return true;
    if (_hasConcentration != character.stats.hasConcentration) return true;
    if (_hasShield != character.stats.hasShield) return true;
    
    // Check health changes
    if ((int.tryParse(_maxHpController.text) ?? 10) != character.health.maxHitPoints) return true;
    if ((int.tryParse(_currentHpController.text) ?? 10) != character.health.currentHitPoints) return true;
    if ((int.tryParse(_tempHpController.text) ?? 0) != character.health.temporaryHitPoints) return true;
    if ((int.tryParse(_hitDiceController.text) ?? 1) != character.health.hitDice) return true;
    if ((_hitDiceTypeController.text.trim().isEmpty ? 'd8' : _hitDiceTypeController.text.trim()) != character.health.hitDiceType) return true;
    
    // Check death saves changes
    if (!_listsEqual(_deathSaveSuccesses, character.deathSaves.successes)) return true;
    if (!_listsEqual(_deathSaveFailures, character.deathSaves.failures)) return true;
    if (_exhaustionLevel != character.deathSaves.exhaustionLevel) return true;
    
    // Check languages changes
    final currentLanguages = _languagesController.text
        .split(',')
        .map((lang) => lang.trim())
        .where((lang) => lang.isNotEmpty)
        .toList();
    if (!_listsEqual(currentLanguages, character.languages.languages)) return true;
    
    // Check saving throws changes
    if (_savingThrows.strengthProficiency != character.savingThrows.strengthProficiency) return true;
    if (_savingThrows.dexterityProficiency != character.savingThrows.dexterityProficiency) return true;
    if (_savingThrows.constitutionProficiency != character.savingThrows.constitutionProficiency) return true;
    if (_savingThrows.intelligenceProficiency != character.savingThrows.intelligenceProficiency) return true;
    if (_savingThrows.wisdomProficiency != character.savingThrows.wisdomProficiency) return true;
    if (_savingThrows.charismaProficiency != character.savingThrows.charismaProficiency) return true;
    
    // Check skill checks changes
    if (_skillChecks.acrobaticsProficiency != character.skillChecks.acrobaticsProficiency) return true;
    if (_skillChecks.acrobaticsExpertise != character.skillChecks.acrobaticsExpertise) return true;
    if (_skillChecks.animalHandlingProficiency != character.skillChecks.animalHandlingProficiency) return true;
    if (_skillChecks.animalHandlingExpertise != character.skillChecks.animalHandlingExpertise) return true;
    if (_skillChecks.arcanaProficiency != character.skillChecks.arcanaProficiency) return true;
    if (_skillChecks.arcanaExpertise != character.skillChecks.arcanaExpertise) return true;
    if (_skillChecks.athleticsProficiency != character.skillChecks.athleticsProficiency) return true;
    if (_skillChecks.athleticsExpertise != character.skillChecks.athleticsExpertise) return true;
    if (_skillChecks.deceptionProficiency != character.skillChecks.deceptionProficiency) return true;
    if (_skillChecks.deceptionExpertise != character.skillChecks.deceptionExpertise) return true;
    if (_skillChecks.historyProficiency != character.skillChecks.historyProficiency) return true;
    if (_skillChecks.historyExpertise != character.skillChecks.historyExpertise) return true;
    if (_skillChecks.insightProficiency != character.skillChecks.insightProficiency) return true;
    if (_skillChecks.insightExpertise != character.skillChecks.insightExpertise) return true;
    if (_skillChecks.intimidationProficiency != character.skillChecks.intimidationProficiency) return true;
    if (_skillChecks.intimidationExpertise != character.skillChecks.intimidationExpertise) return true;
    if (_skillChecks.investigationProficiency != character.skillChecks.investigationProficiency) return true;
    if (_skillChecks.investigationExpertise != character.skillChecks.investigationExpertise) return true;
    if (_skillChecks.medicineProficiency != character.skillChecks.medicineProficiency) return true;
    if (_skillChecks.medicineExpertise != character.skillChecks.medicineExpertise) return true;
    if (_skillChecks.natureProficiency != character.skillChecks.natureProficiency) return true;
    if (_skillChecks.natureExpertise != character.skillChecks.natureExpertise) return true;
    if (_skillChecks.perceptionProficiency != character.skillChecks.perceptionProficiency) return true;
    if (_skillChecks.perceptionExpertise != character.skillChecks.perceptionExpertise) return true;
    if (_skillChecks.performanceProficiency != character.skillChecks.performanceProficiency) return true;
    if (_skillChecks.performanceExpertise != character.skillChecks.performanceExpertise) return true;
    if (_skillChecks.persuasionProficiency != character.skillChecks.persuasionProficiency) return true;
    if (_skillChecks.persuasionExpertise != character.skillChecks.persuasionExpertise) return true;
    if (_skillChecks.religionProficiency != character.skillChecks.religionProficiency) return true;
    if (_skillChecks.religionExpertise != character.skillChecks.religionExpertise) return true;
    if (_skillChecks.sleightOfHandProficiency != character.skillChecks.sleightOfHandProficiency) return true;
    if (_skillChecks.sleightOfHandExpertise != character.skillChecks.sleightOfHandExpertise) return true;
    if (_skillChecks.stealthProficiency != character.skillChecks.stealthProficiency) return true;
    if (_skillChecks.stealthExpertise != character.skillChecks.stealthExpertise) return true;
    if (_skillChecks.survivalProficiency != character.skillChecks.survivalProficiency) return true;
    if (_skillChecks.survivalExpertise != character.skillChecks.survivalExpertise) return true;
    
    // Check attacks changes
    if (!_attacksEqual(_attacks, character.attacks)) return true;
    
    // Check spells changes
    if (!_listsEqual(_spells, character.spells)) return true;
    
    // Check feats changes
    if (!_listsEqual(_feats, character.feats)) return true;
    
    // Check spell slots changes
    if (_spellSlots.level1Slots != character.spellSlots.level1Slots) return true;
    if (_spellSlots.level1Used != character.spellSlots.level1Used) return true;
    if (_spellSlots.level2Slots != character.spellSlots.level2Slots) return true;
    if (_spellSlots.level2Used != character.spellSlots.level2Used) return true;
    if (_spellSlots.level3Slots != character.spellSlots.level3Slots) return true;
    if (_spellSlots.level3Used != character.spellSlots.level3Used) return true;
    if (_spellSlots.level4Slots != character.spellSlots.level4Slots) return true;
    if (_spellSlots.level4Used != character.spellSlots.level4Used) return true;
    if (_spellSlots.level5Slots != character.spellSlots.level5Slots) return true;
    if (_spellSlots.level5Used != character.spellSlots.level5Used) return true;
    if (_spellSlots.level6Slots != character.spellSlots.level6Slots) return true;
    if (_spellSlots.level6Used != character.spellSlots.level6Used) return true;
    if (_spellSlots.level7Slots != character.spellSlots.level7Slots) return true;
    if (_spellSlots.level7Used != character.spellSlots.level7Used) return true;
    if (_spellSlots.level8Slots != character.spellSlots.level8Slots) return true;
    if (_spellSlots.level8Used != character.spellSlots.level8Used) return true;
    if (_spellSlots.level9Slots != character.spellSlots.level9Slots) return true;
    if (_spellSlots.level9Used != character.spellSlots.level9Used) return true;
    
    // Check spell preparation changes
    if (_spellPreparation.preparedSpells != character.spellPreparation.preparedSpells) return true;
    if (_spellPreparation.alwaysPreparedSpells != character.spellPreparation.alwaysPreparedSpells) return true;
    if (_spellPreparation.freeUseSpells != character.spellPreparation.freeUseSpells) return true;
    
    // Check personalized slots changes
    if (!_personalizedSlotsEqual(_personalizedSlots, character.personalizedSlots)) return true;
    
    // Check money changes
    if (_moneyController.text.trim() != character.moneyItems.money) return true;
    
    // Check rich text content changes
    if (!_areDeltasEqual(_quickGuideController.document.toDelta().toJson(), character.quickGuide)) return true;
    if (!_areDeltasEqual(_proficienciesController.document.toDelta().toJson(), character.proficiencies)) return true;
    if (!_areDeltasEqual(_featuresTraitsController.document.toDelta().toJson(), character.featuresTraits)) return true;
    if (!_areDeltasEqual(_backstoryController.document.toDelta().toJson(), character.backstory)) return true;
    if (!_areDeltasEqual(_featNotesController.document.toDelta().toJson(), character.featNotes)) return true;
    if (!_areDeltasEqual(_itemsController.document.toDelta().toJson(), character.moneyItems.items.isNotEmpty ? character.moneyItems.items.first : '')) return true;
    if (!_areDeltasEqual(_additionalDetailsController.document.toDelta().toJson(), character.appearance.additionalDetails)) return true;
    
    // Check pillars changes
    if (_gimmickController.text.trim() != character.pillars.gimmick) return true;
    if (_quirkController.text.trim() != character.pillars.quirk) return true;
    if (_wantsController.text.trim() != character.pillars.wants) return true;
    if (_needsController.text.trim() != character.pillars.needs) return true;
    if (_conflictController.text.trim() != character.pillars.conflict) return true;
    
    // Check appearance changes
    if (_heightController.text.trim() != character.appearance.height) return true;
    if (_ageController.text.trim() != character.appearance.age) return true;
    if (_eyeColorController.text.trim() != character.appearance.eyeColor) return true;
    
    // Check existing flags
    if (_hasUnsavedClassChanges || _hasUnsavedAbilityChanges) return true;
    
    return false;
  }
  
  /// Helper method to compare deltas properly
  bool _areDeltasEqual(List<dynamic> currentDelta, String storedJson) {
    if (storedJson.isEmpty) {
      // If stored is empty, check if current is also empty (just a newline)
      final currentText = currentDelta.isNotEmpty ? currentDelta.first['insert']?.toString() ?? '' : '';
      return currentText.trim().isEmpty;
    }
    
    try {
      final storedDelta = jsonDecode(storedJson);
      // Compare the JSON strings for reliable comparison
      return jsonEncode(currentDelta) == jsonEncode(storedDelta);
    } catch (e) {
      // If stored is not valid JSON, treat it as plain text
      final currentText = currentDelta.isNotEmpty ? currentDelta.first['insert']?.toString() ?? '' : '';
      return currentText.trim() == storedJson.trim();
    }
  }
  
  /// Helper method to parse JSON delta from string
  List<dynamic> _parseJsonDelta(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      // Fallback to plain text
      final delta = Delta()..insert(jsonString.endsWith('\n') ? jsonString : '$jsonString\n');
      return delta.toJson();
    }
  }
  
  /// Helper method to compare lists
  bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  
  /// Helper method to compare attack lists
  bool _attacksEqual(List<CharacterAttack> a, List<CharacterAttack> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_attackEqual(a[i], b[i])) return false;
    }
    return true;
  }
  
  /// Helper method to compare individual attacks
  bool _attackEqual(CharacterAttack a, CharacterAttack b) {
    return a.id == b.id &&
           a.name == b.name &&
           a.attackBonus == b.attackBonus &&
           a.damage == b.damage &&
           a.damageType == b.damageType;
  }
  
  /// Helper method to compare personalized slots lists
  bool _personalizedSlotsEqual(List<CharacterPersonalizedSlot> a, List<CharacterPersonalizedSlot> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_personalizedSlotEqual(a[i], b[i])) return false;
    }
    return true;
  }
  
  /// Helper method to compare individual personalized slots
  bool _personalizedSlotEqual(CharacterPersonalizedSlot a, CharacterPersonalizedSlot b) {
    return a.name == b.name &&
           a.maxSlots == b.maxSlots &&
           a.usedSlots == b.usedSlots &&
           a.diceType == b.diceType;
  }

  void _saveCharacter({String? successMessage, bool showToast = true}) async {
    // Show loading indicator with blocking overlay
    setState(() {
      _isSaving = true;
    });

    try {
      // Add minimum delay to show spinner for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update all character data from controllers
      debugPrint('=== SAVE CHARACTER DEBUG ===');
      debugPrint('Background controller text: "${_backgroundController.text}"');
      debugPrint('Selected background: "$_selectedBackground"');
      debugPrint('Has unsaved changes: $_hasUnsavedClassChanges');

      final updatedCharacter = widget.character.copyWith(
        name: _nameController.text.trim(),
        customImagePath: _customImagePath,
        customImageData: _customImageData,
        characterClass: _classController.text.trim(),
        level: int.tryParse(_levelController.text) ?? 1,
        subclass:
            _subclassController.text.trim().isEmpty
                ? null
                : _subclassController.text.trim(),
        race:
            _raceController.text.trim().isEmpty
                ? null
                : _raceController.text.trim(),
        background:
            _backgroundController.text.trim().isEmpty
                ? null
                : _backgroundController.text.trim(),
        stats: CharacterStats(
          strength: int.tryParse(_strengthController.text) ?? 10,
          dexterity: int.tryParse(_dexterityController.text) ?? 10,
          constitution: int.tryParse(_constitutionController.text) ?? 10,
          intelligence: int.tryParse(_intelligenceController.text) ?? 10,
          wisdom: int.tryParse(_wisdomController.text) ?? 10,
          charisma: int.tryParse(_charismaController.text) ?? 10,
          proficiencyBonus: CharacterStats.calculateProficiencyBonus(
            int.tryParse(_levelController.text) ?? 1,
          ),
          armorClass: int.tryParse(_armorClassController.text) ?? 10,
          speed: int.tryParse(_speedController.text) ?? 30,
          initiative: int.tryParse(_initiativeController.text) ?? 0,
          inspiration: _hasInspiration,
          hasConcentration: _hasConcentration,
          hasShield: _hasShield,
        ),
        savingThrows: _savingThrows,
        skillChecks: _skillChecks,
        health: CharacterHealth(
          maxHitPoints: int.tryParse(_maxHpController.text) ?? 10,
          currentHitPoints: int.tryParse(_currentHpController.text) ?? 10,
          temporaryHitPoints: int.tryParse(_tempHpController.text) ?? 0,
          hitDice: int.tryParse(_hitDiceController.text) ?? 1,
          hitDiceType:
              _hitDiceTypeController.text.trim().isEmpty
                  ? 'd8'
                  : _hitDiceTypeController.text.trim(),
        ),
        attacks: _attacks,
        spellSlots: _spellSlots,
        spells: _spells,
        feats: _feats,
        personalizedSlots: _personalizedSlots,
        spellPreparation: _spellPreparation,
        quickGuide: jsonEncode(
          _quickGuideController.document.toDelta().toJson(),
        ),
        proficiencies: jsonEncode(
          _proficienciesController.document.toDelta().toJson(),
        ),
        featuresTraits: jsonEncode(
          _featuresTraitsController.document.toDelta().toJson(),
        ),
        backstory: jsonEncode(_backstoryController.document.toDelta().toJson()),
        featNotes: jsonEncode(_featNotesController.document.toDelta().toJson()),
        pillars: CharacterPillars(
          gimmick: _gimmickController.text.trim(),
          quirk: _quirkController.text.trim(),
          wants: _wantsController.text.trim(),
          needs: _needsController.text.trim(),
          conflict: _conflictController.text.trim(),
        ),
        appearance: CharacterAppearance(
          height: _heightController.text.trim(),
          age: _ageController.text.trim(),
          eyeColor: _eyeColorController.text.trim(),
          additionalDetails: jsonEncode(
            _additionalDetailsController.document.toDelta().toJson(),
          ),
          appearanceImagePath: _appearanceImagePath ?? '',
          appearanceImageData: _appearanceImageData,
        ),
        deathSaves: CharacterDeathSaves(
          successes: _deathSaveSuccesses,
          failures: _deathSaveFailures,
          exhaustionLevel: _exhaustionLevel,
        ),
        languages: CharacterLanguages(
          languages:
              _languagesController.text
                  .split(',')
                  .map((lang) => lang.trim())
                  .where((lang) => lang.isNotEmpty)
                  .toList(),
        ),
        moneyItems: CharacterMoneyItems(
          money: _moneyController.text.trim(),
          items: [jsonEncode(_itemsController.document.toDelta().toJson())],
        ),
        updatedAt: DateTime.now(),
      );

      debugPrint('=== SAVING CHARACTER ===');
      debugPrint(
        'Updated character background: ${updatedCharacter.background}',
      );
      debugPrint('========================');

      // Save character and wait for completion
      await context.read<CharactersViewModel>().updateCharacter(
        updatedCharacter,
      );

      // Update baseline character and clear unsaved changes flags
      setState(() {
        _baselineCharacter = updatedCharacter;
        _hasUnsavedClassChanges = false;
        _hasUnsavedAbilityChanges = false;
      });

      // Show success message
      if (mounted && showToast) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage ?? 'Character saved successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to character list after successful save
        //Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving character: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save character: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Toggle spell preparation status
  void _toggleSpellPreparation(String spellId, bool prepare) {
    setState(() {
      if (prepare) {
        // Add spell to preparation if not already there
        if (!_spellPreparation.preparedSpells.contains(spellId)) {
          _spellPreparation = _spellPreparation.copyWith(
            preparedSpells: [..._spellPreparation.preparedSpells, spellId],
          );
        }
      } else {
        // Remove spell from preparation
        _spellPreparation = _spellPreparation.copyWith(
          preparedSpells: _spellPreparation.preparedSpells
              .where((id) => id != spellId)
              .toList(),
        );
      }
      // Manual save only - no auto-save for toggle preparation
    });
  }

  /// Toggle always prepared status
  void _toggleAlwaysPrepared(String spellId) {
    setState(() {
      if (_spellPreparation.isSpellAlwaysPrepared(spellId)) {
        // Remove from always prepared
        final newAlwaysPrepared =
            _spellPreparation.alwaysPreparedSpells
                .where((id) => id != spellId)
                .toList();
        _spellPreparation = _spellPreparation.copyWith(
          alwaysPreparedSpells: newAlwaysPrepared,
        );

        // Also remove from regular prepared if it's there
        if (_spellPreparation.preparedSpells.contains(spellId)) {
          final newPrepared =
              _spellPreparation.preparedSpells
                  .where((id) => id != spellId)
                  .toList();
          _spellPreparation = _spellPreparation.copyWith(
            preparedSpells: newPrepared,
          );
        }
      } else {
        // Add to always prepared
        _spellPreparation = _spellPreparation.copyWith(
          alwaysPreparedSpells: [
            ..._spellPreparation.alwaysPreparedSpells,
            spellId,
          ],
        );

        // Also add to prepared if not already there
        if (!_spellPreparation.preparedSpells.contains(spellId)) {
          _spellPreparation = _spellPreparation.copyWith(
            preparedSpells: [..._spellPreparation.preparedSpells, spellId],
          );
        }
      }
    });
    // Manual save only - no auto-save for toggle always prepared
  }

  /// Toggle free use status
  void _toggleFreeUse(String spellId) {
    setState(() {
      if (_spellPreparation.isSpellFreeUse(spellId)) {
        _spellPreparation = _spellPreparation.copyWith(
          freeUseSpells:
              _spellPreparation.freeUseSpells
                  .where((id) => id != spellId)
                  .toList(),
        );
      } else {
        _spellPreparation = _spellPreparation.copyWith(
          freeUseSpells: [..._spellPreparation.freeUseSpells, spellId],
        );
      }
    });
    // Manual save only - no auto-save for toggle free use
  }

  /// Get the name of the modifier based on character class
  String _getModifierName(int modifier) {
    final className = _classController.text.trim().toLowerCase();

    switch (className) {
      case 'wizard':
      case 'artificer':
        return 'Intelligence';
      case 'cleric':
      case 'druid':
      case 'ranger':
        return 'Wisdom';
      case 'paladin':
      case 'sorcerer':
      case 'bard':
      case 'warlock':
        return 'Charisma';
      default:
        return 'Intelligence'; // Default fallback
    }
  }

  /// Show dialog to modify initiative modifier
  void _showInitiativeDialog() {
    final currentInitiative = int.tryParse(_initiativeController.text) ?? 0;
    final dexterityScore = int.tryParse(_dexterityController.text) ?? 10;
    final dexterityModifier = ((dexterityScore - 10) / 2).floor();

    final controller = TextEditingController(
      text: currentInitiative.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modify Initiative Modifier'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter initiative modifier for this character:'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Initiative Modifier',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dexterity modifier: $dexterityModifier',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final newInitiative = int.tryParse(controller.text);
                  if (newInitiative != null) {
                    setState(() {
                      _initiativeController.text = newInitiative.toString();
                    });
                    // Manual save only - no auto-save
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid number'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  /// Show dialog to modify maximum prepared spells
  void _showMaxPreparedDialog() {
    // Calculate current max to show in dialog using current controller values
    final currentMax =
        _spellPreparation.maxPreparedSpells == 0
            ? CharacterSpellPreparation.calculateMaxPreparedSpells(
              _classController.text.trim(),
              int.tryParse(_levelController.text) ?? 1,
              _getCurrentSpellcastingModifier(),
            )
            : _spellPreparation.maxPreparedSpells;

    final controller = TextEditingController(text: currentMax.toString());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modify Maximum Prepared Spells'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter the maximum number of spells this character can prepare:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Maximum Prepared Spells',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calculated maximum: ${CharacterSpellPreparation.calculateMaxPreparedSpells(_classController.text.trim(), int.tryParse(_levelController.text) ?? 1, _getCurrentSpellcastingModifier())}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final newMax = int.tryParse(controller.text);
                  if (newMax != null && newMax >= 0) {
                    setState(() {
                      // If reducing max, uncheck ALL regular prepared spells
                      final alwaysPreparedOnly =
                          _spellPreparation.preparedSpells
                              .where(
                                (spellId) => _spellPreparation
                                    .alwaysPreparedSpells
                                    .contains(spellId),
                              )
                              .toList();

                      if (newMax < _spellPreparation.currentPreparedCount) {
                        // Clear all regular prepared spells, keep only always prepared
                        _spellPreparation = _spellPreparation.copyWith(
                          maxPreparedSpells: newMax,
                          preparedSpells: [...alwaysPreparedOnly],
                        );
                      } else {
                        // Just update max if no reduction needed
                        _spellPreparation = _spellPreparation.copyWith(
                          maxPreparedSpells: newMax,
                        );
                      }
                    });
                    // Manual save only - no auto-save
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid number'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Widget _buildAppearanceTab() {
    return CharactersAppereance(
      appearanceImagePath: _appearanceImagePath,
      appearanceImageData: _appearanceImageData,
      isPickingImage: _isPickingImage,
      pickAppearanceImage: _pickAppearanceImage,
      removeAppearanceImage: _removeAppearanceImage,
      heightController: _heightController,
      ageController: _ageController,
      eyeColorController: _eyeColorController,
      additionalDetailsController: _additionalDetailsController,
      autoSaveCharacter: () {
        // Manual save only - no auto-save
      },
    );
  }
}
