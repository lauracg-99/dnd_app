---
name: dnd-spell-reference
description: Use this skill for spell data, filtering, search, and D&D reference features in this Flutter app.
---

# Spell reference guidance

## Domain context

The app includes a large D&D spell database with filters by level, school, class, casting components, and searching by name or metadata.

**Key files:**
- `lib/models/spell_model.dart` - Spell data structure with level, school, classes, damage dice
- `lib/services/spell_service.dart` - Spell data loading and management
- `lib/views/characters/SpellsTab/` - Spell-related UI components
- `lib/views/spells/spells_list_screen.dart` - Spell reference listing

## Best practices

- Preserve the data model from `lib/models/spell_model.dart` and avoid breaking JSON-backed spell references.
- Keep filtering logic deterministic and easy to test.
- Ensure lists and search results remain responsive even with a large dataset.
- Prefer stable sorting and filtering behavior over ad-hoc UI logic.

**Spell model structure:**
- Spell fields: id, name, level, school, castingTime, range, duration, classes, dice
- Components: verbal, somatic, material (boolean flags)
- Damage parsing: damageDice getter extracts SpellDamageDice from nested JSON
- Level parsing: levelNumber converts "spell_level_X" to integer X
- School parsing: schoolName removes "spell_school_" prefix
- Damage modifier detection: includesDamageModifier checks description text

## Common work patterns

- Add search/filter updates in the view model or service layer, not only inside screen widgets.
- Keep UI labels and filter categories aligned with the spell metadata used in the data model.
- When introducing new spell fields, consider backward compatibility with existing stored/reference data.

**Spell management patterns:**
- Spells stored in Character.spells list (list of spell IDs)
- CharacterSpellPreparation tracks prepared spells, always prepared, and free use spells
- SpellService loads spell data from JSON resources
- Spell filtering supports: level, school, class, character class toggle, and name search
- Search is case-insensitive and works with partial matches
- Spell selection uses checkboxes for multi-selection in character edit screen

## Validation

- Verify search, class filtering, and level filtering still match the expected spells.
- Check empty states, no-result states, and list rendering.
- Ensure performance remains acceptable with the full spell catalog.

**Test commands:**
- `flutter test test/spell_search_test.dart` - Tests spell search functionality
- `flutter test test/spell_removal_confirmation_simple_test.dart` - Tests spell removal with confirmation
- Test spell search: type query, verify results update in real-time
- Test spell filtering: apply level/class filters, verify correct spells shown
- Test spell addition: add spells to character, verify they appear in spell list
- Test spell preparation: mark spells as prepared, verify preparation state persists
