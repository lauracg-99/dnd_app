import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/weapons_viewmodel.dart';
import '../../../models/weapon_model.dart';
import '../../../utils/source_mapper.dart';
import 'package:material_symbols_icons/symbols.dart';

class WeaponsScreen extends StatefulWidget {
  const WeaponsScreen({Key? key}) : super(key: key);

  @override
  _WeaponsScreenState createState() => _WeaponsScreenState();
}

class _WeaponsScreenState extends State<WeaponsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Schedule the loading to happen after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeapons();
    });
  }

  Future<void> _loadWeapons() async {
    if (!mounted) return; // Safety check
    setState(() => _isLoading = true);
    final viewModel = context.read<WeaponsViewModel>();
    await viewModel.loadWeapons();
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
        title: const Text('Weapons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<WeaponsViewModel>(
        builder: (context, viewModel, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWeapons,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final weapons = viewModel.weapons;
          if (weapons.isEmpty) {
            return const Center(child: Text('No weapons found'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search weapons...',
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
                  onChanged: (value) {
                    viewModel.setSearchQuery(value);
                  },
                ),
              ),
              // Active filters display
              Consumer<WeaponsViewModel>(
                builder: (context, viewModel, child) {
                  final hasActiveFilters = viewModel.searchQuery.isNotEmpty || viewModel.selectedType != 'All';
                  if (!hasActiveFilters) return const SizedBox.shrink();
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.filter_list, size: 16, color: Colors.blue.shade700),
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
                                _searchController.clear();
                                viewModel.setSearchQuery('');
                                viewModel.setSelectedType('All');
                                setState(() {
                                  _selectedType = 'All';
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Clear All', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (viewModel.searchQuery.isNotEmpty)
                              _buildFilterChip(
                                'Search: "${viewModel.searchQuery}"',
                                () {
                                  _searchController.clear();
                                  viewModel.setSearchQuery('');
                                },
                              ),
                            if (viewModel.selectedType != 'All')
                              _buildFilterChip(
                                'Type: ${_getFormattedSelectedType()}',
                                () {
                                  setState(() {
                                    _selectedType = 'All';
                                  });
                                  viewModel.setSelectedType('All');
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: weapons.length,
                  itemBuilder: (context, index) {
                    final weapon = weapons[index];
                    return _buildWeaponCard(weapon);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeaponCard(Weapon weapon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(        
        title: Text(
          weapon.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${weapon.formattedType}'),
            Text('Damage: ${weapon.formattedDamage}'),
          ],
        ),        
        onTap: () {
          _showWeaponDetailSheet(weapon);
        },
      ),
    );
  }

  IconData _getRarityIcon(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Icons.circle;
      case 'uncommon':
        return Icons.star;
      case 'rare':
        return Icons.diamond;
      case 'very rare':
        return Icons.emoji_events;
      case 'legendary':
        return Icons.military_tech;
      default:
        return Icons.circle;
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'very rare':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showWeaponDetailSheet(Weapon weapon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Row(
                children: [
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
              const SizedBox(height: 24),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSheetSection('Type', weapon.formattedType),
                      const SizedBox(height: 16),
                      if (weapon.rarity != 'none')
                        _buildSheetSection('Rarity', weapon.rarity.toUpperCase()),
                      const SizedBox(height: 16),
                      _buildSheetSection('Source', '${SourceMapper.getFullBookName(weapon.source)}${weapon.isCore ? ' • Core' : ''}'),
                      const SizedBox(height: 16),

                      // Damage Information
                      if (weapon.damageDice.isNotEmpty) ...[
                        _buildSheetSection('Damage', weapon.formattedDamage),
                        const SizedBox(height: 16),
                      ],

                      // Properties
                      _buildSheetSection('Properties', weapon.formattedProperties),
                      const SizedBox(height: 16),

                      // Cost and Weight
                      Row(
                        children: [
                          Expanded(
                            child: _buildSheetSection('Weight', '${weapon.weight} lb'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Thrown Range (if applicable)
                      if (weapon.isThrown && weapon.thrownRange != null) ...[
                        _buildSheetSection('Thrown Range', weapon.thrownRange!),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onClear) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close,
              size: 14,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final viewModel = context.read<WeaponsViewModel>();
        final types = viewModel.getAvailableFormattedTypes();

        return AlertDialog(
          title: const Text('Filter Weapons'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weapon Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...types.map(
                  (type) => RadioListTile<String>(
                    title: Text(type),
                    value: type,
                    groupValue: _getFormattedSelectedType(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = viewModel.getFormattedTypeForFilter(value!);
                      });
                      viewModel.setSelectedType(viewModel.getFormattedTypeForFilter(value!));
                      Navigator.pop(context);
                    },
                  ),
                ),
                if (types.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = 'All';
                      });
                      viewModel.setSelectedType('All');
                      Navigator.pop(context);
                    },
                    child: const Text('Clear Filter'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFormattedSelectedType() {
    final viewModel = context.read<WeaponsViewModel>();
    if (_selectedType == 'All') return 'All';
    
    // Find the formatted type that matches the current raw type
    for (final weapon in viewModel.weapons) {
      if (weapon.type == _selectedType) {
        return weapon.formattedType;
      }
    }
    return _selectedType;
  }
}
