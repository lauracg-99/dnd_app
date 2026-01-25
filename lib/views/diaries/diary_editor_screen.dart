import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'dart:convert';
import '../../models/character_model.dart';
import '../../models/diary_model.dart';
import '../../services/diary_service.dart';
import '../../utils/QuillToolbarConfigs.dart';
import '../../utils/simple_quill_editor_no_card.dart';

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
  final _contentController = QuillController.basic();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.diaryEntry != null) {
      _titleController.text = widget.diaryEntry!.title;
      
      // Initialize content with rich text support
      try {
        // Try to parse as JSON (new format with rich text)
        final List<dynamic> jsonDelta = jsonDecode(widget.diaryEntry!.content);
        _contentController.document = Document.fromJson(jsonDelta);
      } catch (e) {
        // Fallback to plain text (old format)
        String text = widget.diaryEntry!.content;
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        _contentController.document = Document.fromDelta(delta);
      }
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
          
          // Content field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SimpleQuillEditorNoCard(
                controller: _contentController,
                toolbarConfig: QuillToolbarConfigs.minimal,
                placeholder: 'Write your diary entry here...',
                height: double.infinity,
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
          content: jsonEncode(
            _contentController.document.toDelta().toJson(),
          ),
        );
      } else {
        // Update existing diary entry
        final updatedEntry = widget.diaryEntry!.copyWith(
          title: _titleController.text.trim(),
          content: jsonEncode(
            _contentController.document.toDelta().toJson(),
          ),
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
