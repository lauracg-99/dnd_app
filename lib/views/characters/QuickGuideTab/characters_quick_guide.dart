import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../utils/simple_quill_editor.dart';
import '../../../utils/quill_toolbar_configs.dart';

class CharactersQuickGuide extends StatelessWidget {
  final QuillController controller;

  const CharactersQuickGuide({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    child: SimpleQuillEditor(
                      controller: controller,
                      toolbarConfig: QuillToolbarConfigs.minimal,
                      height:
                          MediaQuery.of(context).size.height < 600
                              ? MediaQuery.of(context).size.height * 0.4
                              : MediaQuery.of(context).size.height * 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
