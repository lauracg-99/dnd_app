import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/QuickGuide/characters_quick_guide.dart';
import 'package:dnd_app/utils/ExpandableQuillEditor.dart';

void main() {
  group('CharactersQuickGuide Widget Tests', () {
    testWidgets('CharactersQuickGuide renders correctly with all required parameters', (WidgetTester tester) async {
      // Create QuillController
      final controller = QuillController.basic();

      // Create the widget
      final widget = MaterialApp(
        home: Scaffold(
          body: CharactersQuickGuide(
            controller: controller,
            onSaveCharacter: () {},
          ),
        ),
      );

      // Build the widget
      await tester.pumpWidget(widget);

      // Verify the widget renders
      expect(find.byType(CharactersQuickGuide), findsOneWidget);
      expect(find.text('Character Quick Guide'), findsOneWidget);
      
      // Verify Quill editor is present
      expect(find.byType(ExpandableQuillEditor), findsOneWidget);

      // Clean up
      controller.dispose();
    });

    testWidgets('CharactersQuickGuide handles save callback correctly', (WidgetTester tester) async {
      // Create QuillController
      final controller = QuillController.basic();

      bool saveCalled = false;

      // Create the widget
      final widget = MaterialApp(
        home: Scaffold(
          body: CharactersQuickGuide(
            controller: controller,
            onSaveCharacter: () => saveCalled = true,
          ),
        ),
      );

      // Build the widget
      await tester.pumpWidget(widget);

      // Verify the widget is properly initialized
      expect(find.byType(CharactersQuickGuide), findsOneWidget);
      expect(saveCalled, isFalse); // Save should not be called initially

      // Clean up
      controller.dispose();
    });
  });
}
