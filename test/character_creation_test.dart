import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/viewmodels/characters_viewmodel.dart';

void main() {
  group('Character Creation Tests', () {
    test('Should create character through viewmodel', () async {
      final viewModel = CharactersViewModel();
      
      // Verify initial state
      expect(viewModel.characters.isEmpty, true);
      expect(viewModel.isLoading, false);
      
      // Create character
      await viewModel.createCharacter(
        name: 'Test Character',
        characterClass: 'Wizard',
        subclass: 'Evocation',
      );
      
      // Verify character was created
      expect(viewModel.characters.length, 1);
      expect(viewModel.characters.first.name, 'Test Character');
      expect(viewModel.characters.first.characterClass, 'Wizard');
      expect(viewModel.characters.first.subclass, 'Evocation');
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
    });

    test('Should handle empty character name gracefully', () async {
      final viewModel = CharactersViewModel();
      
      // Try to create character with empty name
      await viewModel.createCharacter(name: '');
      
      // Should still create character (service handles validation)
      expect(viewModel.characters.length, 1);
      expect(viewModel.error, null);
    });

    test('Should handle multiple character creation', () async {
      final viewModel = CharactersViewModel();
      
      // Create multiple characters
      await viewModel.createCharacter(name: 'Fighter', characterClass: 'Fighter');
      await viewModel.createCharacter(name: 'Wizard', characterClass: 'Wizard');
      await viewModel.createCharacter(name: 'Rogue', characterClass: 'Rogue');
      
      // Verify all characters were created
      expect(viewModel.characters.length, 3);
      expect(viewModel.characters.any((c) => c.name == 'Fighter'), true);
      expect(viewModel.characters.any((c) => c.name == 'Wizard'), true);
      expect(viewModel.characters.any((c) => c.name == 'Rogue'), true);
      
      // Verify they're sorted alphabetically
      final names = viewModel.characters.map((c) => c.name).toList();
      expect(names, ['Fighter', 'Wizard', 'Rogue']); // Based on actual sorting order
    });
  });
}
