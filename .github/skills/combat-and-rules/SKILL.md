---
name: dnd-combat-rules
description: Use this skill for combat, hit points, armor class, saving throws, skills, and D&D rule calculations in the app.
---

# Combat and rules guidance

## Domain focus

This app includes combat-related values such as HP, AC, speed, saves, skill modifiers, hit dice, and death saves. These values must remain consistent and easy to understand in the UI.

## Rules

- Keep calculations transparent and deterministic.
- Distinguish between permanent values and temporary modifiers to avoid confusion in UI and logic.
- Do not silently override user input; validate and show clear states for invalid values.
- When a feature affects battle or character mechanics, ensure the displayed values and underlying data stay synchronized.

## Common patterns

- Use model fields and derived helpers for modifiers and calculations rather than hardcoded formulas in multiple widgets.
- Keep combat-related formulas near the relevant domain logic or service layer.
- If values are displayed in a form, show the user the exact meaning of each field to reduce confusion.

## Validation

- Check battle-related screens and character sheets after edits.
- Verify that HP/AC/save values persist correctly and are not lost after reload.
- Validate that the UI reflects the current rules state without stale values.
