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

**Performance patterns in codebase:**
- ListView.builder for spell lists and character lists
- Debounce timers (5 seconds) in CloudSyncService to prevent excessive Firebase writes
- Cache maps (_lastKnownCharacters, _lastKnownDiaries) to detect actual data changes
- mounted checks before setState() to prevent rebuilds on disposed widgets
- WidgetsBinding.instance.addPostFrameCallback for deferred initialization
- StreamController.broadcast() for efficient state broadcasting

## Watch for

- large widget trees rebuilt on unrelated state changes
- repeated network or Firestore calls due to missing guards
- unbounded lists or unfiltered data rendering
- heavy work triggered during animation or scroll callbacks

**Specific performance considerations:**
- Spell search filters in real-time with setState() - consider debouncing for large spell lists
- Character edit screen auto-saves on every field change - ensure this doesn't cause performance issues
- Image cropping processes full-resolution images - consider compression for large images
- Real-time sync listeners for characters and diaries - cache changes to avoid unnecessary rebuilds
- JSON corruption recovery adds validation overhead - only run when needed

## Validation

Review whether the change reduces redraws or avoids repeated expensive operations. Prefer simpler code that preserves responsiveness without broad refactors.