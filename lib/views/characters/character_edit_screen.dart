import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/character_model.dart';
import '../../viewmodels/characters_viewmodel.dart';

class CharacterEditScreen extends StatefulWidget {
  final Character character;

  const CharacterEditScreen({
    super.key,
    required this.character,
  });

  @override
  State<CharacterEditScreen> createState() => _CharacterEditScreenState();
}

class _CharacterEditScreenState extends State<CharacterEditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeCharacterData();
  }

  void _initializeCharacterData() {
    final character = widget.character;
    
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
    
    // Initialize other data
    _spellSlots = character.spellSlots;
    _pillars = character.pillars;
    _attacks = List.from(character.attacks);
    _spells = List.from(character.spells);
    
    // Initialize pillars controllers
    _gimmickController.text = _pillars.gimmick;
    _quirkController.text = _pillars.quirk;
    _wantsController.text = _pillars.wants;
    _needsController.text = _pillars.needs;
    _conflictController.text = _pillars.conflict;
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
        title: Text('Edit ${widget.character.name}'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Basic', icon: Icon(Icons.person)),
            Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Skills', icon: Icon(Icons.psychology)),
            Tab(text: 'Health', icon: Icon(Icons.favorite)),
            Tab(text: 'Spells', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Notes', icon: Icon(Icons.note)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCharacter,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildStatsTab(),
          _buildSkillsTab(),
          _buildHealthTab(),
          _buildSpellsTab(),
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
          // Character image placeholder
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(Icons.person, size: 60, color: Colors.grey),
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
          const Text('Attacks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._attacks.asMap().entries.map((entry) {
            final index = entry.key;
            final attack = entry.value;
            return Card(
              child: ListTile(
                title: Text(attack.name),
                subtitle: Text('${attack.attackBonus} | ${attack.damage} ${attack.damageType}'),
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
          const Text('Ability Scores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Ability scores grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildStatField('STR', _strengthController),
              _buildStatField('DEX', _dexterityController),
              _buildStatField('CON', _constitutionController),
              _buildStatField('INT', _intelligenceController),
              _buildStatField('WIS', _wisdomController),
              _buildStatField('CHA', _charismaController),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text('Combat Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _proficiencyBonusController,
                  decoration: const InputDecoration(
                    labelText: 'Proficiency Bonus',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _armorClassController,
                  decoration: const InputDecoration(
                    labelText: 'Armor Class',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _speedController,
            decoration: const InputDecoration(
              labelText: 'Speed',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildStatField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saving Throws', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Saving throws checkboxes
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildCheckbox('STR Save', _savingThrows.strengthProficiency, (value) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: value ?? false,
                    dexterityProficiency: _savingThrows.dexterityProficiency,
                    constitutionProficiency: _savingThrows.constitutionProficiency,
                    intelligenceProficiency: _savingThrows.intelligenceProficiency,
                    wisdomProficiency: _savingThrows.wisdomProficiency,
                    charismaProficiency: _savingThrows.charismaProficiency,
                  );
                });
              }),
              _buildCheckbox('DEX Save', _savingThrows.dexterityProficiency, (value) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: _savingThrows.strengthProficiency,
                    dexterityProficiency: value ?? false,
                    constitutionProficiency: _savingThrows.constitutionProficiency,
                    intelligenceProficiency: _savingThrows.intelligenceProficiency,
                    wisdomProficiency: _savingThrows.wisdomProficiency,
                    charismaProficiency: _savingThrows.charismaProficiency,
                  );
                });
              }),
              _buildCheckbox('CON Save', _savingThrows.constitutionProficiency, (value) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: _savingThrows.strengthProficiency,
                    dexterityProficiency: _savingThrows.dexterityProficiency,
                    constitutionProficiency: value ?? false,
                    intelligenceProficiency: _savingThrows.intelligenceProficiency,
                    wisdomProficiency: _savingThrows.wisdomProficiency,
                    charismaProficiency: _savingThrows.charismaProficiency,
                  );
                });
              }),
              _buildCheckbox('INT Save', _savingThrows.intelligenceProficiency, (value) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: _savingThrows.strengthProficiency,
                    dexterityProficiency: _savingThrows.dexterityProficiency,
                    constitutionProficiency: _savingThrows.constitutionProficiency,
                    intelligenceProficiency: value ?? false,
                    wisdomProficiency: _savingThrows.wisdomProficiency,
                    charismaProficiency: _savingThrows.charismaProficiency,
                  );
                });
              }),
              _buildCheckbox('WIS Save', _savingThrows.wisdomProficiency, (value) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: _savingThrows.strengthProficiency,
                    dexterityProficiency: _savingThrows.dexterityProficiency,
                    constitutionProficiency: _savingThrows.constitutionProficiency,
                    intelligenceProficiency: _savingThrows.intelligenceProficiency,
                    wisdomProficiency: value ?? false,
                    charismaProficiency: _savingThrows.charismaProficiency,
                  );
                });
              }),
              _buildCheckbox('CHA Save', _savingThrows.charismaProficiency, (value) {
                setState(() {
                  _savingThrows = CharacterSavingThrows(
                    strengthProficiency: _savingThrows.strengthProficiency,
                    dexterityProficiency: _savingThrows.dexterityProficiency,
                    constitutionProficiency: _savingThrows.constitutionProficiency,
                    intelligenceProficiency: _savingThrows.intelligenceProficiency,
                    wisdomProficiency: _savingThrows.wisdomProficiency,
                    charismaProficiency: value ?? false,
                  );
                });
              }),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Skill checkboxes
          ...[
            _buildCheckbox('Acrobatics', _skillChecks.acrobaticsProficiency, (value) {
              _updateSkillCheck('acrobatics', value ?? false);
            }),
            _buildCheckbox('Animal Handling', _skillChecks.animalHandlingProficiency, (value) {
              _updateSkillCheck('animal_handling', value ?? false);
            }),
            _buildCheckbox('Arcana', _skillChecks.arcanaProficiency, (value) {
              _updateSkillCheck('arcana', value ?? false);
            }),
            _buildCheckbox('Athletics', _skillChecks.athleticsProficiency, (value) {
              _updateSkillCheck('athletics', value ?? false);
            }),
            _buildCheckbox('Deception', _skillChecks.deceptionProficiency, (value) {
              _updateSkillCheck('deception', value ?? false);
            }),
            _buildCheckbox('History', _skillChecks.historyProficiency, (value) {
              _updateSkillCheck('history', value ?? false);
            }),
            _buildCheckbox('Insight', _skillChecks.insightProficiency, (value) {
              _updateSkillCheck('insight', value ?? false);
            }),
            _buildCheckbox('Intimidation', _skillChecks.intimidationProficiency, (value) {
              _updateSkillCheck('intimidation', value ?? false);
            }),
            _buildCheckbox('Investigation', _skillChecks.investigationProficiency, (value) {
              _updateSkillCheck('investigation', value ?? false);
            }),
            _buildCheckbox('Medicine', _skillChecks.medicineProficiency, (value) {
              _updateSkillCheck('medicine', value ?? false);
            }),
            _buildCheckbox('Nature', _skillChecks.natureProficiency, (value) {
              _updateSkillCheck('nature', value ?? false);
            }),
            _buildCheckbox('Perception', _skillChecks.perceptionProficiency, (value) {
              _updateSkillCheck('perception', value ?? false);
            }),
            _buildCheckbox('Performance', _skillChecks.performanceProficiency, (value) {
              _updateSkillCheck('performance', value ?? false);
            }),
            _buildCheckbox('Persuasion', _skillChecks.persuasionProficiency, (value) {
              _updateSkillCheck('persuasion', value ?? false);
            }),
            _buildCheckbox('Religion', _skillChecks.religionProficiency, (value) {
              _updateSkillCheck('religion', value ?? false);
            }),
            _buildCheckbox('Sleight of Hand', _skillChecks.sleightOfHandProficiency, (value) {
              _updateSkillCheck('sleight_of_hand', value ?? false);
            }),
            _buildCheckbox('Stealth', _skillChecks.stealthProficiency, (value) {
              _updateSkillCheck('stealth', value ?? false);
            }),
            _buildCheckbox('Survival', _skillChecks.survivalProficiency, (value) {
              _updateSkillCheck('survival', value ?? false);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Expanded(child: Text(label)),
      ],
    );
  }

  void _updateSkillCheck(String skill, bool value) {
    setState(() {
      _skillChecks = CharacterSkillChecks(
        acrobaticsProficiency: skill == 'acrobatics' ? value : _skillChecks.acrobaticsProficiency,
        animalHandlingProficiency: skill == 'animal_handling' ? value : _skillChecks.animalHandlingProficiency,
        arcanaProficiency: skill == 'arcana' ? value : _skillChecks.arcanaProficiency,
        athleticsProficiency: skill == 'athletics' ? value : _skillChecks.athleticsProficiency,
        deceptionProficiency: skill == 'deception' ? value : _skillChecks.deceptionProficiency,
        historyProficiency: skill == 'history' ? value : _skillChecks.historyProficiency,
        insightProficiency: skill == 'insight' ? value : _skillChecks.insightProficiency,
        intimidationProficiency: skill == 'intimidation' ? value : _skillChecks.intimidationProficiency,
        investigationProficiency: skill == 'investigation' ? value : _skillChecks.investigationProficiency,
        medicineProficiency: skill == 'medicine' ? value : _skillChecks.medicineProficiency,
        natureProficiency: skill == 'nature' ? value : _skillChecks.natureProficiency,
        perceptionProficiency: skill == 'perception' ? value : _skillChecks.perceptionProficiency,
        performanceProficiency: skill == 'performance' ? value : _skillChecks.performanceProficiency,
        persuasionProficiency: skill == 'persuasion' ? value : _skillChecks.persuasionProficiency,
        religionProficiency: skill == 'religion' ? value : _skillChecks.religionProficiency,
        sleightOfHandProficiency: skill == 'sleight_of_hand' ? value : _skillChecks.sleightOfHandProficiency,
        stealthProficiency: skill == 'stealth' ? value : _skillChecks.stealthProficiency,
        survivalProficiency: skill == 'survival' ? value : _skillChecks.survivalProficiency,
      );
    });
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hit Points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          const Text('Hit Dice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildSpellsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spell Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Spell slots grid
          ...[
            for (int level = 1; level <= 9; level++)
              _buildSpellSlotField('Level $level', level),
          ],
          
          const SizedBox(height: 24),
          const Text('Known Spells', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Spells list
          ..._spells.asMap().entries.map((entry) {
            final index = entry.key;
            final spell = entry.value;
            return Card(
              child: ListTile(
                title: Text(spell),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _spells.removeAt(index);
                    });
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
      case 1: slots = _spellSlots.level1Slots; used = _spellSlots.level1Used; break;
      case 2: slots = _spellSlots.level2Slots; used = _spellSlots.level2Used; break;
      case 3: slots = _spellSlots.level3Slots; used = _spellSlots.level3Used; break;
      case 4: slots = _spellSlots.level4Slots; used = _spellSlots.level4Used; break;
      case 5: slots = _spellSlots.level5Slots; used = _spellSlots.level5Used; break;
      case 6: slots = _spellSlots.level6Slots; used = _spellSlots.level6Used; break;
      case 7: slots = _spellSlots.level7Slots; used = _spellSlots.level7Used; break;
      case 8: slots = _spellSlots.level8Slots; used = _spellSlots.level8Used; break;
      case 9: slots = _spellSlots.level9Slots; used = _spellSlots.level9Used; break;
    }
    
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: '$label Total',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _updateSpellSlot(level, 'slots', int.tryParse(value) ?? 0);
            },
            controller: TextEditingController(text: slots.toString()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: '$label Used',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _updateSpellSlot(level, 'used', int.tryParse(value) ?? 0);
            },
            controller: TextEditingController(text: used.toString()),
          ),
        ),
      ],
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
        // Add other levels as needed
      }
    });
  }

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Guide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          const Text('Backstory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          const Text('Character Pillars', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
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
                    _attacks.add(CharacterAttack(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      attackBonus: bonusController.text.trim(),
                      damage: damageController.text.trim(),
                      damageType: typeController.text.trim(),
                      description: descController.text.trim(),
                    ));
                  });
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
    showDialog(
      context: context,
      builder: (context) {
        final spellController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Add Spell'),
          content: TextField(
            controller: spellController,
            decoration: const InputDecoration(
              labelText: 'Spell Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (spellController.text.trim().isNotEmpty) {
                  setState(() {
                    _spells.add(spellController.text.trim());
                  });
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

  void _saveCharacter() {
    // Update all character data from controllers
    final updatedCharacter = widget.character.copyWith(
      name: _nameController.text.trim(),
      characterClass: _classController.text.trim(),
      subclass: _subclassController.text.trim().isEmpty ? null : _subclassController.text.trim(),
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
        hitDiceType: _hitDiceTypeController.text.trim().isEmpty ? 'd8' : _hitDiceTypeController.text.trim(),
      ),
      attacks: _attacks,
      spellSlots: _spellSlots,
      spells: _spells,
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
      const SnackBar(content: Text('Character saved successfully!')),
    );
    
    Navigator.pop(context);
  }
}
