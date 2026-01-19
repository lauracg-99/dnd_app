import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/spell_model.dart';
import '../../models/character_model.dart';
import '../../viewmodels/spells_viewmodel.dart';
import '../../viewmodels/characters_viewmodel.dart';

class SpellsListScreen extends StatefulWidget {
  const SpellsListScreen({super.key});

  @override
  State<SpellsListScreen> createState() => _SpellsListScreenState();
}

class _SpellsListScreenState extends State<SpellsListScreen> {
  final _searchController = TextEditingController();
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    // Load spells when the screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellsViewModel>().loadSpells();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('D&D Spells'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isFilterExpanded ? 200 : 80),
          child: _buildSearchAndFilters(),
        ),
      ),
      body: Consumer<SpellsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.spells.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return _buildErrorView(viewModel);
          }

          if (viewModel.spells.isEmpty) {
            return _buildEmptyView();
          }

          return _buildSpellsList(viewModel);
        },
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Consumer<SpellsViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search spells...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            viewModel.setSearchQuery('');
                          },
                        )
                      : null,
                ),
                onChanged: viewModel.setSearchQuery,
              ),
              
              // Expandable filter section
              if (_isFilterExpanded) ..._buildFilterControls(viewModel),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFilterControls(SpellsViewModel viewModel) {
    return [
      const SizedBox(height: 8),
      // Level filter
      SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const Text('Level: ', style: TextStyle(fontWeight: FontWeight.bold)),
            FilterChip(
              label: const Text('All'),
              selected: viewModel.selectedLevel == null,
              onSelected: (_) => viewModel.setSelectedLevel(null),
            ),
            ...viewModel.availableLevels.map((level) {
              final label = level == 0 ? 'Cantrip' : 'Level $level';
              return Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: FilterChip(
                  label: Text(label),
                  selected: viewModel.selectedLevel == level,
                  onSelected: (_) => viewModel.setSelectedLevel(level),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      
      // Class filter
      const SizedBox(height: 8),
      SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const Text('Class: ', style: TextStyle(fontWeight: FontWeight.bold)),
            FilterChip(
              label: const Text('All'),
              selected: viewModel.selectedClass.isEmpty,
              onSelected: (_) => viewModel.setSelectedClass(''),
            ),
            ...viewModel.availableClasses.map((className) {
              return Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: FilterChip(
                  label: Text(
                    className.split('_').map((s) => s[0].toUpperCase() + s.substring(1)).join(' '),
                  ),
                  selected: viewModel.selectedClass == className,
                  onSelected: (_) => viewModel.setSelectedClass(className),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      
      // School filter
      const SizedBox(height: 8),
      SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const Text('School: ', style: TextStyle(fontWeight: FontWeight.bold)),
            FilterChip(
              label: const Text('All'),
              selected: viewModel.selectedSchool.isEmpty,
              onSelected: (_) => viewModel.setSelectedSchool(''),
            ),
            ...viewModel.availableSchools.map((school) {
              return Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: FilterChip(
                  label: Text(school[0].toUpperCase() + school.substring(1)),
                  selected: viewModel.selectedSchool == school,
                  onSelected: (_) => viewModel.setSelectedSchool(school),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    ];
  }

  Widget _buildErrorView(SpellsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: ${viewModel.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.loadSpells,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('No spells found. Try adjusting your search or filters.'),
        ],
      ),
    );
  }

  // Group spells by their level
  Map<int, List<Spell>> _groupSpellsByLevel(List<Spell> spells) {
    final Map<int, List<Spell>> groupedSpells = {};
    
    for (final spell in spells) {
      final level = spell.levelNumber;
      groupedSpells.putIfAbsent(level, () => []).add(spell);
    }
    
    // Sort each level's spells alphabetically
    for (final level in groupedSpells.keys) {
      groupedSpells[level]!.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return Map.fromEntries(
      groupedSpells.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  // Build a section header for a spell level
  Widget _buildSectionHeader(int level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        level == 0 ? 'Cantrips' : 'Level $level Spells',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Build a single spell item
  Widget _buildSpellItem(Spell spell, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        title: Text(spell.name),
        subtitle: Text(
          '${spell.schoolName.capitalize()} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}${spell.ritual ? ' (Ritual)' : ''}'.trim(),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showSpellDetails(context, spell);
        },
      ),
    );
  }

  // The main method to build the spells list
  Widget _buildSpellsList(SpellsViewModel viewModel) {
    final groupedSpells = _groupSpellsByLevel(viewModel.spells);
    final levels = groupedSpells.keys.toList()..sort();
    
    // If no spells after filtering
    if (viewModel.spells.isEmpty) {
      return _buildEmptyView();
    }

    // Calculate total number of items (1 header + spells for each level)
    int itemCount = 0;
    for (final level in levels) {
      itemCount += 1 + groupedSpells[level]!.length; // 1 for header + number of spells
    }

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        int currentPos = 0;
        
        for (final level in levels) {
          final spells = groupedSpells[level]!;
          
          // Check if this is the header position
          if (index == currentPos) {
            return _buildSectionHeader(level);
          }
          currentPos++;
          
          // Check if this is a spell position
          final spellIndex = index - currentPos;
          if (spellIndex < spells.length) {
            return _buildSpellItem(spells[spellIndex], context);
          }
          
          currentPos += spells.length;
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  void _showSpellDetails(BuildContext context, Spell spell) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
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
                  '${spell.schoolName.capitalize()} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add to Character'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showCharacterSelectionDialog(context, spell);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Details Only'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
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
                  spell.classes.map((c) => c.capitalize().replaceAll('_', ' ')).join(', ')
                ),
                
                const Divider(),
                
                // Description
                Text(
                  spell.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                
                // Add more details here as needed
              ],
            ),
          ),
        ),
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
}

  void _showCharacterSelectionDialog(BuildContext context, Spell spell) {
    final charactersViewModel = context.read<CharactersViewModel>();
    final characters = charactersViewModel.characters;
    
    if (characters.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Characters'),
          content: const Text('You need to create a character first before adding spells.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add "${spell.name}" to Character'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: characters.map((character) {
              return RadioListTile<Character>(
                title: Text(character.name),
                subtitle: Text(character.characterClass),
                value: character,
                groupValue: null,
                onChanged: (selectedCharacter) {
                  if (selectedCharacter != null) {
                    Navigator.pop(context);
                    _addSpellToCharacter(context, selectedCharacter, spell);
                  }
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addSpellToCharacter(BuildContext context, Character character, Spell spell) {
    final charactersViewModel = context.read<CharactersViewModel>();
    
    // Check if character already knows this spell
    if (character.spells.contains(spell.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${character.name} already knows ${spell.name}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Add spell to character
    final updatedSpells = List<String>.from(character.spells)..add(spell.name);
    final updatedCharacter = character.copyWith(
      spells: updatedSpells,
      updatedAt: DateTime.now(),
    );
    
    // Save updated character
    charactersViewModel.updateCharacter(updatedCharacter);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${spell.name} to ${character.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
