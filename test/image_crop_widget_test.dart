import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dnd_app/widgets/image_crop_widget.dart';

void main() {
  group('ImageCropWidget Tests', () {
    testWidgets('ImageCropWidget renders correctly', (WidgetTester tester) async {
      // Create a temporary image file for testing
      final tempDir = Directory.systemTemp;
      final testImageFile = File('${tempDir.path}/test_image.jpg');
      
      // Create a simple test image (1x1 pixel JPEG)
      final testImageData = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43
      ]);
      
      await testImageFile.writeAsBytes(testImageData);

      // Test callback to capture cropped result
      Uint8List? croppedResult;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageCropWidget(
              imageFile: testImageFile,
              title: 'Test Crop',
              isCircleCrop: true,
              aspectRatio: 1.0,
              onCropped: (result) {
                croppedResult = result;
              },
              onCancelled: () {},
            ),
          ),
        ),
      );

      // Wait for image to load
      await tester.pumpAndSettle();

      // Verify the widget renders
      expect(find.text('Test Crop'), findsOneWidget);
      expect(find.text('Show Grid'), findsOneWidget);
      expect(find.text('CROP IMAGE'), findsOneWidget);

      // Clean up
      await testImageFile.delete();
    });

    test('GridPainter shouldRepaint returns false', () {
      final painter = GridPainter();
      expect(painter.shouldRepaint(painter), isFalse);
    });

    test('ImageCropWidget parameters are correctly assigned', () {
      final tempDir = Directory.systemTemp;
      final testImageFile = File('${tempDir.path}/test_params.jpg');
      
      // Test the widget constructor parameters
      final widget = ImageCropWidget(
        imageFile: testImageFile,
        title: 'Custom Title',
        isCircleCrop: true,
        aspectRatio: 16.0 / 9.0,
        onCropped: (result) {},
        onCancelled: () {},
      );

      expect(widget.title, equals('Custom Title'));
      expect(widget.isCircleCrop, isTrue);
      expect(widget.aspectRatio, equals(16.0 / 9.0));
      expect(widget.imageFile, equals(testImageFile));
    });
  });
}
