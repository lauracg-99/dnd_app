import 'package:flutter/material.dart';

class HealthSection extends StatelessWidget {
  final TextEditingController maxHpController;
  final TextEditingController currentHpController;
  final TextEditingController tempHpController;
  final TextEditingController hitDiceController;
  final TextEditingController hitDiceTypeController;

  const HealthSection({
    super.key,
    required this.maxHpController,
    required this.currentHpController,
    required this.tempHpController,
    required this.hitDiceController,
    required this.hitDiceTypeController,
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: iconColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
