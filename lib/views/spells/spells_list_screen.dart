import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/spell_model.dart';
import '../../viewmodels/spells_viewmodel.dart';
import '../debug/debug_screen.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DebugScreen()),
          );
        },
        tooltip: 'Debug Tools',
        child: const Icon(Icons.bug_report),
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

  Widget _buildSpellsList(SpellsViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.spells.length,
      itemBuilder: (context, index) {
        final spell = viewModel.spells[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(spell.name),
            subtitle: Text(
              '${spell.schoolName.capitalize()} ${spell.levelNumber == 0 ? 'Cantrip' : 'Level ${spell.levelNumber}'}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showSpellDetails(context, spell);
            },
          ),
        );
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
