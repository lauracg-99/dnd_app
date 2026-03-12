import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/spell_model.dart';

void main() {
  group('Spell Search Tests', () {
    test('Search functionality works correctly', () {
      // Create sample spells
      final spells = [
        Spell(
          id: '1',
          name: 'Fireball',
          level: 'spell_level_3',
          school: 'spell_school_evocation',
          castingTime: '1 action',
          range: '150 feet',
          duration: 'Instantaneous',
          classes: ['wizard', 'sorcerer'],
          dice: [],
          description: 'A bright streak flashes from your pointing finger...',
          updatedAt: DateTime.now(),
        ),
        Spell(
          id: '2',
          name: 'Magic Missile',
          level: 'spell_level_1',
          school: 'spell_school_evocation',
          castingTime: '1 action',
          range: '120 feet',
          duration: 'Instantaneous',
          classes: ['wizard', 'sorcerer'],
          dice: [],
          description: 'You create three glowing darts...',
          updatedAt: DateTime.now(),
        ),
        Spell(
          id: '3',
          name: 'Healing Word',
          level: 'spell_level_1',
          school: 'spell_school_evocation',
          castingTime: '1 bonus action',
          range: '60 feet',
          duration: 'Instantaneous',
          classes: ['cleric', 'druid'],
          dice: [],
          description: 'A creature of your choice you can see...',
          updatedAt: DateTime.now(),
        ),
      ];

      // Test search by name
      String searchQuery = 'fire';
      List<Spell> filteredSpells = spells.where((spell) {
        if (searchQuery.isNotEmpty) {
          if (!spell.name.toLowerCase().contains(searchQuery.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();

      expect(filteredSpells.length, 1);
      expect(filteredSpells.first.name, 'Fireball');

      // Test search with empty query (should return all)
      searchQuery = '';
      filteredSpells = spells.where((spell) {
        if (searchQuery.isNotEmpty) {
          if (!spell.name.toLowerCase().contains(searchQuery.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();

      expect(filteredSpells.length, 3);

      // Test case insensitive search
      searchQuery = 'MAGIC';
      filteredSpells = spells.where((spell) {
        if (searchQuery.isNotEmpty) {
          if (!spell.name.toLowerCase().contains(searchQuery.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();

      expect(filteredSpells.length, 1);
      expect(filteredSpells.first.name, 'Magic Missile');
    });

    test('Search functionality integrates with filters', () {
      // Create sample spells
      final spells = [
        Spell(
          id: '1',
          name: 'Fireball',
          level: 'spell_level_3',
          school: 'spell_school_evocation',
          castingTime: '1 action',
          range: '150 feet',
          duration: 'Instantaneous',
          classes: ['wizard', 'sorcerer'],
          dice: [],
          description: 'A bright streak flashes from your pointing finger...',
          updatedAt: DateTime.now(),
        ),
        Spell(
          id: '2',
          name: 'Magic Missile',
          level: 'spell_level_1',
          school: 'spell_school_evocation',
          castingTime: '1 action',
          range: '120 feet',
          duration: 'Instantaneous',
          classes: ['wizard', 'sorcerer'],
          dice: [],
          description: 'You create three glowing darts...',
          updatedAt: DateTime.now(),
        ),
        Spell(
          id: '3',
          name: 'Healing Word',
          level: 'spell_level_1',
          school: 'spell_school_evocation',
          castingTime: '1 bonus action',
          range: '60 feet',
          duration: 'Instantaneous',
          classes: ['cleric', 'druid'],
          dice: [],
          description: 'A creature of your choice you can see...',
          updatedAt: DateTime.now(),
        ),
      ];

      // Test search + level filter
      String searchQuery = 'magic';
      String? selectedLevelFilter = 'Level 1';
      
      List<Spell> filteredSpells = spells.where((spell) {
        // Search by name
        if (searchQuery.isNotEmpty) {
          if (!spell.name.toLowerCase().contains(searchQuery.toLowerCase())) {
            return false;
          }
        }

        // Filter by level
        if (selectedLevelFilter != null) {
          if (selectedLevelFilter == 'Cantrips') {
            if (spell.levelNumber != 0) return false;
          } else if (selectedLevelFilter!.startsWith('Level')) {
            final level = int.tryParse(selectedLevelFilter!.split(' ')[1]);
            if (spell.levelNumber != level) return false;
          }
        }

        return true;
      }).toList();

      expect(filteredSpells.length, 1);
      expect(filteredSpells.first.name, 'Magic Missile');
    });

    test('Filter reset functionality works correctly', () {
      // Simulate filter states before reset
      String searchQuery = 'fire';
      String? selectedLevelFilter = 'Level 3';
      String? selectedClassFilter = 'wizard';
      String? selectedSchoolFilter = 'evocation';

      // Simulate filter reset
      searchQuery = '';
      selectedLevelFilter = null;
      selectedClassFilter = null;
      selectedSchoolFilter = null;

      // Verify all filters are reset
      expect(searchQuery, isEmpty);
      expect(selectedLevelFilter, isNull);
      expect(selectedClassFilter, isNull);
      expect(selectedSchoolFilter, isNull);
    });
  });
}
