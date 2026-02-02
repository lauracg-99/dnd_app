import 'package:flutter/material.dart';
import '../CharacterCoverTab/death_saving_throws_section.dart';

/// Widget for managing death saving throws
/// 
/// This widget encapsulates the death saves UI and logic,
/// making it reusable and easier to test.
class DeathSavesWidget extends StatelessWidget {
  final List<bool> successes;
  final List<bool> failures;
  final Function(int) onToggleSuccess;
  final Function(int) onToggleFailure;
  final VoidCallback onClear;

  const DeathSavesWidget({
    super.key,
    required this.successes,
    required this.failures,
    required this.onToggleSuccess,
    required this.onToggleFailure,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return DeathSavingThrowsSection(
      deathSaveSuccesses: successes,
      deathSaveFailures: failures,
      onToggleSuccess: onToggleSuccess,
      onToggleFailure: onToggleFailure,
      onClear: onClear,
    );
  }
}
