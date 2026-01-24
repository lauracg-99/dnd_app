import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/views/characters/AppeareanceTab/characters_appereance.dart';

void main() {
  group('CharactersAppereance Widget Tests', () {
    testWidgets('CharactersAppereance widget can be created with required parameters', (WidgetTester tester) async {
      // Create required controllers
      final heightController = TextEditingController();
      final ageController = TextEditingController();
      final eyeColorController = TextEditingController();
      final additionalDetailsController = QuillController.basic();

      // Verify widget can be instantiated without throwing
      expect(
        () => CharactersAppereance(
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
        returnsNormally,
      );

      // Clean up
      heightController.dispose();
      ageController.dispose();
      eyeColorController.dispose();
      additionalDetailsController.dispose();
    });
  });
}
