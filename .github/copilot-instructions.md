# Copilot instructions for this Flutter project

## General guidance

- Work in a minimal, focused way and respect the current architecture of the app.
- Prefer existing patterns and files already used in the repository.
- Keep changes small, readable, and aligned with the current codebase.
- Do not introduce broad refactors unless the task explicitly requires it.

## Flutter and Dart

- Prefer idiomatic Dart and Flutter patterns.
- Use `const` and `final` when appropriate.
- Keep widgets small and reusable.
- Avoid expensive work inside `build`.
- Respect null safety and avoid unsafe assumptions.
- Handle async code with proper `try/catch` and error states.

## Project structure

- Keep domain logic in `lib/models`, `lib/services`, and `lib/viewmodels`.
- Keep UI in `lib/views` and `lib/widgets`.
- Reuse existing helpers and utilities instead of duplicating logic.

## Testing

- Add or update tests for behavioral changes and bug fixes.
- Prefer targeted validation and focused tests.
- Use TDD when feasible: write the failing test first, then fix the bug.

## Validation

Before concluding work, validate with the smallest relevant commands, such as:

- `dart format .`
- `flutter analyze`
- `flutter test <targeted_test_path>`
