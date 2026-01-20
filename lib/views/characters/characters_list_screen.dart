import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/character_model.dart';
import '../../models/race_model.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../viewmodels/races_viewmodel.dart';
import 'character_edit_screen.dart';

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  final _searchController = TextEditingController();
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    // Load characters when the screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharactersViewModel>().loadCharacters();
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
        title: const Text('D&D Characters'),
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
          preferredSize: Size.fromHeight(_isFilterExpanded ? 120 : 80),
          child: _buildSearchAndFilters(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'characters_fab',
        onPressed: _showCreateCharacterDialog,
        tooltip: 'Create Character',
        child: const Icon(Icons.add),
      ),
      body: Consumer<CharactersViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.characters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return _buildErrorView(viewModel);
          }

          if (viewModel.characters.isEmpty) {
            return _buildEmptyView();
          }

          return _buildCharactersList(viewModel);
        },
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Consumer<CharactersViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search characters...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
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

  List<Widget> _buildFilterControls(CharactersViewModel viewModel) {
    return [
      const SizedBox(height: 8),
      // Class filter
      SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const Text(
              'Class: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            FilterChip(
              label: const Text('All'),
              selected: viewModel.selectedClass.isEmpty,
              onSelected: (_) => viewModel.setSelectedClass(''),
            ),
            ...viewModel.availableClasses.map((className) {
              return Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: FilterChip(
                  label: Text(className),
                  selected: viewModel.selectedClass == className,
                  onSelected: (_) => viewModel.setSelectedClass(className),
                ),
              );
            }),
          ],
        ),
      ),
    ];
  }

  Widget _buildErrorView(CharactersViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: ${viewModel.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.loadCharacters,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No characters found. Create your first character!'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showCreateCharacterDialog,
            child: const Text('Create Character'),
          ),
        ],
      ),
    );
  }

  Widget _buildCharactersList(CharactersViewModel viewModel) {
    // If no characters after filtering
    if (viewModel.characters.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.builder(
      itemCount: viewModel.characters.length,
      itemBuilder: (context, index) {
        final character = viewModel.characters[index];
        return _buildCharacterItem(character, context);
      },
    );
  }

  Widget _buildCharacterItem(Character character, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          child:
              character.customImagePath != null
                  ? ClipOval(
                    child: Image.file(
                      File(character.customImagePath!),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person);
                      },
                    ),
                  )
                  : const Icon(Icons.person),
        ),
        title: Text(character.name),
        subtitle: Text(
          '${character.characterClass}${character.subclass != null && character.subclass!.isNotEmpty ? ' (${character.subclass})' : ''}${character.race != null && character.race!.isNotEmpty ? ' • ${character.race}' : ''}',
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _navigateToEditCharacter(character);
                break;
              case 'delete':
                _showDeleteConfirmation(character);
                break;
              case 'duplicate':
                _duplicateCharacter(character);
                break;
              case 'export':
                _exportCharacter(character);
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Export'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () {
          _navigateToEditCharacter(character);
        },
      ),
    );
  }

  void _navigateToEditCharacter(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterEditScreen(character: character),
      ),
    );
  }

  void _showCreateCharacterDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateCharacterDialog(),
    );
  }

  void _showDeleteConfirmation(Character character) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Character'),
            content: Text(
              'Are you sure you want to delete ${character.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<CharactersViewModel>().deleteCharacter(
                    character.id,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _duplicateCharacter(Character character) {
    final duplicatedCharacter = character.copyWith(
      id: '${character.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
      name: '${character.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<CharactersViewModel>().updateCharacter(duplicatedCharacter);
  }

  void _exportCharacter(Character character) {
    final viewModel = context.read<CharactersViewModel>();
    viewModel.exportCharacter(character);

    // TODO: Implement proper file sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${character.name} to clipboard'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // TODO: Copy to clipboard
          },
        ),
      ),
    );
  }
}

class CreateCharacterDialog extends StatefulWidget {
  const CreateCharacterDialog({super.key});

  @override
  State<CreateCharacterDialog> createState() => _CreateCharacterDialogState();
}

class _CreateCharacterDialogState extends State<CreateCharacterDialog> {
  final _nameController = TextEditingController();
  final _levelController = TextEditingController(text: '1');
  String _selectedClass = 'Fighter';
  final _subclassController = TextEditingController();
  final _raceController = TextEditingController();
  bool _useCustomSubclass = false;

