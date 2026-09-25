---
name: dnd-spell-reference
description: Use this skill for spell data, filtering, search, and D&D reference features in this Flutter app.
---

# Spell reference guidance

## Domain context

The app includes a large D&D spell database with filters by level, school, class, casting components, and searching by name or metadata.

## Best practices

- Preserve the data model from `lib/models/spell_model.dart` and avoid breaking JSON-backed spell references.
- Keep filtering logic deterministic and easy to test.
- Ensure lists and search results remain responsive even with a large dataset.
- Prefer stable sorting and filtering behavior over ad-hoc UI logic.

## Common work patterns

- Add search/filter updates in the view model or service layer, not only inside screen widgets.
- Keep UI labels and filter categories aligned with the spell metadata used in the data model.
- When introducing new spell fields, consider backward compatibility with existing stored/reference data.

## Validation

- Verify search, class filtering, and level filtering still match the expected spells.
- Check empty states, no-result states, and list rendering.
- Ensure performance remains acceptable with the full spell catalog.
