import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/utils/QuillToolbarConfigs.dart';
import 'package:dnd_app/utils/SimpleQuillEditor.dart';
import 'package:dnd_app/utils/image_utils.dart';
import 'dart:io';

class CharactersAppereance extends StatelessWidget {
  final String? appearanceImagePath;
  final String? appearanceImageData;
  final bool isPickingImage;
  final VoidCallback pickAppearanceImage;
  final VoidCallback removeAppearanceImage;
  final TextEditingController heightController;
  final TextEditingController ageController;
  final TextEditingController eyeColorController;
  final QuillController additionalDetailsController;
  final VoidCallback autoSaveCharacter;

  const CharactersAppereance({
    super.key,
    required this.appearanceImagePath,
    this.appearanceImageData,
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
                          child: _buildAppearanceImage(),
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
                    child: SimpleQuillEditor(
                      controller: additionalDetailsController,
                      toolbarConfig: QuillToolbarConfigs.minimal,
                      placeholder: 'Start writing your character\'s appearance...\n\n',
                      height: 200,
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

  Widget _buildAppearanceImage() {
    // Prioritize base64 data if available
    if (appearanceImageData != null && appearanceImageData!.isNotEmpty) {
      final imageBytes = ImageUtils.base64ToImageBytes(appearanceImageData);
      if (imageBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageBytes,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              );
            },
          ),
        );
      }
    }
    
    // Fallback to file path if base64 is not available
    if (appearanceImagePath != null && appearanceImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(appearanceImagePath!),
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              size: 60,
              color: Colors.grey,
            );
          },
        ),
      );
    }
    
    // Default icon if no image is available
    return const Icon(
      Icons.person,
      size: 60,
      color: Colors.grey,
    );
  }
  
}
