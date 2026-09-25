---
name: dnd-equipment-and-items
description: Use this skill for equipment, inventory, items, currencies, weapons, and D&D item management in this app.
---

# Equipment and items guidance

## Domain focus

This app includes character equipment, inventory, coins, weapons, and item data that should remain consistent with the rest of the character sheet and game references.

**Key files:**
- `lib/models/character_model.dart` - CharacterAttack, CharacterMoneyItems, CharacterLanguages
- `lib/models/weapon_model.dart` - Weapon data structure with damage dice and properties
- `lib/models/item_model.dart` - Item data structure
- `lib/services/weapon_service.dart` - Weapon data loading and management
- `lib/views/characters/WeaponsTab/` - Weapon-related UI components

## Best practices

- Keep item and equipment data structured and easy to serialize in the existing model layer.
- Preserve user-edited values such as quantity, name, description, and metadata without silently dropping fields.
- Avoid duplicating item logic between widgets and domain services; prefer centralized behavior.
- Keep inventory flows predictable: add, edit, remove, and display states should all behave consistently.

**Equipment model structure:**
- CharacterAttack: name, attackBonus, damage, damageType, properties (list of strings)
- CharacterMoneyItems: copper, silver, electrum, gold, platinum, items (string)
- CharacterLanguages: languages (string)
- Weapon model includes: diceType, damageType, properties, range, weight, and damage dice parsing
- DamageDice class: count, diceType, damageType for multi-dice weapons

## Rules for implementation

- If a new item field is introduced, ensure it is handled by the model, UI, and persistence layers together.
- Respect the current app conventions for local persistence and sync behavior when item data changes.
- Ensure the UI shows meaningful empty states when no equipment or inventory entries exist.

**Weapon-specific patterns:**
- Weapons are stored in Character.attacks list
- Weapon data loaded from JSON via WeaponService
- Damage display uses diceType field (e.g., "1d8 piercing" for Light Crossbow)
- Weapon properties include: two-handed, ranged, ammunition, finesse, etc.
- Attack bonus and damage calculations are user-editable fields

## Validation

- Verify that inventory changes are saved and reloaded correctly.
- Check that equipment values remain coherent with the character sheet.
- Ensure search, listing, and editing views continue to work with item-related data.

**Test commands:**
- `flutter test test/weapons_test.dart` - Tests weapon model and damage display
- Test weapon addition: add weapon to character, verify it appears in attacks list
- Test weapon editing: modify damage, attack bonus, verify persistence
- Test inventory: add items, change currency, verify after reload
