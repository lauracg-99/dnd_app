import 'package:flutter/material.dart';

/// A reusable detail row widget for displaying label-value pairs.
/// 
/// Displays a label with a colon followed by the value on the same line.
/// The value is wrapped in an Expanded widget to handle long text properly.
/// Used in detail views to show information in a compact format.
class DetailRow extends StatelessWidget {
  /// The label text to display (will have ": " appended).
  final String label;

  /// The value text to display.
  final String value;

  /// Optional color for the value text.
  final Color? valueColor;

  const DetailRow({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
