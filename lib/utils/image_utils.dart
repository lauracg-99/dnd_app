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

  /// Compress an image file and return a base64-encoded WebP string.
  ///
  /// The function will resize the image if its largest dimension is greater
  /// than [maxWidth] and will iteratively reduce WebP quality until the
  /// output fits within [maxBytes] or quality reaches 30.
  /// WebP provides better compression than JPEG for the same quality.
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
        debugPrint('ImageUtils: Failed to decode image, using original bytes');
        return base64Encode(rawBytes);
      }

      img.Image working = decoded;

      // Resize if necessary - following Performance Optimization rule
      final int maxDim =
          working.width > working.height ? working.width : working.height;
      if (maxDim > maxWidth) {
        debugPrint('ImageUtils: Resizing image from ${working.width}x${working.height} to max $maxWidth');
        working = img.copyResize(working, width: maxWidth);
      }

      int currentQuality = quality;
      final webpEncoder = img.WebPEncoder(lossless: false, quality: currentQuality);
      List<int> encoded = webpEncoder.encode(working);

      // Iteratively reduce quality until size is below threshold or quality low
      while (encoded.length > maxBytes && currentQuality > 30) {
        currentQuality -= 5;
        debugPrint('ImageUtils: Reducing WebP quality to $currentQuality, current size: ${encoded.length} bytes');
        final reducedEncoder = img.WebPEncoder(lossless: false, quality: currentQuality);
        encoded = reducedEncoder.encode(working);
      }

      final base64Result = base64Encode(Uint8List.fromList(encoded));
      debugPrint('ImageUtils: WebP compression complete - Final size: ${encoded.length} bytes, Base64 length: ${base64Result.length}');
      return base64Result;
    } catch (e) {
      debugPrint('ImageUtils: Error compressing image: $e');
      return null;
    }
  }

  /// Migrate existing base64 JPEG image data to WebP format for better compression.
  /// 
  /// This function takes existing base64 image data (which may be JPEG or other formats),
  /// decodes it, compresses it using WebP, and returns the new base64 string.
  /// Used for automatic migration of existing character images.
  static Future<String?> migrateToWebP(
    String? base64ImageData, {
    int maxWidth = 1024,
    int quality = 85,
    int maxBytes = 900000,
  }) async {
    if (base64ImageData == null || base64ImageData.isEmpty) {
      debugPrint('ImageUtils: No base64 data to migrate');
      return null;
    }

    try {
      // Remove data URI prefix if present (e.g., "data:image/jpeg;base64,")
      String cleanBase64 = base64ImageData;
      if (base64ImageData.contains(',')) {
        cleanBase64 = base64ImageData.split(',').last;
      }

      // Decode base64 to bytes
      final Uint8List imageBytes = base64Decode(cleanBase64);
      debugPrint('ImageUtils: Migrating image - Original size: ${imageBytes.length} bytes');

      // Decode image using package:image
      final img.Image? decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        debugPrint('ImageUtils: Failed to decode image during migration, keeping original');
        return base64ImageData; // Return original if decoding fails
      }

      img.Image working = decoded;

      // Resize if necessary - following Performance Optimization rule
      final int maxDim =
          working.width > working.height ? working.width : working.height;
      if (maxDim > maxWidth) {
        debugPrint('ImageUtils: Resizing during migration from ${working.width}x${working.height} to max $maxWidth');
        working = img.copyResize(working, width: maxWidth);
      }

      int currentQuality = quality;
      final webpEncoder = img.WebPEncoder(lossless: false, quality: currentQuality);
      List<int> encoded = webpEncoder.encode(working);

      // Iteratively reduce quality until size is below threshold or quality low
      while (encoded.length > maxBytes && currentQuality > 30) {
        currentQuality -= 5;
        debugPrint('ImageUtils: Reducing WebP quality during migration to $currentQuality, current size: ${encoded.length} bytes');
        final reducedEncoder = img.WebPEncoder(lossless: false, quality: currentQuality);
        encoded = reducedEncoder.encode(working);
      }

      final base64Result = base64Encode(Uint8List.fromList(encoded));
      final sizeReduction = ((imageBytes.length - encoded.length) / imageBytes.length * 100).toStringAsFixed(1);
      debugPrint('ImageUtils: Migration complete - Final size: ${encoded.length} bytes (reduced by $sizeReduction%), Base64 length: ${base64Result.length}');
      return base64Result;
    } catch (e) {
      debugPrint('ImageUtils: Error migrating image to WebP: $e');
      return base64ImageData; // Return original on error
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
