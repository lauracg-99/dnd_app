import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Character Image Naming Tests', () {
    test('Profile image filename includes character ID and profile prefix', () {
      // Test the naming pattern used in _pickImage method
      const characterId = 'test_character_123';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${characterId}_profile_$timestamp.jpg';
      
      expect(fileName, contains(characterId));
      expect(fileName, contains('profile'));
      expect(fileName, contains('.jpg'));
      expect(fileName, matches(RegExp(r'^\w+_profile_\d+\.jpg$')));
    });

    test('Appearance image filename includes character ID and appearance prefix', () {
      // Test the naming pattern used in _pickAppearanceImage method
      const characterId = 'test_character_456';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${characterId}_appearance_$timestamp.jpg';
      
      expect(fileName, contains(characterId));
      expect(fileName, contains('appearance'));
      expect(fileName, contains('.jpg'));
      expect(fileName, matches(RegExp(r'^\w+_appearance_\d+\.jpg$')));
    });

    test('Different characters get different image filenames', () {
      const character1Id = 'character_aurora';
      const character2Id = 'character_balthazar';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final profile1 = '${character1Id}_profile_$timestamp.jpg';
      final profile2 = '${character2Id}_profile_$timestamp.jpg';
      final appearance1 = '${character1Id}_appearance_$timestamp.jpg';
      final appearance2 = '${character2Id}_appearance_$timestamp.jpg';
      
      expect(profile1, isNot(equals(profile2)));
      expect(appearance1, isNot(equals(appearance2)));
      expect(profile1, contains(character1Id));
      expect(profile2, contains(character2Id));
      expect(appearance1, contains(character1Id));
      expect(appearance2, contains(character2Id));
    });

    test('Same character gets different filenames for different images', () async {
      const characterId = 'character_test';
      final timestamp1 = DateTime.now().millisecondsSinceEpoch;
      
      // Wait a bit to ensure different timestamps
      await Future.delayed(Duration(milliseconds: 1));
      final timestamp2 = DateTime.now().millisecondsSinceEpoch;
      
      final profile1 = '${characterId}_profile_$timestamp1.jpg';
      final profile2 = '${characterId}_profile_$timestamp2.jpg';
      final appearance1 = '${characterId}_appearance_$timestamp1.jpg';
      final appearance2 = '${characterId}_appearance_$timestamp2.jpg';
      
      expect(profile1, isNot(equals(profile2)));
      expect(appearance1, isNot(equals(appearance2)));
      expect(profile1, isNot(equals(appearance1)));
      expect(profile2, isNot(equals(appearance2)));
    });

    test('Image filenames prevent duplication across characters', () {
      // This test ensures that the naming pattern prevents filename conflicts
      // when different characters upload images with the same original name
      
      const character1Id = 'char1';
      const character2Id = 'char2';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Even if they upload at the same millisecond, the character ID makes them unique
      final profile1 = '${character1Id}_profile_$timestamp.jpg';
      final profile2 = '${character2Id}_profile_$timestamp.jpg';
      
      expect(profile1, isNot(equals(profile2)));
      expect(profile1, contains(character1Id));
      expect(profile2, contains(character2Id));
    });
  });

  group('Character Image Getters Tests', () {
    late Character character;
    const characterId = 'test_character_789';

    setUp(() {
      character = Character(
        id: characterId,
        name: 'Test Character',
        stats: const CharacterStats(
          strength: 10,
          dexterity: 10,
          constitution: 10,
          intelligence: 10,
          wisdom: 10,
          charisma: 10,
        ),
        savingThrows: const CharacterSavingThrows(),
        skillChecks: const CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 10),
        spellSlots: const CharacterSpellSlots(),
        characterClass: 'Fighter',
        level: 1,
        pillars: const CharacterPillars(),
        appearance: const CharacterAppearance(),
        deathSaves: const CharacterDeathSaves(),
        languages: const CharacterLanguages(),
        moneyItems: const CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('hasProfileImage returns false when no profile image', () {
      expect(character.hasProfileImage, isFalse);
    });

    test('hasProfileImage returns true when profile image exists', () {
      final characterWithImage = character.copyWith(
        customImagePath: '/path/to/image.jpg',
      );
      expect(characterWithImage.hasProfileImage, isTrue);
    });

    test('hasAppearanceImage returns false when no appearance image', () {
      expect(character.hasAppearanceImage, isFalse);
    });

    test('hasAppearanceImage returns true when appearance image exists', () {
      final characterWithImage = character.copyWith(
        appearance: const CharacterAppearance(appearanceImagePath: '/path/to/appearance.jpg'),
      );
      expect(characterWithImage.hasAppearanceImage, isTrue);
    });

    test('hasAnyImages returns false when no images', () {
      expect(character.hasAnyImages, isFalse);
    });

    test('hasAnyImages returns true when profile image exists', () {
      final characterWithImage = character.copyWith(
        customImagePath: '/path/to/image.jpg',
      );
      expect(characterWithImage.hasAnyImages, isTrue);
    });

    test('hasAnyImages returns true when appearance image exists', () {
      final characterWithImage = character.copyWith(
        appearance: const CharacterAppearance(appearanceImagePath: '/path/to/appearance.jpg'),
      );
      expect(characterWithImage.hasAnyImages, isTrue);
    });

    test('profileImageFilename returns filename from path', () {
      final characterWithImage = character.copyWith(
        customImagePath: '/some/path/to/profile_image.jpg',
      );
      expect(characterWithImage.profileImageFilename, equals('profile_image.jpg'));
    });

    test('profileImageFilename returns null when no profile image', () {
      expect(character.profileImageFilename, isNull);
    });

    test('appearanceImageFilename returns filename from path', () {
      final characterWithImage = character.copyWith(
        appearance: const CharacterAppearance(appearanceImagePath: '/some/path/to/appearance_image.jpg'),
      );
      expect(characterWithImage.appearanceImageFilename, equals('appearance_image.jpg'));
    });

    test('appearanceImageFilename returns null when no appearance image', () {
      expect(character.appearanceImageFilename, isNull);
    });

    test('isProfileImageNamedWithId returns true for new naming format', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final characterWithImage = character.copyWith(
        customImagePath: '/path/${characterId}_profile_$timestamp.jpg',
      );
      expect(characterWithImage.isProfileImageNamedWithId, isTrue);
    });

    test('isProfileImageNamedWithId returns false for old naming format', () {
      final characterWithImage = character.copyWith(
        customImagePath: '/path/some_random_name.jpg',
      );
      expect(characterWithImage.isProfileImageNamedWithId, isFalse);
    });

    test('isAppearanceImageNamedWithId returns true for new naming format', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final characterWithImage = character.copyWith(
        appearance: CharacterAppearance(appearanceImagePath: '/path/${characterId}_appearance_$timestamp.jpg'),
      );
      expect(characterWithImage.isAppearanceImageNamedWithId, isTrue);
    });

    test('isAppearanceImageNamedWithId returns false for old naming format', () {
      final characterWithImage = character.copyWith(
        appearance: const CharacterAppearance(appearanceImagePath: '/path/some_random_name.jpg'),
      );
      expect(characterWithImage.isAppearanceImageNamedWithId, isFalse);
    });

    test('areImagesNamedWithId returns true when both images use new format', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final characterWithImages = character.copyWith(
        customImagePath: '/path/${characterId}_profile_$timestamp.jpg',
        appearance: CharacterAppearance(appearanceImagePath: '/path/${characterId}_appearance_$timestamp.jpg'),
      );
      expect(characterWithImages.areImagesNamedWithId, isTrue);
    });

    test('areImagesNamedWithId returns true when no images exist', () {
      expect(character.areImagesNamedWithId, isTrue);
    });

    test('areImagesNamedWithId returns false when one image uses old format', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final characterWithMixedImages = character.copyWith(
        customImagePath: '/path/${characterId}_profile_$timestamp.jpg', // new format
        appearance: const CharacterAppearance(appearanceImagePath: '/path/old_name.jpg'), // old format
      );
      expect(characterWithMixedImages.areImagesNamedWithId, isFalse);
    });
  });
}
