import 'package:dnd_app/views/characters/character_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../models/character_model.dart';
import '../../widgets/character_card.dart';
import 'diary_list_screen.dart';

class DiariesOverviewScreen extends StatefulWidget {
  const DiariesOverviewScreen({super.key});

  @override
  State<DiariesOverviewScreen> createState() => _DiariesOverviewScreenState();
}

class _DiariesOverviewScreenState extends State<DiariesOverviewScreen> {
  final _searchController = TextEditingController();

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
        backgroundColor: const Color.fromARGB(255, 209, 161, 216),
        title: const Text('Character Diaries'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10),
            child: const SizedBox(),
          ),
      ),
      body: Consumer<CharactersViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildSearchAndFilters(),
              Expanded(
                child: Builder(
                  builder: (context) {
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
              ),
            ],
          );
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
            ],
          ),
        );
      },
    );
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
    return CharacterCard(
      character: character,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
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
          const SizedBox(height: 4),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryListScreen(character: character),
          ),
        );
      },
    );
  }

  void _navigateToCreateCharacter() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CharacterCreateScreen()),
    );
  }
}
