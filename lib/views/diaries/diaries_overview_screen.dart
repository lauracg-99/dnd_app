import 'package:dnd_app/views/characters/character_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../viewmodels/characters_viewmodel.dart';
import '../../models/character_model.dart';
import '../../utils/image_utils.dart';
import 'diary_list_screen.dart';

class DiariesOverviewScreen extends StatefulWidget {
  const DiariesOverviewScreen({super.key});

  @override
  State<DiariesOverviewScreen> createState() => _DiariesOverviewScreenState();
}

class _DiariesOverviewScreenState extends State<DiariesOverviewScreen> {
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
        title: const Text('Character Diaries'),
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
          const Text(
            'No characters found. \n Create your first character to start writing diaries!',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {              
              _navigateToCreateCharacter();
            },
            child: const Text('Go to Characters'),
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
        return _buildCharacterDiaryCard(character, context);
      },
    );
  }

  Widget _buildCharacterDiaryCard(Character character, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(child: _buildCharacterImage(character)),
        title: Text(
          character.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${character.characterClass}${character.subclass != null && character.subclass!.isNotEmpty ? ' (${character.subclass})' : ''}${character.race != null && character.race!.isNotEmpty ? ' • ${character.race}' : ''}',
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.book, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'View diary entries',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryListScreen(character: character),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCharacterImage(Character character) {
    // Prioritize base64 data if available
    if (character.customImageData != null &&
        character.customImageData!.isNotEmpty) {
      final imageBytes = ImageUtils.base64ToImageBytes(
        character.customImageData,
      );
      if (imageBytes != null) {
        return ClipOval(
          child: Image.memory(
            imageBytes,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person);
            },
          ),
        );
      }
    }

    // Fallback to file path if base64 is not available
    if (character.customImagePath != null &&
        character.customImagePath!.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(character.customImagePath!),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person);
          },
        ),
      );
    }

    // Default icon if no image is available
    return const Icon(Icons.person);
  }

  void _navigateToCreateCharacter() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CharacterCreateScreen()),
    );
  }
}
