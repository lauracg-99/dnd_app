import 'package:flutter/material.dart';

class InitiativeSection extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController dexterityController;
  final void Function(String) onChanged;
  final VoidCallback showInitiativeDialog;

  const InitiativeSection({
    super.key,
    required this.controller,
    required this.dexterityController,
    required this.onChanged,
    required this.showInitiativeDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          _buildInitiativeField(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInitiativeField(BuildContext context) {
    final currentInitiative = int.tryParse(controller.text) ?? 0;
    final currentDexterity = int.tryParse(dexterityController.text) ?? 10;
    final dexterityModifier = ((currentDexterity - 10) / 2).floor();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Initiative Modifier:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: showInitiativeDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Center(
                      child: Text(
                        currentInitiative.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current: $currentInitiative (Dex modifier: $dexterityModifier). Usually equals dexterity modifier but can be modified by feats, items, or special abilities.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
