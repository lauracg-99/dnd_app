import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/character_model.dart';
import '../../viewmodels/characters_viewmodel.dart';
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

  List<Widget> _buildFilterControls(CharactersViewModel viewModel) {
    return [
      const SizedBox(height: 8),
      // Class filter
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
          child: character.customImagePath != null
              ? ClipOval(
                  child: Image.asset(
                    character.customImagePath!,
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
          '${character.characterClass}${character.subclass != null ? ' (${character.subclass})' : ''}',
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
          itemBuilder: (context) => [
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Character'),
        content: Text('Are you sure you want to delete ${character.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CharactersViewModel>().deleteCharacter(character.id);
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
  String _selectedClass = 'Fighter';
  final _subclassController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _subclassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<CharactersViewModel>();
    
    return AlertDialog(
      title: const Text('Create New Character'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Character Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(
                labelText: 'Class',
                border: OutlineInputBorder(),
              ),
              items: viewModel.availableClasses.map((className) {
                return DropdownMenuItem(
                  value: className,
                  child: Text(className),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClass = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subclassController,
              decoration: const InputDecoration(
                labelText: 'Subclass (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.trim().isEmpty
              ? null
              : () {
                  Navigator.pop(context);
                  viewModel.createCharacter(
                    name: _nameController.text.trim(),
                    characterClass: _selectedClass,
                    subclass: _subclassController.text.trim().isEmpty
                        ? null
                        : _subclassController.text.trim(),
                  );
                },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
