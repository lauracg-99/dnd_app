import 'package:dnd_app/l10n/app_localizations.dart';
import 'package:dnd_app/services/dice_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/spell_model.dart';
import '../../viewmodels/spells_viewmodel.dart';
import '../../widgets/detail_row.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dndSpells),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color:
                    _isFilterExpanded
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
              onPressed: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
                // Debug print to verify button is working
                debugPrint(
                  'Filter button pressed. Expanded: $_isFilterExpanded',
                );
              },
              tooltip: l10n.filterSpells,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isFilterExpanded ? 280 : 80),
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
        final l10n = AppLocalizations.of(context)!;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchSpells,
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
              if (_isFilterExpanded) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(children: _buildFilterControls(viewModel)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFilterControls(SpellsViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    return [
      const SizedBox(height: 8),
      // Level filter
      SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Text(
              '${l10n.levelFilter} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            FilterChip(
              label: Text(l10n.all),
              selected: viewModel.selectedLevel == null,
              onSelected: (_) => viewModel.setSelectedLevel(null),
            ),
            ...viewModel.availableLevels.map((level) {
              final label = level == 0 ? l10n.cantrip : l10n.levelLabel(level);
              return Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: FilterChip(
                  label: Text(label),
                  selected: viewModel.selectedLevel == level,
                  onSelected: (_) => viewModel.setSelectedLevel(level),
                ),
              );
            }),
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
            Text(
              '${l10n.classFilter} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            FilterChip(
              label: Text(l10n.all),
              selected: viewModel.selectedClass.isEmpty,
              onSelected: (_) => viewModel.setSelectedClass(''),
            ),
            ...viewModel.availableClasses.map((className) {
              return Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: FilterChip(
                  label: Text(
                    className
                        .split('_')
                        .map((s) => s[0].toUpperCase() + s.substring(1))
                        .join(' '),
                  ),
                  selected: viewModel.selectedClass == className,
                  onSelected: (_) => viewModel.setSelectedClass(className),
                ),
              );
            }),
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
            Text(
              '${l10n.schoolFilter} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            FilterChip(
              label: Text(l10n.all),
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
            }),
          ],
        ),
      ),
    ];
  }

  Widget _buildErrorView(SpellsViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('${l10n.error}: ${viewModel.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.loadSpells,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.noSpellsFound),
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
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        level == 0 ? l10n.cantrip : l10n.levelLabel(level),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Build a single spell item
  Widget _buildSpellItem(Spell spell, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SelectionArea(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: ListTile(
          title: Text(spell.name),
          subtitle: Text(
            '${spell.schoolName.capitalize()} ${spell.levelNumber == 0 ? l10n.cantrip : l10n.levelLabel(spell.levelNumber)}${spell.ritual ? ' (${l10n.ritual})' : ''}'
                .trim(),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showSpellDetails(context, spell);
          },
        ),
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
      itemCount +=
          1 + groupedSpells[level]!.length; // 1 for header + number of spells
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
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (_, controller) => SelectionArea(
                  child: SingleChildScrollView(
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
                            '${spell.schoolName.capitalize()} ${spell.levelNumber == 0 ? l10n.cantrip : l10n.levelLabel(spell.levelNumber)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),

                          DetailRow(
                            label: l10n.castingTime,
                            value: spell.castingTime,
                          ),
                          DetailRow(label: l10n.range, value: spell.range),
                          DetailRow(
                            label: l10n.components,
                            value: _formatComponents(spell),
                          ),
                          DetailRow(label: l10n.duration, value: spell.duration),
                          if (spell.ritual)
                            DetailRow(label: l10n.ritual, value: l10n.yes),
                          DetailRow(
                            label: l10n.classes,
                            value: spell.classes
                                .map((c) => c.capitalize().replaceAll('_', ' '))
                                .join(', '),
                          ),
                          const Divider(),
                          const SizedBox(height: 5),
                          DetailRow(label: l10n.descriptionLabel, value: ''),
                          Text(
                            spell.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (spell.higherLevelDescription != null &&
                              spell.higherLevelDescription!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            DetailRow(label: l10n.atHigherLevels, value: ''),
                            Text(
                              spell.higherLevelDescription ?? '',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
