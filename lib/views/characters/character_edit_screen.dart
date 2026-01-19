import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:vibration/vibration.dart';
import 'dart:io';
import '../../models/character_model.dart';
import '../../models/spell_model.dart';
import '../../models/feat_model.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../viewmodels/spells_viewmodel.dart';
import '../../viewmodels/feats_viewmodel.dart';

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
  bool _isPickingImage = false;
  bool _hasUnsavedAbilityChanges = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _subclassController = TextEditingController();
  final _quickGuideController = TextEditingController();
  final _backstoryController = TextEditingController();

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
  late CharacterPillars _pillars;
  late List<CharacterAttack> _attacks;
  late List<String> _spells;
  late List<String> _feats;
  late List<CharacterPersonalizedSlot> _personalizedSlots;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _initializeCharacterData();
  }

  void _initializeCharacterData() {
    final character = widget.character;

    // Initialize profile image
    _customImagePath = character.customImagePath;

    // Initialize controllers
    _nameController.text = character.name;
    _classController.text = character.characterClass;
    _subclassController.text = character.subclass ?? '';
    _quickGuideController.text = character.quickGuide;
    _backstoryController.text = character.backstory;

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

    // Set up auto-save listeners
    _setupAutoSaveListeners();
  }

  void _setupAutoSaveListeners() {
    // Add listeners to all text controllers for auto-save
    _nameController.addListener(_autoSaveCharacter);
    _classController.addListener(_autoSaveCharacter);
    _subclassController.addListener(_autoSaveCharacter);
    _quickGuideController.addListener(_autoSaveCharacter);
    _backstoryController.addListener(_autoSaveCharacter);

    _gimmickController.addListener(_autoSaveCharacter);
    _quirkController.addListener(_autoSaveCharacter);
    _wantsController.addListener(_autoSaveCharacter);
    _needsController.addListener(_autoSaveCharacter);
    _conflictController.addListener(_autoSaveCharacter);

    _strengthController.addListener(_autoSaveCharacter);
    _dexterityController.addListener(_autoSaveCharacter);
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
    _classController.dispose();
    _subclassController.dispose();
    _quickGuideController.dispose();
    _backstoryController.dispose();
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
            Tab(text: 'Basic', icon: Icon(Icons.person)),
            Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Skills', icon: Icon(Icons.psychology)),
            Tab(text: 'Health', icon: Icon(Icons.favorite)),
            Tab(text: 'Spell Slots', icon: Icon(Icons.grid_view)),
            Tab(text: 'Spells', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Feats', icon: Icon(Icons.military_tech)),
            Tab(text: 'Class Slots', icon: Icon(Icons.casino)),
            Tab(text: 'Notes', icon: Icon(Icons.note)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveCharacter),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildStatsTab(),
          _buildSkillsTab(),
          _buildHealthTab(),
          _buildSpellSlotsTab(),
          _buildSpellsTab(),
          _buildFeatsTab(),
          _buildPersonalizedSlotsTab(),
          _buildNotesTab(),
        ],
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

          // Class and subclass
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _classController,
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _subclassController,
                  decoration: const InputDecoration(
                    labelText: 'Subclass (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Attacks section
          const Text(
            'Attacks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
                  },
                ),
              ),
            );
          }),

          TextButton.icon(
            onPressed: _showAddAttackDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Attack'),
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
              const Text(
                'Ability Scores',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

          const SizedBox(height: 10),
          const Text(
            'Combat Stats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Combat stats using separate combat field method
          Row(
            children: [
              Expanded(
                child: _buildCombatField('Proficiency', _proficiencyBonusController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCombatField('Armor Class', _armorClassController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCombatField('Speed', _speedController),
              ),
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
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black54, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 46, 
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
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
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

          const SizedBox(height: 24),
          const Text(
            'Skills',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Skills with calculated modifiers, proficiency, and expertise
          ...[
            _buildSkillRow(
              'Acrobatics',
              'DEX',
              _skillChecks.acrobaticsProficiency,
              _skillChecks.acrobaticsExpertise,
              'acrobatics',
            ),
            _buildSkillRow(
              'Animal Handling',
              'WIS',
              _skillChecks.animalHandlingProficiency,
              _skillChecks.animalHandlingExpertise,
              'animal_handling',
            ),
            _buildSkillRow(
              'Arcana',
              'INT',
              _skillChecks.arcanaProficiency,
              _skillChecks.arcanaExpertise,
              'arcana',
            ),
            _buildSkillRow(
              'Athletics',
              'STR',
              _skillChecks.athleticsProficiency,
              _skillChecks.athleticsExpertise,
              'athletics',
            ),
            _buildSkillRow(
              'Deception',
              'CHA',
              _skillChecks.deceptionProficiency,
              _skillChecks.deceptionExpertise,
              'deception',
            ),
            _buildSkillRow(
              'History',
              'INT',
              _skillChecks.historyProficiency,
              _skillChecks.historyExpertise,
              'history',
            ),
            _buildSkillRow(
              'Insight',
              'WIS',
              _skillChecks.insightProficiency,
              _skillChecks.insightExpertise,
              'insight',
            ),
            _buildSkillRow(
              'Intimidation',
              'CHA',
              _skillChecks.intimidationProficiency,
              _skillChecks.intimidationExpertise,
              'intimidation',
            ),
            _buildSkillRow(
              'Investigation',
              'INT',
              _skillChecks.investigationProficiency,
              _skillChecks.investigationExpertise,
              'investigation',
            ),
            _buildSkillRow(
              'Medicine',
              'WIS',
              _skillChecks.medicineProficiency,
              _skillChecks.medicineExpertise,
              'medicine',
            ),
            _buildSkillRow(
              'Nature',
              'WIS',
              _skillChecks.natureProficiency,
              _skillChecks.natureExpertise,
              'nature',
            ),
            _buildSkillRow(
              'Perception',
              'WIS',
              _skillChecks.perceptionProficiency,
              _skillChecks.perceptionExpertise,
              'perception',
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
            _buildSkillRow(
              'Religion',
              'INT',
              _skillChecks.religionProficiency,
              _skillChecks.religionExpertise,
              'religion',
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
            _buildSkillRow(
              'Survival',
              'WIS',
              _skillChecks.survivalProficiency,
              _skillChecks.survivalExpertise,
              'survival',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavingThrowRow(
    String ability,
    bool isProficient,
    Function(bool?) onChanged,
  ) {
    final abilityScore = _getAbilityScore(ability);
    final modifier = _stats.getModifier(abilityScore);
    final proficiencyBonus =
        int.tryParse(_proficiencyBonusController.text) ?? 2;
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
    final modifier = _stats.getModifier(abilityScore);
    final proficiencyBonus =
        int.tryParse(_proficiencyBonusController.text) ?? 2;
    final total = _skillChecks.calculateSkillModifier(
      skillKey,
      _stats,
      proficiencyBonus,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color:
            hasExpertise
                ? Colors.blue.shade50
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
                  color: hasExpertise ? Colors.blue : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(4),
                color: hasExpertise ? Colors.blue : Colors.transparent,
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
                        ? Colors.blue
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
    await _triggerHapticFeedback();
    _showDeleteConfirmation();
  }

  Future<void> _triggerHapticAndShowOptions() async {
    await _triggerHapticFeedback();
    _showImageOptionsDialog();
  }

  Future<void> _triggerHapticAndPickImage() async {
    await _triggerHapticFeedback();
    _pickImage();
  }

  Future<void> _triggerHapticFeedback() async {
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 50, amplitude: 100);
      }
    } catch (e) {
      // Ignore haptic feedback errors
    }
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
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _currentHpController,
                  decoration: const InputDecoration(
                    labelText: 'Current HP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                ),
              ),
              const SizedBox(width: 16),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Known Spells',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your character\'s known spells',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Spells list
          ..._spells.asMap().entries.map((entry) {
            final index = entry.key;
            final spellName = entry.value;

            // Try to find spell details
            final spellsViewModel = context.read<SpellsViewModel>();
            final spell = spellsViewModel.spells.firstWhere(
              (s) => s.name.toLowerCase() == spellName.toLowerCase(),
              orElse:
                  () => Spell(
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

            return Card(
              child: ListTile(
                title: InkWell(
                  child: Text(
                    spell.name,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () => _showSpellDetails(spell.name),
                ),
                subtitle: Text(
                  '${spell.schoolName.split('_').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ')} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _spells.removeAt(index);
                    });

                    // Auto-save the character when a spell is removed
                    _autoSaveCharacter();
                  },
                ),
              ),
            );
          }),

          TextButton.icon(
            onPressed: _showAddSpellDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Spell'),
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
                    const SizedBox(width: 16),
                    Container(
                      width: 80,
                      child: TextField(
                        controller: textController, // Use the controller
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
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
                    const SizedBox(width: 16),
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
          const Text(
            'Quick Guide',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _quickGuideController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Add quick notes about your character...',
            ),
            maxLines: 5,
          ),

          const SizedBox(height: 24),
          const Text(
            'Backstory',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _backstoryController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Write your character\'s backstory...',
            ),
            maxLines: 8,
          ),

          const SizedBox(height: 24),
          const Text(
            'Character Pillars',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _buildPillarField('Gimmick', _gimmickController),
          const SizedBox(height: 16),
          _buildPillarField('Quirk', _quirkController),
          const SizedBox(height: 16),
          _buildPillarField('Wants', _wantsController),
          const SizedBox(height: 16),
          _buildPillarField('Needs', _needsController),
          const SizedBox(height: 16),
          _buildPillarField('Conflict', _conflictController),
        ],
      ),
    );
  }

  Widget _buildPillarField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
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
                  maxLines: 2,
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

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
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
                        const Icon(Icons.auto_awesome),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Add Spell to ${widget.character.name}',
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

                  // Search bar
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
                            child: Text('Error: ${spellsViewModel.error}'),
                          );
                        }

                        final spells = spellsViewModel.spells;
                        if (spells.isEmpty) {
                          return const Center(child: Text('No spells found'));
                        }

                        return ListView.builder(
                          itemCount: spells.length,
                          itemBuilder: (context, index) {
                            final spell = spells[index];
                            final isKnown = _spells.contains(spell.name);

                            return ListTile(
                              title: Text(spell.name),
                              subtitle: Text(
                                '${spell.schoolName.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}',
                              ),
                              trailing:
                                  isKnown
                                      ? const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                      : const Icon(Icons.add),
                              enabled: !isKnown,
                              onTap:
                                  isKnown
                                      ? null
                                      : () {
                                        setState(() {
                                          _spells.add(spell.name);
                                        });
                                        Navigator.pop(context);

                                        // Auto-save the character when a spell is added
                                        _autoSaveCharacter();

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Added ${spell.name} to ${widget.character.name}',
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
                          '${_spells.length} spells known',
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
      subclass:
          _subclassController.text.trim().isEmpty
              ? null
              : _subclassController.text.trim(),
      stats: CharacterStats(
        strength: int.tryParse(_strengthController.text) ?? 10,
        dexterity: int.tryParse(_dexterityController.text) ?? 10,
        constitution: int.tryParse(_constitutionController.text) ?? 10,
        intelligence: int.tryParse(_intelligenceController.text) ?? 10,
        wisdom: int.tryParse(_wisdomController.text) ?? 10,
        charisma: int.tryParse(_charismaController.text) ?? 10,
        proficiencyBonus: int.tryParse(_proficiencyBonusController.text) ?? 2,
        armorClass: int.tryParse(_armorClassController.text) ?? 10,
        speed: int.tryParse(_speedController.text) ?? 30,
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
      quickGuide: _quickGuideController.text.trim(),
      backstory: _backstoryController.text.trim(),
      pillars: CharacterPillars(
        gimmick: _gimmickController.text.trim(),
        quirk: _quirkController.text.trim(),
        wants: _wantsController.text.trim(),
        needs: _needsController.text.trim(),
        conflict: _conflictController.text.trim(),
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

              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<FeatsViewModel>(
                  builder: (context, featsViewModel, child) {
                    return TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search feats...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (query) {
                        // Filter feats based on search
                        // Note: FeatsViewModel doesn't have setSearchQuery, so we'll handle search locally
                        setState(() {});
                      },
                    );
                  },
                ),
              ),

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
                    if (feats.isEmpty) {
                      return const Center(child: Text('No feats found'));
                    }

                    return ListView.builder(
                      itemCount: feats.length,
                      itemBuilder: (context, index) {
                        final feat = feats[index];
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

  void _saveCharacter([String? successMessage]) {
    // Update all character data from controllers
    final updatedCharacter = widget.character.copyWith(
      name: _nameController.text.trim(),
      customImagePath: _customImagePath,
      characterClass: _classController.text.trim(),
      subclass:
          _subclassController.text.trim().isEmpty
              ? null
              : _subclassController.text.trim(),
      stats: CharacterStats(
        strength: int.tryParse(_strengthController.text) ?? 10,
        dexterity: int.tryParse(_dexterityController.text) ?? 10,
        constitution: int.tryParse(_constitutionController.text) ?? 10,
        intelligence: int.tryParse(_intelligenceController.text) ?? 10,
        wisdom: int.tryParse(_wisdomController.text) ?? 10,
        charisma: int.tryParse(_charismaController.text) ?? 10,
        proficiencyBonus: int.tryParse(_proficiencyBonusController.text) ?? 2,
        armorClass: int.tryParse(_armorClassController.text) ?? 10,
        speed: int.tryParse(_speedController.text) ?? 30,
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
      quickGuide: _quickGuideController.text.trim(),
      backstory: _backstoryController.text.trim(),
      pillars: CharacterPillars(
        gimmick: _gimmickController.text.trim(),
        quirk: _quirkController.text.trim(),
        wants: _wantsController.text.trim(),
        needs: _needsController.text.trim(),
        conflict: _conflictController.text.trim(),
      ),
      updatedAt: DateTime.now(),
    );

    context.read<CharactersViewModel>().updateCharacter(updatedCharacter);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage ?? 'Character saved successfully!')),
    );

   // Navigator.pop(context);
  }
}
