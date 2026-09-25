---
name: flutter-accessibility
description: Use this skill for accessible Flutter UI, semantics, keyboard support, and inclusive user experiences.
---

# Accessibility guidance

## Principles

- Build interfaces that work well for screen readers, keyboard users, and users with visual or motor impairments.
- Treat accessibility as part of the feature, not a late add-on.

## Good practices

- Provide meaningful labels and semantics for interactive elements.
- Use semantic widgets appropriately for buttons, form fields, and navigation items.
- Ensure contrast and readable text sizing are adequate.
- Keep interactive targets large enough and clearly distinguishable.
- Preserve focus order and avoid surprising focus jumps.

## For Flutter specifically

- Use `Semantics` and text labels when necessary.
- Prefer material widgets that already include standard semantics when possible.
- Ensure error states and validation messages are announced properly.
- Avoid hidden controls that are only discoverable by color or position.

## Validation

Review the screen for discoverability, label quality, focus behavior, and general usability without relying on visual clues alone.