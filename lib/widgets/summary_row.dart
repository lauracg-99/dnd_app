import 'package:flutter/material.dart';

/// A reusable summary row widget for displaying label-value pairs.
/// 
/// Displays a label and value on opposite sides of the row with space between.
/// The value text is bold and can optionally have a custom color.
/// Used in summary views to show key statistics or information.
class SummaryRow extends StatelessWidget {
  /// The label text to display on the left side.
  final String label;

  /// The value text to display on the right side.
  final String value;

  /// Optional color for the value text.
  final Color? valueColor;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
