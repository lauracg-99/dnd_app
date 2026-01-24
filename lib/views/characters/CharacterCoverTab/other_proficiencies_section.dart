import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/utils/QuillToolbarConfigs.dart';
import 'package:dnd_app/utils/SimpleQuillEditor.dart';

class OtherProficienciesSection extends StatelessWidget {
  final QuillController controller;
  final void Function() onChanged;

  const OtherProficienciesSection({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bookmark,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Other proficiencies',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: SimpleQuillEditor(
                controller: controller,
                toolbarConfig: QuillToolbarConfigs.minimal,
                placeholder: 'Add other proficiencies and bonuses...\n\n',
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
