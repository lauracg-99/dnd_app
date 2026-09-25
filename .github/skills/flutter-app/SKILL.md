---
name: flutter-app-development
description: Use this skill when working on a Flutter/Dart app, including UI, state, Firebase, testing, and app-quality improvements.
---

# Flutter app development guide

## Project context

This repository is a Flutter application. Keep all work aligned with the existing project structure and app conventions.

### Preferred project layout

- `lib/models`: domain models and data structures.
- `lib/services`: Firebase, persistence, network, and business logic.
- `lib/viewmodels`: state and presentation logic.
- `lib/views`: screens/pages.
- `lib/widgets`: reusable UI components.
- `lib/helpers` and `lib/utils`: shared support logic.

## Coding standards

- Prefer idiomatic Dart and Flutter patterns.
- Use `final` and `const` whenever appropriate.
- Keep widget trees readable and modular; prefer small reusable widgets.
- Avoid unnecessary rebuilds and avoid expensive work inside `build`.
- Handle async operations with `try/catch` and clear error handling.
- Respect null safety and avoid forced unwraps unless there is a justified reason.
- Keep logic separated from UI when possible; avoid placing business logic directly in widgets.

## Flutter-specific best practices

- Prefer existing patterns already used in the codebase over introducing a new architecture for a small change.
- Use `Key` values when required for stable widget identity.
- Prefer `AsyncSnapshot` and proper loading/error states for async UI flows.
- When dealing with Firebase, ensure auth/session and persistence flows are resilient and observable.
- Check mounted state before using `BuildContext` after async operations.
- Keep accessibility in mind: labels, semantics, focus order, and touch targets matter.

## Testing requirements

- Add or update tests for bug fixes and behavioral changes.
- Prefer focused, deterministic tests over broad and flaky ones.
- Use TDD when possible: write the failing test first, then implement the fix.
- Validate with the smallest relevant command, such as a specific test file or widget test.

## Validation workflow

Before concluding work, run the relevant checks:

- `dart format .`
- `flutter analyze`
- `flutter test <targeted_test_or_path>`

If a full suite is needed, keep the scope justified and document the reason.

## Change hygiene

- Make the smallest possible change that solves the root cause.
- Avoid unrelated refactors in the same patch.
- Preserve existing behavior unless the task explicitly requires change.
- Do not add test-only production code just to satisfy tests.

## Output expectations

When implementing a change, provide:

1. A short description of the root cause.
2. The exact fix applied.
3. The validation command(s) run.
4. Any follow-up notes or risks.
