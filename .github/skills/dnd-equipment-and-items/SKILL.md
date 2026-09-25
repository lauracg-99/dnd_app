---
name: dnd-equipment-and-items
description: Use this skill for equipment, inventory, items, currencies, weapons, and D&D item management in this app.
---

# Equipment and items guidance

## Domain focus

This app includes character equipment, inventory, coins, weapons, and item data that should remain consistent with the rest of the character sheet and game references.

## Best practices

- Keep item and equipment data structured and easy to serialize in the existing model layer.
- Preserve user-edited values such as quantity, name, description, and metadata without silently dropping fields.
- Avoid duplicating item logic between widgets and domain services; prefer centralized behavior.
- Keep inventory flows predictable: add, edit, remove, and display states should all behave consistently.

## Rules for implementation

- If a new item field is introduced, ensure it is handled by the model, UI, and persistence layers together.
- Respect the current app conventions for local persistence and sync behavior when item data changes.
- Ensure the UI shows meaningful empty states when no equipment or inventory entries exist.

## Validation

- Verify that inventory changes are saved and reloaded correctly.
- Check that equipment values remain coherent with the character sheet.
- Ensure search, listing, and editing views continue to work with item-related data.
