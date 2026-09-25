---
name: flutter-testing
description: Use this skill for creating and updating tests for Flutter features, bug fixes, and UI behavior.
---

# Flutter testing guidance

## Core principle

Write tests that cover real user-visible behavior, not mocked-only implementation details.

## Expectations

- Prefer targeted tests for the feature or bug being fixed.
- Add or update tests for behavioral changes and regressions.
- Follow TDD when feasible: write the failing test first, then fix the code.
- Use realistic data and screen flows instead of overly artificial mocks.

## Test types

- Unit tests for pure logic and model transformations.
- Widget tests for UI rendering, interactions, and state changes.
- Integration tests for flows spanning multiple screens or services.

## Rules

- Keep test setup minimal and easy to follow.
- Assert on actual user outcomes: text, visible states, navigation, and actions.
- Do not add test-only production methods or code paths solely to satisfy tests.
- When mocking dependencies, mock the lowest level that preserves the real behavior.

## Validation

Run the smallest relevant tests first, for example:

- `flutter test test/path/to_file_test.dart`
- `flutter test --plain-name "feature name"`
