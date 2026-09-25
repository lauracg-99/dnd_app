---
name: flutter-ui
description: Use this skill for widget composition, layouts, navigation, theming, and reusable UI patterns in Flutter.
---

# Flutter UI guidance

## Principles

- Keep widgets small, composable, and easy to reason about.
- Prefer composition over deeply nested widget trees.
- Use `const` for static widgets and values whenever possible.
- Reuse existing widgets and patterns from the project before creating new ones.

## Layout and UX

- Prefer clear layout semantics: `Column`, `Row`, `Expanded`, `Flexible`, `ListView`, `Stack`, etc., according to the actual need.
- Avoid expensive layout work in frequently rebuilt widgets.
- Keep spacing, padding, and sizing consistent with the current app design.
- Use proper navigation patterns and avoid unclear state transitions between screens.

## Visual consistency

- Follow the app's design system and current style patterns.
- Use existing theme colors, text styles, spacing, and widgets where possible.
- Keep screen states explicit: loading, empty, error, and populated.

## Accessibility and usability

- Add proper labels and semantics for actions and important content.
- Ensure tappable controls are large enough and easy to interact with.
- Respect focus order and avoid hidden or misleading interactive elements.
