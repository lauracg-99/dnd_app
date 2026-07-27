import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import '../../models/character_model.dart';
import '../../models/diary_model.dart';
import '../../models/diary_group_model.dart';
import '../../services/diary_service.dart';
import '../../services/diary_group_service.dart';
import '../../utils/snackbar_helper.dart';
import 'diary_editor_screen.dart';
import 'diary_view_screen.dart';

class DiaryListScreen extends StatefulWidget {
  final Character character;

  const DiaryListScreen({super.key, required this.character});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  List<DiaryEntry> _diaryEntries = [];
  List<DiaryGroup> _diaryGroups = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  String? _selectedGroupId; // Currently selected group filter
  String _sortBy = 'date'; // Sort option: 'date' or 'name'
  bool _isSelectionMode = false; // Selection mode for bulk operations
  final Set<String> _selectedEntryIds = <String>{}; // IDs of selected entries

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
    _loadDiaryGroups();
    // Initialize diary services
    DiaryService.initializeStorage();
    DiaryGroupService.initializeStorage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDiaryEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final entries = await DiaryService.loadDiaryEntriesForCharacter(
        widget.character.id,
        groupId: _selectedGroupId, // Pass selected group filter
      );

      setState(() {
        _diaryEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading diary entries: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDiaryGroups() async {
    try {
      final groups = await DiaryGroupService.loadDiaryGroupsForCharacter(
        widget.character.id,
      );
      setState(() {
        _diaryGroups = groups;
      });
    } catch (e) {
      debugPrint('Error loading diary groups: $e');
    }
  }

  List<DiaryEntry> get _filteredEntries {
    List<DiaryEntry> entries = _diaryEntries;
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      entries = DiaryService.searchDiaryEntries(
        entries,
        _searchController.text,
      );
    }
    
    // Apply sorting
    if (_sortBy == 'name') {
      entries = List<DiaryEntry>.from(entries)
        ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (_sortBy == 'date') {
      entries = List<DiaryEntry>.from(entries)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Newest first
    }
    
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.character.name}\'s Diary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isSelectionMode) ...[
            // Selection count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  '${_selectedEntryIds.length} selected',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            // Assign to group button
            if (_selectedEntryIds.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.folder),
                onPressed: _showBulkAssignGroupDialog,
                tooltip: 'Assign to Group',
              ),
            // Cancel selection mode
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedEntryIds.clear();
                });
              },
              tooltip: 'Cancel Selection',
            ),
          ] else ...[
            // Selection mode toggle
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
              tooltip: 'Select Multiple',
            ),
            _buildSortSelector(),
          ],
        ],
      ),
      body: Column(
        children: [

         // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search diary entries...',
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
                            setState(() {});
                          },
                        )
                        : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Group selector
          _buildGroupSelector(),
          
          // Active group filter indicator
          if (_selectedGroupId != null) _buildActiveGroupFilter(),
          
          SizedBox(height: 16), 

          // Diary entries list
          Expanded(child: _buildBody()),

          SizedBox(height: 16), // Add some spacing at the bottom
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'diary_fab',
        onPressed: _createNewDiaryEntry,
        tooltip: 'New Diary Entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorView();
    }

    if (_filteredEntries.isEmpty) {
      return _buildEmptyView();
    }

    return _buildDiaryList();
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDiaryEntries,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    final isSearchResult = _searchController.text.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off : Icons.book,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            isSearchResult
                ? 'No diary entries found matching your search.'
                : 'No diary entries yet. Create your first entry!',
          ),
          if (!isSearchResult) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createNewDiaryEntry,
              child: const Text('Create Diary Entry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiaryList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 96.0),
      itemCount: _filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = _filteredEntries[index];
        return _buildDiaryEntryCard(entry);
      },
    );
  }

  Widget _buildDiaryEntryCard(DiaryEntry entry) {
    // Find the entry's group if it has one
    final entryGroup = entry.groupId != null
        ? _diaryGroups.firstWhere(
            (g) => g.id == entry.groupId,
            orElse: () => DiaryGroup(
              id: '',
              characterId: widget.character.id,
              name: 'Unknown',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
        : null;
    
    final isSelected = _selectedEntryIds.contains(entry.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: _isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedEntryIds.add(entry.id);
                    } else {
                      _selectedEntryIds.remove(entry.id);
                    }
                  });
                },
              )
            : null,
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getPreviewText(entry.content),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Updated: ${_formatDate(entry.updatedAt)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 4),
            if (entryGroup != null && entryGroup.name != 'Unknown')
              Text(
                  'Group: ${entryGroup.name}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                )
          ],
        ),
        trailing: _isSelectionMode
            ? null
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editDiaryEntry(entry);
                      break;
                    case 'assign_group':
                      _showAssignGroupDialog(entry);
                      break;
                    case 'delete':
                      _deleteDiaryEntry(entry);
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
                      PopupMenuItem(
                        value: 'assign_group',
                        child: Row(
                          children: [
                            const Icon(Icons.folder),
                            const SizedBox(width: 8),
                            Text('Assign to Group'),
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
        onTap: _isSelectionMode
            ? () {
                setState(() {
                  if (isSelected) {
                    _selectedEntryIds.remove(entry.id);
                  } else {
                    _selectedEntryIds.add(entry.id);
                  }
                });
              }
            : () => _viewDiaryEntry(entry),
      ),
    );
  }

  String _getPreviewText(String content) {
    if (content.isEmpty) return 'No content';

    try {
      // Try to parse as JSON (new format with rich text)
      final List<dynamic> jsonDelta = jsonDecode(content);
      final controller =
          QuillController.basic()..document = Document.fromJson(jsonDelta);

      // Get plain text from rich text
      String plainText = controller.document.toPlainText();

      // Clean up the plain text for preview
      String cleanContent =
          plainText
              .replaceAll(RegExp(r'\n'), ' ') // Newlines to spaces
              .replaceAll(
                RegExp(r'\s+'),
                ' ',
              ) // Multiple spaces to single space
              .trim();

      if (cleanContent.length > 100) {
        return '${cleanContent.substring(0, 100)}...';
      }
      return cleanContent;
    } catch (e) {
      // Fallback to plain text (old format)
      String cleanContent =
          content
              .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Bold
              .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // Italic
              .replaceAll(RegExp(r'_(.*?)_'), r'$1') // Italic
              .replaceAll(RegExp(r'`(.*?)`'), r'$1') // Code
              .replaceAll(RegExp(r'#{1,6}\s*'), '') // Headers
              .replaceAll(RegExp(r'\n'), ' ') // Newlines to spaces
              .trim();

      if (cleanContent.length > 100) {
        return '${cleanContent.substring(0, 100)}...';
      }
      return cleanContent;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _createNewDiaryEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEditorScreen(character: widget.character),
      ),
    );

    if (result != null) {
      // Refresh the list and groups when returning from editor
      _loadDiaryEntries();
      _loadDiaryGroups();
    }
  }

  void _viewDiaryEntry(DiaryEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                DiaryViewScreen(character: widget.character, diaryEntry: entry),
      ),
    );

    if (result != null) {
      // Refresh the list and groups when returning from editor (via view screen)
      _loadDiaryEntries();
      _loadDiaryGroups();
    }
  }

  void _editDiaryEntry(DiaryEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DiaryEditorScreen(
              character: widget.character,
              diaryEntry: entry,
            ),
      ),
    );

    if (result != null) {
      // Refresh the list and groups when returning from editor
      _loadDiaryEntries();
      _loadDiaryGroups();
    }
  }

  void _deleteDiaryEntry(DiaryEntry entry) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Diary Entry'),
            content: Text(
              'Are you sure you want to delete "${entry.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    await DiaryService.deleteDiaryEntry(
                      widget.character.id,
                      entry.id,
                    );
                    _loadDiaryEntries();

                    if (mounted) {
                      SnackbarHelper.showSuccess(
                        context,
                        'Diary entry deleted',
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      SnackbarHelper.showError(
                        context,
                        'Error deleting diary entry: $e',
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Widget _buildActiveGroupFilter() {
    // Only show filter if the selected group actually exists in _diaryGroups
    final selectedGroup = _diaryGroups.firstWhere(
      (g) => g.id == _selectedGroupId,
      orElse: () => DiaryGroup(
        id: '',
        characterId: widget.character.id,
        name: 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    // Don't show filter if group doesn't exist (Unknown)
    if (selectedGroup.name == 'Unknown') {
      // Clear the invalid selection
      setState(() {
        _selectedGroupId = null;
      });
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                selectedGroup.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        onDeleted: () {
          setState(() {
            _selectedGroupId = null;
          });
          _loadDiaryEntries();
        },
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        deleteIcon: const Icon(Icons.close, size: 18),
        deleteIconColor: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }

  Widget _buildGroupSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedGroupId,
              borderRadius: BorderRadius.circular(10),
              decoration: InputDecoration(
                labelText: 'Filter by Group',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Entries'),
                ),
                ..._diaryGroups.map((group) {
                  return DropdownMenuItem(
                    value: group.id,
                    child: Text(
                      group.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value;
                });
                _loadDiaryEntries(); // Reload entries with new filter
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateGroupDialog,
            tooltip: 'Create New Group',
          ),
          if (_selectedGroupId != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditGroupDialog(_selectedGroupId!),
              tooltip: 'Edit Group Name',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteGroupDialog(_selectedGroupId!),
              tooltip: 'Delete Group',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSortSelector() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: DropdownButton<String>(
        value: _sortBy,
        underline: const SizedBox(),
        icon: const Icon(Icons.sort),
        borderRadius: BorderRadius.circular(10),
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        dropdownColor: Theme.of(context).colorScheme.inversePrimary,
        items: const [
          DropdownMenuItem(
            value: 'date',
            child: Text('Date'),
          ),
          DropdownMenuItem(
            value: 'name',
            child: Text('Name'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _sortBy = value;
            });
          }
        },
      ),
    );
  }

  void _showCreateGroupDialog() {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            hintText: 'e.g., Session 1, Campaign Arc, etc.',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final groupName = nameController.text.trim();
              if (groupName.isEmpty) {
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    'Please enter a group name',
                  );
                }
                return;
              }
              
              Navigator.pop(context);
              
              try {
                await DiaryGroupService.createDiaryGroup(
                  characterId: widget.character.id,
                  name: groupName,
                );
                await _loadDiaryGroups();
                
                if (mounted) {
                  SnackbarHelper.showSuccess(
                    context,
                    'Group created successfully',
                  );
                }
              } catch (e) {
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    'Error creating group: $e',
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(String groupId) {
    final group = _diaryGroups.firstWhere((g) => g.id == groupId);
    final TextEditingController nameController = TextEditingController(text: group.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            hintText: 'e.g., Session 1, Campaign Arc, etc.',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final groupName = nameController.text.trim();
              if (groupName.isEmpty) {
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    'Please enter a group name',
                  );
                }
                return;
              }
              
              Navigator.pop(context);
              
              try {
                final updatedGroup = group.copyWith(name: groupName);
                await DiaryGroupService.updateDiaryGroup(updatedGroup);
                await _loadDiaryGroups();
                
                if (mounted) {
                  SnackbarHelper.showSuccess(
                    context,
                    'Group name updated successfully',
                  );
                }
              } catch (e) {
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    'Error updating group: $e',
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(String groupId) {
    final group = _diaryGroups.firstWhere((g) => g.id == groupId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
          'Are you sure you want to delete "${group.name}"? Entries in this group will be unassigned but not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Unassign all entries from this group
                final entriesToUpdate = _diaryEntries.where((e) => e.groupId == groupId).toList();
                for (final entry in entriesToUpdate) {
                  final updatedEntry = entry.copyWith(groupId: null);
                  await DiaryService.updateDiaryEntry(updatedEntry);
                }
                
                // Delete the group
                await DiaryGroupService.deleteDiaryGroup(
                  widget.character.id,
                  groupId,
                );
                
                // Clear selected group if it was the deleted one
                if (_selectedGroupId == groupId) {
                  setState(() {
                    _selectedGroupId = null;
                  });
                }
                
                // Reload groups and entries
                await _loadDiaryGroups();
                await _loadDiaryEntries();
                
                if (mounted) {
                  SnackbarHelper.showSuccess(
                    context,
                    'Group deleted successfully',
                  );
                }
              } catch (e) {
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    'Error deleting group: $e',
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAssignGroupDialog(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign to Group'),
        content: _diaryGroups.isEmpty
            ? const Text('No groups available. Create a group first.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select a group for this entry:'),
                  const SizedBox(height: 16),
                  ..._diaryGroups.map((group) {
                    return ListTile(
                      title: Text(group.name),
                      leading: RadioGroup<String>(
                          groupValue: entry.groupId,
                          onChanged: (value) async {
                            Navigator.pop(context);
                            if (value != null) {
                              await _assignEntryToGroup(entry, value);
                            }
                          },
                          child: Radio<String>(
                            value: group.id,
                          ),
                        ),
                      onTap: () async {
                        Navigator.pop(context);
                        await _assignEntryToGroup(entry, group.id);
                      },
                    );
                  }),
                  ListTile(
                    title: const Text('No Group'),
                    leading: RadioGroup<String>(
                      groupValue: entry.groupId ?? '',
                      onChanged: (value) async {
                        Navigator.pop(context);
                        if (value == '') {
                          await _assignEntryToGroup(entry, null);
                        }
                      },
                      child: Radio<String>(
                        value: '',
                      ),
                    ),

                    onTap: () async {
                      Navigator.pop(context);
                      await _assignEntryToGroup(entry, null);
                    },
                  ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignEntryToGroup(DiaryEntry entry, String? groupId) async {
    try {
      final updatedEntry = entry.copyWith(groupId: groupId);
      await DiaryService.updateDiaryEntry(updatedEntry);
      await _loadDiaryEntries();
      
      if (mounted) {
        final groupName = groupId != null 
            ? _diaryGroups.firstWhere((g) => g.id == groupId).name 
            : 'No Group';
        SnackbarHelper.showSuccess(
          context,
          'Assigned to "$groupName"',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Error assigning to group: $e',
        );
      }
    }
  }

  void _showBulkAssignGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign ${_selectedEntryIds.length} Entries to Group'),
        content: _diaryGroups.isEmpty
            ? const Text('No groups available. Create a group first.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select a group for these entries:'),
                  const SizedBox(height: 16),
                  ..._diaryGroups.map((group) {
                    return ListTile(
                      title: Text(group.name),
                      onTap: () async {
                        Navigator.pop(context);
                        await _bulkAssignEntriesToGroup(group.id);
                      },
                    );
                  }),
                  ListTile(
                    title: const Text('No Group'),
                    onTap: () async {
                      Navigator.pop(context);
                      await _bulkAssignEntriesToGroup(null);
                    },
                  ),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkAssignEntriesToGroup(String? groupId) async {
    try {
      // Save count before clearing
      final assignedCount = _selectedEntryIds.length;
      
      // Update all selected entries
      for (final entryId in _selectedEntryIds) {
        final entry = _diaryEntries.firstWhere((e) => e.id == entryId);
        final updatedEntry = groupId == null
            ? entry.copyWith(clearGroupId: true)
            : entry.copyWith(groupId: groupId);
        await DiaryService.updateDiaryEntry(updatedEntry);
      }
      
      // Reload entries and exit selection mode
      await _loadDiaryEntries();
      setState(() {
        _isSelectionMode = false;
        _selectedEntryIds.clear();
      });
      
      if (mounted) {
        final groupName = groupId != null 
            ? _diaryGroups.firstWhere((g) => g.id == groupId).name 
            : 'No Group';
        SnackbarHelper.showSuccess(
          context,
          '$assignedCount entries assigned to "$groupName"',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Error assigning entries to group: $e',
        );
      }
    }
  }

  // groups
}
