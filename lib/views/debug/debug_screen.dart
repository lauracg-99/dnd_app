import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/spell_service.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Tools'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await SpellService.debugCheckSpellSchools();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Check debug console for spell school report'),
                    ),
                  );
                }
              },
              child: const Text('Check Spell Schools'),
            ),
          ],
        ),
      ),
    );
  }
}
