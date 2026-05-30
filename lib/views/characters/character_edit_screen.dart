import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/character_cover_tab.dart';
import 'package:dnd_app/views/characters/QuickGuideTab/characters_quick_guide.dart';
import 'package:dnd_app/views/characters/StatsTab/stats_tab.dart';
import 'package:dnd_app/views/characters/AppeareanceTab/characters_appereance.dart';
import 'package:dnd_app/views/characters/NotesTab/characters_notes.dart';
import 'package:dnd_app/views/characters/PersonalizedSlotsTab/characters_personalized_tab.dart';
import 'package:dnd_app/views/characters/FeatsTab/characters_feats_tab.dart';
import 'package:dnd_app/views/characters/TabReorderDialog/tab_reorder_dialog.dart';
import 'package:dnd_app/utils/source_mapper.dart';
import 'package:dnd_app/widgets/appfilter_chip.dart';
import 'package:dnd_app/widgets/dialogs/spell_slot_modifier_dialog.dart';
import 'package:flutter/material.dart';
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
import '../../models/tab_config_model.dart';
import '../../services/user_preferences_service.dart';
import '../../helpers/character_ability_helper.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../viewmodels/spells_viewmodel.dart';
import '../../viewmodels/races_viewmodel.dart';
import '../../viewmodels/backgrounds_viewmodel.dart';
import '../../utils/image_utils.dart';
import '../../widgets/image_crop_widget.dart';
import '../../widgets/dialogs/image_options_dialog.dart';
import '../../widgets/dialogs/max_prepared_dialog.dart';
import '../../widgets/dialogs/spell_details_modal.dart';
import 'SpellsTab/spells_tab.dart';
import 'SkillsTab/skills_tab.dart';
import 'SpellSlotsTab/spell_slots_tab.dart';
import 'AttacksTab/attacks_tab.dart';
import 'WeaponsTab/weapon_selection_dialog.dart';
import 'WeaponsTab/weapon_attack_mapper.dart';
import '../../widgets/dialogs/add_attack_dialog.dart';
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
  String _selectedBackground = '';

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

  // Skill bonus controllers
  final _acrobaticsBonusController = TextEditingController();
  final _animalHandlingBonusController = TextEditingController();
  final _arcanaBonusController = TextEditingController();
  final _athleticsBonusController = TextEditingController();
  final _deceptionBonusController = TextEditingController();
  final _historyBonusController = TextEditingController();
  final _insightBonusController = TextEditingController();
  final _intimidationBonusController = TextEditingController();
  final _investigationBonusController = TextEditingController();
  final _medicineBonusController = TextEditingController();
  final _natureBonusController = TextEditingController();
  final _perceptionBonusController = TextEditingController();
  final _performanceBonusController = TextEditingController();
  final _persuasionBonusController = TextEditingController();
  final _religionBonusController = TextEditingController();
  final _sleightOfHandBonusController = TextEditingController();
  final _stealthBonusController = TextEditingController();
  final _survivalBonusController = TextEditingController();

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
    _classController.text = character.characterClass;
    _subclassController.text = character.subclass ?? '';
    _raceController.text = character.race ?? '';
    _backgroundController.text = character.background ?? '';
    _selectedBackground = character.background ?? '';

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

    // Initialize skill bonus controllers
    _acrobaticsBonusController.text = _skillChecks.acrobaticsBonus.toString();
    _animalHandlingBonusController.text =
        _skillChecks.animalHandlingBonus.toString();
    _arcanaBonusController.text = _skillChecks.arcanaBonus.toString();
    _athleticsBonusController.text = _skillChecks.athleticsBonus.toString();
    _deceptionBonusController.text = _skillChecks.deceptionBonus.toString();
    _historyBonusController.text = _skillChecks.historyBonus.toString();
    _insightBonusController.text = _skillChecks.insightBonus.toString();
    _intimidationBonusController.text =
        _skillChecks.intimidationBonus.toString();
    _investigationBonusController.text =
        _skillChecks.investigationBonus.toString();
    _medicineBonusController.text = _skillChecks.medicineBonus.toString();
    _natureBonusController.text = _skillChecks.natureBonus.toString();
    _perceptionBonusController.text = _skillChecks.perceptionBonus.toString();
    _performanceBonusController.text = _skillChecks.performanceBonus.toString();
    _persuasionBonusController.text = _skillChecks.persuasionBonus.toString();
    _religionBonusController.text = _skillChecks.religionBonus.toString();
    _sleightOfHandBonusController.text =
        _skillChecks.sleightOfHandBonus.toString();
    _stealthBonusController.text = _skillChecks.stealthBonus.toString();
    _survivalBonusController.text = _skillChecks.survivalBonus.toString();

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
        final List<dynamic> jsonDelta = jsonDecode(
          character.appearance.additionalDetails,
        );
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

    // Dispose skill bonus controllers
    _acrobaticsBonusController.dispose();
    _animalHandlingBonusController.dispose();
    _arcanaBonusController.dispose();
    _athleticsBonusController.dispose();
    _deceptionBonusController.dispose();
    _historyBonusController.dispose();
    _insightBonusController.dispose();
    _intimidationBonusController.dispose();
    _investigationBonusController.dispose();
    _medicineBonusController.dispose();
    _natureBonusController.dispose();
    _perceptionBonusController.dispose();
    _performanceBonusController.dispose();
    _persuasionBonusController.dispose();
    _religionBonusController.dispose();
    _sleightOfHandBonusController.dispose();
    _stealthBonusController.dispose();
    _survivalBonusController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character.name),
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
              color: Colors.black.withValues(alpha: 0.5),
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
    return CharacterCoverTab(
      isEditingCharacterCover: _isEditingCharacterCover,
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
      onClassChanged: (value) {
        setState(() {
          _hasUnsavedClassChanges = true;
        });
      },
      onSubclassChanged: (value) {
        setState(() {
          _hasUnsavedClassChanges = true;
        });
      },
      onRaceChanged: (value) {
        debugPrint('Race changed to: $value');
        setState(() {
          _raceController.text = value;
          _hasUnsavedClassChanges = true;
        });
      },
      onBackgroundChanged: (value) {
        debugPrint('Background changed to: $value');
        setState(() {
          _selectedBackground = value;
          _backgroundController.text = value;
          _hasUnsavedClassChanges = true;
        });
      },
      buildPickImageButton: _buildPickImageButton,
      showRaceDetailsModal: _showRaceDetailsModal,
      showBackgroundDetailsModal: _showBackgroundDetailsModal,
      selectedBackground: _selectedBackground,
      buildInspiration: _buildInspirationField,
      buildArmorClass: _buildArmorClassField,
      buildSpeed: _buildSpeedField,
      initiativeController: _initiativeController,
      dexterityController: _dexterityController,
      onInitiativeChanged: (value) {
        // Manual save only - no auto-save
      },
      showInitiativeDialog: _showInitiativeDialog,
      hasConcentration: _canCastSpells(),
      onConcentrationToggle: () {
        setState(() {
          _hasConcentration = !_hasConcentration;
        });
      },
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
      },
      deathSaveSuccesses: _deathSaveSuccesses,
      deathSaveFailures: _deathSaveFailures,
      onToggleSuccess: (index) {
        setState(() {
          _deathSaveSuccesses[index] = !_deathSaveSuccesses[index];
        });
      },
      onToggleFailure: (index) {
        setState(() {
          _deathSaveFailures[index] = !_deathSaveFailures[index];
        });
      },
      onClearDeathSaves: () {
        setState(() {
          _deathSaveSuccesses = [false, false, false];
          _deathSaveFailures = [false, false, false];
        });
      },
      featuresTraitsController: _featuresTraitsController,
      onFeaturesTraitsChanged: (value) {
        // Manual save only - no auto-save
      },
      proficienciesController: _proficienciesController,
      onProficienciesChanged: () {
        // Manual save only - no auto-save
      },
      languagesController: _languagesController,
      onLanguagesChanged: (value) {
        // Manual save only - no auto-save
      },
      moneyController: _moneyController,
      itemsController: _itemsController,
      onMoneyChanged: (value) {
        // Manual save only - no auto-save
      },
      onItemsChanged: () {
        // Manual save only - no auto-save
      },
      takeComprehensiveLongRest: _takeComprehensiveLongRest,
    );
  }

  Widget _buildAttacksTab() {
    return AttacksTab(
      attacks: _attacks,
      onAddAttack: _showAddAttackDialog,
      onRemoveAttack: (index) {
        setState(() {
          _attacks.removeAt(index);
        });
      },
    );
  }

  Widget _buildQuickGuideTab() {
    return CharactersQuickGuide(
      controller: _quickGuideController,
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
        _saveCharacter(
          successMessage: 'Ability scores and saving throws updated!',
        );
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
            color: (_hasInspiration ? Colors.green : Colors.blue).withValues(alpha: 
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
    return SkillsTab(
      skillChecks: _skillChecks,
      levelController: _levelController,
      athleticsBonusController: _athleticsBonusController,
      acrobaticsBonusController: _acrobaticsBonusController,
      sleightOfHandBonusController: _sleightOfHandBonusController,
      stealthBonusController: _stealthBonusController,
      arcanaBonusController: _arcanaBonusController,
      historyBonusController: _historyBonusController,
      investigationBonusController: _investigationBonusController,
      natureBonusController: _natureBonusController,
      religionBonusController: _religionBonusController,
      animalHandlingBonusController: _animalHandlingBonusController,
      insightBonusController: _insightBonusController,
      medicineBonusController: _medicineBonusController,
      perceptionBonusController: _perceptionBonusController,
      survivalBonusController: _survivalBonusController,
      deceptionBonusController: _deceptionBonusController,
      intimidationBonusController: _intimidationBonusController,
      performanceBonusController: _performanceBonusController,
      persuasionBonusController: _persuasionBonusController,
      onUpdateSkillCheck: _updateSkillCheck,
      onUpdateSkillExpertise: _updateSkillExpertise,
      getAbilityScore: _getAbilityScore,
    );
  }

  Widget _buildSpellSlotsTab() {
    return SpellSlotsTab(
      spellSlots: _spellSlots,
      onRestoreSlots: _takeLongRest,
      onShowSlotModifierDialog: _showSlotModifierDialog,
      onToggleSpellSlot: _toggleSpellSlot,
    );
  }

  Widget _buildSpellsTab() {
    final spellcastingAbility = _getSpellcastingAbility();
    final modifier = _getCurrentSpellcastingModifier();
    final calculatedMax = CharacterSpellPreparation.calculateMaxPreparedSpells(
      _classController.text.trim(),
      int.tryParse(_levelController.text) ?? 1,
      modifier,
    );
    final maxPrepared =
        _spellPreparation.maxPreparedSpells == 0
            ? calculatedMax
            : _spellPreparation.maxPreparedSpells;
    final isModified =
        _spellPreparation.maxPreparedSpells != 0 &&
        _spellPreparation.maxPreparedSpells != calculatedMax;
    final canPrepare = maxPrepared > 0;

    return SpellsTab(
      spells: _spells,
      spellPreparation: _spellPreparation,
      character: widget.character,
      classController: _classController,
      levelController: _levelController,
      currentModifier: modifier,
      calculatedMax: calculatedMax,
      maxPreparedSpells: maxPrepared,
      isMaxPreparedModified: isModified,
      canPrepare: canPrepare,
      spellcastingAbility: spellcastingAbility,
      spellSaveDC: _getSpellSaveDC(),
      spellAttackBonus: _getSpellAttackBonus(),
      getAbilityName: _getAbilityName,
      getModifierName: _getModifierName,
      onShowAddSpellDialog: _showAddSpellDialog,
      onShowMaxPreparedDialog: _showMaxPreparedDialog,
      onResetMaxPrepared: () {
        setState(() {
          final currentCalculatedMax = calculatedMax;
          final currentPrepared = _spellPreparation.preparedSpells;
          if (currentPrepared.length > currentCalculatedMax) {
            final spellsToKeep =
                currentPrepared.take(currentCalculatedMax).toList();
            _spellPreparation = _spellPreparation.copyWith(
              maxPreparedSpells: 0,
              preparedSpells: spellsToKeep,
            );
          } else {
            _spellPreparation = _spellPreparation.copyWith(
              maxPreparedSpells: 0,
            );
          }
        });
      },
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
    debugPrint(
      'STR modifier: ${_getAbilityModifier('strength')} (prof: ${updatedSavingThrows.strengthProficiency})',
    );
    debugPrint(
      'DEX modifier: ${_getAbilityModifier('dexterity')} (prof: ${updatedSavingThrows.dexterityProficiency})',
    );
    debugPrint(
      'CON modifier: ${_getAbilityModifier('constitution')} (prof: ${updatedSavingThrows.constitutionProficiency})',
    );
    debugPrint(
      'INT modifier: ${_getAbilityModifier('intelligence')} (prof: ${updatedSavingThrows.intelligenceProficiency})',
    );
    debugPrint(
      'WIS modifier: ${_getAbilityModifier('wisdom')} (prof: ${updatedSavingThrows.wisdomProficiency})',
    );
    debugPrint(
      'CHA modifier: ${_getAbilityModifier('charisma')} (prof: ${updatedSavingThrows.charismaProficiency})',
    );
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
            color: isActiveColor.withValues(alpha: 0.1),
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
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _hasShield = !_hasShield;
                        });
                        // Manual save only - no auto-save
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Text(
                        'Shield',
                        style: TextStyle(
                          fontSize: 14,
                          color: isActiveColor.shade700,
                          fontWeight: FontWeight.w600,
                        ),
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
            color: Colors.blue.withValues(alpha: 0.1),
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

  Widget _buildPickImageButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
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

  void _showImageOptionsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => ImageOptionsDialog(
            hasImage: _customImagePath != null,
            onPickFromGallery: _pickImage,
            onPickFromCamera:
                _pickImage, // same handler used for camera/gallery pick
            onRemoveImage: _removeImage,
          ),
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
        acrobaticsBonus: acrobaticsBonus,
        animalHandlingProficiency:
            skill == 'animal_handling'
                ? value
                : _skillChecks.animalHandlingProficiency,
        animalHandlingExpertise:
            skill == 'animal_handling'
                ? (value ? _skillChecks.animalHandlingExpertise : false)
                : _skillChecks.animalHandlingExpertise,
        animalHandlingBonus: animalHandlingBonus,
        arcanaProficiency:
            skill == 'arcana' ? value : _skillChecks.arcanaProficiency,
        arcanaExpertise:
            skill == 'arcana'
                ? (value ? _skillChecks.arcanaExpertise : false)
                : _skillChecks.arcanaExpertise,
        arcanaBonus: arcanaBonus,
        athleticsProficiency:
            skill == 'athletics' ? value : _skillChecks.athleticsProficiency,
        athleticsExpertise:
            skill == 'athletics'
                ? (value ? _skillChecks.athleticsExpertise : false)
                : _skillChecks.athleticsExpertise,
        athleticsBonus: athleticsBonus,
        deceptionProficiency:
            skill == 'deception' ? value : _skillChecks.deceptionProficiency,
        deceptionExpertise:
            skill == 'deception'
                ? (value ? _skillChecks.deceptionExpertise : false)
                : _skillChecks.deceptionExpertise,
        deceptionBonus: deceptionBonus,
        historyProficiency:
            skill == 'history' ? value : _skillChecks.historyProficiency,
        historyExpertise:
            skill == 'history'
                ? (value ? _skillChecks.historyExpertise : false)
                : _skillChecks.historyExpertise,
        historyBonus: historyBonus,
        insightProficiency:
            skill == 'insight' ? value : _skillChecks.insightProficiency,
        insightExpertise:
            skill == 'insight'
                ? (value ? _skillChecks.insightExpertise : false)
                : _skillChecks.insightExpertise,
        insightBonus: insightBonus,
        intimidationProficiency:
            skill == 'intimidation'
                ? value
                : _skillChecks.intimidationProficiency,
        intimidationExpertise:
            skill == 'intimidation'
                ? (value ? _skillChecks.intimidationExpertise : false)
                : _skillChecks.intimidationExpertise,
        intimidationBonus: intimidationBonus,
        investigationProficiency:
            skill == 'investigation'
                ? value
                : _skillChecks.investigationProficiency,
        investigationExpertise:
            skill == 'investigation'
                ? (value ? _skillChecks.investigationExpertise : false)
                : _skillChecks.investigationExpertise,
        investigationBonus: investigationBonus,
        medicineProficiency:
            skill == 'medicine' ? value : _skillChecks.medicineProficiency,
        medicineExpertise:
            skill == 'medicine'
                ? (value ? _skillChecks.medicineExpertise : false)
                : _skillChecks.medicineExpertise,
        medicineBonus: medicineBonus,
        natureProficiency:
            skill == 'nature' ? value : _skillChecks.natureProficiency,
        natureExpertise:
            skill == 'nature'
                ? (value ? _skillChecks.natureExpertise : false)
                : _skillChecks.natureExpertise,
        natureBonus: natureBonus,
        perceptionProficiency:
            skill == 'perception' ? value : _skillChecks.perceptionProficiency,
        perceptionExpertise:
            skill == 'perception'
                ? (value ? _skillChecks.perceptionExpertise : false)
                : _skillChecks.perceptionExpertise,
        perceptionBonus: perceptionBonus,
        performanceProficiency:
            skill == 'performance'
                ? value
                : _skillChecks.performanceProficiency,
        performanceExpertise:
            skill == 'performance'
                ? (value ? _skillChecks.performanceExpertise : false)
                : _skillChecks.performanceExpertise,
        performanceBonus: performanceBonus,
        persuasionProficiency:
            skill == 'persuasion' ? value : _skillChecks.persuasionProficiency,
        persuasionExpertise:
            skill == 'persuasion'
                ? (value ? _skillChecks.persuasionExpertise : false)
                : _skillChecks.persuasionExpertise,
        persuasionBonus: persuasionBonus,
        religionProficiency:
            skill == 'religion' ? value : _skillChecks.religionProficiency,
        religionExpertise:
            skill == 'religion'
                ? (value ? _skillChecks.religionExpertise : false)
                : _skillChecks.religionExpertise,
        religionBonus: religionBonus,
        sleightOfHandProficiency:
            skill == 'sleight_of_hand'
                ? value
                : _skillChecks.sleightOfHandProficiency,
        sleightOfHandExpertise:
            skill == 'sleight_of_hand'
                ? (value ? _skillChecks.sleightOfHandExpertise : false)
                : _skillChecks.sleightOfHandExpertise,
        sleightOfHandBonus: sleightOfHandBonus,
        stealthProficiency:
            skill == 'stealth' ? value : _skillChecks.stealthProficiency,
        stealthExpertise:
            skill == 'stealth'
                ? (value ? _skillChecks.stealthExpertise : false)
                : _skillChecks.stealthExpertise,
        stealthBonus: stealthBonus,
        survivalProficiency:
            skill == 'survival' ? value : _skillChecks.survivalProficiency,
        survivalExpertise:
            skill == 'survival'
                ? (value ? _skillChecks.survivalExpertise : false)
                : _skillChecks.survivalExpertise,
        survivalBonus: survivalBonus,
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
        acrobaticsBonus: acrobaticsBonus,
        animalHandlingProficiency: _skillChecks.animalHandlingProficiency,
        animalHandlingExpertise:
            skill == 'animal_handling'
                ? value
                : _skillChecks.animalHandlingExpertise,
        animalHandlingBonus: animalHandlingBonus,
        arcanaProficiency: _skillChecks.arcanaProficiency,
        arcanaExpertise:
            skill == 'arcana' ? value : _skillChecks.arcanaExpertise,
        arcanaBonus: arcanaBonus,
        athleticsProficiency: _skillChecks.athleticsProficiency,
        athleticsExpertise:
            skill == 'athletics' ? value : _skillChecks.athleticsExpertise,
        athleticsBonus: athleticsBonus,
        deceptionProficiency: _skillChecks.deceptionProficiency,
        deceptionExpertise:
            skill == 'deception' ? value : _skillChecks.deceptionExpertise,
        deceptionBonus: deceptionBonus,
        historyProficiency: _skillChecks.historyProficiency,
        historyExpertise:
            skill == 'history' ? value : _skillChecks.historyExpertise,
        historyBonus: historyBonus,
        insightProficiency: _skillChecks.insightProficiency,
        insightExpertise:
            skill == 'insight' ? value : _skillChecks.insightExpertise,
        insightBonus: insightBonus,
        intimidationProficiency: _skillChecks.intimidationProficiency,
        intimidationExpertise:
            skill == 'intimidation'
                ? value
                : _skillChecks.intimidationExpertise,
        intimidationBonus: intimidationBonus,
        investigationProficiency: _skillChecks.investigationProficiency,
        investigationExpertise:
            skill == 'investigation'
                ? value
                : _skillChecks.investigationExpertise,
        investigationBonus: investigationBonus,
        medicineProficiency: _skillChecks.medicineProficiency,
        medicineExpertise:
            skill == 'medicine' ? value : _skillChecks.medicineExpertise,
        medicineBonus: medicineBonus,
        natureProficiency: _skillChecks.natureProficiency,
        natureExpertise:
            skill == 'nature' ? value : _skillChecks.natureExpertise,
        natureBonus: natureBonus,
        perceptionProficiency: _skillChecks.perceptionProficiency,
        perceptionExpertise:
            skill == 'perception' ? value : _skillChecks.perceptionExpertise,
        perceptionBonus: perceptionBonus,
        performanceProficiency: _skillChecks.performanceProficiency,
        performanceExpertise:
            skill == 'performance' ? value : _skillChecks.performanceExpertise,
        performanceBonus: performanceBonus,
        persuasionProficiency: _skillChecks.persuasionProficiency,
        persuasionExpertise:
            skill == 'persuasion' ? value : _skillChecks.persuasionExpertise,
        persuasionBonus: persuasionBonus,
        religionProficiency: _skillChecks.religionProficiency,
        religionExpertise:
            skill == 'religion' ? value : _skillChecks.religionExpertise,
        religionBonus: religionBonus,
        sleightOfHandProficiency: _skillChecks.sleightOfHandProficiency,
        sleightOfHandExpertise:
            skill == 'sleight_of_hand'
                ? value
                : _skillChecks.sleightOfHandExpertise,
        sleightOfHandBonus: sleightOfHandBonus,
        stealthProficiency: _skillChecks.stealthProficiency,
        stealthExpertise:
            skill == 'stealth' ? value : _skillChecks.stealthExpertise,
        stealthBonus: stealthBonus,
        survivalProficiency: _skillChecks.survivalProficiency,
        survivalExpertise:
            skill == 'survival' ? value : _skillChecks.survivalExpertise,
        survivalBonus: survivalBonus,
      );
      // Manual save only - no auto-save for skill expertise changes
    });
  }

  // Skill bonus getter methods
  int get acrobaticsBonus => int.tryParse(_acrobaticsBonusController.text) ?? 0;
  int get animalHandlingBonus =>
      int.tryParse(_animalHandlingBonusController.text) ?? 0;
  int get arcanaBonus => int.tryParse(_arcanaBonusController.text) ?? 0;
  int get athleticsBonus => int.tryParse(_athleticsBonusController.text) ?? 0;
  int get deceptionBonus => int.tryParse(_deceptionBonusController.text) ?? 0;
  int get historyBonus => int.tryParse(_historyBonusController.text) ?? 0;
  int get insightBonus => int.tryParse(_insightBonusController.text) ?? 0;
  int get intimidationBonus =>
      int.tryParse(_intimidationBonusController.text) ?? 0;
  int get investigationBonus =>
      int.tryParse(_investigationBonusController.text) ?? 0;
  int get medicineBonus => int.tryParse(_medicineBonusController.text) ?? 0;
  int get natureBonus => int.tryParse(_natureBonusController.text) ?? 0;
  int get perceptionBonus => int.tryParse(_perceptionBonusController.text) ?? 0;
  int get performanceBonus =>
      int.tryParse(_performanceBonusController.text) ?? 0;
  int get persuasionBonus => int.tryParse(_persuasionBonusController.text) ?? 0;
  int get religionBonus => int.tryParse(_religionBonusController.text) ?? 0;
  int get sleightOfHandBonus =>
      int.tryParse(_sleightOfHandBonusController.text) ?? 0;
  int get stealthBonus => int.tryParse(_stealthBonusController.text) ?? 0;
  int get survivalBonus => int.tryParse(_survivalBonusController.text) ?? 0;

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
    showDialog(
      context: context,
      builder:
          (context) => SpellSlotModifierDialog(
            level: level,
            type: type,
            initialValue: currentValue,
            onUpdate: (lvl, t, value) => _updateSpellSlot(lvl, t, value),
            getMaxSlots: (lvl) => _getMaxSlots(lvl),
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
    );
  }

  void _showAddAttackDialog() async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => const AddAttackDialog(),
    );

    if (result == null) return;

    if (result is List<WeaponSelectionResult>) {
      final attacks =
          result.map((res) {
            return WeaponAttackMapper.mapWeaponToAttack(
              res.weapon,
              widget.character,
              customAttackBonus: res.customAttackBonus,
              customDamage: res.customDamage,
            );
          }).toList();

      setState(() {
        _attacks.addAll(attacks);
      });
    } else if (result is CharacterAttack) {
      setState(() {
        _attacks.add(result);
      });
    }
  }

  void _showAddSpellDialog() {
    // Load spells if not already loaded
    context.read<SpellsViewModel>().loadSpells();

    final Set<String> selectedSpells = <String>{};

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent automatic dismissal to ensure we handle cleanup
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.95,
                      minWidth: 350,
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                            padding: const EdgeInsets.all(12.0),
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
                                                initialValue:
                                                    _selectedLevelFilter ??
                                                    'All',
                                                isExpanded: true,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Level',
                                                      border:
                                                          OutlineInputBorder(),
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
                                                          style:
                                                              const TextStyle(
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
                                                initialValue:
                                                    _selectedClassFilter ??
                                                    'All',
                                                isExpanded: true,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Class',
                                                      border:
                                                          OutlineInputBorder(),
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
                                                          displayName.length >
                                                                  15
                                                              ? '${displayName.substring(0, 15)}...'
                                                              : displayName,
                                                          style:
                                                              const TextStyle(
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
                                                initialValue:
                                                    _selectedSchoolFilter ??
                                                    'All',
                                                isExpanded: true,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'School',
                                                      border:
                                                          OutlineInputBorder(),
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
                                                          style:
                                                              const TextStyle(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
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

                          // Active filters display
                          Consumer<SpellsViewModel>(
                            builder: (context, spellsViewModel, child) {
                              final hasActiveFilters =
                                  _searchQuery.isNotEmpty ||
                                  _selectedLevelFilter != null ||
                                  _selectedClassFilter != null ||
                                  _selectedSchoolFilter != null ||
                                  _filterByCharacterClass;

                              if (!hasActiveFilters) {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.filter_list,
                                          size: 16,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Active Filters:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {
                                            this.setState(() {
                                              _searchQuery = '';
                                              _selectedLevelFilter = null;
                                              _selectedClassFilter = null;
                                              _selectedSchoolFilter = null;
                                              _filterByCharacterClass = false;
                                            });
                                            setState(() {});
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'Clear All',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        if (_searchQuery.isNotEmpty)
                                          AppFilterChip(
                                            label: 'Search: "$_searchQuery"',
                                            onClear: () {
                                              this.setState(() {
                                                _searchQuery = '';
                                              });
                                              setState(() {});
                                            },
                                          ),
                                        if (_filterByCharacterClass)
                                          AppFilterChip(
                                            label:
                                                'Only ${widget.character.characterClass} spells',
                                            onClear: () {
                                              this.setState(() {
                                                _filterByCharacterClass = false;
                                              });
                                              setState(() {});
                                            },
                                          ),
                                        if (_selectedLevelFilter != null)
                                          AppFilterChip(
                                            label:
                                                'Level: $_selectedLevelFilter',
                                            onClear: () {
                                              this.setState(() {
                                                _selectedLevelFilter = null;
                                              });
                                              setState(() {});
                                            },
                                          ),
                                        if (_selectedClassFilter != null)
                                          AppFilterChip(
                                            label:
                                                'Class: $_selectedClassFilter',
                                            onClear: () {
                                              this.setState(() {
                                                _selectedClassFilter = null;
                                              });
                                              setState(() {});
                                            },
                                          ),
                                        if (_selectedSchoolFilter != null)
                                          AppFilterChip(
                                            label:
                                                'School: ${_selectedSchoolFilter?.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}',
                                            onClear: () {
                                              this.setState(() {
                                                _selectedSchoolFilter = null;
                                              });
                                              setState(() {});
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Spells list
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.4,
                            ),
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
                                        if (!spell.name.toLowerCase().contains(
                                          _searchQuery,
                                        )) {
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
                                        if (_selectedLevelFilter ==
                                            'Cantrips') {
                                          if (spell.levelNumber != 0) {
                                            return false;
                                          }
                                        } else if (_selectedLevelFilter!
                                            .startsWith('Level')) {
                                          final level = int.tryParse(
                                            _selectedLevelFilter!.split(' ')[1],
                                          );
                                          if (spell.levelNumber != level) {
                                            return false;
                                          }
                                        }
                                      }

                                      // Filter by class
                                      if (_selectedClassFilter != null) {
                                        if (!spell.classes.contains(
                                          _selectedClassFilter,
                                        )) {
                                          return false;
                                        }
                                      }

                                      // Filter by school
                                      if (_selectedSchoolFilter != null) {
                                        if (spell.schoolName !=
                                            _selectedSchoolFilter) {
                                          return false;
                                        }
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
                                    final isKnown = _spells.contains(
                                      spell.name,
                                    );
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
                                                    : Icons
                                                        .check_circle_outline,
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
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
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
          (context) => SpellDetailsModal(
            spell: spell,
            characterName: widget.character.name,
            onRemoveSpell: (removedSpell) {
              setState(() {
                _spells.remove(removedSpell.name);
              });
            },
          ),
    );
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
    String message =
        'Long rest completed! HP, spell slots, and all class resources restored!';
    if (hadExhaustion && _exhaustionLevel < previousLevel) {
      message += ' Exhaustion reduced by 1.';
    }
    SnackbarHelper.showSuccess(context, message);    
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
    SnackbarHelper.showSuccess(context, 'All spell slots have been restored!');    
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
            builder:
                (context) => ImageCropWidget(
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

          // Compress and encode image to keep JSON payload small
          final compressedBase64 = await ImageUtils.compressAndEncodeImage(
            savedFile.path,
          );

          setState(() {
            _customImagePath = savedFile.path;
            _customImageData = compressedBase64;
            debugPrint(
              'Profile image cropped and saved (compressed): ${_customImageData?.length ?? 0} characters',
            );
          });

          // Show success message
          if (mounted) {
            SnackbarHelper.showSuccess(context, 'Profile image updated successfully!');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error picking image: $e');        
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
        SnackbarHelper.showWarning(context, 'Profile image removed');       
      }

      // Manual save only - no auto-save after profile image removal
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error removing image: $e');        
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
            builder:
                (context) => ImageCropWidget(
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
          final String fileName =
              '${widget.character.id}_appearance_$timestamp.jpg';
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
            SnackbarHelper.showSuccess(context, 'Appearance image updated successfully!');            
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking appearance image: $e');
      if (mounted) {
        SnackbarHelper.showError(context, 'Error picking appearance image: $e');        
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
        SnackbarHelper.showWarning(context, 'Appearance image removed');        
      }

      // Manual save only - no auto-save after appearance image removal
    } catch (e) {
      debugPrint('Error removing appearance image: $e');
      if (mounted) {
        SnackbarHelper.showError(context, 'Error removing appearance image: $e');        
      }
    }
  }

  /// Check if there are any unsaved changes in the character data
  bool get hasUnsavedChanges {
    final character = _baselineCharacter;

    // Check basic info changes
    if (_nameController.text.trim() != character.name) return true;
    if ((int.tryParse(_levelController.text) ?? 1) != character.level) {
      return true;
    }
    if (_classController.text.trim() != character.characterClass) return true;
    if ((_subclassController.text.trim().isEmpty
            ? null
            : _subclassController.text.trim()) !=
        character.subclass) {
      return true;
    }
    if ((_raceController.text.trim().isEmpty
            ? null
            : _raceController.text.trim()) !=
        character.race) {
      return true;
    }
    if ((_backgroundController.text.trim().isEmpty
            ? null
            : _backgroundController.text.trim()) !=
        character.background) {
      return true;
    }

    // Check image changes
    if (_customImagePath != character.customImagePath) return true;
    if (_appearanceImagePath != character.appearance.appearanceImagePath) {
      return true;
    }

    // Check stats changes
    if ((int.tryParse(_strengthController.text) ?? 10) !=
        character.stats.strength) {
      return true;
    }
    if ((int.tryParse(_dexterityController.text) ?? 10) !=
        character.stats.dexterity) {
      return true;
    }
    if ((int.tryParse(_constitutionController.text) ?? 10) !=
        character.stats.constitution) {
      return true;
    }
    if ((int.tryParse(_intelligenceController.text) ?? 10) !=
        character.stats.intelligence) {
      return true;
    }
    if ((int.tryParse(_wisdomController.text) ?? 10) != character.stats.wisdom) {
      return true;
    }
    if ((int.tryParse(_charismaController.text) ?? 10) !=
        character.stats.charisma) {
      return true;
    }
    if ((int.tryParse(_armorClassController.text) ?? 10) !=
        character.stats.armorClass) {
      return true;
    }
    if ((int.tryParse(_speedController.text) ?? 30) != character.stats.speed) {
      return true;
    }
    if ((int.tryParse(_initiativeController.text) ?? 0) !=
        character.stats.initiative) {
      return true;
    }
    if (_hasInspiration != character.stats.inspiration) return true;
    if (_hasConcentration != character.stats.hasConcentration) return true;
    if (_hasShield != character.stats.hasShield) return true;

    // Check health changes
    if ((int.tryParse(_maxHpController.text) ?? 10) !=
        character.health.maxHitPoints) {
      return true;
    }
    if ((int.tryParse(_currentHpController.text) ?? 10) !=
        character.health.currentHitPoints) {
      return true;
    }
    if ((int.tryParse(_tempHpController.text) ?? 0) !=
        character.health.temporaryHitPoints) {
      return true;
    }
    if ((int.tryParse(_hitDiceController.text) ?? 1) !=
        character.health.hitDice) {
      return true;
    }
    if ((_hitDiceTypeController.text.trim().isEmpty
            ? 'd8'
            : _hitDiceTypeController.text.trim()) !=
        character.health.hitDiceType) {
      return true;
    }

    // Check death saves changes
    if (!_listsEqual(_deathSaveSuccesses, character.deathSaves.successes)) {
      return true;
    }
    if (!_listsEqual(_deathSaveFailures, character.deathSaves.failures)) {
      return true;
    }
    if (_exhaustionLevel != character.deathSaves.exhaustionLevel) return true;

    // Check languages changes
    final currentLanguages =
        _languagesController.text
            .split(',')
            .map((lang) => lang.trim())
            .where((lang) => lang.isNotEmpty)
            .toList();
    if (!_listsEqual(currentLanguages, character.languages.languages)) {
      return true;
    }

    // Check saving throws changes
    if (_savingThrows.strengthProficiency !=
        character.savingThrows.strengthProficiency) {
      return true;
    }
    if (_savingThrows.dexterityProficiency !=
        character.savingThrows.dexterityProficiency) {
      return true;
    }
    if (_savingThrows.constitutionProficiency !=
        character.savingThrows.constitutionProficiency) {
      return true;
    }
    if (_savingThrows.intelligenceProficiency !=
        character.savingThrows.intelligenceProficiency) {
      return true;
    }
    if (_savingThrows.wisdomProficiency !=
        character.savingThrows.wisdomProficiency) {
      return true;
    }
    if (_savingThrows.charismaProficiency !=
        character.savingThrows.charismaProficiency) {
      return true;
    }

    // Check skill checks changes
    if (_skillChecks.acrobaticsProficiency !=
        character.skillChecks.acrobaticsProficiency) {
      return true;
    }
    if (_skillChecks.acrobaticsExpertise !=
        character.skillChecks.acrobaticsExpertise) {
      return true;
    }
    if (acrobaticsBonus != character.skillChecks.acrobaticsBonus) return true;
    if (_skillChecks.animalHandlingProficiency !=
        character.skillChecks.animalHandlingProficiency) {
      return true;
    }
    if (_skillChecks.animalHandlingExpertise !=
        character.skillChecks.animalHandlingExpertise) {
      return true;
    }
    if (animalHandlingBonus != character.skillChecks.animalHandlingBonus) {
      return true;
    }
    if (_skillChecks.arcanaProficiency !=
        character.skillChecks.arcanaProficiency) {
      return true;
    }
    if (_skillChecks.arcanaExpertise != character.skillChecks.arcanaExpertise) {
      return true;
    }
    if (arcanaBonus != character.skillChecks.arcanaBonus) return true;
    if (_skillChecks.athleticsProficiency !=
        character.skillChecks.athleticsProficiency) {
      return true;
    }
    if (_skillChecks.athleticsExpertise !=
        character.skillChecks.athleticsExpertise) {
      return true;
    }
    if (athleticsBonus != character.skillChecks.athleticsBonus) return true;
    if (_skillChecks.deceptionProficiency !=
        character.skillChecks.deceptionProficiency) {
      return true;
    }
    if (_skillChecks.deceptionExpertise !=
        character.skillChecks.deceptionExpertise) {
      return true;
    }
    if (deceptionBonus != character.skillChecks.deceptionBonus) return true;
    if (_skillChecks.historyProficiency !=
        character.skillChecks.historyProficiency) {
      return true;
    }
    if (_skillChecks.historyExpertise != character.skillChecks.historyExpertise) {
      return true;
    }
    if (historyBonus != character.skillChecks.historyBonus) return true;
    if (_skillChecks.insightProficiency !=
        character.skillChecks.insightProficiency) {
      return true;
    }
    if (_skillChecks.insightExpertise != character.skillChecks.insightExpertise) {
      return true;
    }
    if (insightBonus != character.skillChecks.insightBonus) return true;
    if (_skillChecks.intimidationProficiency !=
        character.skillChecks.intimidationProficiency) {
      return true;
    }
    if (_skillChecks.intimidationExpertise !=
        character.skillChecks.intimidationExpertise) {
      return true;
    }
    if (intimidationBonus != character.skillChecks.intimidationBonus) {
      return true;
    }
    if (_skillChecks.investigationProficiency !=
        character.skillChecks.investigationProficiency) {
      return true;
    }
    if (_skillChecks.investigationExpertise !=
        character.skillChecks.investigationExpertise) {
      return true;
    }
    if (investigationBonus != character.skillChecks.investigationBonus) {
      return true;
    }
    if (_skillChecks.medicineProficiency !=
        character.skillChecks.medicineProficiency) {
      return true;
    }
    if (_skillChecks.medicineExpertise !=
        character.skillChecks.medicineExpertise) {
      return true;
    }
    if (medicineBonus != character.skillChecks.medicineBonus) return true;
    if (_skillChecks.natureProficiency !=
        character.skillChecks.natureProficiency) {
      return true;
    }
    if (_skillChecks.natureExpertise != character.skillChecks.natureExpertise) {
      return true;
    }
    if (natureBonus != character.skillChecks.natureBonus) return true;
    if (_skillChecks.perceptionProficiency !=
        character.skillChecks.perceptionProficiency) {
      return true;
    }
    if (_skillChecks.perceptionExpertise !=
        character.skillChecks.perceptionExpertise) {
      return true;
    }
    if (perceptionBonus != character.skillChecks.perceptionBonus) return true;
    if (_skillChecks.performanceProficiency !=
        character.skillChecks.performanceProficiency) {
      return true;
    }
    if (_skillChecks.performanceExpertise !=
        character.skillChecks.performanceExpertise) {
      return true;
    }
    if (performanceBonus != character.skillChecks.performanceBonus) return true;
    if (_skillChecks.persuasionProficiency !=
        character.skillChecks.persuasionProficiency) {
      return true;
    }
    if (_skillChecks.persuasionExpertise !=
        character.skillChecks.persuasionExpertise) {
      return true;
    }
    if (persuasionBonus != character.skillChecks.persuasionBonus) return true;
    if (_skillChecks.religionProficiency !=
        character.skillChecks.religionProficiency) {
      return true;
    }
    if (_skillChecks.religionExpertise !=
        character.skillChecks.religionExpertise) {
      return true;
    }
    if (religionBonus != character.skillChecks.religionBonus) return true;
    if (_skillChecks.sleightOfHandProficiency !=
        character.skillChecks.sleightOfHandProficiency) {
      return true;
    }
    if (_skillChecks.sleightOfHandExpertise !=
        character.skillChecks.sleightOfHandExpertise) {
      return true;
    }
    if (sleightOfHandBonus != character.skillChecks.sleightOfHandBonus) {
      return true;
    }
    if (_skillChecks.stealthProficiency !=
        character.skillChecks.stealthProficiency) {
      return true;
    }
    if (_skillChecks.stealthExpertise != character.skillChecks.stealthExpertise) {
      return true;
    }
    if (stealthBonus != character.skillChecks.stealthBonus) return true;
    if (_skillChecks.survivalProficiency !=
        character.skillChecks.survivalProficiency) {
      return true;
    }
    if (_skillChecks.survivalExpertise !=
        character.skillChecks.survivalExpertise) {
      return true;
    }
    if (survivalBonus != character.skillChecks.survivalBonus) return true;

    // Check attacks changes
    if (!_attacksEqual(_attacks, character.attacks)) return true;

    // Check spells changes
    if (!_listsEqual(_spells, character.spells)) return true;

    // Check feats changes
    if (!_listsEqual(_feats, character.feats)) return true;

    // Check spell slots changes
    if (_spellSlots.level1Slots != character.spellSlots.level1Slots) {
      return true;
    }
    if (_spellSlots.level1Used != character.spellSlots.level1Used) return true;
    if (_spellSlots.level2Slots != character.spellSlots.level2Slots) {
      return true;
    }
    if (_spellSlots.level2Used != character.spellSlots.level2Used) return true;
    if (_spellSlots.level3Slots != character.spellSlots.level3Slots) {
      return true;
    }
    if (_spellSlots.level3Used != character.spellSlots.level3Used) return true;
    if (_spellSlots.level4Slots != character.spellSlots.level4Slots) {
      return true;
    }
    if (_spellSlots.level4Used != character.spellSlots.level4Used) return true;
    if (_spellSlots.level5Slots != character.spellSlots.level5Slots) {
      return true;
    }
    if (_spellSlots.level5Used != character.spellSlots.level5Used) return true;
    if (_spellSlots.level6Slots != character.spellSlots.level6Slots) {
      return true;
    }
    if (_spellSlots.level6Used != character.spellSlots.level6Used) return true;
    if (_spellSlots.level7Slots != character.spellSlots.level7Slots) {
      return true;
    }
    if (_spellSlots.level7Used != character.spellSlots.level7Used) return true;
    if (_spellSlots.level8Slots != character.spellSlots.level8Slots) {
      return true;
    }
    if (_spellSlots.level8Used != character.spellSlots.level8Used) return true;
    if (_spellSlots.level9Slots != character.spellSlots.level9Slots) {
      return true;
    }
    if (_spellSlots.level9Used != character.spellSlots.level9Used) return true;

    // Check spell preparation changes
    if (_spellPreparation.preparedSpells !=
        character.spellPreparation.preparedSpells) {
      return true;
    }
    if (_spellPreparation.alwaysPreparedSpells !=
        character.spellPreparation.alwaysPreparedSpells) {
      return true;
    }
    if (_spellPreparation.freeUseSpells !=
        character.spellPreparation.freeUseSpells) {
      return true;
    }

    // Check personalized slots changes
    if (!_personalizedSlotsEqual(
      _personalizedSlots,
      character.personalizedSlots,
    )) {
      return true;
    }

    // Check money changes
    if (_moneyController.text.trim() != character.moneyItems.money) return true;

    // Check rich text content changes
    if (!_areDeltasEqual(
      _quickGuideController.document.toDelta().toJson(),
      character.quickGuide,
    )) {
      return true;
    }
    if (!_areDeltasEqual(
      _proficienciesController.document.toDelta().toJson(),
      character.proficiencies,
    )) {
      return true;
    }
    if (!_areDeltasEqual(
      _featuresTraitsController.document.toDelta().toJson(),
      character.featuresTraits,
    )) {
      return true;
    }
    if (!_areDeltasEqual(
      _backstoryController.document.toDelta().toJson(),
      character.backstory,
    )) {
      return true;
    }
    if (!_areDeltasEqual(
      _featNotesController.document.toDelta().toJson(),
      character.featNotes,
    )) {
      return true;
    }
    if (!_areDeltasEqual(
      _itemsController.document.toDelta().toJson(),
      character.moneyItems.items.isNotEmpty
          ? character.moneyItems.items.first
          : '',
    )) {
      return true;
    }
    if (!_areDeltasEqual(
      _additionalDetailsController.document.toDelta().toJson(),
      character.appearance.additionalDetails,
    )) {
      return true;
    }

    // Check pillars changes
    if (_gimmickController.text.trim() != character.pillars.gimmick) {
      return true;
    }
    if (_quirkController.text.trim() != character.pillars.quirk) return true;
    if (_wantsController.text.trim() != character.pillars.wants) return true;
    if (_needsController.text.trim() != character.pillars.needs) return true;
    if (_conflictController.text.trim() != character.pillars.conflict) {
      return true;
    }

    // Check appearance changes
    if (_heightController.text.trim() != character.appearance.height) {
      return true;
    }
    if (_ageController.text.trim() != character.appearance.age) return true;
    if (_eyeColorController.text.trim() != character.appearance.eyeColor) {
      return true;
    }

    // Check existing flags
    if (_hasUnsavedClassChanges || _hasUnsavedAbilityChanges) return true;

    return false;
  }

  /// Helper method to compare deltas properly
  bool _areDeltasEqual(List<dynamic> currentDelta, String storedJson) {
    if (storedJson.isEmpty) {
      // If stored is empty, check if current is also empty (just a newline)
      final currentText =
          currentDelta.isNotEmpty
              ? currentDelta.first['insert']?.toString() ?? ''
              : '';
      return currentText.trim().isEmpty;
    }

    try {
      final storedDelta = jsonDecode(storedJson);
      // Compare the JSON strings for reliable comparison
      return jsonEncode(currentDelta) == jsonEncode(storedDelta);
    } catch (e) {
      // If stored is not valid JSON, treat it as plain text
      final currentText =
          currentDelta.isNotEmpty
              ? currentDelta.first['insert']?.toString() ?? ''
              : '';
      return currentText.trim() == storedJson.trim();
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
  bool _personalizedSlotsEqual(
    List<CharacterPersonalizedSlot> a,
    List<CharacterPersonalizedSlot> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_personalizedSlotEqual(a[i], b[i])) return false;
    }
    return true;
  }

  /// Helper method to compare individual personalized slots
  bool _personalizedSlotEqual(
    CharacterPersonalizedSlot a,
    CharacterPersonalizedSlot b,
  ) {
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
        skillChecks: CharacterSkillChecks(
          acrobaticsProficiency: _skillChecks.acrobaticsProficiency,
          acrobaticsExpertise: _skillChecks.acrobaticsExpertise,
          acrobaticsBonus: acrobaticsBonus,
          animalHandlingProficiency: _skillChecks.animalHandlingProficiency,
          animalHandlingExpertise: _skillChecks.animalHandlingExpertise,
          animalHandlingBonus: animalHandlingBonus,
          arcanaProficiency: _skillChecks.arcanaProficiency,
          arcanaExpertise: _skillChecks.arcanaExpertise,
          arcanaBonus: arcanaBonus,
          athleticsProficiency: _skillChecks.athleticsProficiency,
          athleticsExpertise: _skillChecks.athleticsExpertise,
          athleticsBonus: athleticsBonus,
          deceptionProficiency: _skillChecks.deceptionProficiency,
          deceptionExpertise: _skillChecks.deceptionExpertise,
          deceptionBonus: deceptionBonus,
          historyProficiency: _skillChecks.historyProficiency,
          historyExpertise: _skillChecks.historyExpertise,
          historyBonus: historyBonus,
          insightProficiency: _skillChecks.insightProficiency,
          insightExpertise: _skillChecks.insightExpertise,
          insightBonus: insightBonus,
          intimidationProficiency: _skillChecks.intimidationProficiency,
          intimidationExpertise: _skillChecks.intimidationExpertise,
          intimidationBonus: intimidationBonus,
          investigationProficiency: _skillChecks.investigationProficiency,
          investigationExpertise: _skillChecks.investigationExpertise,
          investigationBonus: investigationBonus,
          medicineProficiency: _skillChecks.medicineProficiency,
          medicineExpertise: _skillChecks.medicineExpertise,
          medicineBonus: medicineBonus,
          natureProficiency: _skillChecks.natureProficiency,
          natureExpertise: _skillChecks.natureExpertise,
          natureBonus: natureBonus,
          perceptionProficiency: _skillChecks.perceptionProficiency,
          perceptionExpertise: _skillChecks.perceptionExpertise,
          perceptionBonus: perceptionBonus,
          performanceProficiency: _skillChecks.performanceProficiency,
          performanceExpertise: _skillChecks.performanceExpertise,
          performanceBonus: performanceBonus,
          persuasionProficiency: _skillChecks.persuasionProficiency,
          persuasionExpertise: _skillChecks.persuasionExpertise,
          persuasionBonus: persuasionBonus,
          religionProficiency: _skillChecks.religionProficiency,
          religionExpertise: _skillChecks.religionExpertise,
          religionBonus: religionBonus,
          sleightOfHandProficiency: _skillChecks.sleightOfHandProficiency,
          sleightOfHandExpertise: _skillChecks.sleightOfHandExpertise,
          sleightOfHandBonus: sleightOfHandBonus,
          stealthProficiency: _skillChecks.stealthProficiency,
          stealthExpertise: _skillChecks.stealthExpertise,
          stealthBonus: stealthBonus,
          survivalProficiency: _skillChecks.survivalProficiency,
          survivalExpertise: _skillChecks.survivalExpertise,
          survivalBonus: survivalBonus,
        ),
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
          // Do not include raw appearance image data in saved JSON.
          appearanceImageData: null,
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
        SnackbarHelper.showSuccess(
          context,
          successMessage ?? 'Character saved successfully!',
        );        
      }
    } catch (e) {
      debugPrint('Error saving character: $e');

      if (mounted) {
        SnackbarHelper.showError(context, 'Failed to save character: $e');        
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
          preparedSpells:
              _spellPreparation.preparedSpells
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
                    SnackbarHelper.showError(context, 'Please enter a valid number');                        
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
    final currentMax =
        _spellPreparation.maxPreparedSpells == 0
            ? CharacterSpellPreparation.calculateMaxPreparedSpells(
              _classController.text.trim(),
              int.tryParse(_levelController.text) ?? 1,
              _getCurrentSpellcastingModifier(),
            )
            : _spellPreparation.maxPreparedSpells;

    showDialog(
      context: context,
      builder:
          (context) => MaxPreparedDialog(
            initialMax: currentMax,
            calculatedMax: CharacterSpellPreparation.calculateMaxPreparedSpells(
              _classController.text.trim(),
              int.tryParse(_levelController.text) ?? 1,
              _getCurrentSpellcastingModifier(),
            ),
            currentPreparedCount: _spellPreparation.currentPreparedCount,
            className: _classController.text.trim(),
            level: int.tryParse(_levelController.text) ?? 1,
            onSave: (newMax) {
              setState(() {
                final alwaysPreparedOnly =
                    _spellPreparation.preparedSpells
                        .where(
                          (spellId) => _spellPreparation.alwaysPreparedSpells
                              .contains(spellId),
                        )
                        .toList();

                if (newMax < _spellPreparation.currentPreparedCount) {
                  _spellPreparation = _spellPreparation.copyWith(
                    maxPreparedSpells: newMax,
                    preparedSpells: [...alwaysPreparedOnly],
                  );
                } else {
                  _spellPreparation = _spellPreparation.copyWith(
                    maxPreparedSpells: newMax,
                  );
                }
              });
            },
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
