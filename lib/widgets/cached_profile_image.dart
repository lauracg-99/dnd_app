import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A cached profile image widget that prevents repeated base64 decoding
/// and eliminates the double flash effect when loading images
class CachedProfileImage extends StatefulWidget {
  final String? base64ImageData;
  final double width;
  final double height;
  final Widget placeholder;
  final BoxFit fit;
  final bool isCircular;

  const CachedProfileImage({
    super.key,
    this.base64ImageData,
    this.width = 40,
    this.height = 40,
    Widget? placeholder,
    this.fit = BoxFit.cover,
    this.isCircular = true,
  }) : placeholder = placeholder ?? const Icon(Icons.person);

  @override
  State<CachedProfileImage> createState() => _CachedProfileImageState();
}

class _CachedProfileImageState extends State<CachedProfileImage> {
  Uint8List? _cachedImageBytes;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reload if the image data actually changed
    if (oldWidget.base64ImageData != widget.base64ImageData) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.base64ImageData == null || widget.base64ImageData!.isEmpty) {
      setState(() {
        _cachedImageBytes = null;
        _hasError = false;
      });
      return;
    }

    setState(() {
      _hasError = false;
    });

    try {
      // Decode base64 data in background
      final bytes = await compute(_decodeBase64, widget.base64ImageData!);

      if (mounted) {
        setState(() {
          _cachedImageBytes = bytes;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
      if (mounted) {
        setState(() {
          _cachedImageBytes = null;
          _hasError = true;
        });
      }
    }
  }

  // Static function for background computation
  static Uint8List _decodeBase64(String base64String) {
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    // Show placeholder while loading or if there's no image
    if (_cachedImageBytes == null || _hasError) {
      return widget.placeholder;
    }

    Widget imageWidget = Image.memory(
      _cachedImageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true, // Prevents flickering during rebuilds
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error displaying cached image: $error');
        return widget.placeholder;
      },
    );

    // Apply circular clip if needed
    if (widget.isCircular) {
      return ClipOval(child: imageWidget);
    }

    return imageWidget;
  }
}

/// A simpler version for character list avatars
class CharacterAvatar extends StatelessWidget {
  final String? base64ImageData;
  final String? imagePath;
  final double size;

  const CharacterAvatar({
    super.key,
    this.base64ImageData,
    this.imagePath,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (base64ImageData != null && base64ImageData!.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: CachedProfileImage(
          base64ImageData: base64ImageData,
          width: size,
          height: size,
          isCircular: true,
          placeholder: const Icon(Icons.person),
        ),
      );
    }

    if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(imagePath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person);
          },
        ),
      );
    }

    return SizedBox(width: size, height: size, child: const Icon(Icons.person));
  }
}
