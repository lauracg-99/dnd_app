---
name: dnd-character-sheet
description: Use this skill for D&D 5e character creation, stats, skill modifiers, health tracking, and character-sheet editing in this app.
---

# D&D character sheet guidance

## Domain rules

This app manages D&D 5e characters, including attributes, combat stats, class/race/background details, equipment, notes, and roleplaying data.

## Core expectations

- Preserve character data integrity when editing attributes like ability scores, HP, AC, speed, hit dice, and death saves.
- Keep model fields consistent with the existing character structure in `lib/models/character_model.dart` and related model classes.
- When a change affects derived values, update the relevant calculations and avoid mismatched state between UI and model data.
- Be careful with values that are user-editable and can be blank, negative, or temporarily invalid.

## Recommended approach

- Put domain logic in service or view-model layers instead of embedding rules directly inside widgets.
- Maintain the current repository patterns rather than introducing a new architecture for a small change.
- Treat health, temporary HP, hit dice, and death saves as stateful combat data, not just labels.
- Keep roleplaying details, appearance, backstory, and notes separate from mechanical character data when possible.

## Validation

- Verify that changes update the displayed sheet correctly across tabs.
- Check that saved character data still loads correctly after restart.
- Ensure edits remain consistent with the app’s current character validation rules.
