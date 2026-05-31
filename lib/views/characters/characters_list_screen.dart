import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../models/character_model.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/cloud_sync_service.dart';
import '../../widgets/character_card.dart';
import 'character_edit_screen.dart';
import 'character_create_screen.dart';
import '../diaries/diary_list_screen.dart';
import '../auth/login_screen.dart';

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen>
    with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  final _syncService = CloudSyncService();
  final _authService = FirebaseAuthService();

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
        // Second refresh after a bit more time to ensure cloud data is loaded
        Future.delayed(const Duration(milliseconds: 500), () {
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
              // Use current status from service if snapshot has no data yet
              final syncStatus =
                  snapshot.data ?? _syncService.currentSyncStatus;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: IconButton(                
                icon: Stack(
                  children: [
                    Icon(
                      _authService.isAuthenticated
                          ? Icons.cloud_done
                          : Icons.cloud_upload,
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
                onPressed: () => _handleCloudButtonPressed(syncStatus),
                tooltip: _getCloudButtonTooltip(syncStatus),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
              )
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
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
                    style: TextStyle(color: Colors.blue.shade600, fontSize: 14),
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
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: viewModel.characters.length,
      itemBuilder: (context, index) {
        final character = viewModel.characters[index];
        return _buildCharacterItem(character, context);
      },
    );
  }

  Widget _buildCharacterItem(Character character, BuildContext context) {
    return CharacterCard(
      character: character,
      onTap: () {
        _navigateToEditCharacter(character);
      },
      popupMenuItems: [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
          ),
        ),
        const PopupMenuItem(
          value: 'diary',
          child: Row(
            children: [Icon(Icons.book), SizedBox(width: 8), Text('Diary')],
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
      onPopupMenuSelected: (value) {
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
        }
      },
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
      MaterialPageRoute(builder: (context) => const CharacterCreateScreen()),
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

  /// Handle cloud button press based on authentication state
  void _handleCloudButtonPressed(SyncStatus currentStatus) {
    if (!_authService.isAuthenticated) {
      _navigateToLogin();
      return;
    }

    // Check current sync status
    if (currentStatus == SyncStatus.changesAvailable) {
      // If changes are available, trigger manual sync immediately
      _manualSyncChanges();
    } else {
      // Otherwise, show full sync options
      _showCloudSyncOptions();
    }
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  /// Manual sync when changes are available
  void _manualSyncChanges() async {
    // Show confirmation dialog before downloading changes
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Download Changes'),
            content: const Text(
              'Changes from other devices are available. Download them now?\n\n'
              'This will replace your local data with the latest changes from the cloud.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  _showCloudSyncOptions();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Download'),
              ),
            ],
          ),
    );

    if (confirmed == null || !confirmed) return;

    try {
      final result = await _syncService.manualSyncFromCloud();

      if (!mounted) return;

      if (result.success) {
        // Refresh characters after sync
        context.read<CharactersViewModel>().loadCharacters();
        SnackbarHelper.showSuccess(context, 'Changes downloaded successfully!');
      } else {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'Download failed: ${result.errorMessage}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Download error: $e');
      }
    }
  }

  /// Show cloud sync options for authenticated users
  void _showCloudSyncOptions() {
    final userEmail = _authService.currentUser?.email ?? 'Unknown';

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Cloud Sync Options'),
                  subtitle: Text('Signed in as: $userEmail'),
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
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Sign out and disable cloud sync'),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(
                    'Permanently delete your account and all cloud data',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmAndDeleteAccount();
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
      builder:
          (context) => AlertDialog(
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
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 54, 114, 244),
                ),
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
          content: Text(
            result.success ? result.successMessage! : result.errorMessage!,
          ),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
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
          content: Text(
            result.success ? result.successMessage! : result.errorMessage!,
          ),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
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
        SnackbarHelper.showSuccess(context, 'Signed out successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error signing out: $e');
      }
    }
  }

  /// Confirm and delete account with multi-step confirmation
  void _confirmAndDeleteAccount() async {
    // First confirmation dialog - explain what will be deleted
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account?'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will permanently delete:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('• Your account'),
                Text('• All cloud-synced characters'),
                Text('• All cloud-synced diaries'),
                SizedBox(height: 16),
                Text(
                  'Note: Local data on this device will NOT be deleted.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 16),
                Text(
                  'This action cannot be undone.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Continue'),
              ),
            ],
          ),
    );

    if (firstConfirm != true) return;
    if (!mounted) return;

    // Second confirmation dialog - final warning
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Are you absolutely sure?'),
            content: const Text(
              'Your account and all cloud data will be permanently deleted. This action cannot be undone.\n\nDo you want to proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete My Account'),
              ),
            ],
          ),
    );

    if (secondConfirm != true) return;

    // Proceed with account deletion
    _deleteAccount();
  }

  /// Delete account and all cloud data
  void _deleteAccount() async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text('Deleting account...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Step 1: Delete all cloud data
      final cloudDeleteResult = await _syncService.deleteAllCloudData();
      if (!cloudDeleteResult.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          SnackbarHelper.showError(
            context,
            'Failed to delete cloud data: ${cloudDeleteResult.errorMessage}',
          );
        }
        return;
      }

      // Step 2: Delete authentication account
      final authDeleteResult = await _authService.deleteAccount();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (authDeleteResult.success) {
          SnackbarHelper.showSuccess(context, 'Account deleted successfully');
        } else {
          SnackbarHelper.showError(
            context,
            'Failed to delete account: ${authDeleteResult.errorMessage}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        SnackbarHelper.showError(context, 'Error deleting account: $e');
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
      case SyncStatus.changesAvailable:
        return Colors.purple; // Violet color for changes available
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.disconnected:
        return Colors.grey;
    }
  }

  /// Get tooltip text based on sync status
  String _getCloudButtonTooltip(SyncStatus status) {
    if (!_authService.isAuthenticated) {
      return 'Sign In & Sync';
    }

    switch (status) {
      case SyncStatus.changesAvailable:
        return 'Tap to download changes from other devices';
      case SyncStatus.connected:
        return 'Cloud Sync Options';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Sync Error - Tap to retry';
      case SyncStatus.disconnected:
        return 'Cloud Sync Options';
    }
  }
}
