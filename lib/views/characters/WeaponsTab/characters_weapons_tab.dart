import 'package:dnd_app/utils/quill_toolbar_configs.dart';
import 'package:dnd_app/utils/simple_quill_editor.dart';
import 'package:dnd_app/utils/source_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import '../../../models/weapon_model.dart';
import '../../../viewmodels/weapons_viewmodel.dart';
import 'package:material_symbols_icons/symbols.dart';

class CharactersWeaponsTab extends StatefulWidget {
  final List<String> weapons;
  final QuillController weaponNotesController;
  final Function(List<String>) onWeaponsChanged;
  final Function() onAutoSaveCharacter;
  final String characterName;

  const CharactersWeaponsTab({
    super.key,
    required this.weapons,
    required this.weaponNotesController,
    required this.onWeaponsChanged,
    required this.onAutoSaveCharacter,
    required this.characterName,
  });

  @override
  State<CharactersWeaponsTab> createState() => _CharactersWeaponsTabState();
}

class _CharactersWeaponsTabState extends State<CharactersWeaponsTab> {
  late List<String> _weapons;
  late QuillController _weaponNotesController;
  String _searchQuery = '';
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _weapons = List.from(widget.weapons);
    _weaponNotesController = widget.weaponNotesController;
    
    // Load weapons when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WeaponsViewModel>().loadWeapons();
      }
    });
  }

  @override
  void didUpdateWidget(CharactersWeaponsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weapons != widget.weapons) {
      _weapons = List.from(widget.weapons);
    }
    if (oldWidget.weaponNotesController != widget.weaponNotesController) {
      _weaponNotesController = widget.weaponNotesController;
    }
  }

  void _updateWeapons(List<String> newWeapons) {
    setState(() {
      _weapons = newWeapons;
    });
    widget.onWeaponsChanged(_weapons);
    widget.onAutoSaveCharacter();
  }

  void _showAddWeaponDialog() {
    // Load weapons if not already loaded
    context.read<WeaponsViewModel>().loadWeapons();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Symbols.swords),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add Weapon to ${widget.characterName}',
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

              // Search and Filter
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search weapons by name...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    
                    // Type filter
                    Consumer<WeaponsViewModel>(
                      builder: (context, weaponsViewModel, child) {
                        final types = weaponsViewModel.getAvailableTypes();
                        return DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Filter by type',
                            border: OutlineInputBorder(),
                          ),
                          items: types.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value ?? 'All';
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Weapons list
              Expanded(
                child: Consumer<WeaponsViewModel>(
                  builder: (context, weaponsViewModel, child) {
                    if (weaponsViewModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (weaponsViewModel.error != null) {
                      return Center(
                        child: Text('Error: ${weaponsViewModel.error}'),
                      );
                    }

                    var filteredWeapons = weaponsViewModel.weapons;

                    // Apply search filter
                    if (_searchQuery.isNotEmpty) {
                      filteredWeapons = filteredWeapons
                          .where((weapon) => weapon.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();
                    }

                    // Apply type filter
                    if (_selectedType != 'All') {
                      filteredWeapons = filteredWeapons
                          .where((weapon) => weapon.type == _selectedType)
                          .toList();
                    }

                    if (filteredWeapons.isEmpty) {
                      return const Center(child: Text('No weapons found'));
                    }

                    return ListView.builder(
                      itemCount: filteredWeapons.length,
                      itemBuilder: (context, index) {
                        final weapon = filteredWeapons[index];
                        final isKnown = _weapons.contains(weapon.name);

                        return ListTile(
                          title: Text(weapon.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${weapon.type} • ${weapon.formattedDamage}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${weapon.cost} ${weapon.costUnit} • ${weapon.weight} lb',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
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
                                  final newWeapons = List<String>.from(_weapons);
                                  newWeapons.add(weapon.name);
                                  _updateWeapons(newWeapons);
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added ${weapon.name} to ${widget.characterName}',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
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
                      '${_weapons.length} weapons equipped',
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

  void _showWeaponDetails(Weapon weapon) {
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
                  const Icon(Symbols.swords, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      weapon.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Source and Core status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.book,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Source: ${SourceMapper.getFullBookName(weapon.source)}${weapon.isCore ? ' • Core' : ''}',
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

              // Weapon Type and Properties
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type: ${weapon.type}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Properties: ${weapon.formattedProperties}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Damage Information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Damage',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weapon.formattedDamage,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cost and Weight
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cost',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text('${weapon.cost} ${weapon.costUnit}'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weight',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text('${weapon.weight} lb'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rarity
              if (weapon.rarity != 'none')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.diamond,
                        size: 16,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rarity: ${weapon.rarity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (weapon.rarity != 'none') const SizedBox(height: 16),

              // Character info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Equipped by: ${widget.characterName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Character Weapons',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your character\'s weapons',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Weapons list
          Consumer<WeaponsViewModel>(
            builder: (context, weaponsViewModel, child) {
              if (weaponsViewModel.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (weaponsViewModel.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading weapons: ${weaponsViewModel.error}',
                          style: TextStyle(color: Colors.red.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => weaponsViewModel.loadWeapons(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: _weapons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final weaponName = entry.value;

                  // Try to find weapon details
                  final weapon = weaponsViewModel.weapons.firstWhere(
                    (w) => w.name.toLowerCase() == weaponName.toLowerCase(),
                    orElse: () => Weapon(
                      id: 'unknown',
                      name: weaponName,
                      source: 'Unknown',
                      isCore: false,
                      cost: 0,
                      costUnit: 'gold',
                      weight: 0,
                      type: 'unknown',
                      rarity: 'none',
                      isFinesse: false,
                      isThrown: false,
                      isLight: false,
                      damageDice: [],
                    ),
                  );

                  return Card(
                    child: ListTile(
                      title: InkWell(
                        child: Text(
                          weapon.name,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () => _showWeaponDetails(weapon),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weapon.type} • ${weapon.formattedDamage}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            SourceMapper.getFullBookName(weapon.source),
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          final newWeapons = List<String>.from(_weapons);
                          newWeapons.removeAt(index);
                          _updateWeapons(newWeapons);
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          TextButton.icon(
            onPressed: _showAddWeaponDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Weapon'),
          ),
          const SizedBox(height: 16),

          // Weapon Notes Section
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
                    'Additional notes about your weapons and combat equipment.',
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
                    child: SimpleQuillEditor(
                      controller: _weaponNotesController, 
                      toolbarConfig: QuillToolbarConfigs.minimal,
                      placeholder: 'Add notes about your weapons...\n\n',                           
                            height: 300,
                    )

                  ),                  
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
