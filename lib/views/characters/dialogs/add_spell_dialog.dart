import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/spell_model.dart';
import '../../../viewmodels/spells_viewmodel.dart';

/// Dialog for adding spells to a character
/// 
/// Allows filtering spells by:
/// - Character class (toggle)
/// - Spell level
/// - Class
/// - School of magic
class AddSpellDialog extends StatefulWidget {
  final String characterName;
  final String characterClass;
  final List<String> currentSpells;
  final Function(List<String>) onSpellsAdded;

  const AddSpellDialog({
    super.key,
    required this.characterName,
    required this.characterClass,
    required this.currentSpells,
    required this.onSpellsAdded,
  });

  @override
  State<AddSpellDialog> createState() => _AddSpellDialogState();
}

class _AddSpellDialogState extends State<AddSpellDialog> {
  final Set<String> _selectedSpells = <String>{};
  bool _filterByCharacterClass = true;
  String? _selectedLevelFilter;
  String? _selectedClassFilter;
  String? _selectedSchoolFilter;

  @override
  void initState() {
    super.initState();
    // Load spells when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellsViewModel>().loadSpells();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: 600,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            _buildFilters(),
            const Divider(height: 1),
            _buildSpellsList(),
            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Add Spells to ${widget.characterName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_selectedSpells.isNotEmpty)
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
                '${_selectedSpells.length} selected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter by character class toggle
          Row(
            children: [
              Switch(
                value: _filterByCharacterClass,
                onChanged: (value) {
                  setState(() {
                    _filterByCharacterClass = value;
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Only show ${widget.characterClass} spells',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filter dropdowns
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildLevelFilter()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildClassFilter()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildSchoolFilter()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilter() {
    return Consumer<SpellsViewModel>(
      builder: (context, spellsViewModel, child) {
        final levels = [
          'All',
          'Cantrips',
          'Level 1',
          'Level 2',
          'Level 3',
          'Level 4',
          'Level 5',
          'Level 6',
          'Level 7',
          'Level 8',
          'Level 9',
        ];
        return DropdownButtonFormField<String>(
          value: _selectedLevelFilter ?? 'All',
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Level',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
          items: levels.map((level) {
            return DropdownMenuItem(
              value: level,
              child: Text(
                level,
                style: const TextStyle(fontSize: 11),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLevelFilter = value == 'All' ? null : value;
            });
          },
        );
      },
    );
  }

  Widget _buildClassFilter() {
    return Consumer<SpellsViewModel>(
      builder: (context, spellsViewModel, child) {
        final classes = [
          'All',
          ...spellsViewModel.spells
              .map((s) => s.classes)
              .expand((c) => c)
              .toSet()
              .toList()
            ..sort(),
        ];
        return DropdownButtonFormField<String>(
          value: _selectedClassFilter ?? 'All',
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Class',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
          items: classes.map((className) {
            final displayName = className == 'All'
                ? 'All'
                : className
                    .split('_')
                    .map(
                      (word) => word.isNotEmpty
                          ? word[0].toUpperCase() + word.substring(1)
                          : '',
                    )
                    .join(' ');
            return DropdownMenuItem(
              value: className,
              child: Text(
                displayName.length > 15
                    ? '${displayName.substring(0, 15)}...'
                    : displayName,
                style: const TextStyle(fontSize: 11),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedClassFilter = value == 'All' ? null : value;
            });
          },
        );
      },
    );
  }

  Widget _buildSchoolFilter() {
    return Consumer<SpellsViewModel>(
      builder: (context, spellsViewModel, child) {
        final schools = [
          'All',
          ...spellsViewModel.spells
              .map((s) => s.schoolName)
              .toSet()
              .toList()
            ..sort(),
        ];
        return DropdownButtonFormField<String>(
          value: _selectedSchoolFilter ?? 'All',
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'School',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
          items: schools.map((school) {
            return DropdownMenuItem(
              value: school,
              child: Text(
                school
                    .split('_')
                    .map(
                      (word) => word.isNotEmpty
                          ? word[0].toUpperCase() + word.substring(1)
                          : '',
                    )
                    .join(' '),
                style: const TextStyle(fontSize: 11),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSchoolFilter = value == 'All' ? null : value;
            });
          },
        );
      },
    );
  }

  Widget _buildSpellsList() {
    return Expanded(
      child: Consumer<SpellsViewModel>(
        builder: (context, spellsViewModel, child) {
          if (spellsViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (spellsViewModel.error != null) {
            return Center(
              child: Text('Error: ${spellsViewModel.error}'),
            );
          }

          // Apply filters
          final filteredSpells = _applyFilters(spellsViewModel.spells);

          if (filteredSpells.isEmpty) {
            return const Center(
              child: Text('No spells found with current filters'),
            );
          }

          return ListView.builder(
            itemCount: filteredSpells.length,
            itemBuilder: (context, index) {
              final spell = filteredSpells[index];
              final isKnown = widget.currentSpells.contains(spell.name);
              final isSelected = _selectedSpells.contains(spell.name);

              return CheckboxListTile(
                value: isSelected,
                onChanged: isKnown
                    ? null
                    : (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedSpells.add(spell.name);
                          } else {
                            _selectedSpells.remove(spell.name);
                          }
                        });
                      },
                title: Text(
                  spell.name,
                  style: TextStyle(
                    color: isKnown ? Colors.grey : null,
                    decoration: isKnown ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  '${_formatSchoolName(spell.schoolName)} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                secondary: isKnown
                    ? const Icon(Icons.check, color: Colors.green)
                    : Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                enabled: !isKnown,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Expanded(
            child: Text(
              '${widget.currentSpells.length} spells known',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: _selectedSpells.isEmpty
                ? null
                : () {
                    widget.onSpellsAdded(_selectedSpells.toList());
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added ${_selectedSpells.length} spell${_selectedSpells.length == 1 ? '' : 's'} to ${widget.characterName}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
            child: Text(
              'Add ${_selectedSpells.isEmpty ? 'Spells' : '${_selectedSpells.length} Spell${_selectedSpells.length == 1 ? '' : 's'}'}',
            ),
          ),
        ],
      ),
    );
  }

  List<Spell> _applyFilters(List<Spell> spells) {
    return spells.where((spell) {
      // Filter by character class if enabled
      if (_filterByCharacterClass) {
        final characterClass = widget.characterClass.toLowerCase();
        if (!spell.classes.any(
          (className) => className.toLowerCase() == characterClass,
        )) {
          return false;
        }
      }

      // Filter by level
      if (_selectedLevelFilter != null) {
        if (_selectedLevelFilter == 'Cantrips') {
          if (spell.levelNumber != 0) return false;
        } else if (_selectedLevelFilter!.startsWith('Level')) {
          final level = int.tryParse(_selectedLevelFilter!.split(' ')[1]);
          if (spell.levelNumber != level) return false;
        }
      }

      // Filter by class
      if (_selectedClassFilter != null) {
        if (!spell.classes.contains(_selectedClassFilter)) {
          return false;
        }
      }

      // Filter by school
      if (_selectedSchoolFilter != null) {
        if (spell.schoolName != _selectedSchoolFilter) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  String _formatSchoolName(String schoolName) {
    return schoolName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
