import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/utils/QuillToolbarConfigs.dart';
import 'package:dnd_app/utils/SimpleQuillEditor.dart';

class CharactersNotes extends StatefulWidget {
  final QuillController backstoryController;
  final TextEditingController gimmickController;
  final TextEditingController quirkController;
  final TextEditingController wantsController;
  final TextEditingController needsController;
  final TextEditingController conflictController;
  final VoidCallback onSaveCharacter;

  const CharactersNotes({
    super.key,
    required this.backstoryController,
    required this.gimmickController,
    required this.quirkController,
    required this.wantsController,
    required this.needsController,
    required this.conflictController,
    required this.onSaveCharacter,
  });

  @override
  State<CharactersNotes> createState() => _CharactersNotesState();
}

class _CharactersNotesState extends State<CharactersNotes> 
    with WidgetsBindingObserver {
  bool _hasUnsavedChanges = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Add listeners to all controllers to detect changes
    widget.backstoryController.addListener(_onTextChanged);
    widget.gimmickController.addListener(_onTextChanged);
    widget.quirkController.addListener(_onTextChanged);
    widget.wantsController.addListener(_onTextChanged);
    widget.needsController.addListener(_onTextChanged);
    widget.conflictController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    // Remove listeners
    widget.backstoryController.removeListener(_onTextChanged);
    widget.gimmickController.removeListener(_onTextChanged);
    widget.quirkController.removeListener(_onTextChanged);
    widget.wantsController.removeListener(_onTextChanged);
    widget.needsController.removeListener(_onTextChanged);
    widget.conflictController.removeListener(_onTextChanged);
    
    // Save any pending changes before disposing (without setState)
    if (_hasUnsavedChanges) {
      widget.onSaveCharacter();
    }
    
    super.dispose();
  }

  
  void _onTextChanged() {
    if (_hasUnsavedChanges) {
      widget.onSaveCharacter();
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          
          // Backstory Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_edu,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Backstory',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The complete history and background story of your character.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: SimpleQuillEditor(
                      controller: widget.backstoryController,
                      toolbarConfig: QuillToolbarConfigs.minimal,
                      placeholder: 'Write your character\'s backstory...\n\n'
                          'Consider including:\n'
                          '• Place of birth and family background\n'
                          '• Life events that shaped their personality\n'
                          '• How they became an adventurer\n'
                          '• Significant relationships and experiences\n'
                          '• Secrets, traumas, or triumphs\n'
                          '• Hopes for the future',
                      height: 300,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Character Pillars Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.foundation,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Pillars',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Core elements that define your character\'s role in the story.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField(
                    context,
                    'Gimmick',
                    widget.gimmickController,
                    'What makes your character unique or memorable?',
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField(
                    context,
                    'Quirk',
                    widget.quirkController,
                    'Odd habits or mannerisms that define your character.',
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField(
                    context,
                    'Wants',
                    widget.wantsController,
                    'What does your character desire most in the world?',
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField(
                    context,
                    'Needs',
                    widget.needsController,
                    'What must your character accomplish or obtain?',
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField(
                    context,
                    'Conflict',
                    widget.conflictController,
                    'What internal or external struggles drive your character?',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Auto-save info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'All notes auto-save automatically • No character limit • Rich text supported',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 56),
        ],
      ),
    );
  }

  Widget _buildEnhancedPillarField(
    BuildContext context,
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 6,
            minLines: 3,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
