---
name: firebase-sync
description: Use this skill for cross-device sync, Firestore persistence, offline behavior, and user-account data synchronization in this D&D app.
---

# Firebase sync guidance

## Scope

This app stores character data locally and syncs user data with Firebase, so changes must be safe across restarts and multiple sessions.

**Key files:**
- `lib/services/cloud_sync_service.dart` - Cloud sync orchestration with Firestore
- `lib/services/character_service.dart` - Local character storage
- `lib/services/diary_service.dart` - Local diary storage
- `lib/models/character_model.dart` - Character data structure
- `lib/models/diary_model.dart` - Diary data structure

## Rules

- Prefer consistent service-layer sync logic over direct Firestore calls from widgets.
- Handle loading, no-user, offline, and error states explicitly.
- Ensure local data does not silently conflict with remote data without a clear merge strategy.
- Preserve user/session identity across app restarts and cloud sync operations.
- Keep sync-related logic observable and easy to test in the project’s existing architecture.

## Good patterns

- Centralize `Firestore`, auth, and sync workflows in service classes.
- Keep UI screens focused on presentation and user actions.
- Validate sync behavior for create, update, delete, and recovery scenarios.

**Firestore collections:**
- 'characters' collection stores character documents
- 'diaries' collection stores diary documents
- 'devices' collection tracks device information
- Documents keyed by character/diary IDs
- User-scoped data via user UID in document paths
- Timestamps (createdAt, updatedAt) for conflict resolution

## Validation

- Test user login/logout and the app behavior when data is resynced.
- Check edge cases like offline mode, missing user data, and stale local state.
- Confirm that character editing and cloud sync remain consistent without duplicate writes.

**Test scenarios:**
- Test sync on login: sign in, verify characters/diaries sync from cloud
- Test sync on edit: edit character on device A, verify syncs to device B
- Test offline mode: edit while offline, verify syncs when connection restored
- Test conflict resolution: edit same character on two devices, verify merge behavior
- Test logout: sign out, verify sync stops and local data remains accessible
