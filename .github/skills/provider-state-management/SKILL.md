---
name: flutter-provider-state
description: Use this skill for state management, view models, provider usage, and UI reactivity in this Flutter app.
---

# Provider state management guidance

## Project context

This repository uses the Provider pattern for state management. Keep the app’s state flow consistent with that architecture.

**State management in codebase:**
- Minimal use of Provider - most state is managed locally in StatefulWidget
- Character edit screen uses local state with setState() for form fields
- Services are singletons (FirebaseAuthService, CloudSyncService) for global state
- Streams for auth state (FirebaseAuthService.authStateChanges)
- Streams for sync status (CloudSyncService.syncStatus)
- Auto-save in character edit screen triggers on field changes

## Principles

- Keep state changes predictable and localized to the relevant view model or service.
- Avoid spreading business logic directly across widgets and screens.
- Prefer exposing clear state and actions instead of many ad-hoc setters.
- Use loading, empty, and error states for async operations.

**State patterns used:**
- StatefulWidget with setState() for local UI state
- Singleton services for global app state (auth, sync)
- StreamController.broadcast() for state broadcasting
- Completer for async state initialization
- mounted checks before setState() to prevent errors
- Auto-save pattern for real-time persistence

## Good practices

- Keep view models responsible for screen state and domain behavior.
- Reuse the same model/service patterns already present in the codebase.
- Do not introduce alternative state management patterns unless the task clearly requires it.

**Service layer state management:**
- FirebaseAuthService: singleton with authStateChanges stream
- CloudSyncService: singleton with syncStatus stream and cache maps
- CharacterService: static methods for CRUD operations
- SpellService, WeaponService: static methods for data loading
- Services handle business logic, widgets handle UI state
- No view models in current architecture - state managed in widgets

## Validation

- Ensure UI updates react to observable state changes without stale values.
- Verify that async flows do not leave stale loading or error states behind.
- Check that state transitions remain correct when navigating, editing, saving, and reloading character data.

**State validation scenarios:**
- Test auth state changes: login/logout, verify UI updates correctly
- Test sync status changes: connected/syncing/error, verify status indicators update
- Test character edit: edit fields, verify auto-save triggers and state persists
- Test spell search: type query, verify list updates in real-time
- Test mounted checks: navigate away during async operation, verify no errors
