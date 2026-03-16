import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/widgets/cached_profile_image.dart';

void main() {
  group('CachedProfileImage Tests', () {
    testWidgets('should display placeholder when no image data provided', (WidgetTester tester) async {
      // Arrange
      const widget = MaterialApp(
        home: Scaffold(
          body: CachedProfileImage(
            base64ImageData: null,
            width: 40,
            height: 40,
            placeholder: Icon(Icons.person),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display placeholder when empty image data provided', (WidgetTester tester) async {
      // Arrange
      const widget = MaterialApp(
        home: Scaffold(
          body: CachedProfileImage(
            base64ImageData: '',
            width: 40,
            height: 40,
            placeholder: Icon(Icons.person),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('CharacterAvatar should render correctly', (WidgetTester tester) async {
      // Arrange
      const widget = MaterialApp(
        home: Scaffold(
          body: CharacterAvatar(
            base64ImageData: null,
            size: 40,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets); // Multiple SizedBox widgets is expected
      expect(find.byType(CachedProfileImage), findsOneWidget);
    });

    testWidgets('should handle invalid base64 data gracefully', (WidgetTester tester) async {
      // Arrange
      const widget = MaterialApp(
        home: Scaffold(
          body: CachedProfileImage(
            base64ImageData: 'invalid_base64_data',
            width: 40,
            height: 40,
            placeholder: Icon(Icons.person),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump(const Duration(milliseconds: 100)); // Allow async loading

      // Assert - should show placeholder on error
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
