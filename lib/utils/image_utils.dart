import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Utility class for image operations
class ImageUtils {
  /// Convert an image file to base64 string
  /// Returns base64 string without data URI prefix
  static String? imageFileToBase64(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        debugPrint('Image file does not exist: $imagePath');
        return null;
      }

      final Uint8List imageBytes = imageFile.readAsBytesSync();
      final String base64String = base64Encode(imageBytes);

      debugPrint(
        'Converted image to base64: ${base64String.length} characters',
      );
      return base64String;
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }

  /// Convert base64 string back to image bytes
  /// Returns Uint8List or null if conversion fails
  static Uint8List? base64ToImageBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }

    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Error converting base64 to image bytes: $e');
      return null;
    }
  }

  /// Check if a base64 string is valid image data
  static bool isValidBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return false;
    }

    try {
      final bytes = base64Decode(base64String);
      return bytes.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get image file size in bytes
  static int? getImageFileSize(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        return null;
      }
      return imageFile.lengthSync();
    } catch (e) {
      debugPrint('Error getting image file size: $e');
      return null;
    }
  }

  /// Compress an image file and return a base64-encoded JPEG string.
  ///
  /// The function will resize the image if its largest dimension is greater
  /// than [maxWidth] and will iteratively reduce JPEG quality until the
  /// output fits within [maxBytes] or quality reaches 30.
  static Future<String?> compressAndEncodeImage(
    String? imagePath, {
    int maxWidth = 1024,
    int quality = 85,
    int maxBytes = 900000, // ~900 KB to stay safely under 1MB limit
  }) async {
    if (imagePath == null || imagePath.isEmpty) return null;

    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) return null;

      final Uint8List rawBytes = await imageFile.readAsBytes();

      // Decode image using package:image
      final img.Image? decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        // Fallback to original base64 if decoding fails
        return base64Encode(rawBytes);
      }

      img.Image working = decoded;

      // Resize if necessary
      final int maxDim =
          working.width > working.height ? working.width : working.height;
      if (maxDim > maxWidth) {
        working = img.copyResize(working, width: maxWidth);
      }

      int currentQuality = quality;
      List<int> encoded = img.encodeJpg(working, quality: currentQuality);

      // Iteratively reduce quality until size is below threshold or quality low
      while (encoded.length > maxBytes && currentQuality > 30) {
        currentQuality -= 5;
        encoded = img.encodeJpg(working, quality: currentQuality);
      }

      return base64Encode(Uint8List.fromList(encoded));
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Check if image file size is within reasonable limits (5MB)
  static bool isImageSizeReasonable(String? imagePath) {
    final size = getImageFileSize(imagePath);
    if (size == null) return false;

    // 5MB limit for base64 conversion
    const maxSize = 5 * 1024 * 1024; // 5MB in bytes
    return size <= maxSize;
  }
}
