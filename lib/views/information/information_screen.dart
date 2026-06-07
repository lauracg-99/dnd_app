import 'package:dart_dice_parser/dart_dice_parser.dart';
import 'package:dnd_app/services/dice_service.dart';
import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:dnd_app/views/information/weapons_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'feats_screen.dart';
import 'classes_screen.dart';
import 'races_screen.dart';
import 'backgrounds_screen.dart';
import 'package:flutter/services.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Information')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // _buildSectionTitle('Game References'),
          const SizedBox(height: 8),
          _buildCategoryCard(
            context: context,
            title: 'Feats',
            icon: Icons.emoji_events,
            onTap: () {
              // Navigate to Feats screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeatsScreen()),
              );
            },
          ),
          _buildCategoryCard(
            context: context,
            title: 'Dados 1',
            icon: Icons.class_,
            onTap: () {
              // Prueba
              DiceService.lanzarDados(context, "2d6+3");
            },
          ),
          _buildCategoryCard(
            context: context,
            title: 'Dados 2',
            icon: Icons.people,
            onTap: () {
              DiceService.lanzarVariasVeces(context, "1d100", 5);
            },
          ),
          _buildCategoryCard(
            context: context,
            title: 'Weapons',
            icon: Symbols.swords,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeaponsScreen()),
              );
            },
          ),
          _buildCategoryCard(
            context: context,
            title: 'Backgrounds',
            icon: Icons.history_edu,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackgroundsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
