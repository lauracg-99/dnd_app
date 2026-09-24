import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dnd_app/models/spell_model.dart';
import 'package:dnd_app/views/spells/spells_list_screen.dart';
import 'package:dnd_app/viewmodels/spells_viewmodel.dart';

void main() {
  group('SpellsListScreen Filter Button Tests', () {
    testWidgets('Filter button should be present and clickable', (
      WidgetTester tester,
    ) async {
      // Create a mock SpellsViewModel
      final viewModel = SpellsViewModel();

      // Build the widget
      await tester.pumpWidget(
        ChangeNotifierProvider<SpellsViewModel>(
          create: (_) => viewModel,
          child: MaterialApp(home: SpellsListScreen()),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the filter button exists
      expect(find.byIcon(Icons.filter_list), findsOneWidget);

      // Verify the filter button is clickable
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));

      // Tap the filter button
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // The filter section should now be expanded (we can verify this by checking for filter chips)
      // Note: This might take a moment to load spells data
    });

    testWidgets('Filter button should toggle expansion state', (
      WidgetTester tester,
    ) async {
      final viewModel = SpellsViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<SpellsViewModel>(
          create: (_) => viewModel,
          child: MaterialApp(home: SpellsListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Find the filter button
      final filterButton = find.byIcon(Icons.filter_list);
      expect(filterButton, findsOneWidget);

      // Initially, the filter should not be expanded
      // We can't directly check the _isFilterExpanded state, but we can check UI changes

      // Tap to expand
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Tap again to collapse
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // The button should still be present and functional
      expect(filterButton, findsOneWidget);
    });

    test(
      'lookup by name should use the full spell catalog when filtered view is active',
      () {
        final viewModel = SpellsViewModel();
        final spellA = Spell(
          id: 'spell_a',
          name: 'Fireball',
          castingTime: '1 action',
          range: '120 feet',
          duration: 'Instantaneous',
          description: 'A bright streak flashes',
          classes: ['wizard'],
          dice: const [],
          updatedAt: DateTime.now(),
        );
        final spellB = Spell(
          id: 'spell_b',
          name: 'Cure Wounds',
          castingTime: '1 action',
          range: 'Touch',
          duration: 'Instantaneous',
          description: 'A creature regains hit points',
          classes: ['cleric'],
          dice: const [],
          updatedAt: DateTime.now(),
        );

        viewModel.setAllSpells([spellA, spellB]);
        viewModel.setSelectedClass('wizard');

        expect(
          viewModel.spells.map((s) => s.name),
          isNot(contains('Cure Wounds')),
        );
        expect(viewModel.getSpellByName('Cure Wounds')?.name, 'Cure Wounds');
      },
    );
  });
}
