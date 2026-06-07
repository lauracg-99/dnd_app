import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/utils/quill_toolbar_configs.dart';
import 'package:dnd_app/utils/simple_quill_editor.dart';

class CharactersNotes extends StatelessWidget {
  final QuillController backstoryController;
  final TextEditingController gimmickController;
  final TextEditingController quirkController;
  final TextEditingController wantsController;
  final TextEditingController needsController;
  final TextEditingController conflictController;

  const CharactersNotes({
    super.key,
    required this.backstoryController,
    required this.gimmickController,
    required this.quirkController,
    required this.wantsController,
    required this.needsController,
    required this.conflictController,
  });

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
                      controller: backstoryController,
                      toolbarConfig: QuillToolbarConfigs.minimal,
                      placeholder:'''Write your character's backstory. 
                      
                      Consider including:
                      
                          • Place of birth and family background
                          • Life events that shaped their personality
                          • How they became an adventurer
                          • Significant relationships and experiences
                          • Secrets, traumas, or triumphs
                          • Hopes for the future''',

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
                    gimmickController,
                    'What makes your character unique or memorable?',
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField(
                    context,
                    'Quirk',
                    quirkController,
                    'Odd habits or mannerisms that define your character.',
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField(
                    context,
                    'Wants',
                    wantsController,
                    'What does your character desire most in the world?',
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField(
                    context,
                    'Needs',
                    needsController,
                    'What must your character accomplish or obtain?',
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedPillarField(
                    context,
                    'Conflict',
                    conflictController,
                    'What internal or external struggles drive your character?',
                  ),
                ],
              ),
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
