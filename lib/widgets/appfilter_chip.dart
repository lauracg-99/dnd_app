import 'package:flutter/material.dart';

/// A reusable filter chip widget with a clear button.
///
/// Displays a label with a close icon that triggers [onClear] when tapped.
/// Used in filter UIs to show active filters that can be removed.
class AppFilterChip extends StatelessWidget {
  /// The text label to display in the chip.
  final String label;

  /// Callback when the clear/close button is tapped.
  final VoidCallback onClear;

  /// Optional background color for the chip.
  /// Defaults to blue.shade100 if not provided.
  final Color? backgroundColor;

  /// Optional text color for the label.
  /// Defaults to blue.shade800 if not provided.
  final Color? textColor;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.onClear,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use provided colors or default to blue theme
    final bgColor = backgroundColor ?? Colors.blue.shade100;
    final txtColor = textColor ?? Colors.blue.shade800;
    final iconColor = textColor?.withValues(alpha: 0.75) ?? Colors.blue.shade600;
    final borderColor =
        backgroundColor != null
            ? bgColor.withValues(alpha: 0.5)
            : Colors.blue.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: txtColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: 14, color: iconColor),
          ),
        ],
      ),
    );
  }
}
