import 'package:flutter/material.dart';

class FeaturesTraitsSection extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;

  const FeaturesTraitsSection({
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
                  'Features & traits',
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
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Add features and traits...\n\n'
                      'Examples:\n'
                      '• Specific abilities from your Race, Class, Background, or Feats',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  alignLabelWithHint: true,
                ),
                maxLines: 12,
                minLines: 6,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
