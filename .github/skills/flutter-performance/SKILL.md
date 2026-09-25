---
name: flutter-performance
description: Use this skill for optimizing Flutter apps, reducing rebuilds, and improving responsiveness and efficiency.
---

# Flutter performance guidance

## Goals

Keep the app responsive and minimize unnecessary work in builds, lists, and async flows.

## Best practices

- Use `const` constructors and immutable widgets where possible.
- Avoid expensive computations inside `build`.
- Keep rebuild scope tight by splitting widgets and using the correct state management approach.
- Use `ListView.builder` and lazy rendering for large collections.
- Avoid unnecessary re-creation of objects, especially in frequently rebuilt UI.
- Cache images and reuse expensive resources when appropriate.

## Watch for

- large widget trees rebuilt on unrelated state changes
- repeated network or Firestore calls due to missing guards
- unbounded lists or unfiltered data rendering
- heavy work triggered during animation or scroll callbacks

## Validation

Review whether the change reduces redraws or avoids repeated expensive operations. Prefer simpler code that preserves responsiveness without broad refactors.