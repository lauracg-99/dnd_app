import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'dart:convert';
import '../../models/character_model.dart';
import '../../models/diary_model.dart';
import '../../services/diary_service.dart';
import '../../utils/quill_toolbar_configs.dart';
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
  bool _isSavingOnPop = false;

  // Variables para almacenar el estado inicial y detectar cambios
  String _initialTitle = '';
  String _initialContentJson = '';

  @override
  void initState() {
    super.initState();
    if (widget.diaryEntry != null) {
      _titleController.text = widget.diaryEntry!.title;
      _initialTitle = widget.diaryEntry!.title;

      // Initialize content with rich text support
      try {
        // Try to parse as JSON (new format with rich text)
        final List<dynamic> jsonDelta = jsonDecode(widget.diaryEntry!.content);
        _contentController.document = Document.fromJson(jsonDelta);
        _initialContentJson = jsonEncode(jsonDelta);
      } catch (e) {
        // Fallback to plain text (old format)
        String text = widget.diaryEntry!.content;
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        _contentController.document = Document.fromDelta(delta);
        _initialContentJson = jsonEncode(delta.toJson());
      }
    } else {
      // Para una entrada nueva, el estado inicial es vacío
      _initialContentJson = jsonEncode(
        _contentController.document.toDelta().toJson(),
      );
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
    return PopScope(
      canPop:
          false, // Bloquea la salida inmediata para ejecutar el guardado primero
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Ejecuta el guardado automático
        await _saveDiaryEntry(isAutosave: true);
      },
      child: (Scaffold(
        appBar: AppBar(
          title: Text(
            widget.diaryEntry == null ? 'New Diary Entry' : 'Edit Diary Entry',
          ),
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  if (widget.diaryEntry != null) ...[
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Created: ${_formatDate(widget.diaryEntry!.createdAt)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  // Método auxiliar para verificar si el usuario modificó algo
  bool _hasChanges() {
    final currentTitle = _titleController.text.trim();
    final currentContentJson = jsonEncode(
      _contentController.document.toDelta().toJson(),
    );

    final titleChanged = currentTitle != _initialTitle.trim();
    // Flutter Quill añade un salto de línea por defecto; ignoramos diferencias de espacios vacíos
    final contentChanged = currentContentJson != _initialContentJson;

    return titleChanged || contentChanged;
  }

  Future<void> _saveDiaryEntry({bool isAutosave = false}) async {
    // 1. Si es autoguardado y NO hay cambios, salimos sin guardar e informamos que no hubo cambios (false)
    if (isAutosave && !_hasChanges()) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    // Si se hace un guardado automático y todo está vacío, salimos sin guardar nada
    if (isAutosave &&
        _titleController.text.trim().isEmpty &&
        _contentController.document.isEmpty()) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    // Validación de título vacío obligatorio solo si el usuario intenta guardar manualmente
    // o si cambió el contenido en el autoguardado.
    if (_titleController.text.trim().isEmpty) {
      if (isAutosave) {
        // Si sale con título vacío en autoguardado, no podemos guardar. Salimos sin guardar.
        if (mounted) Navigator.pop(context, false);
      } else {
        _showErrorSnackBar('Please enter a title for the diary entry');
      }
      return;
    }

    if (_isSavingOnPop) return;

    setState(() {
      _isLoading = true;
      if (isAutosave) _isSavingOnPop = true;
    });

    try {
      final currentContent = jsonEncode(
        _contentController.document.toDelta().toJson(),
      );

      if (widget.diaryEntry == null) {
        // Create new diary entry
        await DiaryService.createDiaryEntry(
          characterId: widget.character.id,
          title: _titleController.text.trim(),
          content: currentContent,
        );
      } else {
        // Update existing diary entry
        final updatedEntry = widget.diaryEntry!.copyWith(
          title: _titleController.text.trim(),
          content: currentContent,
        );
        await DiaryService.saveDiaryEntry(updatedEntry);
      }

      if (mounted) {
        Navigator.pop(context, true);

        SnackbarHelper.showSuccess(
          context,
          widget.diaryEntry == null
              ? 'Diary entry created successfully'
              : 'Diary entry updated successfully',
        );
      }
    } catch (e) {
      debugPrint('Error saving diary entry: $e');
      if (mounted) {
        _showErrorSnackBar('Error saving diary entry: $e');
        if (isAutosave) Navigator.pop(context, false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSavingOnPop = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    SnackbarHelper.showError(context, message);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
