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
import '../character_edit_helpers.dart';

class CharacterEditScreen extends StatefulWidget {
  final Character character;

  const CharacterEditScreen({super.key, required this.character});

  @override
  State<CharacterEditScreen> createState() => _CharacterEditScreenState();
}

class _CharacterEditScreenState extends State<CharacterEditScreen>
    with SingleTickerProviderStateMixin, CharacterImageHandling {
  late TabController _tabController;
  late CharacterEditControllers _controllers;
  late CharacterEditState _state;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _controllers = CharacterEditControllers();
    _state = CharacterEditState();
    _initializeCharacterData();
    _setupAutoSaveListeners();
    
    // Load races and backgrounds data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RacesViewModel>().loadRaces();
      context.read<BackgroundsViewModel>().loadBackgrounds();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controllers.disposeAll();
    super.dispose();
  }

  void _initializeCharacterData() {
    final character = widget.character;

    // Initialize state
    _state.initializeFromCharacter(character);
    
    // Initialize controllers
    _controllers.initializeFromCharacter(character);
    
    // Initialize death saves
    _controllers.deathSaveSuccesses.clear();
    _controllers.deathSaveSuccesses.addAll(character.deathSaves.successes);
    _controllers.deathSaveFailures.clear();
    _controllers.deathSaveFailures.addAll(character.deathSaves.failures);

    // Initialize initiative tracking
    final currentInitiative = int.tryParse(_controllers.initiativeController.text) ?? 0;
    final currentDexterity = int.tryParse(_controllers.dexterityController.text) ?? 10;
    final expectedInitiative = _state.calculateInitiative(currentDexterity);
    _state.initiativeManuallyModified = (currentInitiative != expectedInitiative);
    
    // Check if current subclass is custom (not in preset list)
    final availableSubclasses = _getSubclassesForClass(character.characterClass);
    _state.useCustomSubclass = character.subclass != null && !availableSubclasses.contains(character.subclass);
  }

  void _setupAutoSaveListeners() {
    // Add listeners to all text controllers for auto-save
    _controllers.nameController.addListener(_autoSaveCharacter);
    _controllers.levelController.addListener(() {
      _autoSaveCharacter();
      setState(() {}); // Rebuild to update proficiency bonus display
    });
    _controllers.classController.addListener(() {
      _autoSaveCharacter();
      if (_controllers.classController.text != widget.character.characterClass) {
        setState(() {
          _state.hasUnsavedClassChanges = true;
        });
      }
    });
    _controllers.subclassController.addListener(() {
      _autoSaveCharacter();
      if (_controllers.subclassController.text != (widget.character.subclass ?? '')) {
        setState(() {
          _state.hasUnsavedClassChanges = true;
        });
      }
    });
    _controllers.raceController.addListener(() {
      _autoSaveCharacter();
      if (_controllers.raceController.text != (widget.character.race ?? '')) {
        setState(() {
          _state.hasUnsavedClassChanges = true;
        });
      }
    });
    _controllers.backgroundController.addListener(() {
      _autoSaveCharacter();
      if (_controllers.backgroundController.text != (widget.character.background ?? '')) {
        setState(() {
          _state.hasUnsavedClassChanges = true;
        });
      }
    });
    _controllers.quickGuideController.addListener(_autoSaveCharacter);
    _controllers.backstoryController.addListener(_autoSaveCharacter);
    _controllers.featNotesController.addListener(_autoSaveCharacter);

    // Appearance controllers
    _controllers.heightController.addListener(_autoSaveCharacter);
    _controllers.ageController.addListener(_autoSaveCharacter);
    _controllers.eyeColorController.addListener(_autoSaveCharacter);
    _controllers.additionalDetailsController.addListener(_autoSaveCharacter);

    // Pillars controllers
    _controllers.gimmickController.addListener(_autoSaveCharacter);
    _controllers.quirkController.addListener(_autoSaveCharacter);
    _controllers.wantsController.addListener(_autoSaveCharacter);
    _controllers.needsController.addListener(_autoSaveCharacter);
    _controllers.conflictController.addListener(_autoSaveCharacter);

    // Stats controllers
    _controllers.strengthController.addListener(() {
      _autoSaveCharacter();
      _state.updateInitiativeIfNotManuallyModified(
        _controllers.dexterityController,
        _controllers.initiativeController,
      );
      setState(() => _state.hasUnsavedAbilityChanges = true);
    });
    _controllers.dexterityController.addListener(() {
      _autoSaveCharacter();
      _state.updateInitiativeIfNotManuallyModified(
        _controllers.dexterityController,
        _controllers.initiativeController,
      );
      setState(() => _state.hasUnsavedAbilityChanges = true);
    });
    _controllers.constitutionController.addListener(() {
      _autoSaveCharacter();
      setState(() => _state.hasUnsavedAbilityChanges = true);
    });
    _controllers.intelligenceController.addListener(() {
      _autoSaveCharacter();
      setState(() => _state.hasUnsavedAbilityChanges = true);
    });
    _controllers.wisdomController.addListener(() {
      _autoSaveCharacter();
      setState(() => _state.hasUnsavedAbilityChanges = true);
    });
    _controllers.charismaController.addListener(() {
      _autoSaveCharacter();
      setState(() => _state.hasUnsavedAbilityChanges = true);
    });
    _controllers.proficiencyBonusController.addListener(_autoSaveCharacter);
    _controllers.armorClassController.addListener(_autoSaveCharacter);
    _controllers.speedController.addListener(_autoSaveCharacter);
    _controllers.initiativeController.addListener(() {
      _autoSaveCharacter();
      _state.initiativeManuallyModified = true;
    });

    // Health controllers
    _controllers.maxHpController.addListener(_autoSaveCharacter);
    _controllers.currentHpController.addListener(_autoSaveCharacter);
    _controllers.tempHpController.addListener(_autoSaveCharacter);
    _controllers.hitDiceController.addListener(_autoSaveCharacter);
    _controllers.hitDiceTypeController.addListener(_autoSaveCharacter);

    // Languages and items controllers
    _controllers.languagesController.addListener(_autoSaveCharacter);
    _controllers.moneyController.addListener(_autoSaveCharacter);
    _controllers.itemsController.addListener(_autoSaveCharacter);
  }

  void _autoSaveCharacter() {
    final character = widget.character;
    final updatedCharacter = character.copyWith(
      name: _controllers.nameController.text.trim(),
      level: int.tryParse(_controllers.levelController.text),
      characterClass: _controllers.classController.text.trim(),
      subclass: _controllers.subclassController.text.trim(),
      race: _controllers.raceController.text.trim(),
      background: _controllers.backgroundController.text.trim(),
      quickGuide: _controllers.quickGuideController.text.trim(),
      backstory: _controllers.backstoryController.text.trim(),
      featNotes: _controllers.featNotesController.text.trim(),
      
      // Appearance
      height: _controllers.heightController.text.trim(),
      age: int.tryParse(_controllers.ageController.text),
      eyeColor: _controllers.eyeColorController.text.trim(),
      additionalDetails: _controllers.additionalDetailsController.text.trim(),
      
      // Pillars
      gimmick: _controllers.gimmickController.text.trim(),
      quirk: _controllers.quirkController.text.trim(),
      wants: _controllers.wantsController.text.trim(),
      needs: _controllers.needsController.text.trim(),
      conflict: _controllers.conflictController.text.trim(),
      
      // Stats
      strength: int.tryParse(_controllers.strengthController.text),
      dexterity: int.tryParse(_controllers.dexterityController.text),
      constitution: int.tryParse(_controllers.constitutionController.text),
      intelligence: int.tryParse(_controllers.intelligenceController.text),
      wisdom: int.tryParse(_controllers.wisdomController.text),
      charisma: int.tryParse(_controllers.charismaController.text),
      proficiencyBonus: int.tryParse(_controllers.proficiencyBonusController.text),
      armorClass: int.tryParse(_controllers.armorClassController.text),
      speed: int.tryParse(_controllers.speedController.text),
      initiative: int.tryParse(_controllers.initiativeController.text),
      
      // Health
      maxHp: int.tryParse(_controllers.maxHpController.text),
      currentHp: int.tryParse(_controllers.currentHpController.text),
      tempHp: int.tryParse(_controllers.tempHpController.text),
      hitDice: int.tryParse(_controllers.hitDiceController.text),
      hitDiceType: _controllers.hitDiceTypeController.text.trim(),
      
      // Languages and items
      languages: _controllers.languagesController.text.trim(),
      money: _controllers.moneyController.text.trim(),
      items: _controllers.itemsController.text.trim(),
      
      // Images
      customImagePath: _state.customImagePath,
      appearance: widget.character.appearance.copyWith(
        appearanceImagePath: _state.appearanceImagePath,
      ),
      
      // States
      hasInspiration: _state.hasInspiration,
      hasConcentration: _state.hasConcentration,
      stats: _state.stats,
      savingThrows: _state.savingThrows,
      skillChecks: _state.skillChecks,
      personalizedSlots: _state.personalizedSlots,
    );

    final charactersViewModel = Provider.of<CharactersViewModel>(context, listen: false);
    charactersViewModel.updateCharacter(updatedCharacter);
  }

  void _saveCharacter(String message) {
    _autoSaveCharacter();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character.name),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Stats'),
            Tab(text: 'Health'),
            Tab(text: 'Skills'),
            Tab(text: 'Spells'),
            Tab(text: 'Feats'),
            Tab(text: 'Equipment'),
            Tab(text: 'Notes'),
            Tab(text: 'Appearance'),
            Tab(text: 'Cover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildStatsTab(),
          _buildHealthTab(),
          _buildSkillsTab(),
          _buildSpellsTab(),
          _buildFeatsTab(),
          _buildEquipmentTab(),
          _buildNotesTab(),
          _buildAppearanceTab(),
          _buildCoverTab(),
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
          _buildProfileImageSection(),
          const SizedBox(height: 16),
          
          // Basic information fields
          _buildTextField(_controllers.nameController, 'Character Name'),
          _buildTextField(_controllers.levelController, 'Level', keyboardType: TextInputType.number),
          _buildClassSelection(),
          _buildTextField(_controllers.raceController, 'Race'),
          _buildTextField(_controllers.backgroundController, 'Background'),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
            image: _state.customImagePath != null
                ? DecorationImage(
                    image: FileImage(File(_state.customImagePath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _state.customImagePath == null
              ? const Icon(Icons.person, size: 60, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showImageOptionsDialog(),
          child: Text(_state.customImagePath != null ? 'Change Image' : 'Add Image'),
        ),
      ],
    );
  }

  void _showImageOptionsDialog() {
    showImageOptionsDialog(
      context,
      onTakePhoto: () => _pickImage(ImageSource.camera),
      onChooseFromGallery: () => _pickImage(ImageSource.gallery),
      onRemoveImage: _state.customImagePath != null ? _removeImage : null,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_state.isPickingImage) return;

    setState(() {
      _state.isPickingImage = true;
    });

    try {
      final imagePath = await pickAndSaveImage(
        source,
        widget.character.id,
        imageType: 'character',
      );

      if (imagePath != null) {
        setState(() {
          _state.customImagePath = imagePath;
        });
        _autoSaveCharacter();
      }
    } catch (e) {
      showImageError(context, e);
    } finally {
      setState(() {
        _state.isPickingImage = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _state.customImagePath = null;
    });
    _autoSaveCharacter();
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildClassSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _state.selectedClass,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: ['Fighter', 'Wizard', 'Cleric', 'Rogue', 'Ranger', 'Paladin', 'Barbarian', 'Bard', 'Druid', 'Monk', 'Sorcerer', 'Warlock']
              .map((className) => DropdownMenuItem(
                    value: className,
                    child: Text(className),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _state.selectedClass = value;
                _controllers.classController.text = value;
                _state.hasUnsavedClassChanges = true;
              });
            }
          },
        ),
      ],
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
          
          Row(
            children: [
              Expanded(child: _buildStatField(_controllers.strengthController, 'Strength')),
              const SizedBox(width: 8),
              Expanded(child: _buildStatField(_controllers.dexterityController, 'Dexterity')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatField(_controllers.constitutionController, 'Constitution')),
              const SizedBox(width: 8),
              Expanded(child: _buildStatField(_controllers.intelligenceController, 'Intelligence')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatField(_controllers.wisdomController, 'Wisdom')),
              const SizedBox(width: 8),
              Expanded(child: _buildStatField(_controllers.charismaController, 'Charisma')),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text('Combat Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildTextField(_controllers.armorClassController, 'Armor Class', keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_controllers.speedController, 'Speed', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(_controllers.initiativeController, 'Initiative', keyboardType: TextInputType.number),
          
          if (_state.hasUnsavedAbilityChanges)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  _saveCharacter('Ability scores saved!');
                  setState(() => _state.hasUnsavedAbilityChanges = false);
                },
                child: const Text('Save Ability Scores'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixText: _calculateModifier(controller),
      ),
      keyboardType: TextInputType.number,
    );
  }

  String _calculateModifier(TextEditingController controller) {
    final value = int.tryParse(controller.text) ?? 10;
    final modifier = (value - 10) ~/ 2;
    return modifier >= 0 ? '+$modifier' : '$modifier';
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Health Points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildTextField(_controllers.maxHpController, 'Max HP', keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_controllers.currentHpController, 'Current HP', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(_controllers.tempHpController, 'Temporary HP', keyboardType: TextInputType.number),
          
          const SizedBox(height: 24),
          const Text('Hit Dice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildTextField(_controllers.hitDiceController, 'Hit Dice', keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_controllers.hitDiceTypeController, 'Hit Dice Type')),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text('Death Saves', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildDeathSavesSection(),
        ],
      ),
    );
  }

  Widget _buildDeathSavesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Successes'),
        Row(
          children: List.generate(3, (index) => 
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Checkbox(
                value: _controllers.deathSaveSuccesses[index],
                onChanged: (value) {
                  setState(() {
                    _controllers.deathSaveSuccesses[index] = value ?? false;
                  });
                  _autoSaveCharacter();
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Failures'),
        Row(
          children: List.generate(3, (index) => 
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Checkbox(
                value: _controllers.deathSaveFailures[index],
                onChanged: (value) {
                  setState(() {
                    _controllers.deathSaveFailures[index] = value ?? false;
                  });
                  _autoSaveCharacter();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // This would contain the skill checkboxes and proficiency/expertise toggles
          // For brevity, showing a simplified version
          _buildSkillItem('Acrobatics'),
          _buildSkillItem('Athletics'),
          _buildSkillItem('Stealth'),
          // Add more skills as needed...
        ],
      ),
    );
  }

  Widget _buildSkillItem(String skillName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(skillName)),
          Checkbox(
            value: false, // This would be connected to the skill checks
            onChanged: (value) {
              // Update skill proficiency
            },
          ),
          Checkbox(
            value: false, // This would be connected to expertise
            onChanged: (value) {
              // Update skill expertise
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpellsTab() {
    return const Center(
      child: Text('Spells tab - To be implemented'),
    );
  }

  Widget _buildFeatsTab() {
    return const Center(
      child: Text('Feats tab - To be implemented'),
    );
  }

  Widget _buildEquipmentTab() {
    return const Center(
      child: Text('Equipment tab - To be implemented'),
    );
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
            controller: _controllers.quickGuideController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter quick guide notes...',
            ),
            maxLines: 3,
          ),
          
          const SizedBox(height: 24),
          const Text('Backstory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _controllers.backstoryController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter character backstory...',
            ),
            maxLines: 5,
          ),
          
          const SizedBox(height: 24),
          const Text('Feat Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _controllers.featNotesController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter feat notes...',
            ),
            maxLines: 3,
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
          const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildTextField(_controllers.heightController, 'Height'),
          _buildTextField(_controllers.ageController, 'Age', keyboardType: TextInputType.number),
          _buildTextField(_controllers.eyeColorController, 'Eye Color'),
          _buildTextField(_controllers.additionalDetailsController, 'Additional Details'),
          
          const SizedBox(height: 24),
          const Text('Appearance Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildAppearanceImageSection(),
        ],
      ),
    );
  }

  Widget _buildAppearanceImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            image: _state.appearanceImagePath != null
                ? DecorationImage(
                    image: FileImage(File(_state.appearanceImagePath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _state.appearanceImagePath == null
              ? const Icon(Icons.image, size: 60, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _pickAppearanceImage(),
          child: Text(_state.appearanceImagePath != null ? 'Change Appearance Image' : 'Add Appearance Image'),
        ),
      ],
    );
  }

  Future<void> _pickAppearanceImage() async {
    if (_state.isPickingImage) return;

    setState(() {
      _state.isPickingImage = true;
    });

    try {
      final imagePath = await pickAndSaveImage(
        ImageSource.gallery,
        widget.character.id,
        imageType: 'appearance',
      );

      if (imagePath != null) {
        setState(() {
          _state.appearanceImagePath = imagePath;
        });
        _autoSaveCharacter();
      }
    } catch (e) {
      showImageError(context, e);
    } finally {
      setState(() {
        _state.isPickingImage = false;
      });
    }
  }

  Widget _buildCoverTab() {
    return const Center(
      child: Text('Cover tab - To be implemented'),
    );
  }

  List<String> _getSubclassesForClass(String characterClass) {
    // This would return the available subclasses for a given class
    // For now, returning empty list
    return [];
  }
}
