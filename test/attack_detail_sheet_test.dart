import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/views/characters/AttacksTab/attack_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttackDetailSheet', () {
    testWidgets('shows editable attack fields and saves changes', (
      tester,
    ) async {
      const initialAttack = CharacterAttack(
        id: 'atk-1',
        name: 'Longsword',
        attackBonus: '+3',
        damage: '1d8 + 3',
        damageType: 'slashing',
      );

      CharacterAttack? savedAttack;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttackDetailSheet(
              attack: initialAttack,
              onSave: (updatedAttack) {
                savedAttack = updatedAttack;
              },
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Save Changes'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Longsword'),
        'Greatsword',
      );
      await tester.enterText(find.widgetWithText(TextFormField, '+3'), '+5');
      await tester.enterText(
        find.widgetWithText(TextFormField, '1d8 + 3'),
        '2d6 + 5',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'slashing'),
        'piercing',
      );

      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(savedAttack, isNotNull);
      expect(savedAttack!.name, 'Greatsword');
      expect(savedAttack!.attackBonus, '+5');
      expect(savedAttack!.damage, '2d6 + 5');
      expect(savedAttack!.damageType, 'piercing');
    });
  });
}
