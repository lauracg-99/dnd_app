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

**Test patterns in codebase:**
- Unit tests for model serialization (fromJson/toJson)
- Widget tests with MaterialApp wrapper for widget rendering
- Integration tests for multi-screen flows
- Test-specific data fixtures for realistic test scenarios
- Mock services for Firebase and storage operations
- Test file naming: <feature>_test.dart

## Test types

- Unit tests for pure logic and model transformations.
- Widget tests for UI rendering, interactions, and state changes.
- Integration tests for flows spanning multiple screens or services.

**Test examples from codebase:**
- `ability_changes_test.dart` - Tests ability score modifications
- `shield_bonus_test.dart` - Tests AC calculations with shield bonus
- `weapons_test.dart` - Tests weapon model and damage display
- `spell_search_test.dart` - Tests spell search functionality
- `spell_removal_confirmation_simple_test.dart` - Tests spell removal with confirmation dialog
- `image_crop_widget_test.dart` - Tests image crop widget rendering
- `json_corruption_test.dart` - Tests JSON corruption recovery
- `account_deletion_test.dart` - Tests account deletion flow

## Rules

- Keep test setup minimal and easy to follow.
- Assert on actual user outcomes: text, visible states, navigation, and actions.
- Do not add test-only production methods or code paths solely to satisfy tests.
- When mocking dependencies, mock the lowest level that preserves the real behavior.

**Testing best practices used:**
- MaterialApp wrapper for widget tests to provide theme context
- pumpAndSettle() for async operations in widget tests
- expect() for assertions on widget state and behavior
- testWidgets() for widget testing
- test() for unit testing
- Descriptive test names that explain what is being tested

## Validation

Run the smallest relevant tests first, for example:

- `flutter test test/path/to_file_test.dart`
- `flutter test --plain-name "feature name"`

**Running tests:**
- Run specific test: `flutter test test/spell_search_test.dart`
- Run tests by name: `flutter test --plain-name "spell search"`
- Run all tests: `flutter test`
- Run with coverage: `flutter test --coverage`

**Test coverage areas:**
- Model serialization (all models should have fromJson/toJson tests)
- Service layer (character, spell, weapon services)
- UI interactions (spell search, spell removal, image cropping)
- Edge cases (JSON corruption, account deletion, offline behavior)
