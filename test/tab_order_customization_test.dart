import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dnd_app/services/user_preferences_service.dart';
import 'package:dnd_app/models/tab_config_model.dart';

void main() {
  group('Tab Order Customization Tests', () {
    setUp(() async {
      // Reset cache before each test
      UserPreferencesService.clearCache();
    });

    test('Default tab order is correct', () {
      final defaultOrder = CharacterTabManager.getDefaultTabOrder();
      
      expect(defaultOrder, [
        'character',
        'quick_guide',
        'stats',
        'skills',
        'attacks',
        'spell_slots',
        'spells',
        'feats',
        'class_slots',
        'appearance',
        'notes',
      ]);
    });

    test('CharacterTabManager returns all tabs', () {
      final allTabs = CharacterTabManager.getAllTabs();
      
      expect(allTabs.length, 11);
      expect(allTabs.containsKey('character'), true);
      expect(allTabs.containsKey('quick_guide'), true);
      expect(allTabs.containsKey('stats'), true);
      expect(allTabs.containsKey('skills'), true);
      expect(allTabs.containsKey('attacks'), true);
      expect(allTabs.containsKey('spell_slots'), true);
      expect(allTabs.containsKey('spells'), true);
      expect(allTabs.containsKey('feats'), true);
      expect(allTabs.containsKey('class_slots'), true);
      expect(allTabs.containsKey('appearance'), true);
      expect(allTabs.containsKey('notes'), true);
    });

    test('CharacterTabManager gets tab config by ID', () {
      final characterTab = CharacterTabManager.getTabConfig('character');
      final statsTab = CharacterTabManager.getTabConfig('stats');
      
      expect(characterTab?.id, 'character');
      expect(characterTab?.label, 'Character');
      expect(characterTab?.icon, Icons.shield);
      
      expect(statsTab?.id, 'stats');
      expect(statsTab?.label, 'Stats');
      expect(statsTab?.icon, Icons.bar_chart);
    });

    test('CharacterTabManager returns ordered tabs correctly', () {
      final customOrder = [
        'stats',
        'character',
        'appearance',
        'notes',
      ];
      
      final builders = {
        'stats': () => Container(),
        'character': () => Container(),
        'appearance': () => Container(),
        'notes': () => Container(),
      };
      
      final orderedTabs = CharacterTabManager.getOrderedTabs(customOrder, builders);
      
      expect(orderedTabs.length, 4);
      expect(orderedTabs[0].id, 'stats');
      expect(orderedTabs[1].id, 'character');
      expect(orderedTabs[2].id, 'appearance');
      expect(orderedTabs[3].id, 'notes');
    });

    test('UserPreferences default values', () {
      final preferences = UserPreferences.defaultPreferences();
      
      expect(preferences.characterTabOrder, CharacterTabManager.getDefaultTabOrder());
      expect(preferences.otherSettings, {});
    });

    test('UserPreferences JSON serialization', () {
      final preferences = UserPreferences(
        characterTabOrder: ['stats', 'character', 'appearance'],
        otherSettings: {'theme': 'dark'},
      );
      
      final json = preferences.toJson();
      expect(json['characterTabOrder'], ['stats', 'character', 'appearance']);
      expect(json['otherSettings'], {'theme': 'dark'});
      
      final deserialized = UserPreferences.fromJson(json);
      expect(deserialized.characterTabOrder, ['stats', 'character', 'appearance']);
      expect(deserialized.otherSettings, {'theme': 'dark'});
    });

    test('UserPreferences copyWith works correctly', () {
      final original = UserPreferences(
        characterTabOrder: ['stats', 'character'],
        otherSettings: {'theme': 'dark'},
      );
      
      final updated = original.copyWith(
        characterTabOrder: ['character', 'stats'],
      );
      
      expect(updated.characterTabOrder, ['character', 'stats']);
      expect(updated.otherSettings, {'theme': 'dark'}); // Should remain unchanged
    });

    test('CharacterTabConfig copyWith works correctly', () {
      final original = CharacterTabConfig(
        id: 'test',
        label: 'Test Tab',
        icon: Icons.star,
        builder: () => Container(),
        isVisible: true,
      );
      
      final updated = original.copyWith(
        isVisible: false,
      );
      
      expect(updated.id, 'test');
      expect(updated.label, 'Test Tab');
      expect(updated.icon, Icons.star);
      expect(updated.isVisible, false);
    });

    test('Tab order validation handles invalid IDs', () {
      final invalidOrder = [
        'invalid_tab',
        'character',
        'another_invalid',
        'stats',
      ];
      
      final builders = {
        'character': () => Container(),
        'stats': () => Container(),
      };
      
      final orderedTabs = CharacterTabManager.getOrderedTabs(invalidOrder, builders);
      
      // Should only include valid tabs with builders
      expect(orderedTabs.length, 2);
      expect(orderedTabs[0].id, 'character');
      expect(orderedTabs[1].id, 'stats');
    });

    test('Tab order includes tabs not in order list', () {
      final partialOrder = [
        'stats',
        'character',
      ];
      
      final builders = {
        'stats': () => Container(),
        'character': () => Container(),
        'appearance': () => Container(),
        'notes': () => Container(),
      };
      
      final orderedTabs = CharacterTabManager.getOrderedTabs(partialOrder, builders);
      
      // Should include all tabs with builders, maintaining order for specified ones
      expect(orderedTabs.length, 4);
      expect(orderedTabs[0].id, 'stats');
      expect(orderedTabs[1].id, 'character');
      // The remaining tabs should be added in their default order
      expect(orderedTabs[2].id, 'appearance'); // From default order
      expect(orderedTabs[3].id, 'notes'); // From default order
    });
  });
}
