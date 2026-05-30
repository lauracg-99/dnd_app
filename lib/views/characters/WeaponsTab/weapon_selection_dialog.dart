import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../models/weapon_model.dart';
import '../../../viewmodels/weapons_viewmodel.dart';
import '../../../utils/source_mapper.dart';
import '../../../widgets/appfilter_chip.dart';

class WeaponSelectionResult {
  final Weapon weapon;
  final String? customAttackBonus;
  final String? customDamage;

  WeaponSelectionResult({
    required this.weapon,
    this.customAttackBonus,
    this.customDamage,
  });
}

class WeaponSelectionDialog extends StatefulWidget {
  const WeaponSelectionDialog({Key? key}) : super(key: key);

  @override
  _WeaponSelectionDialogState createState() => _WeaponSelectionDialogState();
}

class _WeaponSelectionDialogState extends State<WeaponSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';
  bool _isLoading = false;
  final Set<Weapon> _selectedWeapons = <Weapon>{};
  final Map<String, String> _customAttackBonuses = <String, String>{};
  final Map<String, String> _customDamages = <String, String>{};
  final Map<String, TextEditingController> _attackBonusControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _damageModifierControllers =
      <String, TextEditingController>{};

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
    // Dispose all controllers
    for (final controller in _attackBonusControllers.values) {
      controller.dispose();
    }
    for (final controller in _damageModifierControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Calculates total damage by combining weapon base damage with user modifier
  String _calculateTotalDamage(Weapon weapon, String userModifier) {
    if (userModifier.isEmpty) return _getWeaponBaseDamage(weapon);

    // Extract numeric value from user input (handles +4, -2, 3, etc.)
    final modifierValue = _extractNumericValue(userModifier);

    // Get weapon's base damage (e.g., "2d6")
    final baseDamage = _getWeaponBaseDamage(weapon);

    if (baseDamage.isEmpty) return '';

    // Format as "2d6 + 4" or "1d8 - 2"
    if (modifierValue > 0) {
      return '$baseDamage + $modifierValue';
    } else if (modifierValue < 0) {
      return '$baseDamage - ${modifierValue.abs()}';
    } else {
      return baseDamage;
    }
  }

  String _getWeaponBaseDamage(Weapon weapon) {
    if (weapon.damageDice.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < weapon.damageDice.length; i++) {
      if (i > 0) buffer.write(' + ');
      final dice = weapon.damageDice[i];
      buffer.write('${dice.diceAmount}${dice.diceType}');
    }
    return buffer.toString();
  }

  /// Calculates the total attack bonus by combining weapon bonus with user input
  String _calculateTotalAttackBonus(Weapon weapon, String userInput) {
    if (userInput.isEmpty) return '';

    // Extract numeric value from user input (handles +3, -2, 5, etc.)
    final userBonus = _extractNumericValue(userInput);

    // Get weapon's base attack bonus (this would need to be calculated based on character stats)
    // For now, we'll assume 0 since we don't have character context in this dialog
    final weaponBaseBonus = 0;

    final total = userBonus + weaponBaseBonus;
    return total >= 0 ? '+$total' : '$total';
  }

  /// Extracts numeric value from attack bonus string
  int _extractNumericValue(String bonusString) {
    final cleanString = bonusString.replaceAll(RegExp(r'[^\d-]'), '');
    return int.tryParse(cleanString) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          minWidth: 350,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          minHeight: 400,
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Symbols.swords),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Select Weapons',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_selectedWeapons.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedWeapons.length} selected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade400),
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
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
                final hasActiveFilters =
                    viewModel.searchQuery.isNotEmpty ||
                    viewModel.selectedType != 'All';
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
                          Icon(
                            Icons.filter_list,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Clear All',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (viewModel.searchQuery.isNotEmpty)
                            AppFilterChip(
                              label: 'Search: "${viewModel.searchQuery}"',
                              onClear: () {
                                _searchController.clear();
                                _updateSearchQuery('');
                              },
                            ),
                          if (viewModel.selectedType != 'All')
                            AppFilterChip(
                              label: 'Type: ${_getFormattedSelectedType()}',
                              onClear: () {
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
                      children:
                          types
                              .map(
                                (type) => _buildTypeChip(
                                  type,
                                  viewModel.getFormattedTypeForFilter(type),
                                ),
                              )
                              .toList(),
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

            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _selectedWeapons.isNotEmpty
                              ? () {
                                // Create result objects with calculated values
                                final results =
                                    _selectedWeapons.map((weapon) {
                                      final attackBonusController =
                                          _attackBonusControllers[weapon.id]!;
                                      final damageModifierController =
                                          _damageModifierControllers[weapon
                                              .id]!;

                                      return WeaponSelectionResult(
                                        weapon: weapon,
                                        customAttackBonus:
                                            attackBonusController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : attackBonusController.text
                                                    .trim(),
                                        customDamage:
                                            damageModifierController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _calculateTotalDamage(
                                                  weapon,
                                                  damageModifierController.text
                                                      .trim(),
                                                ),
                                      );
                                    }).toList();
                                Navigator.pop(context, results);
                              }
                              : null,
                      icon: const Icon(Icons.add),
                      label: Text(
                        _selectedWeapons.isEmpty
                            ? 'Add Weapons'
                            : 'Add ${_selectedWeapons.length} Weapons',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
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

  Widget _buildWeaponTile(Weapon weapon) {
    final isSelected = _selectedWeapons.contains(weapon);

    // Initialize custom values and controllers if not already set
    if (!_customAttackBonuses.containsKey(weapon.id)) {
      _customAttackBonuses[weapon.id] = ''; // Empty means use calculated value
      _attackBonusControllers[weapon.id] = TextEditingController();
    }
    if (!_customDamages.containsKey(weapon.id)) {
      _customDamages[weapon.id] = ''; // Empty means use weapon damage
      _damageModifierControllers[weapon.id] = TextEditingController();
    }

    final attackBonusController = _attackBonusControllers[weapon.id]!;
    final damageModifierController = _damageModifierControllers[weapon.id]!;
    final currentAttackTotal = _calculateTotalAttackBonus(
      weapon,
      attackBonusController.text,
    );
    final currentDamageTotal = _calculateTotalDamage(
      weapon,
      damageModifierController.text,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.blue.shade50 : Colors.white,
      ),
      child: Column(
        children: [
          // Main weapon info
          ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedWeapons.add(weapon);
                  } else {
                    _selectedWeapons.remove(weapon);
                  }
                });
              },
              activeColor: Colors.blue.shade700,
            ),
            title: Text(
              weapon.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue.shade700 : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${weapon.formattedType}'),
                Text('Base Damage: ${_getWeaponBaseDamage(weapon)}'),
                if (weapon.formattedProperties != 'No special properties')
                  Text(
                    'Properties: ${weapon.formattedProperties}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            onTap: () {
              setState(() {
                if (_selectedWeapons.contains(weapon)) {
                  _selectedWeapons.remove(weapon);
                } else {
                  _selectedWeapons.add(weapon);
                }
              });
            },
          ),

          // Custom fields (only show when selected)
          if (isSelected) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: attackBonusController,
                          decoration: InputDecoration(
                            labelText: 'Attack Bonus',
                            hintText: 'e.g., +6, +5, -1',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue.shade400,
                              ),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            _customAttackBonuses[weapon.id] = value.trim();
                            setState(() {}); // Update to show new total
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: damageModifierController,
                          decoration: InputDecoration(
                            labelText: 'Damage Modifier',
                            hintText: 'e.g., +4, +2, -1',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue.shade400,
                              ),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            _customDamages[weapon.id] = value.trim();
                            setState(() {}); // Update to show new total
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Show calculated totals
                  Row(
                    children: [
                      if (currentAttackTotal.isNotEmpty)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Total Attack: $currentAttackTotal',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      if (currentAttackTotal.isNotEmpty &&
                          currentDamageTotal.isNotEmpty)
                        const SizedBox(width: 8),
                      if (currentDamageTotal.isNotEmpty)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Total Damage: $currentDamageTotal',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Attack: Strength/Dex + proficiency + other bonuses | Damage: Strength/Dex modifier',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
