import 'package:flutter/material.dart';

/// Widget for managing inspiration state
/// 
/// This widget encapsulates the inspiration toggle UI,
/// making it reusable and easier to test.
class InspirationWidget extends StatelessWidget {
  final bool hasInspiration;
  final VoidCallback onToggle;

  const InspirationWidget({
    super.key,
    required this.hasInspiration,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActiveColor = hasInspiration ? Colors.amber : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActiveColor.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActiveColor.shade200,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            hasInspiration ? Icons.lightbulb : Icons.lightbulb_outline,
            color: isActiveColor.shade600,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Inspiration',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActiveColor.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isActiveColor.shade100),
            ),
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(8),
              child: Icon(
                hasInspiration ? Icons.check_circle : Icons.circle_outlined,
                color: hasInspiration
                    ? Colors.green.shade800
                    : Colors.grey.shade400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
