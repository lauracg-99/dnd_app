import 'package:dnd_app/l10n/app_localizations.dart';
import 'package:dnd_app/utils/character_helper.dart';
import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/characters_viewmodel.dart';
import '../../models/character_model.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/cloud_sync_service.dart';
import '../../widgets/character_card.dart';
import '../../widgets/custom_group_expansion_tile.dart';
import 'character_edit_screen.dart';
import 'character_create_screen.dart';
import '../diaries/diary_list_screen.dart';
import '../auth/login_screen.dart';

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({
    super.key,
    required this.onLocaleChanged,
    required this.locale,
  });

  final ValueChanged<Locale> onLocaleChanged;
  final Locale locale;

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

  Future<void> _handleLocaleSelection(Locale locale) async {
    final l10n = AppLocalizations.of(context)!;

    if (locale != const Locale('es')) {
      widget.onLocaleChanged(locale);
      return;
    }

    final shouldChange = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.languageWarningTitle),
          content: Text(l10n.languageWarningMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.continueLabel),
            ),
          ],
        );
      },
    );

    if (shouldChange == true) {
      widget.onLocaleChanged(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        centerTitle: true,
        titleSpacing: 0,
        title: Text(l10n.dndCharacters),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: PopupMenuButton<Locale>(
              tooltip: l10n.language,
              icon: const Icon(Icons.language),
              initialValue: widget.locale,
              onSelected: _handleLocaleSelection,
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: const Locale('en'),
                      child: Row(
                        children: [
                          Expanded(child: Text(l10n.english)),
                          if (widget.locale.languageCode == 'en')
                            const Icon(Icons.check, size: 18),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('es'),
                      child: Row(
                        children: [
                          Expanded(child: Text(l10n.spanish)),
                          if (widget.locale.languageCode == 'es')
                            const Icon(Icons.check, size: 18),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
          // Cloud sync button
          StreamBuilder<SyncStatus>(
            stream: _syncService.syncStatus,
            builder: (context, snapshot) {
              // Use current status from service if snapshot has no data yet
              final syncStatus =
                  snapshot.data ?? _syncService.currentSyncStatus;
              return Padding(
                padding: const EdgeInsets.only(right: 30.0),
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
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: const SizedBox(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'characters_fab',
        onPressed: _navigateToCreateCharacter,
        tooltip: l10n.createCharacter,
        child: const Icon(Icons.add),
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
        final l10n = AppLocalizations.of(context)!;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchCharacters,
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
            onPressed: viewModel.loadCharacters,
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
          const Icon(Icons.person_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.createFirstCharacter),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _navigateToCreateCharacter,
            child: Text(l10n.createCharacter),
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
                    l10n.syncAcrossDevices,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.signInBackupDescription,
                    style: TextStyle(color: Colors.blue.shade600, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _navigateToLogin,
                    icon: const Icon(Icons.login),
                    label: Text(l10n.signIn),
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

    final Map<String, List<Character>> groupedCharacters = {};
    final Map<String, String> groupNames = {};
    final List<Character> ungroupedCharacters = [];

    for (final character in viewModel.characters) {
      if (character.grupo != null && character.grupo!.isNotEmpty) {
        final groupId = CharacterHelper.getGroupKey(character);
        groupNames[groupId] = character.grupo!;
        groupedCharacters.putIfAbsent(groupId, () => []).add(character);
      } else {
        ungroupedCharacters.add(character);
      }
    }

    final groupedEntries =
        groupedCharacters.entries.toList()
          ..sort((a, b) => groupNames[a.key]!.compareTo(groupNames[b.key]!));

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final groupEntry in groupedEntries)
          CustomGroupExpansionTile(
            title: groupNames[groupEntry.key]!,
            initiallyExpanded: false,
            headerBackgroundColor: Colors.blue.shade100,
            expandedBackgroundColor: Colors.blue.shade50,
            textColor: Colors.black87,
            iconColor: Colors.blue.shade700,
            borderRadius: 12,
            headerPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            titleStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
            elevation: 3,
            onRenamePressed:
                () => CharacterHelper.showGroupRenameDialogByGroupKey(
                  context,
                  groupEntry.key,
                  groupNames[groupEntry.key]!,
                ),
            onDeletePressed:
                () => CharacterHelper.confirmAndDeleteGroup(
                  context,
                  groupEntry.key,
                  groupNames[groupEntry.key]!,
                  groupEntry.value,
                ),
            children:
                groupEntry.value
                    .map((character) => _buildCharacterItem(character, context))
                    .toList(),
          ),
        ...ungroupedCharacters.map(
          (character) => _buildCharacterItem(character, context),
        ),
      ],
    );
  }

  Widget _buildCharacterItem(Character character, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CharacterCard(
      character: character,
      onTap: () {
        _navigateToEditCharacter(character);
      },
      popupMenuItems: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit),
              const SizedBox(width: 8),
              Text(l10n.edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'diary',
          child: Row(
            children: [
              const Icon(Icons.book),
              const SizedBox(width: 8),
              Text(l10n.diary),
            ],
          ),
        ),
        if (character.grupo == null || character.grupo!.isEmpty)
          PopupMenuItem(
            value: 'add_group',
            child: Row(
              children: [
                const Icon(Icons.group_add),
                const SizedBox(width: 8),
                Text(l10n.addToGroup),
              ],
            ),
          )
        else ...[
          PopupMenuItem(
            value: 'edit_group',
            child: Row(
              children: [
                const Icon(Icons.edit),
                const SizedBox(width: 8),
                Text(l10n.modifyGroup),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'remove_group',
            child: Row(
              children: [
                const Icon(Icons.remove_circle_outline),
                const SizedBox(width: 8),
                Text(l10n.removeFromGroup),
              ],
            ),
          ),
        ],
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.delete, style: const TextStyle(color: Colors.red)),
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
          case 'add_group':
          case 'edit_group':
            CharacterHelper.showGroupAssignmentDialog(context, character);
            break;
          case 'remove_group':
            CharacterHelper.removeCharacterFromGroup(context, character);
            break;
          case 'delete':
            CharacterHelper.showDeleteConfirmation(context, character);
            break;
        }
      },
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

  /// Manual sync when changes are available
  void _manualSyncChanges() async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog before downloading changes
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.downloadChanges),
            content: Text(l10n.downloadChangesDescription),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  _showCloudSyncOptions();
                },
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.download),
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
        SnackbarHelper.showSuccess(context, l10n.changesDownloadedSuccessfully);
      } else {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            l10n.downloadFailed(result.errorMessage ?? ''),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, l10n.downloadError(e.toString()));
      }
    }
  }

  /// Show cloud sync options for authenticated users
  void _showCloudSyncOptions() {
    final l10n = AppLocalizations.of(context)!;
    final userEmail = _authService.currentUser?.email ?? l10n.unknown;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(l10n.cloudSyncOptions),
                  subtitle: Text(l10n.signedInAs(userEmail)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: Text(l10n.syncNow),
                  subtitle: Text(l10n.syncNowDescription),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmAndSync();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.downloadFromCloud),
                  subtitle: Text(l10n.downloadFromCloudDescription),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadFromCloud();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    l10n.signOut,
                    style: const TextStyle(color: Colors.red),
                  ),
                  subtitle: Text(l10n.signOutAndDisableCloudSync),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(
                    l10n.deleteAccount,
                    style: const TextStyle(color: Colors.red),
                  ),
                  subtitle: Text(l10n.deleteAccountAndCloudData),
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
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.confirmSync),
            content: Text(l10n.confirmSyncDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 54, 114, 244),
                ),
                child: Text(l10n.syncLabel),
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
    final l10n = AppLocalizations.of(context)!;

    if (!_authService.isAuthenticated) {
      return '${l10n.signIn} & ${l10n.syncNow}';
    }

    switch (status) {
      case SyncStatus.changesAvailable:
        return 'Tap to download changes from other devices';
      case SyncStatus.connected:
        return l10n.cloudSyncOptions;
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Sync Error - Tap to retry';
      case SyncStatus.disconnected:
        return l10n.cloudSyncOptions;
    }
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

  /// Navigate to login screen
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  /// Sign out from Firebase
  void _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.signedOutSuccessfully,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          AppLocalizations.of(context)!.errorSigningOut(e.toString()),
        );
      }
    }
  }

  /// Confirm and delete account with multi-step confirmation
  void _confirmAndDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;

    final firstConfirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteAccountQuestion),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deleteAccountWarningTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(l10n.deleteAccountWarningAccount),
                Text(l10n.deleteAccountWarningCharacters),
                Text(l10n.deleteAccountWarningDiaries),
                const SizedBox(height: 16),
                Text(
                  l10n.deleteAccountWarningNote,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.deleteAccountWarningPermanent,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.continueLabel),
              ),
            ],
          ),
    );

    if (firstConfirm != true) return;
    if (!mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.accountDeletionConfirmationTitle),
            content: Text(l10n.accountDeletionConfirmationMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: Text(l10n.deleteMyAccount),
              ),
            ],
          ),
    );

    if (secondConfirm != true) return;

    _deleteAccount();
  }

  /// Delete account and all cloud data
  void _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(l10n.deletingAccount),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );
      }

      final cloudDeleteResult = await _syncService.deleteAllCloudData();
      if (!cloudDeleteResult.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          SnackbarHelper.showError(
            context,
            l10n.failedToDeleteCloudData(
              cloudDeleteResult.errorMessage ?? l10n.unknown,
            ),
          );
        }
        return;
      }

      final authDeleteResult = await _authService.deleteAccount();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (authDeleteResult.success) {
          SnackbarHelper.showSuccess(context, l10n.accountDeletedSuccessfully);
        } else {
          SnackbarHelper.showError(
            context,
            l10n.failedToDeleteAccount(
              authDeleteResult.errorMessage ?? l10n.unknown,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        SnackbarHelper.showError(context, l10n.errorDeletingAccount(e.toString()));
      }
    }
  }
}
