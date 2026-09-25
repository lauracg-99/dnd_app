---
name: flutter-firebase-auth
description: Use this skill for Firebase Authentication, Firestore, session persistence, and user state flows in a Flutter app.
---

# Firebase and auth guidance

## Scope

Use this skill when working on authentication flows, user sessions, Firestore reads/writes, or app state tied to Firebase.

## Rules

- Prefer the repository's existing auth and service patterns instead of introducing a new abstraction for a small task.
- Keep auth state management predictable and consistent across screens.
- Handle unauthenticated, loading, and error states explicitly in the UI.
- Do not assume Firebase callbacks complete synchronously; guard async flows and state changes.
- Check `mounted` before using `BuildContext` after async work.
- Avoid leaking listeners or duplicate subscriptions when auth state changes.

## Good patterns

- Centralize Firebase logic in `lib/services` or dedicated repositories.
- Keep UI screens focused on rendering; move auth logic into view models or service classes.
- Use typed models and explicit state objects when the authenticated user or Firestore data is consumed across screens.
- For persistence, ensure token/session recovery and app restarts behave correctly.

## Validation

- Test login/logout flows and session recovery.
- Ensure required error states are displayed to the user.
- Verify that Firestore reads do not trigger unnecessary rebuilds or duplicate requests.
