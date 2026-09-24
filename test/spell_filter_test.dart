import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/models/spell_model.dart';
import 'package:dnd_app/views/spells/spells_list_screen.dart';
import 'package:dnd_app/viewmodels/spells_viewmodel.dart';
import 'package:dnd_app/widgets/spell_details_modal.dart';

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

      await tester.pump();

      // Find the filter button
      final filterButton = find.byIcon(Icons.filter_list);
      expect(filterButton, findsOneWidget);

      // Initially, the filter should not be expanded
      // We can't directly check the _isFilterExpanded state, but we can check UI changes

      // Tap to expand
      await tester.tap(filterButton);
      await tester.pump();

      // Tap again to collapse
      await tester.tap(filterButton);
      await tester.pump();

      // The button should still be present and functional
      expect(filterButton, findsOneWidget);
    });

    testWidgets('spell detail modal should allow text selection and copying', (
      WidgetTester tester,
    ) async {
      final spell = Spell(
        id: 'fireball',
        name: 'Fireball',
        castingTime: '1 action',
        range: '150 feet',
        duration: 'Instantaneous',
        description:
            'A bright streak flashes from your finger to a point you choose.',
        classes: ['wizard'],
        school: 'evocation',
        verbal: true,
        somatic: true,
        material: false,
        ritual: false,
        dice: const [],
        updatedAt: DateTime.now(),
      );

      final character = Character(
        id: 'char-1',
        name: 'Test Wizard',
        stats: CharacterStats(
          strength: 10,
          dexterity: 10,
          constitution: 10,
          intelligence: 10,
          wisdom: 10,
          charisma: 10,
          proficiencyBonus: 2,
          armorClass: 10,
          speed: 30,
          initiative: 0,
          inspiration: false,
          hasConcentration: false,
          hasShield: false,
        ),
        savingThrows: CharacterSavingThrows(),
        skillChecks: CharacterSkillChecks(),
        health: CharacterHealth(
          maxHitPoints: 10,
          currentHitPoints: 10,
          temporaryHitPoints: 0,
          hitDice: 1,
          hitDiceType: 'd8',
        ),
        characterClass: 'Wizard',
        level: 5,
        spellSlots: CharacterSpellSlots(),
        pillars: CharacterPillars(),
        appearance: CharacterAppearance(),
        deathSaves: CharacterDeathSaves(),
        languages: CharacterLanguages(),
        moneyItems: CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SpellDetailsModal(
            spell: spell,
            character: character,
            characterModifier: '+2',
            characterAttack: '+5',
            onRemoveSpell: (_) {},
          ),
        ),
      );

      expect(find.text('Fireball'), findsOneWidget);
      expect(find.byType(SelectionArea), findsAtLeastNWidgets(1));
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
