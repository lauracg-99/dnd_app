import 'package:flutter/material.dart';

class HealthSection extends StatelessWidget {
  final TextEditingController maxHpController;
  final TextEditingController currentHpController;
  final TextEditingController tempHpController;
  final TextEditingController hitDiceController;
  final TextEditingController hitDiceTypeController;
  final int exhaustionLevel;
  final void Function(int) onExhaustionChanged;

  const HealthSection({
    super.key,
    required this.maxHpController,
    required this.currentHpController,
    required this.tempHpController,
    required this.hitDiceController,
    required this.hitDiceTypeController,
    required this.exhaustionLevel,
    required this.onExhaustionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hpRow(),
          const SizedBox(height: 12),
          _tempHpField(),
          const SizedBox(height: 20),
          const Text(
            'Hit Dice',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          _hitDiceRow(),
          
          const SizedBox(height: 24),
          
          // Exhaustion Points Section
          const Text(
            'Exhaustion Points',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          
          // Exhaustion level selector
          _exhaustionSelector(),
          
          const SizedBox(height: 16),
          
          // Exhaustion effects description
          _exhaustionEffects(),
        ],
      ),
    );
  }

  Widget _hpRow() {
    return Row(
      children: [
        Expanded(child: _field(maxHpController, 'Max HP', Icons.health_and_safety)),
        const SizedBox(width: 12),
        Expanded(child: _field(currentHpController, 'Current HP', Icons.favorite_border)),
      ],
    );
  }

  Widget _tempHpField() {
    return _field(tempHpController, 'Temporary HP', Icons.shield, iconColor: Colors.indigo);
  }

  Widget _hitDiceRow() {
    return Row(
      children: [
        Expanded(child: _field(hitDiceController, 'Number of Hit Dice', Icons.casino)),
        const SizedBox(width: 12),
        Expanded(child: _field(hitDiceTypeController, 'Hit Dice Type', Icons.category)),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    Color iconColor = Colors.blue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: iconColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _exhaustionSelector() {
    return Row(
      children: [
        const Text(
          'Level:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final isSelected = exhaustionLevel == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onExhaustionChanged(index),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? getExhaustionColor(index) : Colors.grey.shade300,
                        border: Border.all(
                          color: isSelected ? getExhaustionColor(index) : Colors.grey.shade400,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          index.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _exhaustionEffects() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getCumulativeExhaustionDescription(exhaustionLevel),
            style: TextStyle(
              fontSize: 13,
              color: getExhaustionColor(exhaustionLevel),
              fontWeight: exhaustionLevel > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          if (exhaustionLevel == 6)
            const SizedBox(height: 8),
          if (exhaustionLevel == 6)
            Text(
              'Character is dead.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade900,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Color getExhaustionColor(int level) {
    switch (level) {
      case 0:
        return Colors.grey.shade700;
      case 1:
        return Colors.orange.shade600; // Light warning
      case 2:
        return Colors.deepOrange.shade600; // Moderate warning
      case 3:
        return Colors.red.shade600; // Serious
      case 4:
        return Colors.red.shade700; // Very serious
      case 5:
        return Colors.red.shade800; // Critical
      case 6:
        return Colors.red.shade900; // Death
      default:
        return Colors.grey.shade700;
    }
  }

  String getCumulativeExhaustionDescription(int level) {
    final effects = <String>[];
    
    for (int i = 1; i <= level; i++) {
      switch (i) {
        case 1:
          effects.add('· Level 1: Disadvantage on ability checks');
          break;
        case 2:
          effects.add('· Level 2: Speed halved');
          break;
        case 3:
          effects.add('· Level 3: Disadvantage on attack and saving throws');
          break;
        case 4:
          effects.add('· Level 4: Maximum hit points halved');
          break;
        case 5:
          effects.add('· Level 5: Movement speed reduced to zero');
          break;
        case 6:
          effects.add('· Level 6: Death');
          break;
      }
    }
    
    if (effects.isEmpty) {
      return 'No exhaustion effects.';
    }
    
    return effects.join('\n');
  }
}
