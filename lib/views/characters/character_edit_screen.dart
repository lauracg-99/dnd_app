import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/character_model.dart';
import '../../models/spell_model.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../viewmodels/spells_viewmodel.dart';

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
            Tab(text: 'Spell Slots', icon: Icon(Icons.grid_view)),
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
          _buildSpellSlotsTab(),
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
          
          // Saving throws with calculated modifiers
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildSavingThrowRow('STR', _savingThrows.strengthProficiency, (value) {
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
              _buildSavingThrowRow('DEX', _savingThrows.dexterityProficiency, (value) {
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
              _buildSavingThrowRow('CON', _savingThrows.constitutionProficiency, (value) {
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
              _buildSavingThrowRow('INT', _savingThrows.intelligenceProficiency, (value) {
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
              _buildSavingThrowRow('WIS', _savingThrows.wisdomProficiency, (value) {
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
              _buildSavingThrowRow('CHA', _savingThrows.charismaProficiency, (value) {
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
          
          // Skills with calculated modifiers, proficiency, and expertise
          ...[
            _buildSkillRow('Acrobatics', 'DEX', _skillChecks.acrobaticsProficiency, _skillChecks.acrobaticsExpertise, 'acrobatics'),
            _buildSkillRow('Animal Handling', 'WIS', _skillChecks.animalHandlingProficiency, _skillChecks.animalHandlingExpertise, 'animal_handling'),
            _buildSkillRow('Arcana', 'INT', _skillChecks.arcanaProficiency, _skillChecks.arcanaExpertise, 'arcana'),
            _buildSkillRow('Athletics', 'STR', _skillChecks.athleticsProficiency, _skillChecks.athleticsExpertise, 'athletics'),
            _buildSkillRow('Deception', 'CHA', _skillChecks.deceptionProficiency, _skillChecks.deceptionExpertise, 'deception'),
            _buildSkillRow('History', 'INT', _skillChecks.historyProficiency, _skillChecks.historyExpertise, 'history'),
            _buildSkillRow('Insight', 'WIS', _skillChecks.insightProficiency, _skillChecks.insightExpertise, 'insight'),
            _buildSkillRow('Intimidation', 'CHA', _skillChecks.intimidationProficiency, _skillChecks.intimidationExpertise, 'intimidation'),
            _buildSkillRow('Investigation', 'INT', _skillChecks.investigationProficiency, _skillChecks.investigationExpertise, 'investigation'),
            _buildSkillRow('Medicine', 'WIS', _skillChecks.medicineProficiency, _skillChecks.medicineExpertise, 'medicine'),
            _buildSkillRow('Nature', 'WIS', _skillChecks.natureProficiency, _skillChecks.natureExpertise, 'nature'),
            _buildSkillRow('Perception', 'WIS', _skillChecks.perceptionProficiency, _skillChecks.perceptionExpertise, 'perception'),
            _buildSkillRow('Performance', 'CHA', _skillChecks.performanceProficiency, _skillChecks.performanceExpertise, 'performance'),
            _buildSkillRow('Persuasion', 'CHA', _skillChecks.persuasionProficiency, _skillChecks.persuasionExpertise, 'persuasion'),
            _buildSkillRow('Religion', 'INT', _skillChecks.religionProficiency, _skillChecks.religionExpertise, 'religion'),
            _buildSkillRow('Sleight of Hand', 'DEX', _skillChecks.sleightOfHandProficiency, _skillChecks.sleightOfHandExpertise, 'sleight_of_hand'),
            _buildSkillRow('Stealth', 'DEX', _skillChecks.stealthProficiency, _skillChecks.stealthExpertise, 'stealth'),
            _buildSkillRow('Survival', 'WIS', _skillChecks.survivalProficiency, _skillChecks.survivalExpertise, 'survival'),
          ],
        ],
      ),
    );
  }

  Widget _buildSavingThrowRow(String ability, bool isProficient, Function(bool?) onChanged) {
    final abilityScore = _getAbilityScore(ability);
    final modifier = _stats.getModifier(abilityScore);
    final proficiencyBonus = int.tryParse(_proficiencyBonusController.text) ?? 2;
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

  Widget _buildSkillRow(String skillName, String ability, bool isProficient, bool hasExpertise, String skillKey) {
    final abilityScore = _getAbilityScore(ability);
    final modifier = _stats.getModifier(abilityScore);
    final proficiencyBonus = int.tryParse(_proficiencyBonusController.text) ?? 2;
    final total = _skillChecks.calculateSkillModifier(skillKey, _stats, proficiencyBonus);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: hasExpertise ? Colors.blue.shade50 : (isProficient ? Colors.green.shade50 : Colors.white),
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
                border: Border.all(color: isProficient ? Colors.green : Colors.grey),
                borderRadius: BorderRadius.circular(4),
                color: isProficient ? Colors.green : Colors.transparent,
              ),
              child: isProficient
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
                border: Border.all(color: hasExpertise ? Colors.blue : Colors.grey),
                borderRadius: BorderRadius.circular(4),
                color: hasExpertise ? Colors.blue : Colors.transparent,
              ),
              child: hasExpertise
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
                color: hasExpertise ? Colors.blue : (isProficient ? Colors.green : Colors.black),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
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
        acrobaticsProficiency: skill == 'acrobatics' ? value : _skillChecks.acrobaticsProficiency,
        acrobaticsExpertise: skill == 'acrobatics' ? (value ? _skillChecks.acrobaticsExpertise : false) : _skillChecks.acrobaticsExpertise,
        animalHandlingProficiency: skill == 'animal_handling' ? value : _skillChecks.animalHandlingProficiency,
        animalHandlingExpertise: skill == 'animal_handling' ? (value ? _skillChecks.animalHandlingExpertise : false) : _skillChecks.animalHandlingExpertise,
        arcanaProficiency: skill == 'arcana' ? value : _skillChecks.arcanaProficiency,
        arcanaExpertise: skill == 'arcana' ? (value ? _skillChecks.arcanaExpertise : false) : _skillChecks.arcanaExpertise,
        athleticsProficiency: skill == 'athletics' ? value : _skillChecks.athleticsProficiency,
        athleticsExpertise: skill == 'athletics' ? (value ? _skillChecks.athleticsExpertise : false) : _skillChecks.athleticsExpertise,
        deceptionProficiency: skill == 'deception' ? value : _skillChecks.deceptionProficiency,
        deceptionExpertise: skill == 'deception' ? (value ? _skillChecks.deceptionExpertise : false) : _skillChecks.deceptionExpertise,
        historyProficiency: skill == 'history' ? value : _skillChecks.historyProficiency,
        historyExpertise: skill == 'history' ? (value ? _skillChecks.historyExpertise : false) : _skillChecks.historyExpertise,
        insightProficiency: skill == 'insight' ? value : _skillChecks.insightProficiency,
        insightExpertise: skill == 'insight' ? (value ? _skillChecks.insightExpertise : false) : _skillChecks.insightExpertise,
        intimidationProficiency: skill == 'intimidation' ? value : _skillChecks.intimidationProficiency,
        intimidationExpertise: skill == 'intimidation' ? (value ? _skillChecks.intimidationExpertise : false) : _skillChecks.intimidationExpertise,
        investigationProficiency: skill == 'investigation' ? value : _skillChecks.investigationProficiency,
        investigationExpertise: skill == 'investigation' ? (value ? _skillChecks.investigationExpertise : false) : _skillChecks.investigationExpertise,
        medicineProficiency: skill == 'medicine' ? value : _skillChecks.medicineProficiency,
        medicineExpertise: skill == 'medicine' ? (value ? _skillChecks.medicineExpertise : false) : _skillChecks.medicineExpertise,
        natureProficiency: skill == 'nature' ? value : _skillChecks.natureProficiency,
        natureExpertise: skill == 'nature' ? (value ? _skillChecks.natureExpertise : false) : _skillChecks.natureExpertise,
        perceptionProficiency: skill == 'perception' ? value : _skillChecks.perceptionProficiency,
        perceptionExpertise: skill == 'perception' ? (value ? _skillChecks.perceptionExpertise : false) : _skillChecks.perceptionExpertise,
        performanceProficiency: skill == 'performance' ? value : _skillChecks.performanceProficiency,
        performanceExpertise: skill == 'performance' ? (value ? _skillChecks.performanceExpertise : false) : _skillChecks.performanceExpertise,
        persuasionProficiency: skill == 'persuasion' ? value : _skillChecks.persuasionProficiency,
        persuasionExpertise: skill == 'persuasion' ? (value ? _skillChecks.persuasionExpertise : false) : _skillChecks.persuasionExpertise,
        religionProficiency: skill == 'religion' ? value : _skillChecks.religionProficiency,
        religionExpertise: skill == 'religion' ? (value ? _skillChecks.religionExpertise : false) : _skillChecks.religionExpertise,
        sleightOfHandProficiency: skill == 'sleight_of_hand' ? value : _skillChecks.sleightOfHandProficiency,
        sleightOfHandExpertise: skill == 'sleight_of_hand' ? (value ? _skillChecks.sleightOfHandExpertise : false) : _skillChecks.sleightOfHandExpertise,
        stealthProficiency: skill == 'stealth' ? value : _skillChecks.stealthProficiency,
        stealthExpertise: skill == 'stealth' ? (value ? _skillChecks.stealthExpertise : false) : _skillChecks.stealthExpertise,
        survivalProficiency: skill == 'survival' ? value : _skillChecks.survivalProficiency,
        survivalExpertise: skill == 'survival' ? (value ? _skillChecks.survivalExpertise : false) : _skillChecks.survivalExpertise,
      );
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
        acrobaticsExpertise: skill == 'acrobatics' ? value : _skillChecks.acrobaticsExpertise,
        animalHandlingProficiency: _skillChecks.animalHandlingProficiency,
        animalHandlingExpertise: skill == 'animal_handling' ? value : _skillChecks.animalHandlingExpertise,
        arcanaProficiency: _skillChecks.arcanaProficiency,
        arcanaExpertise: skill == 'arcana' ? value : _skillChecks.arcanaExpertise,
        athleticsProficiency: _skillChecks.athleticsProficiency,
        athleticsExpertise: skill == 'athletics' ? value : _skillChecks.athleticsExpertise,
        deceptionProficiency: _skillChecks.deceptionProficiency,
        deceptionExpertise: skill == 'deception' ? value : _skillChecks.deceptionExpertise,
        historyProficiency: _skillChecks.historyProficiency,
        historyExpertise: skill == 'history' ? value : _skillChecks.historyExpertise,
        insightProficiency: _skillChecks.insightProficiency,
        insightExpertise: skill == 'insight' ? value : _skillChecks.insightExpertise,
        intimidationProficiency: _skillChecks.intimidationProficiency,
        intimidationExpertise: skill == 'intimidation' ? value : _skillChecks.intimidationExpertise,
        investigationProficiency: _skillChecks.investigationProficiency,
        investigationExpertise: skill == 'investigation' ? value : _skillChecks.investigationExpertise,
        medicineProficiency: _skillChecks.medicineProficiency,
        medicineExpertise: skill == 'medicine' ? value : _skillChecks.medicineExpertise,
        natureProficiency: _skillChecks.natureProficiency,
        natureExpertise: skill == 'nature' ? value : _skillChecks.natureExpertise,
        perceptionProficiency: _skillChecks.perceptionProficiency,
        perceptionExpertise: skill == 'perception' ? value : _skillChecks.perceptionExpertise,
        performanceProficiency: _skillChecks.performanceProficiency,
        performanceExpertise: skill == 'performance' ? value : _skillChecks.performanceExpertise,
        persuasionProficiency: _skillChecks.persuasionProficiency,
        persuasionExpertise: skill == 'persuasion' ? value : _skillChecks.persuasionExpertise,
        religionProficiency: _skillChecks.religionProficiency,
        religionExpertise: skill == 'religion' ? value : _skillChecks.religionExpertise,
        sleightOfHandProficiency: _skillChecks.sleightOfHandProficiency,
        sleightOfHandExpertise: skill == 'sleight_of_hand' ? value : _skillChecks.sleightOfHandExpertise,
        stealthProficiency: _skillChecks.stealthProficiency,
        stealthExpertise: skill == 'stealth' ? value : _skillChecks.stealthExpertise,
        survivalProficiency: _skillChecks.survivalProficiency,
        survivalExpertise: skill == 'survival' ? value : _skillChecks.survivalExpertise,
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

  Widget _buildSpellSlotsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spell Slots',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your character\'s spell slots and usage',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          // Spell slots grid
          ...[
            for (int level = 1; level <= 9; level++)
              _buildSpellSlotField('Level $level', level),
          ],
          
          const SizedBox(height: 32),
          
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
                      final totalSlots = _spellSlots.level1Slots + _spellSlots.level2Slots + 
                                       _spellSlots.level3Slots + _spellSlots.level4Slots + 
                                       _spellSlots.level5Slots + _spellSlots.level6Slots + 
                                       _spellSlots.level7Slots + _spellSlots.level8Slots + 
                                       _spellSlots.level9Slots;
                      
                      final totalUsed = _spellSlots.level1Used + _spellSlots.level2Used + 
                                      _spellSlots.level3Used + _spellSlots.level4Used + 
                                      _spellSlots.level5Used + _spellSlots.level6Used + 
                                      _spellSlots.level7Used + _spellSlots.level8Used + 
                                      _spellSlots.level9Used;
                      
                      final availableSlots = totalSlots - totalUsed;
                      
                      return Column(
                        children: [
                          _buildSummaryRow('Total Slots', totalSlots.toString()),
                          _buildSummaryRow('Used Slots', totalUsed.toString()),
                          _buildSummaryRow('Available Slots', availableSlots.toString(), 
                            availableSlots > 0 ? Colors.green : Colors.red),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
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
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
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
    // Load spells if not already loaded
    context.read<SpellsViewModel>().loadSpells();
    
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
                    const Icon(Icons.auto_awesome),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add Spell to ${widget.character.name}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (spellsViewModel.error != null) {
                      return Center(
                        child: Text('Error: ${spellsViewModel.error}'),
                      );
                    }
                    
                    final spells = spellsViewModel.spells;
                    if (spells.isEmpty) {
                      return const Center(
                        child: Text('No spells found'),
                      );
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
                          trailing: isKnown 
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.add),
                          enabled: !isKnown,
                          onTap: isKnown ? null : () {
                            setState(() {
                              _spells.add(spell.name);
                            });
                            Navigator.pop(context);
                            
                            // Auto-save the character when a spell is added
                            _autoSaveCharacter();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${spell.name} to ${widget.character.name}'),
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
      description: 'This spell details are not available in the spell database. It may be a custom spell or homebrew content.',
      classes: [],
      dice: [],
      updatedAt: DateTime.now(),
    );
  }

  void _showSpellDetailsModal(Spell spell) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
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
                    if (spell.ritual)
                      _buildDetailRow('Ritual', 'Yes'),
                    
                    // Classes
                    _buildDetailRow(
                      'Classes', 
                      spell.classes.isNotEmpty 
                        ? spell.classes.map((c) => c.split('_').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ')).join(', ')
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
                                  content: Text('Removed ${spell.name} from ${widget.character.name}'),
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
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
    // Create updated character with current spell list
    final updatedCharacter = widget.character.copyWith(
      spells: _spells,
      updatedAt: DateTime.now(),
    );
    
    // Save the character silently (no success message)
    context.read<CharactersViewModel>().updateCharacter(updatedCharacter);
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