  @override
  void initState() {
    super.initState();
    // Load races data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RacesViewModel>().loadRaces();
    });
  }

  // Helper method to get subclasses for each class
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

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _subclassController.dispose();
    _raceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<CharactersViewModel>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New Character',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),                      
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Character Name Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Character Name',
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Character Level Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _levelController,
                decoration: InputDecoration(
                  labelText: 'Character Level',
                  prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.green),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Class Selector
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: InputDecoration(
                  labelText: 'Class',
                //  prefixIcon: const Icon(Icons.gavel, color: Colors.purple),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                items: viewModel.availableClasses.map((className) {
                  return DropdownMenuItem(
                    value: className,
                    child: Row(
                      children: [
                       // _getClassIcon(className),
                        const SizedBox(width: 12),
                        Text(
                          className,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Subclass picker
            if (_useCustomSubclass)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _subclassController,
                  decoration: InputDecoration(
                    labelText: 'Custom Subclass',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_subclassController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _subclassController.text = '';
                              });
                            },
                            tooltip: 'Clear subclass',
                          ),
                        IconButton(
                          icon: const Icon(Icons.list),
                          onPressed: () {
                            setState(() {
                              _useCustomSubclass = false;
                            });
                          },
                          tooltip: 'Choose from preset subclasses',
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _subclassController.text.isEmpty ? null : _subclassController.text,
                  decoration: InputDecoration(
                    labelText: 'Subclass (Optional)',
                    //prefixIcon: const Icon(Icons.star, color: Colors.orange),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  isExpanded: true,
                  items: [
                    if (_subclassController.text.isNotEmpty)
                      DropdownMenuItem(
                        value: '__CLEAR__',
                        child: Row(
                          children: [
                            Icon(Icons.clear, color: Colors.red, size: 20),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Clear Subclass',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ..._getSubclassesForClass(_selectedClass).map((subclass) {
                      return DropdownMenuItem(
                        value: subclass,
                        child: Row(
                          children: [
                            //Icon(Icons.star, color: Colors.orange, size: 20),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                subclass,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    DropdownMenuItem(
                      value: '__CUSTOM__',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.grey, size: 20),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Custom Subclass...',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == '__CUSTOM__') {
                        _useCustomSubclass = true;
                        _subclassController.text = '';
                      } else if (value == '__CLEAR__') {
                        _subclassController.text = '';
                      } else {
                        _subclassController.text = value ?? '';
                      }
                    });
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Race selection
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer<RacesViewModel>(
                builder: (context, racesViewModel, child) {
                  // Find matching race for initial value
                  Race? matchingRace;
                  if (_raceController.text.isNotEmpty) {
                    matchingRace = racesViewModel.races.firstWhere(
                      (race) => race.name == _raceController.text,
                      orElse: () => racesViewModel.races.first,
                    );
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: matchingRace != null ? '${matchingRace.name}_${matchingRace.source}' : null,
                    decoration: const InputDecoration(
                      labelText: 'Race (Optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    isExpanded: true,
                    items: [
                      if (_raceController.text.isNotEmpty)
                        DropdownMenuItem(
                          value: '__CLEAR__',
                          child: Row(
                            children: [
                              Icon(Icons.clear, color: Colors.red, size: 20),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Clear Race',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...racesViewModel.races.map((race) {
                        return DropdownMenuItem(
                          value: '${race.name}_${race.source}', // Make unique with source
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  race.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value == '__CLEAR__') {
                          _raceController.text = '';
                        } else if (value != null) {
                          // Extract race name from unique value (remove source suffix)
                          final raceName = value.contains('_') ? value.split('_').first : value;
                          _raceController.text = raceName;
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: (_nameController.text.trim().isEmpty || _levelController.text.trim().isEmpty)
                        ? null
                        : () {
                            final level = int.tryParse(_levelController.text.trim());
                            if (level == null || level < 1 || level > 20) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid level between 1 and 20'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            
                            Navigator.pop(context);
                            viewModel.createCharacter(
                              name: _nameController.text.trim(),
                              level: level,
                              characterClass: _selectedClass,
                              subclass: _subclassController.text.trim().isEmpty
                                  ? null
                                  : _subclassController.text.trim(),
                              race: _raceController.text.trim().isEmpty
                                  ? null
                                  : _raceController.text.trim(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _getClassIcon(String className) {
    switch (className.toLowerCase()) {
      case 'fighter':
        return const Icon(Icons.gavel, color: Colors.red, size: 20);
      case 'wizard':
        return const Icon(Icons.auto_awesome, color: Colors.purple, size: 20);
      case 'cleric':
        return const Icon(Icons.favorite, color: Colors.yellow, size: 20);
      case 'rogue':
        return const Icon(Icons.visibility, color: Colors.grey, size: 20);
      case 'ranger':
        return const Icon(Icons.pets, color: Colors.green, size: 20);
      case 'paladin':
        return const Icon(Icons.security, color: Colors.blue, size: 20);
      case 'barbarian':
        return const Icon(Icons.fitness_center, color: Colors.brown, size: 20);
      case 'bard':
        return const Icon(Icons.music_note, color: Colors.pink, size: 20);
      case 'druid':
        return const Icon(Icons.nature, color: Colors.green, size: 20);
      case 'monk':
        return const Icon(Icons.sports_martial_arts, color: Colors.orange, size: 20);
      case 'sorcerer':
        return const Icon(Icons.local_fire_department, color: Colors.red, size: 20);
      case 'warlock':
        return const Icon(Icons.nightlight, color: Colors.purple, size: 20);
      case 'artificer':
        return const Icon(Icons.build, color: Colors.amber, size: 20);
      default:
        return const Icon(Icons.person, color: Colors.blue, size: 20);
    }
  }
}
