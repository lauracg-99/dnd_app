import 'package:flutter/material.dart';

class ConcentrationSection extends StatelessWidget {
  final bool hasConcentration;
  final VoidCallback onToggle;

  const ConcentrationSection({
    super.key,
    required this.hasConcentration,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = hasConcentration ? Colors.green : Colors.purple;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: hasConcentration ? Colors.green.shade50 : Colors.purple.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasConcentration ? Colors.green.shade200 : Colors.purple.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Spell Concentration',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: hasConcentration
                                  ? Colors.green.shade700
                                  : Colors.purple.shade700,
                            ),
                          ),
                        ),
                        Icon(
                          hasConcentration ? Icons.check_circle : Icons.circle_outlined,
                          color: hasConcentration
                              ? Colors.green.shade800
                              : Colors.grey.shade400,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: activeColor.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You must pass a Constitution Saving Throw (CON ST) when you take damage '
                          '(DC 10 or half the damage, whichever is greater) and you can only maintain '
                          'one concentration spell at a time, losing it if you are incapacitated, die, '
                          'or cast another spell that requires it.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: activeColor.shade700,
                                fontSize: 11,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
