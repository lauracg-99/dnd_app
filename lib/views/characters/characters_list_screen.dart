import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../viewmodels/characters_viewmodel.dart';
import '../../models/character_model.dart';
import '../../services/character_service.dart';
import '../../services/diary_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/cloud_sync_service.dart';
import 'character_edit_screen.dart';
import 'character_create_screen.dart';
import '../diaries/diary_list_screen.dart';
import '../auth/login_screen.dart';

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  bool _isFilterExpanded = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final CloudSyncService _syncService = CloudSyncService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Load characters when the screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharactersViewModel>().loadCharacters();
    });
    
    // Listen to auth state changes to refresh characters when user signs in/out
    _authService.authStateChanges.listen((user) {
      if (mounted) {
        // Add delays to ensure data is fully processed after sign-in
        // First immediate refresh
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            context.read<CharactersViewModel>().loadCharacters();
          }
        });
        
        // Second refresh after a longer delay for data download completion
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            context.read<CharactersViewModel>().loadCharacters();
          }
        });
        
        // Third refresh as a fallback
        Future.delayed(const Duration(milliseconds: 3000), () {
          if (mounted) {
            context.read<CharactersViewModel>().loadCharacters();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Refresh characters when app comes to foreground (after returning from login)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<CharactersViewModel>().loadCharacters();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('D&D Characters'),
        actions: [
          // Cloud sync button
          StreamBuilder<SyncStatus>(
            stream: _syncService.syncStatus,
            builder: (context, snapshot) {
              final syncStatus = snapshot.data ?? SyncStatus.disconnected;
              return IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      _authService.isAuthenticated ? Icons.cloud_done : Icons.cloud_upload,
                      color: _getSyncStatusColor(syncStatus),
                    ),
                    if (syncStatus == SyncStatus.syncing)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: _handleCloudButtonPressed,
                tooltip: _authService.isAuthenticated ? 'Cloud Sync Options' : 'Sign In & Sync',
              );
            },
          ),
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
        onPressed: _navigateToCreateCharacter,
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
          const Text('No characters found. Create your first character!'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _navigateToCreateCharacter,
            child: const Text('Create Character'),
          ),
          const SizedBox(height: 24),
          // Show login option if not authenticated
          if (!_authService.isAuthenticated) ...[
            const Divider(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    color: Colors.blue.shade700,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sync Across Devices',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to backup your data and access it from anywhere',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _navigateToLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade300),
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
          child:
              character.customImageData != null && character.customImageData!.isNotEmpty
                  ? ClipOval(
                    child: Image.memory(
                      base64Decode(character.customImageData!),
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
          '${character.characterClass}${character.subclass != null && character.subclass!.isNotEmpty ? ' (${character.subclass})' : ''}${character.race != null && character.race!.isNotEmpty ? ' • ${character.race}' : ''}',
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _navigateToEditCharacter(character);
                break;
              case 'diary':
                _navigateToDiary(character);
                break;
              case 'delete':
                _showDeleteConfirmation(character);
                break;
              case 'duplicate':
                _duplicateCharacter(character);
                break;
            }
          },
          itemBuilder:
              (context) => [
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
                  value: 'diary',
                  child: Row(
                    children: [
                      Icon(Icons.book),
                      SizedBox(width: 8),
                      Text('Diary'),
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

  void _navigateToDiary(Character character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryListScreen(character: character),
      ),
    );
  }

  void _navigateToCreateCharacter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CharacterCreateScreen(),
      ),
    );
  }

  void _showDeleteConfirmation(Character character) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Character'),
            content: Text(
              'Are you sure you want to delete ${character.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<CharactersViewModel>().deleteCharacter(
                    character.id,
                  );
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

    // Save the duplicated character and add it to the list
    CharacterService.saveCharacter(duplicatedCharacter).then((_) {
      // Reload the characters list to refresh the UI
      context.read<CharactersViewModel>().loadCharacters();
      // Schedule sync if authenticated
      if (_authService.isAuthenticated) {
        _syncService.scheduleCharacterSync();
      }
    });
  }

  /// Handle cloud button press based on authentication state
  void _handleCloudButtonPressed() {
    if (_authService.isAuthenticated) {
      _showCloudSyncOptions();
    } else {
      _navigateToLogin();
    }
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  /// Show cloud sync options for authenticated users
  void _showCloudSyncOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const ListTile(
            title: Text('Cloud Sync Options'),
            subtitle: Text('Manage your cloud synchronization'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Now'),
            subtitle: const Text('Upload all local changes to cloud'),
            onTap: () {
              Navigator.pop(context);
              _confirmAndSync();
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download from Cloud'),
            subtitle: const Text('Replace local data with cloud data'),
            onTap: () {
              Navigator.pop(context);
              _downloadFromCloud();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Sign out and disable cloud sync'),
            onTap: () {
              Navigator.pop(context);
              _signOut();
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
    );
  }

  /// Confirm sync if there are deleted characters, then sync
  void _confirmAndSync() async {
    
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Sync'),
          content: const Text(
            'This sync will permanently change the data from the cloud. Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 54, 114, 244)),
              child: const Text('Sync'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        _syncAllData();
      }
  }

  /// Sync all data to cloud
  void _syncAllData() async {
    final result = await _syncService.syncAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? result.successMessage! : result.errorMessage!),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Download data from cloud
  void _downloadFromCloud() async {
    final result = await _syncService.downloadAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success ? result.successMessage! : result.errorMessage!),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
      // Reload characters if download was successful with a small delay
      if (result.success) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.read<CharactersViewModel>().loadCharacters();
          }
        });
      }
    }
  }

  /// Sign out from Firebase
  void _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Get color based on sync status
  Color _getSyncStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.connected:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.disconnected:
      default:
        return Colors.grey;
    }
  }


}
