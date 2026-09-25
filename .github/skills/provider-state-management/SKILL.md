---
name: flutter-provider-state
description: Use this skill for state management, view models, provider usage, and UI reactivity in this Flutter app.
---

# Provider state management guidance

## Project context

This repository uses the Provider pattern for state management. Keep the app’s state flow consistent with that architecture.

## Principles

- Keep state changes predictable and localized to the relevant view model or service.
- Avoid spreading business logic directly across widgets and screens.
- Prefer exposing clear state and actions instead of many ad-hoc setters.
- Use loading, empty, and error states for async operations.

## Good practices

- Keep view models responsible for screen state and domain behavior.
- Reuse the same model/service patterns already present in the codebase.
- Do not introduce alternative state management patterns unless the task clearly requires it.

## Validation

- Ensure UI updates react to observable state changes without stale values.
- Verify that async flows do not leave stale loading or error states behind.
- Check that state transitions remain correct when navigating, editing, saving, and reloading character data.
