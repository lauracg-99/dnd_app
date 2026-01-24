import 'package:flutter/material.dart';

class LongRestSection extends StatelessWidget {
  final VoidCallback takeComprehensiveLongRest;

  const LongRestSection({super.key, required this.takeComprehensiveLongRest});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.bedtime, color: Colors.green.shade700, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Long Rest',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: takeComprehensiveLongRest,
            icon: const Icon(Icons.night_shelter),
            label: const Text('Take Long Rest'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
