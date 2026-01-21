import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../../models/character_model.dart';
import '../../models/spell_model.dart';
import '../../models/feat_model.dart';
import '../../models/race_model.dart';
import '../../models/background_model.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../viewmodels/spells_viewmodel.dart';
import '../../viewmodels/feats_viewmodel.dart';
import '../../viewmodels/races_viewmodel.dart';
import '../../viewmodels/backgrounds_viewmodel.dart';

class CharacterEditScreen extends StatefulWidget {
  final Character character;

  const CharacterEditScreen({super.key, required this.character});

  @override
  State<CharacterEditScreen> createState() => _CharacterEditScreenState();
}

class _CharacterEditScreenState extends State<CharacterEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _customImagePath;
  String? _appearanceImagePath;
  bool _isPickingImage = false;
  bool _hasUnsavedAbilityChanges = false;
  bool _hasUnsavedClassChanges = false;
  String _selectedClass = 'Fighter';
  bool _useCustomSubclass = false;
  String _selectedRace = '';
  String _selectedBackground = '';

  // Death saves controllers
  List<bool> _deathSaveSuccesses = [false, false, false];
  List<bool> _deathSaveFailures = [false, false, false];

  // Languages controller
  final _languagesController = TextEditingController();

  // Money and items controllers
  final _moneyController = TextEditingController();
  final _itemsController = TextEditingController();

  // Form controllers
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  final _classController = TextEditingController();
  final _subclassController = TextEditingController();
  final _raceController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _quickGuideController = TextEditingController();
  final _proficienciesController = TextEditingController();
  final _featuresTraitsController = TextEditingController();
  final _backstoryController = TextEditingController();
  final _featNotesController = TextEditingController();

  // Appearance controllers
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _eyeColorController = TextEditingController();
  final _additionalDetailsController = TextEditingController();

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
  
  // Flag to track if initiative has been manually modified
  bool _initiativeManuallyModified = false;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
    _initializeCharacterData();
    
    // Load races and backgrounds data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RacesViewModel>().loadRaces();
      context.read<BackgroundsViewModel>().loadBackgrounds();
    });
  }

  void _initializeCharacterData() {
    final character = widget.character;

    // Initialize profile image
    _customImagePath = character.customImagePath;
    _appearanceImagePath = character.appearance.appearanceImagePath;

    // Initialize controllers
    _nameController.text = character.name;
    _levelController.text = character.level.toString();
    _levelController.addListener(() {
      _autoSaveCharacter();
      setState(() {}); // Rebuild to update proficiency bonus display
    });
    _selectedClass = character.characterClass;
    _classController.text = character.characterClass;
    _subclassController.text = character.subclass ?? '';
    _raceController.text = character.race ?? '';
    _backgroundController.text = character.background ?? '';
    _selectedRace = character.race ?? '';
    _selectedBackground = character.background ?? '';
    
    // Check if current subclass is custom (not in preset list)
    final availableSubclasses = _getSubclassesForClass(character.characterClass);
    _useCustomSubclass = character.subclass != null && !availableSubclasses.contains(character.subclass);
    
    _quickGuideController.text = character.quickGuide;
    _proficienciesController.text = character.proficiencies;
    _featuresTraitsController.text = character.featuresTraits;
    _backstoryController.text = character.backstory;

    // Initialize death saves
    _deathSaveSuccesses = List.from(character.deathSaves.successes);
    _deathSaveFailures = List.from(character.deathSaves.failures);

    // Initialize languages and money/items
    _languagesController.text = character.languages.languages.join(', ');
    _moneyController.text = character.moneyItems.money;
    _itemsController.text = character.moneyItems.items.join('\n');

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
      _initiativeManuallyModified = false;
    } else {
      _initiativeController.text = _stats.initiative.toString();
      _initiativeManuallyModified = true;
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
    _featNotesController.text = character.featNotes ?? '';

    // Initialize appearance
    _heightController.text = character.appearance.height;
    _ageController.text = character.appearance.age;
    _eyeColorController.text = character.appearance.eyeColor;
    _additionalDetailsController.text = character.appearance.additionalDetails;

    // Set up auto-save listeners
    _setupAutoSaveListeners();
  }

  void _setupAutoSaveListeners() {
    // Add listeners to all text controllers for auto-save
    _nameController.addListener(_autoSaveCharacter);
    _classController.addListener(() {
      _autoSaveCharacter();
      setState(() {}); // Rebuild to show/hide concentration field
    });
    _subclassController.addListener(() {
      _autoSaveCharacter();
      setState(() {}); // Rebuild to show/hide concentration field
    });
    _raceController.addListener(_autoSaveCharacter);
    _quickGuideController.addListener(_autoSaveCharacter);
    _proficienciesController.addListener(_autoSaveCharacter);
    _featuresTraitsController.addListener(_autoSaveCharacter);
    _backstoryController.addListener(_autoSaveCharacter);
    _featNotesController.addListener(_autoSaveCharacter);

    _gimmickController.addListener(_autoSaveCharacter);
    _quirkController.addListener(_autoSaveCharacter);
    _wantsController.addListener(_autoSaveCharacter);
    _needsController.addListener(_autoSaveCharacter);
    _conflictController.addListener(_autoSaveCharacter);

    _strengthController.addListener(_autoSaveCharacter);
    _dexterityController.addListener(_onDexterityChanged);
    _constitutionController.addListener(_autoSaveCharacter);
    _intelligenceController.addListener(_autoSaveCharacter);
    _wisdomController.addListener(_autoSaveCharacter);
    _charismaController.addListener(_autoSaveCharacter);
    _proficiencyBonusController.addListener(_autoSaveCharacter);
    _armorClassController.addListener(_autoSaveCharacter);
    _speedController.addListener(_autoSaveCharacter);

    _maxHpController.addListener(_autoSaveCharacter);
    _currentHpController.addListener(_autoSaveCharacter);
    _tempHpController.addListener(_autoSaveCharacter);
    _hitDiceController.addListener(_autoSaveCharacter);
    _hitDiceTypeController.addListener(_autoSaveCharacter);
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
          tabs: const [
            Tab(text: 'Character', icon: Icon(Icons.shield)),                        
            Tab(text: 'Quick Guide', icon: Icon(Icons.description)),
            Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Skills', icon: Icon(Icons.psychology)),
            Tab(text: 'Attacks', icon: Icon(Icons.gavel)),
            Tab(text: 'Spell Slots', icon: Icon(Icons.grid_view)),
            Tab(text: 'Spells', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Feats', icon: Icon(Icons.military_tech)),
            Tab(text: 'Class Slots', icon: Icon(Icons.casino)),
            Tab(text: 'Appearance', icon: Icon(Icons.face)),
            Tab(text: 'Notes', icon: Icon(Icons.note)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveCharacter),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Dismiss keyboard when tapping anywhere on screen
          FocusScope.of(context).unfocus();
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCharacterCoverTab(),      
            _buildQuickGuideTab(),
            _buildStatsTab(),
            _buildSkillsTab(),
            _buildAttacksTab(),
            _buildSpellSlotsTab(),
            _buildSpellsTab(),
            _buildFeatsTab(),
            _buildPersonalizedSlotsTab(),
            _buildAppearanceTab(),
            _buildNotesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image section
          Center(
            child: GestureDetector(
              onTap: _showImageOptionsDialog,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child:
                        _customImagePath != null
                            ? ClipOval(
                              child: Image.file(
                                File(_customImagePath!),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            )
                            : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                  ),
                  // Camera button overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildPickImageButton(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name field
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Character Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Level field
          TextField(
            controller: _levelController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Character Level',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Class and subclass
          Row(
            children: [
              Expanded(
                child: Consumer<CharactersViewModel>(
                  builder: (context, viewModel, child) {
                    return DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: const InputDecoration(
                        labelText: 'Class',
                        border: OutlineInputBorder(),
                      ),
                      items: viewModel.availableClasses.map((className) {
                        return DropdownMenuItem(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClass = value!;
                          _classController.text = value;
                          _useCustomSubclass = false;
                          _hasUnsavedClassChanges = true;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_useCustomSubclass)
                      TextField(
                        controller: _subclassController,
                        decoration: InputDecoration(
                          labelText: 'Custom Subclass',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.list),
                            onPressed: () {
                              setState(() {
                                _useCustomSubclass = false;
                                _hasUnsavedClassChanges = true;
                              });
                            },
                            tooltip: 'Choose from preset subclasses',
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _hasUnsavedClassChanges = true;
                          });
                        },
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _useCustomSubclass || _subclassController.text.isEmpty || !_getSubclassesForClass(_selectedClass).contains(_subclassController.text) ? null : _subclassController.text,
                        decoration: const InputDecoration(
                          labelText: 'Subclass (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: [
                          ..._getSubclassesForClass(_selectedClass).map((subclass) {
                            return DropdownMenuItem(
                              value: subclass,
                              child: SizedBox(
                                width: 200,
                                child: Text(
                                  subclass,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }),
                          DropdownMenuItem(
                            value: '__CUSTOM__',
                            child: SizedBox(
                              width: 200,
                              child: Text(
                                'Custom Subclass...',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == '__CUSTOM__') {
                              _useCustomSubclass = true;
                              _subclassController.text = '';
                            } else {
                              _subclassController.text = value ?? '';
                            }
                            _hasUnsavedClassChanges = true;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Race selection
          Consumer<RacesViewModel>(
            builder: (context, racesViewModel, child) {
              return DropdownButtonFormField<String>(
                value: _raceController.text.isEmpty ? null : _raceController.text,
                decoration: const InputDecoration(
                  labelText: 'Race (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: racesViewModel.races.map((race) {
                  return DropdownMenuItem(
                    value: race.name,
                    child: Text(race.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _raceController.text = value ?? '';
                    _selectedRace = value ?? '';
                    _hasUnsavedClassChanges = true;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Background selection
          Consumer<BackgroundsViewModel>(
            builder: (context, backgroundsViewModel, child) {
              return DropdownButtonFormField<String>(
                value: _backgroundController.text.isEmpty ? null : _backgroundController.text,
                decoration: const InputDecoration(
                  labelText: 'Background (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: backgroundsViewModel.backgrounds.map((background) {
                  return DropdownMenuItem(
                    value: background.name,
                    child: Text(background.name),
                  );
                }).toList(),
                onChanged: (value) {
                  debugPrint('Background dropdown changed to: $value');
                  setState(() {
                    _backgroundController.text = value ?? '';
                    _selectedBackground = value ?? '';
                    _hasUnsavedClassChanges = true;
                    debugPrint('_backgroundController.text: "${_backgroundController.text}"');
                    debugPrint('_selectedBackground: "${_selectedBackground}"');
                    debugPrint('_hasUnsavedClassChanges: $_hasUnsavedClassChanges');
                  });
                },
              );
            },
          ),
          const SizedBox(height: 8),
          
          // Class save button
          if (_hasUnsavedClassChanges)
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: () {
                  _saveCharacter('Information saved!');
                  setState(() {
                    _hasUnsavedClassChanges = false;
                  });
                },
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Long Rest section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bedtime,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Long Rest',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Take a long rest to restore hit points, spell slots, and all class resources.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _takeComprehensiveLongRest,
                    icon: const Icon(Icons.night_shelter),
                    label: const Text('Take Long Rest'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
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
          // Character Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.indigo.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                // Header with Edit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // Space for profile image alignment                    
                    IconButton(
                      onPressed: () {
                        setState(() {
                          // If exiting edit mode (clicking "Done"), save changes
                          if (_isEditingCharacterCover && _hasUnsavedClassChanges) {
                            _saveCharacter('Character updated!');
                          }
                          _isEditingCharacterCover = !_isEditingCharacterCover;
                        });
                      },
                      icon: Icon(
                        _isEditingCharacterCover ? Icons.check : Icons.edit,
                        color: Colors.blue.shade700,
                      ),
                      tooltip: _isEditingCharacterCover ? 'Done' : 'Edit Character',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Profile Image
                GestureDetector(
                  onTap: _isEditingCharacterCover ? _showImageOptionsDialog : null,
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: _isEditingCharacterCover 
                                ? Colors.green.shade300 
                                : Colors.blue.shade300, 
                            width: 2,
                          ),
                        ),
                        child: _customImagePath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(_customImagePath!),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                      ),
                      if (_isEditingCharacterCover)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: _buildPickImageButton(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Character Name
                _isEditingCharacterCover
                    ? TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Character Name',
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Text(
                        _nameController.text.isNotEmpty 
                            ? _nameController.text 
                            : 'Character Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                const SizedBox(height: 12),
                
                // Character Level
                _isEditingCharacterCover
                    ? TextField(
                        controller: _levelController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Character Level',
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Text(
                        'Level ${_levelController.text.isNotEmpty ? _levelController.text : '1'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                const SizedBox(height: 12),
                
                // Class and Subclass
                _isEditingCharacterCover
                    ? Row(
                        children: [
                          Expanded(
                            child: Consumer<CharactersViewModel>(
                              builder: (context, viewModel, child) {
                                return DropdownButtonFormField<String>(
                                  value: _selectedClass,
                                  decoration: const InputDecoration(
                                    labelText: 'Class',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: viewModel.availableClasses.map((className) {
                                    return DropdownMenuItem(
                                      value: className,
                                      child: Text(className),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedClass = value!;
                                      _classController.text = value;
                                      _useCustomSubclass = false;
                                      _hasUnsavedClassChanges = true;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_useCustomSubclass)
                                  TextField(
                                    controller: _subclassController,
                                    decoration: InputDecoration(
                                      labelText: 'Custom Subclass',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.list),
                                        onPressed: () {
                                          setState(() {
                                            _useCustomSubclass = false;
                                            _hasUnsavedClassChanges = true;
                                          });
                                        },
                                        tooltip: 'Choose from preset subclasses',
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _hasUnsavedClassChanges = true;
                                      });
                                    },
                                  )
                                else
                                  DropdownButtonFormField<String>(
                                    value: _useCustomSubclass || _subclassController.text.isEmpty || !_getSubclassesForClass(_selectedClass).contains(_subclassController.text) ? null : _subclassController.text,
                                    decoration: const InputDecoration(
                                      labelText: 'Subclass (Optional)',
                                      border: OutlineInputBorder(),
                                    ),
                                    isExpanded: true,
                                    items: [
                                      ..._getSubclassesForClass(_selectedClass).map((subclass) {
                                        return DropdownMenuItem(
                                          value: subclass,
                                          child: SizedBox(
                                            width: 200,
                                            child: Text(
                                              subclass,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        );
                                      }),
                                      const DropdownMenuItem(
                                        value: 'custom',
                                        child: Text('Custom Subclass'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == 'custom') {
                                        setState(() {
                                          _useCustomSubclass = true;
                                          _hasUnsavedClassChanges = true;
                                        });
                                      } else {
                                        setState(() {
                                          _subclassController.text = value!;
                                          _useCustomSubclass = false;
                                          _hasUnsavedClassChanges = true;
                                        });
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _classController.text.isNotEmpty 
                            ? (_subclassController.text.isNotEmpty 
                                ? '${_classController.text} • ${_subclassController.text}'
                                : _classController.text)
                            : 'Class • Subclass',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
              
              // Race selection
              Consumer<RacesViewModel>(
                builder: (context, racesViewModel, child) {
                  // Create unique race items by using race name + source if needed
                  final Map<String, Race> uniqueRaces = {};
                  for (final race in racesViewModel.races) {
                    final key = race.name;
                    if (!uniqueRaces.containsKey(key)) {
                      uniqueRaces[key] = race;
                    }
                  }
                  
                  final selectedRace = _raceController.text.isNotEmpty 
                      ? uniqueRaces[_raceController.text]
                      : null;
                  
                  return _isEditingCharacterCover
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: DropdownButtonFormField<String>(
                                  value: _raceController.text.isEmpty ? null : _raceController.text,
                                  decoration: InputDecoration(
                                    labelText: 'Race (Optional)',
                                    border: OutlineInputBorder(),
                                    suffixIcon: selectedRace != null 
                                        ? IconButton(
                                            icon: const Icon(Icons.info_outline),
                                            onPressed: () => _showRaceDetailsModal(selectedRace),
                                            tooltip: 'View race details',
                                          )
                                        : null,
                                  ),
                                  items: uniqueRaces.values.map<DropdownMenuItem<String>>((race) {
                                    return DropdownMenuItem<String>(
                                      value: race.name,
                                      child: Text(race.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _raceController.text = value ?? '';
                                      _selectedRace = value ?? '';
                                      _hasUnsavedClassChanges = true;
                                    });
                                  },
                                ),
                            ),
                            const SizedBox(height: 16),
                            Consumer<BackgroundsViewModel>(
                              builder: (context, backgroundsViewModel, child) {
                                Background? selectedBackground;
                                if (_backgroundController.text.isNotEmpty && backgroundsViewModel.backgrounds.isNotEmpty) {
                                  try {
                                    selectedBackground = backgroundsViewModel.backgrounds.firstWhere(
                                      (background) => background.name == _backgroundController.text,
                                    );
                                  } catch (e) {
                                    // Background not found, keep selectedBackground as null
                                    debugPrint('Background "${_backgroundController.text}" not found in list');
                                  }
                                }
                                
                                return DropdownButtonFormField<String>(
                                  value: _backgroundController.text.isEmpty ? null : _backgroundController.text,
                                  decoration: InputDecoration(
                                    labelText: 'Background (Optional)',
                                    border: OutlineInputBorder(),
                                    suffixIcon: selectedBackground != null 
                                        ? IconButton(
                                            icon: const Icon(Icons.info_outline),
                                            onPressed: () => _showBackgroundDetailsModal(selectedBackground!),
                                            tooltip: 'View background details',
                                          )
                                        : null,
                                  ),
                                  items: backgroundsViewModel.backgrounds.map((background) {
                                    return DropdownMenuItem(
                                      value: background.name,
                                      child: Text(background.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    debugPrint('Character cover background dropdown changed to: $value');
                                    setState(() {
                                      _backgroundController.text = value ?? '';
                                      _selectedBackground = value ?? '';
                                      _hasUnsavedClassChanges = true;
                                      debugPrint('Cover _backgroundController.text: "${_backgroundController.text}"');
                                      debugPrint('Cover _selectedBackground: "${_selectedBackground}"');
                                      debugPrint('Cover _hasUnsavedClassChanges: $_hasUnsavedClassChanges');
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: selectedRace != null 
                              ? () => _showRaceDetailsModal(selectedRace)
                              : null,
                          child: Consumer<BackgroundsViewModel>(
                          builder: (context, backgroundsViewModel, child) {
                            Background? selectedBackground;
                            if (_backgroundController.text.isNotEmpty && backgroundsViewModel.backgrounds.isNotEmpty) {
                              try {
                                selectedBackground = backgroundsViewModel.backgrounds.firstWhere(
                                  (background) => background.name == _backgroundController.text,
                                );
                              } catch (e) {
                                // Background not found, keep selectedBackground as null
                                debugPrint('Background "${_backgroundController.text}" not found in list');
                              }
                            }
                            
                            final hasRace = _raceController.text.isNotEmpty;
                            final hasBackground = _backgroundController.text.isNotEmpty;
                            
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Race display
                                if (hasRace) ...[
                                  
                                GestureDetector(
                                  onTap: selectedRace != null 
                                      ? () => _showRaceDetailsModal(selectedRace)
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                        _raceController.text.isNotEmpty 
                                            ? _raceController.text
                                            : 'Race',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: selectedRace != null 
                                              ? Colors.blue.shade600
                                              : Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                          decoration: selectedRace != null 
                                              ? TextDecoration.underline
                                              : null,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                  ),
                                ),],
                                
                                // Background display
                                if (hasBackground) ...[ 
                                  Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                          ' • ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: selectedBackground != null 
                                                ? Colors.blue.shade600
                                                : Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,                                            
                                          ),
                                          textAlign: TextAlign.center,
                                      ),
                                    ),
                                                                  
                                  GestureDetector(
                                    onTap: selectedBackground != null
                                        ? () => _showBackgroundDetailsModal(selectedBackground!)
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                          _backgroundController.text,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: selectedBackground != null 
                                                ? Colors.blue.shade600
                                                : const Color.fromARGB(255, 117, 117, 117),
                                            fontStyle: FontStyle.italic,
                                            decoration: selectedBackground != null 
                                                ? TextDecoration.underline
                                                : null,
                                          ),
                                          textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        );
                },
              ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Combat Stats Row
          Row(
            children: [
              Expanded(
                child: _buildInspirationField(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildArmorClassField(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSpeedField(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: 
              Column(children:[                
                _buildIniciativeField(),
                const SizedBox(height: 24)
                ]),
            ),

          // Concentration Row - only show for spellcasting classes
          if (_canCastSpells())           
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: 
              Column(children:[                
                _buildConcentrationField(),
                const SizedBox(height: 24)
                ]),
            ),
            
          // Health Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                                
                // Hit Points
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _maxHpController,
                          decoration: const InputDecoration(
                            labelText: 'Max HP',
                            prefixIcon: Icon(Icons.health_and_safety, color: Colors.blue),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _currentHpController,
                          decoration: const InputDecoration(
                            labelText: 'Current HP',
                            prefixIcon: Icon(Icons.favorite_border, color: Colors.blue),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _tempHpController,
                    decoration: const InputDecoration(
                      labelText: 'Temporary HP',
                      prefixIcon: Icon(Icons.shield, color: Colors.indigo),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Hit Dice
                const Text(
                  'Hit Dice',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _hitDiceController,
                          decoration: const InputDecoration(
                            labelText: 'Number of Hit Dice',
                            prefixIcon: Icon(Icons.casino, color: Colors.blue),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _hitDiceTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Hit Dice Type',
                            prefixIcon: Icon(Icons.category, color: Colors.blue),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Death Saving Throws Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Death Saving Throws',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  // Successes row
                  Row(
                    children: [
                      Text(
                        'Successes:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                      ...List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _deathSaveSuccesses[index] = !_deathSaveSuccesses[index];
                              });
                              _autoSaveCharacter();
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _deathSaveSuccesses[index] ? Colors.green : Colors.grey.shade300,
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: _deathSaveSuccesses[index] 
                                  ? Icon(Icons.check, color: Colors.white, size: 16)
                                  : const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Failures row
                  Row(
                    children: [
                      Text(
                        'Failures:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 35),
                      ...List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _deathSaveFailures[index] = !_deathSaveFailures[index];
                              });
                              _autoSaveCharacter();
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _deathSaveFailures[index] ? Colors.red : Colors.grey.shade300,
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: _deathSaveFailures[index] 
                                  ? Icon(Icons.close, color: Colors.white, size: 16)
                                  : const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Clear button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _deathSaveSuccesses = [false, false, false];
                          _deathSaveFailures = [false, false, false];
                        });
                        _autoSaveCharacter();
                      },                      
                      label: const Text('Clear All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Other proficiencies Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Other proficiencies',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),                  
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _proficienciesController,
                      decoration: const InputDecoration(
                        hintText: 'Add other proficiencies and bonuses...\n\n'
                            'Examples:\n'
                            '• Tool proficiencies (smith\'s tools, herbalism kit, etc.)\n'
                            '• Weapon proficiencies not covered by class/race\n'
                            '• Armor proficiencies from special training\n'
                            '• Skill proficiencies from background or feats\n'
                            '• Languages and special abilities\n'
                            '• Other bonuses or special features',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 12,
                      minLines: 3,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => _autoSaveCharacter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
           const SizedBox(height: 16),
          // Other proficiencies Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Features & traits',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),                  
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _featuresTraitsController,
                      decoration: const InputDecoration(
                        hintText: 'Add features and traits...\n\n'
                            'Examples:\n'
                            '• Specific abilities from your Race, Class, Background, or Feats',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 12,
                      minLines: 6,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => _autoSaveCharacter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          // Languages Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Languages',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'List all languages your character can speak and understand.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _languagesController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your character\'s languages...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 6,
                      minLines: 4,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => _autoSaveCharacter(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Money and Items Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Money & Items',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your character\'s wealth and possessions.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Money field
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _moneyController,
                      decoration: const InputDecoration(
                        labelText: 'Money',
                        hintText: 'Enter your character\'s wealth...\n\n'
                            'Examples:\n'
                            '• 150 gp, 50 sp, 25 cp\n'
                            '• 2,000 gp\n'
                            '• Pocket change: 5 gp, 12 sp, 8 cp\n'
                            '• Bank funds: 10,000 gp',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => _autoSaveCharacter(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Items field
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _itemsController,
                      decoration: const InputDecoration(
                        labelText: 'Items & Equipment',
                        hintText: 'List your character\'s equipment and possessions...\n\n'
                            'Weapons:\n'
                            '• Longsword +1, Shield +1\n'
                            '• Shortbow with 20 arrows\n'
                            '• Dagger +2\n\n'
                            'Armor:\n'
                            '• Chain mail armor\n'
                            '• Steel shield\n'
                            '• Helmet of protection\n\n'
                            'Magic Items:\n'
                            '• Ring of invisibility\n'
                            '• Amulet of health\n'
                            '• Boots of speed\n'
                            '• Cloak of elvenkind\n\n'
                            'Tools & Equipment:\n'
                            '• Thieves\' tools\n'
                            '• Climbing gear\n'
                            '• Rope 50ft\n'
                            '• Rations for 1 week\n'
                            '• Waterskin\n'
                            '• Bedroll and blanket',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 12,
                      minLines: 6,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => _autoSaveCharacter(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Auto-saves automatically • No character limit • Rich text supported',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Long Rest section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bedtime,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Long Rest',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _takeComprehensiveLongRest,
                  icon: const Icon(Icons.night_shelter),
                  label: const Text('Take Long Rest'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24), // Space under long rest section
        ],
      ),
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
    switch (ability) {
      case 'STR':
        return int.tryParse(_strengthController.text) ?? 10;
      case 'DEX':
        return int.tryParse(_dexterityController.text) ?? 10;
      case 'CON':
        return int.tryParse(_constitutionController.text) ?? 10;
      case 'INT':
        return int.tryParse(_intelligenceController.text) ?? 10;
      case 'WIS':
        return int.tryParse(_wisdomController.text) ?? 10;
      case 'CHA':
        return int.tryParse(_charismaController.text) ?? 10;
      default:
        return 10;
    }
  }
  
  int _getAbilityModifier(String ability) {
    final score = _getAbilityScore(ability);
    return ((score - 10) / 2).floor();
  }
  
  int _getSpellSaveDC() {
    final spellcastingAbility = _getSpellcastingAbility();
    if (spellcastingAbility == null) return 0;
    
    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(int.tryParse(_levelController.text) ?? 1);
    final abilityModifier = _getAbilityModifier(spellcastingAbility);
    
    return 8 + proficiencyBonus + abilityModifier;
  }
  
  int _getSpellAttackBonus() {
    final spellcastingAbility = _getSpellcastingAbility();
    if (spellcastingAbility == null) return 0;
    
    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(int.tryParse(_levelController.text) ?? 1);
    final abilityModifier = _getAbilityModifier(spellcastingAbility);
    
    return proficiencyBonus + abilityModifier;
  }

  Widget _buildSpellcastingInfoRow(String label, String description, String value) {
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
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
    switch (ability) {
      case 'STR':
        return 'Strength';
      case 'DEX':
        return 'Dexterity';
      case 'CON':
        return 'Constitution';
      case 'INT':
        return 'Intelligence';
      case 'WIS':
        return 'Wisdom';
      case 'CHA':
        return 'Charisma';
      default:
        return ability;
    }
  }
  
  List<String> _getSubclassesForClass(String className) {
    switch (className.toLowerCase()) {
      case 'fighter':
        return [
          'Battle Master',
          'Champion',
          'Eldritch Knight',
          'Psi Warrior',
          'Rune Knight',
          'Samurai',
          'Cavalier',
          'Gunslinger',
          'Banneret',
        ];
      case 'wizard':
        return [
          'School of Abjuration',
          'School of Conjuration',
          'School of Divination',
          'School of Enchantment',
          'School of Evocation',
          'School of Illusion',
          'School of Necromancy',
          'School of Transmutation',
          'School of Bladesinging',
          'School of Chronurgy',
          'School of Graviturgy',
          'School of Scribes',
          'School of Order',
          'School of Invention',
          'School of War Magic',
        ];
      case 'cleric':
        return [
          'Knowledge Domain',
          'Life Domain',
          'Light Domain',
          'Nature Domain',
          'Order Domain',
          'Peace Domain',
          'Trickery Domain',
          'War Domain',
          'Forge Domain',
          'Grave Domain',
          'Twilight Domain',
          'Arcana Domain',
        ];
      case 'rogue':
        return [
          'Thief',
          'Assassin',
          'Arcane Trickster',
          'Inquisitive',
          'Mastermind',
          'Scout',
          'Soulknife',
          'Swashbuckler',
          'Phantom',
        ];
      case 'ranger':
        return [
          'Hunter',
          'Beast Master',
          'Gloom Stalker',
          'Horizon Walker',
          'Monster Slayer',
          'Fey Wanderer',
          'Druidic Warrior',
          'Swarmkeeper',
        ];
      case 'paladin':
        return [
          'Devotion',
          'Ancients',
          'Vengeance',
          'Oathbreaker',
          'Glory',
          'Crown',
          'Watchers',
        ];
      case 'barbarian':
        return [
          'Path of the Berserker',
          'Path of the Totem Warrior',
          'Path of the Zealot',
          'Path of the Wild Magic',
          'Path of the Storm Herald',
          'Path of the Ancestral Guardian',
          'Path of the Battlerager',
          'Path of the Beast',
          'Path of the Wild Soul',
        ];
      case 'bard':
        return [
          'College of Lore',
          'College of Valor',
          'College of Glamour',
          'College of Swords',
          'College of Whispers',
          'College of Creation',
          'College of Eloquence',
          'College of Spirits',
        ];
      case 'druid':
        return [
          'Circle of the Land',
          'Circle of the Moon',
          'Circle of the Shepherd',
          'Circle of Spores',
          'Circle of Stars',
          'Circle of Wildfire',
          'Circle of Dreams',
          'Circle of the Coast',
        ];
      case 'monk':
        return [
          'Way of the Open Hand',
          'Way of Shadow',
          'Way of the Four Elements',
          'Way of the Long Death',
          'Way of Mercy',
          'Way of the Drunken Master',
          'Way of the Kensei',
          'Way of the Astral Self',
        ];
      case 'sorcerer':
        return [
          'Draconic Bloodline',
          'Wild Magic',
          'Divine Soul',
          'Shadow Magic',
          'Storm Sorcery',
          'Clockwork Soul',
          'Aberrant Mind',
        ];
      case 'warlock':
        return [
          'The Fiend',
          'The Great Old One',
          'The Celestial',
          'The Hexblade',
          'The Archfey',
          'The Undying',
          'The Genie',
          'The Fathomless',
          'The Undead',
        ];
      case 'artificer':
        return [
          'Alchemist',
          'Armorer',
          'Artillerist',
          'Battle Smith',
        ];
      default:
        return [];
    }
  }

  Widget _buildAttacksTab() {
    final spellcastingAbility = _getSpellcastingAbility();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attacks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your character\'s attacks and weapons',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),

          // Attacks list
          ..._attacks.asMap().entries.map((entry) {
            final index = entry.key;
            final attack = entry.value;
            return Card(
              child: ListTile(
                title: Text(attack.name),
                subtitle: Text(
                  '${attack.attackBonus} | ${attack.damage} ${attack.damageType}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _attacks.removeAt(index);
                    });

                    // Auto-save the character when an attack is removed
                    _autoSaveCharacter();
                  },
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          
          // Debug: Always show spellcasting section for testing
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
                
                // Debug info
                /* Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Class: "${_classController.text}"'),
                      Text('Subclass: "${_subclassController.text}"'),
                      Text('Spellcasting Ability: $spellcastingAbility'),
                    ],
                  ),
                ), */
                
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

          TextButton.icon(
            onPressed: _showAddAttackDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Attack'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGuideTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Guide Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Quick Guide',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A quick reference guide for your character\'s key information, abilities, and gameplay notes.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _quickGuideController,
                      decoration: const InputDecoration(
                        hintText: 'Create your character quick guide...\n\n'
                            'Consider including:\n'
                            '• Character concept and role in the party\n'
                            '• Key abilities and combat tactics\n'
                            '• Important spells or features\n'
                            '• Equipment and magic items\n'
                            '• Roleplaying notes and personality traits\n'
                            '• Goals and motivations\n'
                            '• Relationships with other party members\n'
                            '• Weaknesses and limitations',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 15,
                      minLines: 8,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => _autoSaveCharacter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ability Scores',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ' Level ${_levelController.text.isNotEmpty ? _levelController.text : '1'} • proficiency bonus: +${CharacterStats.calculateProficiencyBonus(int.tryParse(_levelController.text) ?? 1)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (_hasUnsavedAbilityChanges)
                ElevatedButton.icon(
                  onPressed: () {                    
                    _saveCharacter('Ability scores saved!');
                    setState(() {
                      _hasUnsavedAbilityChanges = false;
                    });
                  },
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Ability scores grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.1, // Slightly taller cards
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildStatField('STRENGTH', _strengthController),
              _buildStatField('DEXTERITY', _dexterityController),
              _buildStatField('CONSTITUTION', _constitutionController),
              _buildStatField('INTELLIGENCE', _intelligenceController),
              _buildStatField('WISDOM', _wisdomController),
              _buildStatField('CHARISMA', _charismaController),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Saving Throws',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Saving throws with calculated modifiers
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildSavingThrowRow('STR', _savingThrows.strengthProficiency, (
                value,
              ) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: value ?? false,
                    dexterityProficiency: _savingThrows.dexterityProficiency,
                    constitutionProficiency:
                        _savingThrows.constitutionProficiency,
                    intelligenceProficiency:
                        _savingThrows.intelligenceProficiency,
                    wisdomProficiency: _savingThrows.wisdomProficiency,
                    charismaProficiency: _savingThrows.charismaProficiency,
                  );
                  _autoSaveCharacter(); // Auto-save saving throws
                });
              }),
              _buildSavingThrowRow('DEX', _savingThrows.dexterityProficiency, (
                value,
              ) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: _savingThrows.strengthProficiency,
                    dexterityProficiency: value ?? false,
                    constitutionProficiency:
                        _savingThrows.constitutionProficiency,
                    intelligenceProficiency:
                        _savingThrows.intelligenceProficiency,
                    wisdomProficiency: _savingThrows.wisdomProficiency,
                    charismaProficiency: _savingThrows.charismaProficiency,
                  );
                  _autoSaveCharacter(); // Auto-save saving throws
                });
              }),
              _buildSavingThrowRow(
                'CON',
                _savingThrows.constitutionProficiency,
                (value) {
                  setState(() {
                    _savingThrows = CharacterSavingThrows(
                      strengthProficiency: _savingThrows.strengthProficiency,
                      dexterityProficiency: _savingThrows.dexterityProficiency,
                      constitutionProficiency: value ?? false,
                      intelligenceProficiency:
                          _savingThrows.intelligenceProficiency,
                      wisdomProficiency: _savingThrows.wisdomProficiency,
                      charismaProficiency: _savingThrows.charismaProficiency,
                    );
                    _autoSaveCharacter(); // Auto-save saving throws
                  });
                },
              ),
              _buildSavingThrowRow(
                'INT',
                _savingThrows.intelligenceProficiency,
                (value) {
                  setState(() {
                    _savingThrows = CharacterSavingThrows(
                      strengthProficiency: _savingThrows.strengthProficiency,
                      dexterityProficiency: _savingThrows.dexterityProficiency,
                      constitutionProficiency:
                          _savingThrows.constitutionProficiency,
                      intelligenceProficiency: value ?? false,
                      wisdomProficiency: _savingThrows.wisdomProficiency,
                      charismaProficiency: _savingThrows.charismaProficiency,
                    );
                    _autoSaveCharacter(); // Auto-save saving throws
                  });
                },
              ),
              _buildSavingThrowRow('WIS', _savingThrows.wisdomProficiency, (
                value,
              ) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: _savingThrows.strengthProficiency,
                    dexterityProficiency: _savingThrows.dexterityProficiency,
                    constitutionProficiency:
                        _savingThrows.constitutionProficiency,
                    intelligenceProficiency:
                        _savingThrows.intelligenceProficiency,
                    wisdomProficiency: value ?? false,
                    charismaProficiency: _savingThrows.charismaProficiency,
                  );
                  _autoSaveCharacter(); // Auto-save saving throws
                });
              }),
              _buildSavingThrowRow('CHA', _savingThrows.charismaProficiency, (
                value,
              ) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: _savingThrows.strengthProficiency,
                    dexterityProficiency: _savingThrows.dexterityProficiency,
                    constitutionProficiency:
                        _savingThrows.constitutionProficiency,
                    intelligenceProficiency:
                        _savingThrows.intelligenceProficiency,
                    wisdomProficiency: _savingThrows.wisdomProficiency,
                    charismaProficiency: value ?? false,
                  );
                  _autoSaveCharacter(); // Auto-save saving throws
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatField(String label, TextEditingController controller) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0), // Reduced padding from 8.0 to 6.0
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2), // Reduced height from 4 to 2
            Expanded( // Make the container expand to fit available space
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black54, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded( // Make TextField expand
                      child: Center( // Center the TextField within the Expanded space
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: '10',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero, // Remove content padding for better centering
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            // Mark as having unsaved changes and force rebuild
                            setState(() {
                              _hasUnsavedAbilityChanges = true;
                            });
                            // Force rebuild to update modifier
                            (context as Element).markNeedsBuild();
                          },
                          onSubmitted: (value) {
                            // Dismiss keyboard when Done is pressed
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2, // Reduced vertical padding from 3 to 2
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        _getModifier(controller.text),
                        style: const TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0, 
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombatField(String label, TextEditingController controller) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black54, width: 1),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '10',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspirationField() {
    final isActiveColor = _hasInspiration ? Colors.green : Colors.blue;
    
    return Container(
      decoration: BoxDecoration(
        color: _hasInspiration ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _hasInspiration ? Colors.green.shade200 : Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: (_hasInspiration ? Colors.green : Colors.blue).withOpacity(0.1),
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
                    _autoSaveCharacter();
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Icon(
                        _hasInspiration ? Icons.check_circle : Icons.circle_outlined,
                        color: _hasInspiration ? Colors.green.shade800 : Colors.grey.shade400,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Check if the current class or subclass can cast spells
  bool _canCastSpells() {
    final characterClass = _classController.text.trim().toLowerCase();
    final subclass = _subclassController.text.trim().toLowerCase();
    
    // Debug log to track spellcasting detection
    debugPrint('Checking spellcasting for class: "$characterClass", subclass: "$subclass"');
    
    // Full spellcasting classes
    final spellcastingClasses = {
      'wizard', 'sorcerer', 'warlock', 'bard', 'cleric', 'druid', 
      'artificer', 'blood hunter', 'mystic'
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
      debugPrint('Class "$characterClass" is a spellcasting class (special case)');
      return true;
    }
    
    debugPrint('Class "$characterClass" with subclass "$subclass" cannot cast spells');
    return false;
  }

Widget _buildIniciativeField() {
    final currentInitiative = int.tryParse(_initiativeController.text) ?? 0;
    final currentDexterity = int.tryParse(_dexterityController.text) ?? 10;
    final dexterityModifier = ((currentDexterity - 10) / 2).floor();
    
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Initiative Modifier:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _showInitiativeDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Center(
                      child: Text(
                        currentInitiative.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current: $currentInitiative (Dex modifier: $dexterityModifier). Usually equals dexterity modifier but can be modified by feats, items, or special abilities.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConcentrationField() {
    final isActiveColor = _hasConcentration ? Colors.green : Colors.purple;
    
    return Container(
      decoration: BoxDecoration(
        color: _hasConcentration ? Colors.green.shade50 : Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _hasConcentration ? Colors.green.shade200 : Colors.purple.shade200),
        boxShadow: [
          BoxShadow(
            color: (_hasConcentration ? Colors.green : Colors.purple).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _hasConcentration = !_hasConcentration;
                  _autoSaveCharacter();
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Spell Concentration',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _hasConcentration ? Colors.green.shade700 : Colors.purple.shade700,
                      ),
                    ),
                  ),
                  Icon(
                    _hasConcentration ? Icons.check_circle : Icons.circle_outlined,
                    color: _hasConcentration ? Colors.green.shade800 : Colors.grey.shade400,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: isActiveColor.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You must pass a Constitution Saving Throw (CON ST) when you take damage (DC 10 or half the damage, whichever is greater) and you can only maintain one concentration spell at a time, losing it if you are incapacitated, die, or cast another spell that requires it.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActiveColor.shade700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArmorClassField() {
    final isActiveColor = _hasShield ? Colors.red : Colors.blue;
    return Container(
      decoration: BoxDecoration(
        color:  isActiveColor.shade50,
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
            Icon(
              Icons.shield,
              color: isActiveColor.shade600,
              size: 24,
            ),
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
                          _autoSaveCharacter();
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        _hasShield ? Icons.check_circle : Icons.circle_outlined,
                        color: _hasShield ? isActiveColor.shade800 : Colors.grey.shade400,
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
            Icon(
              Icons.directions_run,
              color: Colors.blue.shade600,
              size: 24,
            ),
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
                textInputAction: TextInputAction.done, // Show "Done" button on keyboard
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

  String _getModifier(String scoreText) {
    try {
      final score = int.tryParse(scoreText) ?? 10;
      final modifier = ((score - 10) / 2).floor();
      return modifier >= 0 ? '+$modifier' : '$modifier';
    } catch (e) {
      return '+0';
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    switch (abilityName) {
      case 'Strength':
        return 'STR';
      case 'Dexterity':
        return 'DEX';
      case 'Intelligence':
        return 'INT';
      case 'Wisdom':
        return 'WIS';
      case 'Charisma':
        return 'CHA';
      default:
        return abilityName.substring(0, 3).toUpperCase();
    }
  }

  Widget _buildSavingThrowRow(
    String ability,
    bool isProficient,
    Function(bool?) onChanged,
  ) {
    final abilityScore = _getAbilityScore(ability);
    final modifier = ((abilityScore - 10) / 2).floor();
    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(int.tryParse(_levelController.text) ?? 1);
    final total = modifier + (isProficient ? proficiencyBonus : 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Ability and modifier
          SizedBox(
            width: 50,
            child: Text(
              '$ability\n${modifier >= 0 ? '+' : ''}$modifier',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          // Proficiency checkbox
          Checkbox(
            value: isProficient,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                color: isProficient ? Colors.blue : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
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
    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(int.tryParse(_levelController.text) ?? 1);
    
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

  Widget _buildDeleteButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
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
                : const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 20,
                ),
        onPressed: _isPickingImage ? null : () => _triggerHapticAndConfirm(),
        tooltip: 'Remove image',
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
        onPressed: _isPickingImage ? null : _triggerHapticAndShowOptions,
        tooltip: 'Change image',
      ),
    );
  }

  Future<void> _triggerHapticAndConfirm() async {
    _showDeleteConfirmation();
  }

  Future<void> _triggerHapticAndShowOptions() async {
    _showImageOptionsDialog();
  }

  Future<void> _triggerHapticAndPickImage() async {
    _pickImage();
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
      _autoSaveCharacter(); // Auto-save skill changes
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
      _autoSaveCharacter(); // Auto-save skill expertise changes
    });
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hit Points',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _maxHpController,
                  decoration: const InputDecoration(
                    labelText: 'Max HP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _currentHpController,
                  decoration: const InputDecoration(
                    labelText: 'Current HP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _tempHpController,
            decoration: const InputDecoration(
              labelText: 'Temporary HP',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done, // Show "Done" button on keyboard
          ),

          const SizedBox(height: 24),
          const Text(
            'Hit Dice',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hitDiceController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Hit Dice',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _hitDiceTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Hit Dice Type',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildSpellsTab() {
    // Calculate maximum prepared spells using current state
    final modifier = CharacterSpellPreparation.getSpellcastingModifier(widget.character);
    final calculatedMax = CharacterSpellPreparation.calculateMaxPreparedSpells(
      _classController.text.trim(), // Use current class from controller
      int.tryParse(_levelController.text) ?? 1, // Use current level from controller
      modifier,
    );
    
    // Use the stored max if it's different from calculated (user modified it)
    final maxPrepared = _spellPreparation.maxPreparedSpells == 0 
        ? calculatedMax 
        : _spellPreparation.maxPreparedSpells;
    
    // Check if user has modified the max (for visual indicator)
    final isModified = _spellPreparation.maxPreparedSpells != 0 && _spellPreparation.maxPreparedSpells != calculatedMax;
    
    final canPrepare = maxPrepared > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const SizedBox(height: 8),
          const Text(
            'Manage your character\'s known spells.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _showAddSpellDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Spell'),
              ),
            ],
          ),
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
                      Icon(Icons.auto_stories, color: Colors.indigo.shade700, size: 20),
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
                            builder: (context) => AlertDialog(
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
                            color: _spellPreparation.currentPreparedCount < maxPrepared ? Colors.green.shade700 : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _showMaxPreparedDialog,
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Modify', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo.shade700,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                final currentPrepared = _spellPreparation.preparedSpells;
                                
                                // If we have more prepared spells than the new max, uncheck excess
                                if (currentPrepared.length > newMax) {
                                  final spellsToKeep = currentPrepared.take(newMax).toList();
                                  _spellPreparation = _spellPreparation.copyWith(
                                    maxPreparedSpells: 0, // Reset to calculated
                                    preparedSpells: spellsToKeep, // Keep only up to new max
                                  );
                                } else {
                                  // Just reset max, keep current prepared spells
                                  _spellPreparation = _spellPreparation.copyWith(maxPreparedSpells: 0);
                                }
                              });
                              _autoSaveCharacter();
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
          ..._buildSpellsByLevel(),
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  IconData _getSpellLevelIcon(int level) {
    switch (level) {
      case 0:
        return Icons.auto_awesome;
      case 1:
        return Icons.filter_1;
      case 2:
        return Icons.filter_2;
      case 3:
        return Icons.filter_3;
      case 4:
        return Icons.filter_4;
      case 5:
        return Icons.filter_5;
      case 6:
        return Icons.filter_6;
      case 7:
        return Icons.filter_7;
      case 8:
        return Icons.filter_8;
      case 9:
        return Icons.filter_9;
      default:
        return Icons.star;
    }
  }

  /// Get the count of prepared spells for a specific level
  int _getPreparedSpellsCountForLevel(int level) {
    final spellsViewModel = context.read<SpellsViewModel>();
    int count = 0;
    for (final spellName in _spells) {
      if (_spellPreparation.isSpellPrepared(spellName)) {
        // Get spell level from cached spells list instead of context.read
        final spell = spellsViewModel.spells.firstWhere(
          (s) => s.name.toLowerCase() == spellName.toLowerCase(),
          orElse: () => Spell(
            id: 'unknown',
            name: spellName,
            castingTime: 'Unknown',
            range: 'Unknown',
            duration: 'Unknown',
            description: 'Custom spell',
            classes: [],
            dice: [],
            updatedAt: DateTime.now(),
          ),
        );
        
        if (spell.levelNumber == level) {
          count++;
        }
      }
    }
    return count;
  }

  List<Widget> _buildSpellsByLevel() {
    if (_spells.isEmpty) {
      return [
        const Center(
          child: Text(
            'No spells added yet',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      ];
    }

    final spellsViewModel = context.read<SpellsViewModel>();
    final Map<int, List<Map<String, dynamic>>> spellsByLevel = {};

    // Group spells by level
    for (int i = 0; i < _spells.length; i++) {
      final spellName = _spells[i];
      final spell = spellsViewModel.spells.firstWhere(
        (s) => s.name.toLowerCase() == spellName.toLowerCase(),
        orElse: () => Spell(
          id: 'unknown',
          name: spellName,
          castingTime: 'Unknown',
          range: 'Unknown',
          duration: 'Unknown',
          description: 'Custom spell',
          classes: [],
          dice: [],
          updatedAt: DateTime.now(),
        ),
      );

      final level = spell.levelNumber;
      if (!spellsByLevel.containsKey(level)) {
        spellsByLevel[level] = [];
      }
      spellsByLevel[level]!.add({
        'index': i,
        'spell': spell,
      });
    }

    // Sort levels (0-9, where 0 is cantrips)
    final sortedLevels = spellsByLevel.keys.toList()..sort();

    final List<Widget> widgets = [];

    for (final level in sortedLevels) {
      final spellsInLevel = spellsByLevel[level]!;
      
      // Calculate max prepared spells for this class (used for header and individual spells)
      final currentCalculatedMax = CharacterSpellPreparation.calculateMaxPreparedSpells(
        _classController.text.trim(), // Use current class from controller
        int.tryParse(_levelController.text) ?? 1, // Use current level from controller
        CharacterSpellPreparation.getSpellcastingModifier(widget.character),
      );
      
      // Add level header
      widgets.add(
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: level == 0 
                    ? [Colors.purple.shade50, Colors.purple.shade100]
                    : [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: level == 0 ? Colors.purple.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSpellLevelIcon(level),
                    color: level == 0 ? Colors.purple.shade700 : Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    level == 0 ? 'Cantrips' : 'Level $level Spells',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: level == 0 ? Colors.purple.shade700 : Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (level == 0 ? Colors.purple : Colors.blue).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${spellsInLevel.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: level == 0 ? Colors.purple.shade700 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Only show prepared count if class can prepare spells and level > 0
            if (level > 0 && currentCalculatedMax > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${spellsInLevel.where((spellData) {
                      final spell = spellData['spell'] as Spell;
                      final spellId = spell.id; // Use spell.id instead of spell.name
                      final isPrepared = _spellPreparation.isSpellPrepared(spellId);
                      debugPrint('Spell: ${spell.name}, ID: $spellId, Prepared: $isPrepared');
                      return isPrepared;
                    }).length} prepared',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

      // Sort spells within each level: always prepared first, then prepared spells, then others
      spellsInLevel.sort((a, b) {
        final spellA = a['spell'] as Spell;
        final spellB = b['spell'] as Spell;
        
        final isAlwaysPreparedA = _spellPreparation.isSpellAlwaysPrepared(spellA.id);
        final isAlwaysPreparedB = _spellPreparation.isSpellAlwaysPrepared(spellB.id);
        
        // Always prepared spells come first
        if (isAlwaysPreparedA && !isAlwaysPreparedB) return -1;
        if (!isAlwaysPreparedA && isAlwaysPreparedB) return 1;
        
        // If both are always prepared or both are not, sort by prepared status
        final isPreparedA = _spellPreparation.isSpellPrepared(spellA.id);
        final isPreparedB = _spellPreparation.isSpellPrepared(spellB.id);
        
        if (isPreparedA && !isPreparedB) return -1;
        if (!isPreparedA && isPreparedB) return 1;
        
        // If both have same preparation status, sort alphabetically
        return spellA.name.compareTo(spellB.name);
      });

      // Add spells in this level
      for (final spellData in spellsInLevel) {
        final index = spellData['index'] as int;
        final spell = spellData['spell'] as Spell;
        
        // Check if spell can be prepared (only for classes that prepare spells and non-cantrips)
        final currentMaxPrepared = _spellPreparation.maxPreparedSpells == 0 
            ? currentCalculatedMax 
            : _spellPreparation.maxPreparedSpells;
        
        final canPrepare = spell.levelNumber > 0 && // Cantrips (level 0) cannot be prepared
            currentMaxPrepared > 0;
        
        // Check spell status
        final isPrepared = _spellPreparation.isSpellPrepared(spell.id);
        final isAlwaysPrepared = _spellPreparation.isSpellAlwaysPrepared(spell.id);
        final isFreeUse = _spellPreparation.isSpellFreeUse(spell.id);
        
        // Check if we can prepare more spells
        final canPrepareMore = _spellPreparation.currentPreparedCount < currentMaxPrepared || isAlwaysPrepared;

        widgets.add(
          Card(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: ListTile(
              leading: canPrepare 
                ? Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      shape: CircleBorder(),
                      value: isPrepared,
                      onChanged: (bool? value) {
                        if (value == true) {
                          if (canPrepareMore || isAlwaysPrepared) {
                            _toggleSpellPreparation(spell.id, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Cannot prepare more spells. Maximum: $currentMaxPrepared'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          _toggleSpellPreparation(spell.id, false);
                        }
                      },
                    ),
                  )
                : null,
              title: InkWell(
                child: Text(
                  spell.name,
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onTap: () => _showSpellDetails(spell.name),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${spell.schoolName.split('_').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ')} • ${spell.castingTime}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (isAlwaysPrepared || isFreeUse) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isAlwaysPrepared) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.purple.shade700),
                                const SizedBox(width: 2),
                                Text(
                                  'Always',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (isFreeUse) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt, size: 12, color: Colors.green.shade700),
                                const SizedBox(width: 2),
                                Text(
                                  'Free',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
              trailing: SizedBox(
                width: 80,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (canPrepare) ...[
                      // Always prepared toggle
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isAlwaysPrepared ? Icons.star : Icons.star_border,
                            color: Colors.purple,
                            size: 16,
                          ),
                          onPressed: () => _toggleAlwaysPrepared(spell.id),
                          tooltip: 'Always prepared',
                        ),
                      ),
                      // Free use toggle
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isFreeUse ? Icons.bolt : Icons.bolt_outlined,
                            color: Colors.green,
                            size: 16,
                          ),
                          onPressed: () => _toggleFreeUse(spell.id),
                          tooltip: 'Free use once per day',
                        ),
                      ),
                    ],
                    // Delete button
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.delete, size: 16),
                        onPressed: () {
                          setState(() {
                            _spells.removeAt(index);
                            // Remove from preparation lists if it was prepared
                            if (isPrepared) {
                              _toggleSpellPreparation(spell.id, false);
                            }
                            if (isAlwaysPrepared) {
                              _toggleAlwaysPrepared(spell.id);
                            }
                            if (isFreeUse) {
                              _toggleFreeUse(spell.id);
                            }
                          });

                          // Auto-save the character when a spell is removed
                          _autoSaveCharacter();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Add spacing between levels
      if (level != sortedLevels.last) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
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

    // Auto-save when spell slot usage changes
    _autoSaveCharacter();
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
                        _autoSaveCharacter(); // Auto-save on decrement
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      child: TextField(
                        controller: textController, // Use the controller
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done, // Show "Done" button on keyboard
                        onChanged: (value) {
                          final newValue = int.tryParse(value) ?? 0;
                          if (type == 'slots') {
                            _updateSpellSlot(
                              level,
                              type,
                              newValue.clamp(0, 99),
                            );
                            _autoSaveCharacter(); // Auto-save on text input
                          } else {
                            _updateSpellSlot(
                              level,
                              type,
                              newValue.clamp(0, _getMaxSlots(level)),
                            );
                            _autoSaveCharacter(); // Auto-save on text input
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
                        _autoSaveCharacter(); // Auto-save on increment
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
                          _autoSaveCharacter();
                        },
                        child: const Text('Set 4'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _updateSpellSlot(level, 'slots', 6);
                          currentValue = 6;
                          textController.text = '6';
                          _autoSaveCharacter();
                        },
                        child: const Text('Set 6'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _updateSpellSlot(level, 'slots', 9);
                          currentValue = 9;
                          textController.text = '9';
                          _autoSaveCharacter();
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
                          _autoSaveCharacter();
                        },
                        child: const Text('Clear All'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final maxSlots = _getMaxSlots(level);
                          _updateSpellSlot(level, 'used', maxSlots);
                          currentValue = maxSlots;
                          textController.text = maxSlots.toString();
                          _autoSaveCharacter();
                        },
                        child: const Text('Use All'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final halfSlots = _getMaxSlots(level) ~/ 2;
                          _updateSpellSlot(level, 'used', halfSlots);
                          currentValue = halfSlots;
                          textController.text = halfSlots.toString();
                          _autoSaveCharacter();
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

  Widget _buildFeatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Character Feats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your character\'s feats',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Feats list
          ..._feats.asMap().entries.map((entry) {
            final index = entry.key;
            final featName = entry.value;

            // Try to find feat details
            final featsViewModel = context.read<FeatsViewModel>();
            final feat = featsViewModel.feats.firstWhere(
              (f) => f.name.toLowerCase() == featName.toLowerCase(),
              orElse: () => Feat(
                id: 'unknown',
                name: featName,
                description: 'Custom feat',
                source: 'Unknown',
              ),
            );

            return Card(
              child: ListTile(
                title: InkWell(
                  child: Text(
                    feat.name,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () => _showFeatDetails(feat),
                ),
                subtitle: Text(
                  feat.source,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _feats.removeAt(index);
                    });

                    // Auto-save the character when a feat is removed
                    _autoSaveCharacter();
                  },
                ),
              ),
            );
          }),

          TextButton.icon(
            onPressed: _showAddFeatDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Feat'),
          ),
          const SizedBox(height: 16),
          
          // Feat Notes Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Additional notes about your feats and abilities.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _featNotesController,
                      decoration: const InputDecoration(
                        hintText: 'Add notes about your feats...\n\n'
                            'Examples:\n'
                            '• Feat descriptions and mechanics\n'
                            '• Synergies with other abilities\n'
                            '• Combat strategies using feats\n'
                            '• Roleplaying aspects of feats\n'
                            '• Feat progression plans',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 12,
                      minLines: 3,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => _autoSaveCharacter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedSlotsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const Text(
                  'Personalized Slots',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _restoreAllPersonalizedSlots,
                icon: const Icon(Icons.refresh),
                label: const Text('Restore all'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
                    
          // Personalized slots list
          if (_personalizedSlots.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.casino,
                      color: Colors.grey.shade400,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No class slots configured',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click the + button to add slot types like Superiority Dice, Ki Points, etc.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._personalizedSlots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              return _buildPersonalizedSlotField(slot.name, index);
            }),

          const SizedBox(height: 16),
          
          TextButton.icon(
            onPressed: _showAddPersonalizedSlotDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Personalized Slot'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedSlotField(String label, int slotIndex) {
    final slot = _personalizedSlots[slotIndex];
    final slots = slot.maxSlots;
    final used = slot.usedSlots;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text('Slots: ', style: const TextStyle(color: Colors.grey)),
                    InkWell(
                      onTap: () => _showPersonalizedSlotModifierDialog(slotIndex, 'slots', slots),
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
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {
                        setState(() {
                          _personalizedSlots.removeAt(slotIndex);
                        });
                        _autoSaveCharacter();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visual slot dots
            if (slots > 0) ...[
              Row(
                children: [
                  const Text('Used: ', style: TextStyle(color: Colors.grey)),
                  ...List.generate(slots, (index) {
                    final isUsed = index < used;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: GestureDetector(
                        onTap: () => _togglePersonalizedSlot(slotIndex, index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isUsed ? Colors.red : Colors.grey.shade300,
                            border: Border.all(
                              color: isUsed ? Colors.red.shade300 : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isUsed
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
                        'No slots available',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click the slots number to add slots',
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

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Backstory Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_edu,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Backstory',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The complete history and background story of your character.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _backstoryController,
                      decoration: const InputDecoration(
                        hintText: 'Write your character\'s backstory...\n\n'
                            'Consider including:\n'
                            '• Place of birth and family background\n'
                            '• Life events that shaped their personality\n'
                            '• How they became an adventurer\n'
                            '• Significant relationships and experiences\n'
                            '• Secrets, traumas, or triumphs\n'
                            '• Hopes for the future',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 12,
                      minLines: 6,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => _autoSaveCharacter(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Character Pillars Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.foundation,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Pillars',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Core elements that define your character\'s role in the story.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField('Gimmick', _gimmickController, 
                    'What makes your character unique or memorable?'),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField('Quirk', _quirkController,
                    'Odd habits or mannerisms that define your character.'),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField('Wants', _wantsController,
                    'What does your character desire most in the world?'),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField('Needs', _needsController,
                    'What must your character accomplish or obtain?'),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField('Conflict', _conflictController,
                    'What internal or external struggles drive your character?'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          
          // Auto-save info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'All notes auto-save automatically • No character limit • Rich text supported',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 56),
        ],
      ),
    );
  }

  Widget _buildEnhancedPillarField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 6,
            minLines: 3,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.black87,
            ),
            onChanged: (value) => _autoSaveCharacter(),
          ),
        ),
      ],
    );
  }

  void _showAddAttackDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final bonusController = TextEditingController();
        final damageController = TextEditingController();
        final typeController = TextEditingController();
        final descController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Attack'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Attack Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: bonusController,
                  decoration: const InputDecoration(
                    labelText: 'Attack Bonus',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: damageController,
                        decoration: const InputDecoration(
                          labelText: 'Damage',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: typeController,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    _attacks.add(
                      CharacterAttack(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        attackBonus: bonusController.text.trim(),
                        damage: damageController.text.trim(),
                        damageType: typeController.text.trim(),
                        description: descController.text.trim(),
                      ),
                    );
                  });
                  _autoSaveCharacter();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSpellDialog() {
    // Load spells if not already loaded
    context.read<SpellsViewModel>().loadSpells();

    final Set<String> selectedSpells = <String>{};

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) => Dialog(
              child: Container(
                width: double.maxFinite,
                height: 600,
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            onPressed: () => Navigator.pop(context),
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
                                      builder: (context, spellsViewModel, child) {
                                        final levels = ['All', 'Cantrips', 'Level 1', 'Level 2', 'Level 3', 'Level 4', 'Level 5', 'Level 6', 'Level 7', 'Level 8', 'Level 9'];
                                        return DropdownButtonFormField<String>(
                                          value: _selectedLevelFilter ?? 'All',
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Level',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                          items: levels.map((level) {
                                            return DropdownMenuItem(
                                              value: level,
                                              child: Text(level, style: const TextStyle(fontSize: 11)),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            this.setState(() {
                                              _selectedLevelFilter = value == 'All' ? null : value;
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
                                      builder: (context, spellsViewModel, child) {
                                        final classes = ['All', ...spellsViewModel.spells.map((s) => s.classes).expand((c) => c).toSet().toList()..sort()];
                                        return DropdownButtonFormField<String>(
                                          value: _selectedClassFilter ?? 'All',
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Class',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                          items: classes.map((className) {
                                            final displayName = className == 'All' 
                                              ? 'All'
                                              : className.split('_').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
                                            return DropdownMenuItem(
                                              value: className,
                                              child: Text(
                                                displayName.length > 15 ? '${displayName.substring(0, 15)}...' : displayName,
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            this.setState(() {
                                              _selectedClassFilter = value == 'All' ? null : value;
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
                                      builder: (context, spellsViewModel, child) {
                                        final schools = ['All', ...spellsViewModel.spells.map((s) => s.schoolName).toSet().toList()..sort()];
                                        return DropdownButtonFormField<String>(
                                          value: _selectedSchoolFilter ?? 'All',
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: 'School',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                          items: schools.map((school) {
                                            return DropdownMenuItem(
                                              value: school,
                                              child: Text(
                                                school.split('_').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' '),
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            this.setState(() {
                                              _selectedSchoolFilter = value == 'All' ? null : value;
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

                   /*  // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Consumer<SpellsViewModel>(
                        builder: (context, spellsViewModel, child) {
                          return TextField(
                            decoration: const InputDecoration(
                              labelText: 'Search spells...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (query) {
                              spellsViewModel.setSearchQuery(query);
                            },
                          );
                        },
                      ),
                    ), */

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
                              child: Text('Error: ${spellsViewModel.error}'),
                            );
                          }

                          // Apply filters
                          List<Spell> filteredSpells = spellsViewModel.spells.where((spell) {
                            // Filter by character class if enabled
                            if (_filterByCharacterClass) {
                              final characterClass = widget.character.characterClass.toLowerCase();
                              if (!spell.classes.any((className) => className.toLowerCase() == characterClass)) {
                                return false;
                              }
                            }

                            // Filter by level
                            if (_selectedLevelFilter != null) {
                              if (_selectedLevelFilter == 'Cantrips') {
                                if (spell.levelNumber != 0) return false;
                              } else if (_selectedLevelFilter!.startsWith('Level')) {
                                final level = int.tryParse(_selectedLevelFilter!.split(' ')[1]);
                                if (spell.levelNumber != level) return false;
                              }
                            }

                            // Filter by class
                            if (_selectedClassFilter != null) {
                              if (!spell.classes.contains(_selectedClassFilter)) return false;
                            }

                            // Filter by school
                            if (_selectedSchoolFilter != null) {
                              if (spell.schoolName != _selectedSchoolFilter) return false;
                            }

                            return true;
                          }).toList();

                          if (filteredSpells.isEmpty) {
                            return const Center(child: Text('No spells found with current filters'));
                          }

                          return ListView.builder(
                            itemCount: filteredSpells.length,
                            itemBuilder: (context, index) {
                              final spell = filteredSpells[index];
                              final isKnown = _spells.contains(spell.name);
                              final isSelected = selectedSpells.contains(spell.name);

                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: isKnown ? null : (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedSpells.add(spell.name);
                                    } else {
                                      selectedSpells.remove(spell.name);
                                    }
                                  });
                                },
                                title: Text(
                                  spell.name,
                                  style: TextStyle(
                                    color: isKnown ? Colors.grey : null,
                                    decoration: isKnown ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                subtitle: Text(
                                  '${spell.schoolName.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                secondary: isKnown 
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : Icon(
                                      isSelected ? Icons.check_circle : Icons.check_circle_outline,
                                      color: isSelected ? Colors.blue : Colors.grey,
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
                            onPressed: () => Navigator.pop(context),
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
                            onPressed: selectedSpells.isEmpty ? null : () {
                              // Update the parent state first
                              this.setState(() {
                                _spells.addAll(selectedSpells);
                              });
                              Navigator.pop(context);

                              // Auto-save the character when spells are added
                              _autoSaveCharacter();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added ${selectedSpells.length} spell${selectedSpells.length == 1 ? '' : 's'} to ${widget.character.name}',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: Text('Add ${selectedSpells.isEmpty ? 'Spells' : '${selectedSpells.length} Spell${selectedSpells.length == 1 ? '' : 's'}'}'),
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
                        'Source: ${race.source}',
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
                        'Source: ${background.source}',
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
                        ...background.features.map((feature) => Container(
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
                        )),
                        const SizedBox(height: 16),
                      ],

                      // Description (if available from features)
                      if (background.features.isNotEmpty && background.features.first.description.isNotEmpty) ...[
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

                                  // Auto-save the character when a spell is removed
                                  _autoSaveCharacter();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Removed ${spell.name} from ${widget.character.name}',
                                      ),
                                      backgroundColor: Colors.orange,
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

  void _autoSaveCharacter() {
    // Create updated character with all current data
    final updatedCharacter = widget.character.copyWith(
      name: _nameController.text.trim(),
      customImagePath: _customImagePath,
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
        proficiencyBonus: CharacterStats.calculateProficiencyBonus(int.tryParse(_levelController.text) ?? 1),
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
      quickGuide: _quickGuideController.text.trim(),
      proficiencies: _proficienciesController.text.trim(),
      featuresTraits: _featuresTraitsController.text.trim(),
      backstory: _backstoryController.text.trim(),
      featNotes: _featNotesController.text.trim(),
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
        additionalDetails: _additionalDetailsController.text.trim(),
        appearanceImagePath: _appearanceImagePath ?? '',
      ),
      deathSaves: CharacterDeathSaves(
        successes: _deathSaveSuccesses,
        failures: _deathSaveFailures,
      ),
      languages: CharacterLanguages(
        languages: _languagesController.text
            .split(',')
            .map((lang) => lang.trim())
            .where((lang) => lang.isNotEmpty)
            .toList(),
      ),
      moneyItems: CharacterMoneyItems(
        money: _moneyController.text.trim(),
        items: _itemsController.text
            .split('\n')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
      ),
      updatedAt: DateTime.now(),
    );

    // Save the character silently (no success message)
    context.read<CharactersViewModel>().updateCharacter(updatedCharacter);
    
    // Clear unsaved changes flag
    _hasUnsavedAbilityChanges = false;
  }

  void _showAddFeatDialog() {
    // Load feats if not already loaded
    context.read<FeatsViewModel>().loadFeats();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: 500,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add Feat to ${widget.character.name}',
                        style: const TextStyle(
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
              ),
              const Divider(height: 1),

              // Feats list
              Expanded(
                child: Consumer<FeatsViewModel>(
                  builder: (context, featsViewModel, child) {
                    if (featsViewModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (featsViewModel.error != null) {
                      return Center(
                        child: Text('Error: ${featsViewModel.error}'),
                      );
                    }

                    final feats = featsViewModel.feats;
                    final searchQuery = '';
                    final filteredFeats = searchQuery.isEmpty 
                        ? feats
                        : feats.where((feat) => feat.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
                    
                    if (filteredFeats.isEmpty) {
                      return const Center(child: Text('No feats found'));
                    }
                    
                    return ListView.builder(
                      itemCount: filteredFeats.length,
                      itemBuilder: (context, index) {
                        final feat = filteredFeats[index];
                        final isKnown = _feats.contains(feat.name);

                        return ListTile(
                          title: Text(feat.name),
                          subtitle: Text(
                            feat.source,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          trailing: isKnown
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.add),
                          enabled: !isKnown,
                          onTap: isKnown
                              ? null
                              : () {
                                  setState(() {
                                    _feats.add(feat.name);
                                  });
                                  Navigator.pop(context);

                                  // Auto-save the character when a feat is added
                                  _autoSaveCharacter();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added ${feat.name} to ${widget.character.name}',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    Text(
                      '${_feats.length} feats known',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatDetails(Feat feat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.military_tech, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feat.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Source
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.book, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Source: ${feat.source}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Prerequisite
              if (feat.prerequisite != null && feat.prerequisite!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prerequisite:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(feat.prerequisite!),
                    ],
                  ),
                ),
              if (feat.prerequisite != null && feat.prerequisite!.isNotEmpty)
                const SizedBox(height: 16),

              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                feat.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),

              // Effects
              if (feat.effects.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Effects',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        feat.formattedEffects,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Character info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Known by: ${widget.character.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPersonalizedSlotDialog() {
    final nameController = TextEditingController();
    final maxSlotsController = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Class Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Slot Name',
                hintText: 'e.g., Superiority Dice, Ki Points',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxSlotsController,
              decoration: const InputDecoration(
                labelText: 'Max Slots',
                hintText: 'e.g., 4',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done, // Show "Done" button on keyboard
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final maxSlots = int.tryParse(maxSlotsController.text) ?? 4;

              if (name.isNotEmpty) {
                setState(() {
                  _personalizedSlots.add(CharacterPersonalizedSlot(
                    name: name,
                    maxSlots: maxSlots,
                    usedSlots: 0,
                    diceType: 'd6', // Default value, not shown in UI
                  ));
                });
                _autoSaveCharacter();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $name to ${widget.character.name}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _updatePersonalizedSlot(int index, CharacterPersonalizedSlot updatedSlot) {
    setState(() {
      _personalizedSlots[index] = updatedSlot;
    });
    _autoSaveCharacter();
  }

  Color _getRemainingColor(int remaining, int max) {
    if (max == 0) return Colors.grey;
    final ratio = remaining / max;
    
    if (ratio > 0.5) return Colors.green;
    if (ratio > 0.25) return Colors.orange;
    return Colors.red;
  }

  void _togglePersonalizedSlot(int slotIndex, int dotIndex) {
    final slot = _personalizedSlots[slotIndex];
    if (dotIndex < slot.usedSlots) {
      // Restore the slot
      _updatePersonalizedSlot(slotIndex, slot.copyWith(usedSlots: slot.usedSlots - 1));
    } else {
      // Use the slot
      _updatePersonalizedSlot(slotIndex, slot.copyWith(usedSlots: slot.usedSlots + 1));
    }
  }

  void _showPersonalizedSlotModifierDialog(int slotIndex, String type, int currentValue) {
    final slot = _personalizedSlots[slotIndex];
    final textController = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modify ${slot.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type == 'slots' ? 'Maximum slots:' : 'Used slots:',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done, // Show "Done" button on keyboard
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: type == 'slots' ? 'Max Slots' : 'Used Slots',
              ),
              onChanged: (value) {
                final newValue = int.tryParse(value) ?? currentValue;
                if (type == 'slots') {
                  // Ensure used slots don't exceed new max
                  final newUsedSlots = slot.usedSlots > newValue ? newValue : slot.usedSlots;
                  _updatePersonalizedSlot(slotIndex, slot.copyWith(
                    maxSlots: newValue,
                    usedSlots: newUsedSlots,
                  ));
                } else {
                  // Ensure used slots don't exceed max slots
                  final clampedValue = newValue.clamp(0, slot.maxSlots);
                  _updatePersonalizedSlot(slotIndex, slot.copyWith(usedSlots: clampedValue));
                }
                currentValue = newValue; // Update local value
                textController.text = newValue.toString(); // Update text field
                _autoSaveCharacter(); // Auto-save on text input
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (type == 'slots') ...[
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(slotIndex, slot.copyWith(maxSlots: 4));
                      currentValue = 4;
                      textController.text = '4';
                      _autoSaveCharacter();
                    },
                    child: const Text('Set 4'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(slotIndex, slot.copyWith(maxSlots: 6));
                      currentValue = 6;
                      textController.text = '6';
                      _autoSaveCharacter();
                    },
                    child: const Text('Set 6'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(slotIndex, slot.copyWith(maxSlots: 8));
                      currentValue = 8;
                      textController.text = '8';
                      _autoSaveCharacter();
                    },
                    child: const Text('Set 8'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(slotIndex, slot.copyWith(usedSlots: 0));
                      currentValue = 0;
                      textController.text = '0';
                      _autoSaveCharacter();
                    },
                    child: const Text('Clear All'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updatePersonalizedSlot(slotIndex, slot.copyWith(usedSlots: slot.maxSlots));
                      currentValue = slot.maxSlots;
                      textController.text = slot.maxSlots.toString();
                      _autoSaveCharacter();
                    },
                    child: const Text('Use All'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final halfSlots = (slot.maxSlots / 2).floor();
                      _updatePersonalizedSlot(slotIndex, slot.copyWith(usedSlots: halfSlots));
                      currentValue = halfSlots;
                      textController.text = halfSlots.toString();
                      _autoSaveCharacter();
                    },
                    child: const Text('Half Used'),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _restoreAllPersonalizedSlots() {
    setState(() {
      _personalizedSlots = _personalizedSlots.map((slot) => slot.copyWith(usedSlots: 0)).toList();
    });

    // Auto-save the restoration
    _autoSaveCharacter();

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All class slots have been restored!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _takeComprehensiveLongRest() {
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
      _personalizedSlots = _personalizedSlots.map((slot) => slot.copyWith(usedSlots: 0)).toList();
    });

    // Auto-save the comprehensive long rest
    _autoSaveCharacter();

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Long rest completed! HP, spell slots, and all class resources restored!'),
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

    // Auto-save the long rest
    _autoSaveCharacter();

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
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null && mounted) {
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

        // Copy image to permanent location
        final File sourceFile = File(image.path);
        final File savedFile = await sourceFile.copy(savedImagePath);

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
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Auto-save after image change
        _autoSaveCharacter();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
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
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image removed'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Auto-save after image removal
      _autoSaveCharacter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing image: $e'),
            backgroundColor: Colors.red,
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
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final appearanceImagesDir = Directory(
          path.join(directory.path, 'appearance_images'),
        );
        if (!await appearanceImagesDir.exists()) {
          await appearanceImagesDir.create(recursive: true);
        }

        final String fileName = path.basename(image.path);
        final String savedImagePath = path.join(appearanceImagesDir.path, fileName);
        final File sourceFile = File(image.path);
        final File savedFile = await sourceFile.copy(savedImagePath);

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
        });

        if (mounted) {
          _autoSaveCharacter();
        }
      }
    } catch (e) {
      debugPrint('Error picking appearance image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking appearance image: $e')),
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
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appearance image removed'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Auto-save after image removal
      _autoSaveCharacter();
    } catch (e) {
      debugPrint('Error removing appearance image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing appearance image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveCharacter([String? successMessage]) {
    // Update all character data from controllers
    debugPrint('=== SAVE CHARACTER DEBUG ===');
    debugPrint('Background controller text: "${_backgroundController.text}"');
    debugPrint('Selected background: "$_selectedBackground"');
    debugPrint('Has unsaved changes: $_hasUnsavedClassChanges');
    
    final updatedCharacter = widget.character.copyWith(
      name: _nameController.text.trim(),
      customImagePath: _customImagePath,
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
        proficiencyBonus: CharacterStats.calculateProficiencyBonus(int.tryParse(_levelController.text) ?? 1),
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
      quickGuide: _quickGuideController.text.trim(),
      proficiencies: _proficienciesController.text.trim(),
      featuresTraits: _featuresTraitsController.text.trim(),
      backstory: _backstoryController.text.trim(),
      featNotes: _featNotesController.text.trim(),
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
        additionalDetails: _additionalDetailsController.text.trim(),
        appearanceImagePath: _appearanceImagePath ?? '',
      ),
      deathSaves: CharacterDeathSaves(
        successes: _deathSaveSuccesses,
        failures: _deathSaveFailures,
      ),
      languages: CharacterLanguages(
        languages: _languagesController.text
            .split(',')
            .map((lang) => lang.trim())
            .where((lang) => lang.isNotEmpty)
            .toList(),
      ),
      moneyItems: CharacterMoneyItems(
        money: _moneyController.text.trim(),
        items: _itemsController.text
            .split('\n')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
      ),
      updatedAt: DateTime.now(),
    );

    debugPrint('=== SAVING CHARACTER ===');
    debugPrint('Updated character background: ${updatedCharacter.background}');
    debugPrint('========================');

    context.read<CharactersViewModel>().updateCharacter(updatedCharacter);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage ?? 'Character saved successfully!')),
    );

   // Navigator.pop(context);
  }

  /// Toggle spell preparation status
  void _toggleSpellPreparation(String spellId, bool prepare) {
    setState(() {
      if (prepare) {
        if (!_spellPreparation.preparedSpells.contains(spellId)) {
          _spellPreparation = _spellPreparation.copyWith(
            preparedSpells: [..._spellPreparation.preparedSpells, spellId],
          );
        }
      } else {
        _spellPreparation = _spellPreparation.copyWith(
          preparedSpells: _spellPreparation.preparedSpells.where((id) => id != spellId).toList(),
        );
      }
    });
    _autoSaveCharacter();
  }

  /// Toggle always prepared status
  void _toggleAlwaysPrepared(String spellId) {
    setState(() {
      if (_spellPreparation.isSpellAlwaysPrepared(spellId)) {
        // Remove from always prepared
        final newAlwaysPrepared = _spellPreparation.alwaysPreparedSpells.where((id) => id != spellId).toList();
        _spellPreparation = _spellPreparation.copyWith(alwaysPreparedSpells: newAlwaysPrepared);
        
        // Also remove from regular prepared if it's there
        if (_spellPreparation.preparedSpells.contains(spellId)) {
          final newPrepared = _spellPreparation.preparedSpells.where((id) => id != spellId).toList();
          _spellPreparation = _spellPreparation.copyWith(preparedSpells: newPrepared);
        }
      } else {
        // Add to always prepared
        _spellPreparation = _spellPreparation.copyWith(
          alwaysPreparedSpells: [..._spellPreparation.alwaysPreparedSpells, spellId],
        );
        
        // Also add to prepared if not already there
        if (!_spellPreparation.preparedSpells.contains(spellId)) {
          _spellPreparation = _spellPreparation.copyWith(
            preparedSpells: [..._spellPreparation.preparedSpells, spellId],
          );
        }
      }
    });
    _autoSaveCharacter();
  }

  /// Toggle free use status
  void _toggleFreeUse(String spellId) {
    setState(() {
      if (_spellPreparation.isSpellFreeUse(spellId)) {
        _spellPreparation = _spellPreparation.copyWith(
          freeUseSpells: _spellPreparation.freeUseSpells.where((id) => id != spellId).toList(),
        );
      } else {
        _spellPreparation = _spellPreparation.copyWith(
          freeUseSpells: [..._spellPreparation.freeUseSpells, spellId],
        );
      }
    });
    _autoSaveCharacter();
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
    
    final controller = TextEditingController(text: currentInitiative.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  _initiativeManuallyModified = true;
                });
                _autoSaveCharacter();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number'),
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

  /// Handle dexterity stat changes - always reset initiative to match new dexterity modifier
  void _onDexterityChanged() {
    setState(() {
      final currentDexterity = int.tryParse(_dexterityController.text) ?? 10;
      final newDexterityModifier = ((currentDexterity - 10) / 2).floor();
      _initiativeController.text = newDexterityModifier.toString();
      _initiativeManuallyModified = false; // Reset to auto-calculated state
    });
    _autoSaveCharacter();
  }

  /// Show dialog to modify maximum prepared spells
  void _showMaxPreparedDialog() {
    // Calculate current max to show in dialog
    final currentMax = _spellPreparation.maxPreparedSpells == 0 
        ? CharacterSpellPreparation.calculateMaxPreparedSpells(
            _classController.text.trim(),
            int.tryParse(_levelController.text) ?? 1,
            CharacterSpellPreparation.getSpellcastingModifier(widget.character),
          )
        : _spellPreparation.maxPreparedSpells;
    
    final controller = TextEditingController(text: currentMax.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Maximum Prepared Spells'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the maximum number of spells this character can prepare:'),
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
              'Calculated maximum: ${CharacterSpellPreparation.calculateMaxPreparedSpells(
                widget.character.characterClass,
                widget.character.level,
                CharacterSpellPreparation.getSpellcastingModifier(widget.character),
              )}',
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
                  final alwaysPreparedOnly = _spellPreparation.preparedSpells.where((spellId) => 
                    _spellPreparation.alwaysPreparedSpells.contains(spellId)
                  ).toList();
                  
                  if (newMax < _spellPreparation.currentPreparedCount) {
                    // Clear all regular prepared spells, keep only always prepared
                    _spellPreparation = _spellPreparation.copyWith(
                      maxPreparedSpells: newMax,
                      preparedSpells: [...alwaysPreparedOnly],
                    );
                  } else {
                    // Just update max if no reduction needed
                    _spellPreparation = _spellPreparation.copyWith(maxPreparedSpells: newMax);
                  }
                });
                _autoSaveCharacter();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number'),
                    backgroundColor: Colors.red,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Character Image Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Character Image',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: _appearanceImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_appearanceImagePath!),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isPickingImage ? null : _pickAppearanceImage,
                              icon: const Icon(Icons.photo_library),
                              label: Text(_appearanceImagePath != null ? 'Change' : 'Add'),
                            ),
                            if (_appearanceImagePath != null) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _removeAppearanceImage,
                                icon: const Icon(Icons.delete),
                                label: const Text('Remove'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Physical Traits Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Physical Traits',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Height Field
                  TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      hintText: 'e.g., 5\'10" or 178 cm',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                    ),
                    onChanged: (value) => _autoSaveCharacter(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Age Field
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'e.g., 25 years old',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake),
                    ),
                    onChanged: (value) => _autoSaveCharacter(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Eye Color Field
                  TextField(
                    controller: _eyeColorController,
                    decoration: const InputDecoration(
                      labelText: 'Eye Color',
                      hintText: 'e.g., Blue, Green, Brown',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.visibility),
                    ),
                    onChanged: (value) => _autoSaveCharacter(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Additional Details Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Appereance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe your character\'s appearance.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _additionalDetailsController,
                      decoration: const InputDecoration(
                        hintText: 'Start writing your character\'s story...\n\n'
                            'You can describe:\n'
                            '• Physical appearance beyond basic traits\n'
                            '• Clothing and equipment style\n'
                            '• Notable scars, tattoos, or markings\n'
                            '• Personality traits and mannerisms\n'
                            '• Background story and history\n'
                            '• Goals, dreams, and motivations\n'
                            '• Relationships and connections\n'
                            '• Any other details that bring your character to life',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 12,
                      minLines: 8,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => _autoSaveCharacter(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Auto-saves automatically • No character limit • Supports rich text descriptions',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
