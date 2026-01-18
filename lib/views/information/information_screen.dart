import 'package:flutter/material.dart';
import 'feats_screen.dart';
import 'classes_screen.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Game References'),
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
            title: 'Classes',
            icon: Icons.class_,
            onTap: () {    
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClassesScreen()),
              );
            },
          ),
          _buildCategoryCard(
            context: context,
            title: 'Armor',
            icon: Icons.shield,
            onTap: () {
              // Will be implemented later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Armor section coming soon!')),
              );
            },
          ),
          _buildCategoryCard(
            context: context,
            title: 'Races',
            icon: Icons.people,
            onTap: () {
              // Will be implemented later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Races section coming soon!')),
              );
            },
          ),
          _buildCategoryCard(
            context: context,
            title: 'Items',
            icon: Icons.inventory,
            onTap: () {
              // Will be implemented later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Items section coming soon!')),
              );
            },
          ),
          _buildCategoryCard(
            context: context,
            title: 'Backgrounds',
            icon: Icons.history_edu,
            onTap: () {
              // Will be implemented later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backgrounds section coming soon!')),
              );
            },
          ),
          
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
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
