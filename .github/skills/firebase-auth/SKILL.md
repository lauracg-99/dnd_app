---
name: flutter-firebase-auth
description: Use this skill for Firebase Authentication, Firestore, session persistence, and user state flows in a Flutter app.
---

# Firebase and auth guidance

## Scope

Use this skill when working on authentication flows, user sessions, Firestore reads/writes, or app state tied to Firebase.

**Key files:**
- `lib/services/firebase_auth_service.dart` - Authentication state management and sign-in/sign-up
- `lib/views/auth/login_screen.dart` - Login UI with email/password authentication
- `lib/services/remote_config_service.dart` - Remote config for feature flags (allowSignIn, allowRegister)
- `lib/firebase_options.dart` - Firebase configuration
- `lib/main.dart` - Firebase initialization in main()

## Rules

- Prefer the repository's existing auth and service patterns instead of introducing a new abstraction for a small task.
- Keep auth state management predictable and consistent across screens.
- Handle unauthenticated, loading, and error states explicitly in the UI.
- Do not assume Firebase callbacks complete synchronously; guard async flows and state changes.
- Check `mounted` before using `BuildContext` after async work.
- Avoid leaking listeners or duplicate subscriptions when auth state changes.

**Auth service patterns:**
- FirebaseAuthService is a singleton with authStateChanges stream
- signInWithEmail() handles both sign-in and account creation automatically
- RemoteConfigService controls allowSignIn and allowRegister flags
- Auth state is persisted across app restarts via Firebase SDK
- initialAuthState Completer ensures auth state is loaded before app proceeds

## Good patterns

- Centralize Firebase logic in `lib/services` or dedicated repositories.
- Keep UI screens focused on rendering; move auth logic into view models or service classes.
- Use typed models and explicit state objects when the authenticated user or Firestore data is consumed across screens.
- For persistence, ensure token/session recovery and app restarts behave correctly.

**Login screen patterns:**
- LoginScreen uses Form with email/password controllers
- Loading state (_isLoading) prevents multiple simultaneous auth attempts
- Password obscuring toggle for UX
- AutofillGroup for password manager integration
- Error messages displayed via SnackBarHelper
- Remote config flags checked in initState()

## Validation

- Test login/logout flows and session recovery.
- Ensure required error states are displayed to the user.
- Verify that Firestore reads do not trigger unnecessary rebuilds or duplicate requests.

**Test commands:**
- `flutter test test/account_deletion_test.dart` - Tests account deletion flow
- Test login: sign in with valid credentials, verify auth state updates
- Test sign-up: create new account, verify account creation works
- Test session recovery: close app, reopen, verify user remains logged in
- Test logout: sign out, verify auth state clears and local data remains
