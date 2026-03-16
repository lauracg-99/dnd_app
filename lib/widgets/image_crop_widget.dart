import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

class ImageCropWidget extends StatefulWidget {
  final File imageFile;
  final String title;
  final bool isCircleCrop;
  final double? aspectRatio;
  final Function(Uint8List) onCropped;
  final VoidCallback? onCancelled;

  const ImageCropWidget({
    super.key,
    required this.imageFile,
    this.title = 'Crop Image',
    this.isCircleCrop = false,
    this.aspectRatio,
    required this.onCropped,
    this.onCancelled,
  });

  @override
  State<ImageCropWidget> createState() => _ImageCropWidgetState();
}

class _ImageCropWidgetState extends State<ImageCropWidget> {
  final _cropController = CropController();
  Uint8List? _imageBytes;
  Uint8List? _croppedData;
  var _isCropping = false;
  var _statusText = '';
  var _isOverlayActive = true;
  var _currentAspectRatio = 1.0;
  var _withCircleUi = false;

  @override
  void initState() {
    super.initState();
    // Initialize with default values first
    _currentAspectRatio = 1.0;
    // Load image after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadImage();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now safely update with widget properties
    if (mounted) {
      _updateFromWidget();
    }
  }

  void _updateFromWidget() {
    try {
      _withCircleUi = widget.isCircleCrop;
      if (widget.aspectRatio != null) {
        _currentAspectRatio = widget.aspectRatio!;
        _cropController.aspectRatio = widget.aspectRatio!;
      }
    } catch (e) {
      debugPrint('Error updating from widget: $e');
      // Keep default values if there's an error
    }
  }

  Future<void> _loadImage() async {
    // Double-check widget is properly initialized
    if (!mounted) return;
    
    try {
      final bytes = await widget.imageFile.readAsBytes();
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              widget.onCancelled?.call();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Crop area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildCropArea(),
              ),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grid toggle
                _buildGridToggle(),
                
                const SizedBox(height: 16),
                
                // Crop button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCropping ? null : _performCrop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCropping
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Cropping...'),
                            ],
                          )
                        : const Text(
                            'CROP IMAGE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropArea() {
    if (_imageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Stack(
      children: [
        Crop(
          image: _imageBytes!,
          controller: _cropController,
          onCropped: (result) {
            switch (result) {
              case CropSuccess(:final croppedImage):
                _croppedData = croppedImage;
                widget.onCropped(croppedImage);
              case CropFailure(:final cause):
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to crop image: $cause'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
            }
            setState(() => _isCropping = false);
          },
          withCircleUi: _withCircleUi,
          onStatusChanged: (status) => setState(() {
            _statusText = <CropStatus, String>{
                  CropStatus.nothing: 'Crop has no image data',
                  CropStatus.loading: 'Crop is now loading given image',
                  CropStatus.ready: 'Crop is now ready!',
                  CropStatus.cropping: 'Crop is now cropping image',
                }[status] ??
                '';
          }),
          interactive: true,
          fixCropRect: false,  // Allow crop rect to adapt to image size
          radius: 8,
          initialRectBuilder: InitialRectBuilder.withBuilder(
            (viewportRect, imageRect) {
              // Show image at original size, centered in viewport
              final imageWidth = imageRect.width;
              final imageHeight = imageRect.height;
              final viewportWidth = viewportRect.width;
              final viewportHeight = viewportRect.height;
              
              // Calculate scale to fit image in viewport
              final scaleX = viewportWidth / imageWidth;
              final scaleY = viewportHeight / imageHeight;
              final scale = scaleX < scaleY ? scaleX : scaleY;
              
              // Calculate scaled image dimensions
              final scaledWidth = imageWidth * scale;
              final scaledHeight = imageHeight * scale;
              
              // Center the scaled image in viewport
              final left = (viewportWidth - scaledWidth) / 2;
              final top = (viewportHeight - scaledHeight) / 2;
              final right = left + scaledWidth;
              final bottom = top + scaledHeight;
              
              return Rect.fromLTRB(left, top, right, bottom);
            },
          ),
          overlayBuilder: _isOverlayActive
              ? (context, rect) {
                  final overlay = CustomPaint(
                    painter: GridPainter(),
                  );
                  return widget.isCircleCrop
                      ? ClipOval(child: overlay)
                      : overlay;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildGridToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Show Grid'),
        const SizedBox(width: 8),
        Switch(
          value: _isOverlayActive,
          onChanged: (value) {
            setState(() {
              _isOverlayActive = value;
            });
          },
          activeColor: Colors.blue.shade800,
        ),
      ],
    );
  }

  void _performCrop() {
    setState(() {
      _isCropping = true;
    });
    
    if (widget.isCircleCrop) {
      _cropController.cropCircle();
    } else {
      _cropController.crop();
    }
  }
}

class GridPainter extends CustomPainter {
  final divisions = 2;
  final strokeWidth = 1.0;
  final Color color = Colors.black54;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color;

    final spacing = size / (divisions + 1);
    for (var i = 1; i < divisions + 1; i++) {
      // draw vertical line
      canvas.drawLine(
        Offset(spacing.width * i, 0),
        Offset(spacing.width * i, size.height),
        paint,
      );

      // draw horizontal line
      canvas.drawLine(
        Offset(0, spacing.height * i),
        Offset(size.width, spacing.height * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}
