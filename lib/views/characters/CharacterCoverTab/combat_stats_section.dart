import 'package:flutter/material.dart';

class CombatStatsSection extends StatelessWidget {
  final Widget Function() buildInspiration;
  final Widget Function() buildArmorClass;
  final Widget Function() buildSpeed;

  const CombatStatsSection({
    super.key,
    required this.buildInspiration,
    required this.buildArmorClass,
    required this.buildSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: buildInspiration()),
        const SizedBox(width: 8),
        Expanded(child: buildArmorClass()),
        const SizedBox(width: 8),
        Expanded(child: buildSpeed()),
      ],
    );
  }
}

