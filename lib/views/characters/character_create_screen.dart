import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../viewmodels/races_viewmodel.dart';
import '../../viewmodels/backgrounds_viewmodel.dart';
import '../../models/race_model.dart';

class CharacterCreateScreen extends StatefulWidget {
  const CharacterCreateScreen({super.key});

  @override
  State<CharacterCreateScreen> createState() => _CharacterCreateScreenState();
}

class _CharacterCreateScreenState extends State<CharacterCreateScreen> {
  final _nameController = TextEditingController();
  final _levelController = TextEditingController(text: '1');
  String _selectedClass = 'Fighter';
  final _subclassController = TextEditingController();
  final _raceController = TextEditingController();
  final _backgroundController = TextEditingController();
  bool _useCustomSubclass = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load races and backgrounds data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RacesViewModel>().loadRaces();
      context.read<BackgroundsViewModel>().loadBackgrounds();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _subclassController.dispose();
    _raceController.dispose();
    _backgroundController.dispose();
    super.dispose();
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
          'Crown',
          'Oathbreaker',
          'Glory',
          'Watchers',
        ];
      case 'barbarian':
        return [
          'Path of the Berserker',
          'Path of the Totem Warrior',
          'Path of the Zealot',
          'Path of the Wild Magic',
          'Path of the Beast',
          'Path of the Storm Herald',
          'Path of the Battlerager',
        ];
      case 'bard':
        return [
          'College of Lore',
          'College of Valor',
          'College of Glamour',
          'College of Swords',
          'College of Whispers',
          'College of Creation',
        ];
      case 'druid':
        return [
          'Circle of the Land',
          'Circle of the Moon',
          'Circle of the Shepherd',
          'Circle of Spores',
          'Circle of Stars',
          'Circle of Wildfire',
        ];
      case 'monk':
        return [
          'Way of the Open Hand',
          'Way of Shadow',
          'Way of the Four Elements',
          'Way of Mercy',
          'Way of the Drunken Master',
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
          'The Fathomless',
          'The Genie',
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

  Future<void> _createCharacter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    final viewModel = context.read<CharactersViewModel>();
    
    await viewModel.createCharacter(
      name: _nameController.text.trim(),
      level: level,
      characterClass: _selectedClass,
      subclass: _subclassController.text.trim().isEmpty
          ? null
          : _subclassController.text.trim(),
      race: _raceController.text.trim().isEmpty
          ? null
          : _raceController.text.trim(),
      background: _backgroundController.text.trim().isEmpty
          ? null
          : _backgroundController.text.trim(),
    );

    if (viewModel.error == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Character'),
      ),
      body: Consumer<CharactersViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 4),
                            Text(
                              'Fill in the details below to create your character',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
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
                    child: TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Character name is required';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Character Name *',
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
                    child: TextFormField(
                      controller: _levelController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Character level is required';
                        }
                        final level = int.tryParse(value.trim());
                        if (level == null || level < 1 || level > 20) {
                          return 'Level must be between 1 and 20';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Character Level *',
                        //prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.green),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(18),
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
                        labelText: 'Class *',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      items: viewModel.availableClasses.map((className) {
                        return DropdownMenuItem(
                          value: className,
                          child: Row(
                            children: [
/*                               _getClassIcon(className), */
                              const SizedBox(width: 3),
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
                      child: TextFormField(
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
                  const SizedBox(height: 16),

                  // Background selection
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
                    child: Consumer<BackgroundsViewModel>(
                      builder: (context, backgroundsViewModel, child) {
                        return DropdownButtonFormField<String>(
                          value: _backgroundController.text.isEmpty ? null : _backgroundController.text,
                          decoration: const InputDecoration(
                            labelText: 'Background (Optional)',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          isExpanded: true,
                          items: [
                            if (_backgroundController.text.isNotEmpty)
                              DropdownMenuItem(
                                value: '__CLEAR__',
                                child: Row(
                                  children: [
                                    Icon(Icons.clear, color: Colors.red, size: 20),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        'Clear Background',
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
                            ...backgroundsViewModel.backgrounds.map((background) {
                              return DropdownMenuItem(
                                value: background.name,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        background.name,
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
                                _backgroundController.text = '';
                              } else {
                                _backgroundController.text = value ?? '';
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error message
                  if (viewModel.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.error!,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: viewModel.isLoading ? null : _createCharacter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: viewModel.isLoading 
                                  ? LinearGradient(
                                      colors: [Colors.grey.shade400, Colors.grey.shade500],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [Colors.blue.shade500, Colors.blue.shade700],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                child: viewModel.isLoading
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Creating...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [                                          
                                          const Text(
                                            'Create Character',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
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
