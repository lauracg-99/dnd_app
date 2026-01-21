import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

/// Service for handling image operations in character edit screen
class CharacterEditImageService {
  /// Show image options dialog
  static void showImageOptionsDialog(BuildContext context, {
    required VoidCallback onTakePhoto,
    required VoidCallback onChooseFromGallery,
    VoidCallback? onRemoveImage,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  onTakePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  onChooseFromGallery();
                },
              ),
              if (onRemoveImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Image'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onRemoveImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Pick and save image
  static Future<String?> pickAndSaveImage(
    ImageSource source,
    String characterId, {
    required VoidCallback onPickingStart,
    required VoidCallback onPickingEnd,
    String imageType = 'character',
  }) async {
    onPickingStart();
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        // Save image to app's documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${imageType}_${characterId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImagePath = path.join(appDir.path, fileName);
        
        final File sourceFile = File(pickedFile.path);
        await sourceFile.copy(savedImagePath);

        return savedImagePath;
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image: $e');
    } finally {
      onPickingEnd();
    }
  }

  /// Show error message for image operations
  static void showImageError(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error picking image: $error')),
    );
  }
}
