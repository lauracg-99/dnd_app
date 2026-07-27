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

class DiaryViewScreen extends StatefulWidget {
  final Character character;
  final DiaryEntry diaryEntry;

  const DiaryViewScreen({
    super.key,
    required this.character,
    required this.diaryEntry,
  });

  @override
  State<DiaryViewScreen> createState() => _DiaryViewScreenState();
}

class _DiaryViewScreenState extends State<DiaryViewScreen> {
  late DiaryEntry _diaryEntry;
  bool _hasUpdated = false;
  List<DiaryGroup> _diaryGroups = [];

  @override
  void initState() {
    super.initState();
    _diaryEntry = widget.diaryEntry;
    _loadDiaryGroups();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasUpdated ? true : null);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_diaryEntry.title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            // Group assignment button (left of edit)
            IconButton(
              icon: const Icon(Icons.folder),
              onPressed: _showGroupAssignmentDialog,
              tooltip: 'Assign to Group',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editDiaryEntry(context),
              tooltip: 'Edit Entry',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Entry metadata
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildMetadata(context),
              ),
              
              // Entry content - natural height with full width
              _buildContent(),
              SizedBox(height: 50,)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  widget.character.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(_diaryEntry.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (_diaryEntry.updatedAt.isAfter(_diaryEntry.createdAt.add(const Duration(minutes: 1)))) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Updated: ${_formatDate(_diaryEntry.updatedAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

              if (_diaryEntry.groupId != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.folder, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Group: ${_diaryGroups.firstWhere(
                          (g) => g.id == _diaryEntry.groupId).name}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],

          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.only(top: 5.0, left: 25.0, right: 25.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _diaryEntry.content.isNotEmpty
                  ? _buildRichContent()
                  : Text(
                      'No content',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichContent() {
    try {
      // Try to parse as JSON (new format with rich text)
      final List<dynamic> jsonDelta = jsonDecode(_diaryEntry.content);
      final controller = QuillController.basic()
        ..document = Document.fromJson(jsonDelta);
      
      return IgnorePointer(
        child: QuillEditor.basic(
          controller: controller,
          config: QuillEditorConfig(
            scrollable: false,
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(), 
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      // Fallback to plain text (old format)
      return Text(
        _diaryEntry.content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      );
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

  void _editDiaryEntry(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEditorScreen(
          character: widget.character,
          diaryEntry: _diaryEntry,
        ),
      ),
    );

    if (result is DiaryEntry) {
      setState(() {
        _diaryEntry = result;
        _hasUpdated = true;
      });
    } else if (result == true) {
      _hasUpdated = true;
    }
  }

  Future<void> _loadDiaryGroups() async {
    try {
      final groups = await DiaryGroupService.loadDiaryGroupsForCharacter(
        widget.character.id,
      );
      if (mounted) {
        setState(() {
          _diaryGroups = groups;
        });
      }
    } catch (e) {
      debugPrint('Error loading diary groups: $e');
    }
  }

  void _showGroupAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign to Group'),
        content: SizedBox(
          width: double.maxFinite,
          child: _diaryGroups.isEmpty
              ? const Text('No groups available. Create a group first.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select a group for this entry:'),
                    const SizedBox(height: 16),
                    ..._diaryGroups.map((group) {
                      return RadioListTile<String>(
                        title: Text(group.name),
                        value: group.id,
                        groupValue: _diaryEntry.groupId,
                        onChanged: (value) async {
                          Navigator.pop(context);
                          if (value != null) {
                            await _assignEntryToGroup(value);
                          }
                        },
                      );
                    }),
                    RadioListTile<String>(
                      title: const Text('No Group'),
                      value: '',
                      groupValue: _diaryEntry.groupId ?? '',
                      onChanged: (value) async {
                        Navigator.pop(context);
                        if (value == '') {
                          await _assignEntryToGroup(null);
                        }
                      },
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _showCreateGroupDialog,
            child: const Text('Create New Group'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    Navigator.pop(context); // Close the assignment dialog first
    
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
                final newGroup = await DiaryGroupService.createDiaryGroup(
                  characterId: widget.character.id,
                  name: groupName,
                );
                await _loadDiaryGroups();
                
                // Assign the newly created group to the entry
                await _assignEntryToGroup(newGroup.id);
                
                if (mounted) {
                  SnackbarHelper.showSuccess(
                    context,
                    'Group created and assigned successfully',
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

  Future<void> _assignEntryToGroup(String? groupId) async {
    try {
      final updatedEntry = _diaryEntry.copyWith(groupId: groupId);
      await DiaryService.updateDiaryEntry(updatedEntry);
      
      if (mounted) {
        setState(() {
          _diaryEntry = updatedEntry;
          _hasUpdated = true;
        });
        
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
}
