---
name: mobile-desktop-ux
description: Use this skill for responsive Flutter UX across mobile, desktop, and web platforms in this D&D app.
---

# Mobile and desktop UX guidance

## Scope

This app supports mobile, desktop, and web experiences. User experience should stay coherent across platforms without over-engineering the code.

## Best practices

- Use responsive layouts that adapt to screen size without breaking core flows.
- Prefer platform-aware patterns only when they clearly improve the experience.
- Keep keyboard, touch, and pointer interactions consistent across devices.
- Avoid assuming a mobile-only layout when the app supports wider screens.

## Rules for implementation

- Ensure controls remain usable on smaller screens and still function on larger displays.
- Keep navigation patterns understandable for both touch and desktop pointer interactions.
- Preserve the existing app structure and avoid introducing platform-specific logic unless necessary.

## Validation

- Check that key screens remain usable across different widths and orientations.
- Verify that forms and list views remain readable and interactive in both compact and wide layouts.
- Ensure no platform-specific regression is introduced in shared screens.
