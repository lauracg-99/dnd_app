import 'package:flutter/material.dart';
import '../../models/character_model.dart';
import '../../models/diary_model.dart';
import '../../services/diary_service.dart';
import 'diary_editor_screen.dart';
import 'diary_view_screen.dart';

class DiaryListScreen extends StatefulWidget {
  final Character character;

  const DiaryListScreen({
    super.key,
    required this.character,
  });

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  List<DiaryEntry> _diaryEntries = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
    // Initialize diary service
    DiaryService.initializeStorage();
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

      final entries = await DiaryService.loadDiaryEntriesForCharacter(widget.character.id);
      
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

  List<DiaryEntry> get _filteredEntries {
    if (_searchController.text.isEmpty) {
      return _diaryEntries;
    }
    return DiaryService.searchDiaryEntries(_diaryEntries, _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.character.name}\'s Diary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                suffixIcon: _searchController.text.isNotEmpty
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
          
          // Diary entries list
          Expanded(
            child: _buildBody(),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = _filteredEntries[index];
        return _buildDiaryEntryCard(entry);
      },
    );
  }

  Widget _buildDiaryEntryCard(DiaryEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
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
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editDiaryEntry(entry);
                break;
              case 'delete':
                _deleteDiaryEntry(entry);
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
        onTap: () => _viewDiaryEntry(entry),
      ),
    );
  }

  String _getPreviewText(String content) {
    if (content.isEmpty) return 'No content';
    
    // Remove markdown-like formatting for preview
    String cleanContent = content
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
        builder: (context) => DiaryEditorScreen(
          character: widget.character,
        ),
      ),
    );

    if (result == true) {
      // Refresh the list when returning from editor
      _loadDiaryEntries();
    }
  }

  void _viewDiaryEntry(DiaryEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryViewScreen(
          character: widget.character,
          diaryEntry: entry,
        ),
      ),
    );

    if (result == true) {
      // Refresh the list when returning from editor (via view screen)
      _loadDiaryEntries();
    }
  }

  void _editDiaryEntry(DiaryEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEditorScreen(
          character: widget.character,
          diaryEntry: entry,
        ),
      ),
    );

    if (result == true) {
      // Refresh the list when returning from editor
      _loadDiaryEntries();
    }
  }

  void _deleteDiaryEntry(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                await DiaryService.deleteDiaryEntry(widget.character.id, entry.id);
                _loadDiaryEntries();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Diary entry deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting diary entry: $e'),
                      backgroundColor: Colors.red,
                    ),
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
}
