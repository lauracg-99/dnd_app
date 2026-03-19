import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/weapon_model.dart';
import '../../../viewmodels/weapons_viewmodel.dart';
import '../../../utils/source_mapper.dart';

class WeaponSelectionDialog extends StatefulWidget {
  const WeaponSelectionDialog({Key? key}) : super(key: key);

  @override
  _WeaponSelectionDialogState createState() => _WeaponSelectionDialogState();
}

class _WeaponSelectionDialogState extends State<WeaponSelectionDialog> {
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
    return Dialog(
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
                  const Icon(Icons.gavel),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Select a Weapon',
                      style: TextStyle(
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
            
            // Search and filters
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
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _updateSearchQuery('');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  _updateSearchQuery(value);
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
                              _updateSearchQuery('');
                              _updateSelectedType('All');
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
                                _updateSearchQuery('');
                              },
                            ),
                          if (viewModel.selectedType != 'All')
                            _buildFilterChip(
                              'Type: ${_getFormattedSelectedType()}',
                              () {
                                _updateSelectedType('All');
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer<WeaponsViewModel>(
                builder: (context, viewModel, child) {
                  final types = viewModel.getAvailableFormattedTypes();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTypeChip('All', 'All'),
                        ...types.map((type) => _buildTypeChip(type, viewModel.getFormattedTypeForFilter(type))),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Weapons list
            Expanded(
              child: Consumer<WeaponsViewModel>(
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

                  return ListView.builder(
                    itemCount: weapons.length,
                    itemBuilder: (context, index) {
                      final weapon = weapons[index];
                      return _buildWeaponTile(weapon);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeaponTile(Weapon weapon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          _getWeaponIcon(weapon.type),
          color: Colors.grey.shade700,
        ),
      ),
      title: Text(
        weapon.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${weapon.formattedType}'),
          Text('Damage: ${weapon.formattedDamage}'),
          if (weapon.formattedProperties != 'No special properties')
            Text('Properties: ${weapon.formattedProperties}', style: const TextStyle(fontSize: 12)),
        ],
      ),
      trailing: const Icon(Icons.add_circle_outline),
      onTap: () {
        Navigator.pop(context, weapon);
      },
    );
  }

  Widget _buildTypeChip(String label, String value) {
    return Consumer<WeaponsViewModel>(
      builder: (context, viewModel, child) {
        final isSelected = viewModel.selectedType == value;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (selected) {
              _updateSelectedType(selected ? value : 'All');
            },
            backgroundColor: Colors.grey.shade200,
            selectedColor: Colors.blue.shade100,
            checkmarkColor: Colors.blue.shade700,
          ),
        );
      },
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

  IconData _getWeaponIcon(String type) {
    switch (type.toLowerCase()) {
      case 'simple_melee':
      case 'martial_melee':
        return Icons.sports_martial_arts;
      case 'simple_ranged':
      case 'martial_ranged':
        return Icons.gps_fixed;
      default:
        return Icons.gavel;
    }
  }

  void _updateSearchQuery(String query) {
    context.read<WeaponsViewModel>().setSearchQuery(query);
  }

  void _updateSelectedType(String type) {
    setState(() {
      _selectedType = type;
    });
    context.read<WeaponsViewModel>().setSelectedType(type);
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
