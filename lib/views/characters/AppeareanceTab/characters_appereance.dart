import 'package:flutter/material.dart';
import 'dart:io';

class CharactersAppereance extends StatelessWidget {
  final String? appearanceImagePath;
  final bool isPickingImage;
  final VoidCallback pickAppearanceImage;
  final VoidCallback removeAppearanceImage;
  final TextEditingController heightController;
  final TextEditingController ageController;
  final TextEditingController eyeColorController;
  final TextEditingController additionalDetailsController;
  final VoidCallback autoSaveCharacter;

  const CharactersAppereance({
    super.key,
    required this.appearanceImagePath,
    required this.isPickingImage,
    required this.pickAppearanceImage,
    required this.removeAppearanceImage,
    required this.heightController,
    required this.ageController,
    required this.eyeColorController,
    required this.additionalDetailsController,
    required this.autoSaveCharacter,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Character Image Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Character Image',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child:
                              appearanceImagePath != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(appearanceImagePath!),
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  )
                                  : const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  isPickingImage ? null : pickAppearanceImage,
                              icon: const Icon(Icons.photo_library),
                              label: Text(
                                appearanceImagePath != null ? 'Change' : 'Add',
                              ),
                            ),
                            if (appearanceImagePath != null) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: removeAppearanceImage,
                                icon: const Icon(Icons.delete),
                                label: const Text('Remove'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Physical Traits Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Physical Traits',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Height Field
                  TextField(
                    controller: heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      hintText: 'e.g., 5\'10" or 178 cm',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                    ),
                    onChanged: (value) => autoSaveCharacter(),
                  ),

                  const SizedBox(height: 12),

                  // Age Field
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'e.g., 25 years old',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake),
                    ),
                    onChanged: (value) => autoSaveCharacter(),
                  ),

                  const SizedBox(height: 12),

                  // Eye Color Field
                  TextField(
                    controller: eyeColorController,
                    decoration: const InputDecoration(
                      labelText: 'Eye Color',
                      hintText: 'e.g., Blue, Green, Brown',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.visibility),
                    ),
                    onChanged: (value) => autoSaveCharacter(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Additional Details Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Appereance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe your character\'s appearance.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: additionalDetailsController,
                      decoration: const InputDecoration(
                        hintText:
                            'Start writing your character\'s story...\n\n'
                            'You can describe:\n'
                            '• Physical appearance beyond basic traits\n'
                            '• Clothing and equipment style\n'
                            '• Notable scars, tattoos, or markings\n'
                            '• Personality traits and mannerisms\n'
                            '• Background story and history\n'
                            '• Goals, dreams, and motivations\n'
                            '• Relationships and connections\n'
                            '• Any other details that bring your character to life',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 12,
                      minLines: 8,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => autoSaveCharacter(),
                    ),
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
                          'Auto-saves automatically • No character limit • Supports rich text descriptions',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
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
          ),
        ],
      ),
    );
  
  }
  
}
