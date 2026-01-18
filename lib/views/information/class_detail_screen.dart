// lib/views/information/class_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/class_model.dart';
import '../../../viewmodels/class_viewmodel.dart' show ClassesViewModel;

class ClassDetailScreen extends StatelessWidget {
  final String className;

  const ClassDetailScreen({Key? key, required this.className}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
      ),
      body: Consumer<ClassesViewModel>(
        builder: (context, viewModel, _) {
          // Find the class by name
          final dndClass = viewModel.classes.firstWhere(
            (cls) => cls.name == className,
            orElse: () => throw Exception('Class not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Hit Die', dndClass.hitDie.toUpperCase()),
                const SizedBox(height: 16),
                _buildSection('Saving Throws', dndClass.savingThrows.join(', ').toUpperCase()),
                const SizedBox(height: 16),
                _buildFeaturesSection(dndClass.features),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(content),
        const Divider(),
      ],
    );
  }

  Widget _buildFeaturesSection(List<ClassFeature> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(feature.description),
              const Divider(),
            ],
          ),
        )).toList(),
      ],
    );
  }
}