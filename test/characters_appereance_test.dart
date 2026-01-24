import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/AppeareanceTab/characters_appereance.dart';

void main() {
  group('CharactersAppereance Widget Tests', () {
    testWidgets('CharactersAppereance renders correctly with all required parameters', (WidgetTester tester) async {
      // Create required controllers
      final heightController = TextEditingController();
      final ageController = TextEditingController();
      final eyeColorController = TextEditingController();
      final additionalDetailsController = TextEditingController();

      // Create the widget
      final widget = MaterialApp(
        home: Scaffold(
          body: CharactersAppereance(
            appearanceImagePath: null,
            isPickingImage: false,
            pickAppearanceImage: () {},
            removeAppearanceImage: () {},
            heightController: heightController,
            ageController: ageController,
            eyeColorController: eyeColorController,
            additionalDetailsController: additionalDetailsController,
            autoSaveCharacter: () {},
          ),
        ),
      );

      // Build the widget
      await tester.pumpWidget(widget);

      // Verify the widget renders
      expect(find.byType(CharactersAppereance), findsOneWidget);
      expect(find.text('Character Image'), findsOneWidget);
      expect(find.text('Physical Traits'), findsOneWidget);
      expect(find.text('Character Appereance'), findsOneWidget);
      
      // Verify text fields are present
      expect(find.byType(TextField), findsNWidgets(4)); // Height, Age, Eye Color, Additional Details
      
      // Verify buttons are present
      expect(find.byType(ElevatedButton), findsOneWidget); // Add photo button

      // Clean up
      heightController.dispose();
      ageController.dispose();
      eyeColorController.dispose();
      additionalDetailsController.dispose();
    });

    testWidgets('CharactersAppereance shows remove button when image is present', (WidgetTester tester) async {
      // Create required controllers
      final heightController = TextEditingController();
      final ageController = TextEditingController();
      final eyeColorController = TextEditingController();
      final additionalDetailsController = TextEditingController();

      // Create the widget with image
      final widget = MaterialApp(
        home: Scaffold(
          body: CharactersAppereance(
            appearanceImagePath: '/path/to/image.jpg',
            isPickingImage: false,
            pickAppearanceImage: () {},
            removeAppearanceImage: () {},
            heightController: heightController,
            ageController: ageController,
            eyeColorController: eyeColorController,
            additionalDetailsController: additionalDetailsController,
            autoSaveCharacter: () {},
          ),
        ),
      );

      // Build the widget
      await tester.pumpWidget(widget);

      // Verify both Add and Remove buttons are present
      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);

      // Clean up
      heightController.dispose();
      ageController.dispose();
      eyeColorController.dispose();
      additionalDetailsController.dispose();
    });
  });
}
