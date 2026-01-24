import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../utils/ExpandableQuillEditor.dart';
import '../../../utils/QuillToolbarConfigs.dart';

class CharactersQuickGuide extends StatelessWidget {
  final QuillController controller;

  const CharactersQuickGuide({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Guide Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Quick Guide',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A quick reference guide for your character\'s key information, abilities, and gameplay notes.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ExpandableQuillEditor(
                      controller: controller,
                      toolbarConfig: QuillToolbarConfigs.minimal,
                      title: 'Tools',
                      height: 350,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
