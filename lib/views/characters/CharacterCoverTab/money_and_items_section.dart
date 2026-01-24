import 'package:flutter/material.dart';

class MoneyItemsSection extends StatelessWidget {
  final TextEditingController moneyController;
  final TextEditingController itemsController;
  final void Function(String) onMoneyChanged;
  final void Function(String) onItemsChanged;

  const MoneyItemsSection({
    super.key,
    required this.moneyController,
    required this.itemsController,
    required this.onMoneyChanged,
    required this.onItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Money & Items',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Track your character\'s wealth and possessions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            // Money field
            _buildTextField(
              context: context,
              controller: moneyController,
              label: 'Money',
              hint: 'Enter your character\'s wealth...\n\n'
                  'Examples:\n'
                  '• 150 gp, 50 sp, 25 cp\n'
                  '• 2,000 gp\n'
                  '• Pocket change: 5 gp, 12 sp, 8 cp\n'
                  '• Bank funds: 10,000 gp',
              onChanged: onMoneyChanged,
              alignLabelWithHint: false
            ),
            const SizedBox(height: 16),
            // Items field
            _buildTextField(
              context: context,
              controller: itemsController,
              label: 'Items & Equipment',
              hint: 'List your character\'s equipment and possessions...\n\n'
                  'Weapons:\n'
                  '• Longsword +1, Shield +1\n'
                  '• Shortbow with 20 arrows\n'
                  '• Dagger +2\n\n'
                  'Armor:\n'
                  '• Chain mail armor\n'
                  '• Steel shield\n'
                  '• Helmet of protection\n\n'
                  'Magic Items:\n'
                  '• Ring of invisibility\n'
                  '• Amulet of health\n'
                  '• Boots of speed\n'
                  '• Cloak of elvenkind\n\n'
                  'Tools & Equipment:\n'
                  '• Thieves\' tools\n'
                  '• Climbing gear\n'
                  '• Rope 50ft\n'
                  '• Rations for 1 week\n'
                  '• Waterskin\n'
                  '• Bedroll and blanket',
              onChanged: onItemsChanged,
              maxLines: 12,
              minLines: 6,
            ),            
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Auto-saves automatically • No character limit • Rich text supported',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
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

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required void Function(String) onChanged,
    int maxLines = 1,
    int minLines = 1,
    bool alignLabelWithHint = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          alignLabelWithHint: alignLabelWithHint,
        ),
        maxLines: maxLines,
        minLines: minLines,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.black87,
        ),
        onChanged: onChanged,
      ),
    );
  }

}
