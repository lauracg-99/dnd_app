import 'package:flutter/material.dart';

class DeathSavingThrowsSection extends StatelessWidget {
  final List<bool> deathSaveSuccesses;
  final List<bool> deathSaveFailures;
  final void Function(int) onToggleSuccess;
  final void Function(int) onToggleFailure;
  final VoidCallback onClear;

  const DeathSavingThrowsSection({
    super.key,
    required this.deathSaveSuccesses,
    required this.deathSaveFailures,
    required this.onToggleSuccess,
    required this.onToggleFailure,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Death Saving Throws',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Successes row
            Row(
              children: [
                const Text(
                  'Successes:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                ...List.generate(3, (index) {
                  final isActive = deathSaveSuccesses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () => onToggleSuccess(index),
                      child: _DeathSaveDot(
                        active: isActive,
                        activeColor: Colors.green,
                        icon: Icons.check,
                      ),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 12),

            // Failures row
            Row(
              children: [
                const Text(
                  'Failures:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 35),
                ...List.generate(3, (index) {
                  final isActive = deathSaveFailures[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () => onToggleFailure(index),
                      child: _DeathSaveDot(
                        active: isActive,
                        activeColor: Colors.red,
                        icon: Icons.close,
                      ),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            // Clear button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onClear,
                label: const Text('Clear All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeathSaveDot extends StatelessWidget {
  final bool active;
  final Color activeColor;
  final IconData icon;

  const _DeathSaveDot({
    required this.active,
    required this.activeColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: active ? activeColor : Colors.grey.shade300,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: active
          ? Icon(icon, color: Colors.white, size: 16)
          : const SizedBox.shrink(),
    );
  }
}
