import 'package:flutter/material.dart';
import '../../models/character_model.dart';
import '../../models/diary_model.dart';
import '../../services/diary_service.dart';

class DiaryEditorScreen extends StatefulWidget {
  final Character character;
  final DiaryEntry? diaryEntry;

  const DiaryEditorScreen({
    super.key,
    required this.character,
    this.diaryEntry,
  });

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;

  @override
  void initState() {
    super.initState();
    if (widget.diaryEntry != null) {
      _titleController.text = widget.diaryEntry!.title;
      _contentController.text = widget.diaryEntry!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diaryEntry == null ? 'New Diary Entry' : 'Edit Diary Entry'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveDiaryEntry,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter diary entry title...',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textInputAction: TextInputAction.next,
            ),
          ),
          
          // Formatting toolbar
        //  _buildFormattingToolbar(),
          
          // Content field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Write your diary entry here...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: _isUnderline ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ),
          
          // Character info footer
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Character: ${widget.character.name}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (widget.diaryEntry != null) ...[
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Created: ${_formatDate(widget.diaryEntry!.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          _buildFormatButton(
            icon: Icons.format_bold,
            tooltip: 'Bold',
            isActive: _isBold,
            onPressed: () {
              setState(() {
                _isBold = !_isBold;
              });
            },
          ),
          _buildFormatButton(
            icon: Icons.format_italic,
            tooltip: 'Italic',
            isActive: _isItalic,
            onPressed: () {
              setState(() {
                _isItalic = !_isItalic;
              });
            },
          ),
          _buildFormatButton(
            icon: Icons.format_underlined,
            tooltip: 'Underline',
            isActive: _isUnderline,
            onPressed: () {
              setState(() {
                _isUnderline = !_isUnderline;
              });
            },
          ),
          const SizedBox(width: 16),
          _buildFormatButton(
            icon: Icons.format_list_bulleted,
            tooltip: 'Bullet List',
            onPressed: _insertBulletList,
          ),
          _buildFormatButton(
            icon: Icons.format_list_numbered,
            tooltip: 'Numbered List',
            onPressed: _insertNumberedList,
          ),
          const Spacer(),
          _buildFormatButton(
            icon: Icons.clear_all,
            tooltip: 'Clear Formatting',
            onPressed: _clearFormatting,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isActive ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : null,
          foregroundColor: isActive ? Theme.of(context).primaryColor : null,
        ),
      ),
    );
  }

  void _insertBulletList() {
    final currentText = _contentController.text;
    final selection = _contentController.selection;
    final bulletPoint = '\n• ';
    
    if (selection.isValid) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        bulletPoint,
      );
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + bulletPoint.length,
        ),
      );
    } else {
      _contentController.text += bulletPoint;
      _contentController.selection = TextSelection.collapsed(
        offset: _contentController.text.length,
      );
    }
  }

  void _insertNumberedList() {
    final currentText = _contentController.text;
    final selection = _contentController.selection;
    final numberPoint = '\n1. ';
    
    if (selection.isValid) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        numberPoint,
      );
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + numberPoint.length,
        ),
      );
    } else {
      _contentController.text += numberPoint;
      _contentController.selection = TextSelection.collapsed(
        offset: _contentController.text.length,
      );
    }
  }

  void _clearFormatting() {
    setState(() {
      _isBold = false;
      _isItalic = false;
      _isUnderline = false;
    });
  }

  Future<void> _saveDiaryEntry() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title for the diary entry');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.diaryEntry == null) {
        // Create new diary entry
        await DiaryService.createDiaryEntry(
          characterId: widget.character.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
      } else {
        // Update existing diary entry
        final updatedEntry = widget.diaryEntry!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
        await DiaryService.saveDiaryEntry(updatedEntry);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.diaryEntry == null 
                ? 'Diary entry created successfully' 
                : 'Diary entry updated successfully'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving diary entry: $e');
      if (mounted) {
        _showErrorSnackBar('Error saving diary entry: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
