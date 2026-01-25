import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import '../../models/character_model.dart';
import '../../models/diary_model.dart';
import 'diary_editor_screen.dart';

class DiaryViewScreen extends StatelessWidget {
  final Character character;
  final DiaryEntry diaryEntry;

  const DiaryViewScreen({
    super.key,
    required this.character,
    required this.diaryEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(diaryEntry.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
                  character.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(diaryEntry.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (diaryEntry.updatedAt.isAfter(diaryEntry.createdAt.add(const Duration(minutes: 1)))) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Updated: ${_formatDate(diaryEntry.updatedAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
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
    return Container(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(18.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Content:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              diaryEntry.content.isNotEmpty
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
      final List<dynamic> jsonDelta = jsonDecode(diaryEntry.content);
      final controller = QuillController.basic()
        ..document = Document.fromJson(jsonDelta);
      
      return Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: IgnorePointer(
          child: QuillEditor.basic(
            controller: controller,
            config: QuillEditorConfig(
              scrollable: true,
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
        ),
      );
    } catch (e) {
      // Fallback to plain text (old format)
      return Text(
        diaryEntry.content,
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
          character: character,
          diaryEntry: diaryEntry,
        ),
      ),
    );

    if (result == true && context.mounted) {
      // Close the view screen and let the list refresh
      Navigator.pop(context, true);
    }
  }
}
