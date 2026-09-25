---
name: dnd-character-sheet
description: Use this skill for D&D 5e character creation, stats, skill modifiers, health tracking, and character-sheet editing in this app.
---

# D&D character sheet guidance

## Domain rules

This app manages D&D 5e characters, including attributes, combat stats, class/race/background details, equipment, notes, and roleplaying data.

**Key files:**
- `lib/models/character_model.dart` - Character model with all stats, appearance, pillars, spells, attacks
- `lib/services/character_service.dart` - Character CRUD operations and validation
- `lib/views/characters/character_edit_screen.dart` - Main character editing interface
- `lib/views/characters/character_create_screen.dart` - Character creation flow
- `lib/helpers/character_helper.dart` - Character-related helper functions

## Core expectations

- Preserve character data integrity when editing attributes like ability scores, HP, AC, speed, hit dice, and death saves.
- Keep model fields consistent with the existing character structure in `lib/models/character_model.dart` and related model classes.
- When a change affects derived values, update the relevant calculations and avoid mismatched state between UI and model data.
- Be careful with values that are user-editable and can be blank, negative, or temporarily invalid.

**Character model structure:**
- Core stats: CharacterStats (abilities, proficiency, AC, speed)
- Health: CharacterHealth (maxHP, currentHP, tempHP, hitDice, hitDiceType)
- Combat: CharacterSavingThrows, CharacterSkillChecks, CharacterDeathSaves
- Narrative: CharacterPillars (gimmick, quirk, wants, needs, conflict), CharacterAppearance
- Spells: CharacterSpellSlots, CharacterSpellPreparation, spells list
- Equipment: CharacterAttack list, CharacterMoneyItems, CharacterLanguages
- Roleplaying: backstory, quickGuide, proficiencies, featuresTraits, featNotes

## Recommended approach

- Put domain logic in service or view-model layers instead of embedding rules directly inside widgets.
- Maintain the current repository patterns rather than introducing a new architecture for a small change.
- Treat health, temporary HP, hit dice, and death saves as stateful combat data, not just labels.
- Keep roleplaying details, appearance, backstory, and notes separate from mechanical character data when possible.

**Service patterns:**
- Use CharacterService.createCharacter() for new characters with level validation (1-20)
- Use CharacterService.saveCharacter() for all persistence operations
- CharacterStorageService handles JSON serialization and file I/O
- CharacterService.loadAllCharacters() retrieves all stored characters
- Auto-save is implemented in character edit screen for real-time persistence

## Validation

- Verify that changes update the displayed sheet correctly across tabs.
- Check that saved character data still loads correctly after restart.
- Ensure edits remain consistent with the app’s current character validation rules.

**Test commands:**
- `flutter test test/ability_changes_test.dart` - Tests ability score modifications
- `flutter test test/shield_bonus_test.dart` - Tests AC calculations with shield
- Test character creation flow: create character, edit stats, save, reload
- Test auto-save: edit character, close app, reopen to verify persistence
- Verify image persistence: test customImagePath and appearanceImagePath fields
