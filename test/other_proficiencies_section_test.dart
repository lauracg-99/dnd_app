import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/other_proficiencies_section.dart';

void main() {
  group('OtherProficienciesSection Widget Tests', () {
    testWidgets('OtherProficienciesSection widget can be created with required parameters', (WidgetTester tester) async {
      // Create required controller
      final controller = QuillController.basic();

      // Verify widget can be instantiated without throwing
      expect(
        () => OtherProficienciesSection(
          controller: controller,
          onChanged: () {},
        ),
        returnsNormally,
      );

      // Clean up
      controller.dispose();
    });
  });
}
