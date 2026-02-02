import 'package:flutter/material.dart';
import '../CharacterCoverTab/concentration_section.dart';

/// Widget for managing concentration state
/// 
/// This widget encapsulates the concentration toggle UI,
/// making it reusable and easier to test.
class ConcentrationWidget extends StatelessWidget {
  final bool hasConcentration;
  final VoidCallback onToggle;

  const ConcentrationWidget({
    super.key,
    required this.hasConcentration,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ConcentrationSection(
      hasConcentration: hasConcentration,
      onToggle: onToggle,
    );
  }
}
