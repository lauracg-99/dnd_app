---
name: user-account-and-security
description: Use this skill for user accounts, authentication, privacy, session handling, account deletion, and safe user-data flows in this app.
---

# User account and security guidance

## Scope

This app includes authentication, account management, and sensitive user-related data. Security and state consistency are critical.

**Key files:**
- `lib/services/firebase_auth_service.dart` - Authentication and session management
- `lib/views/auth/login_screen.dart` - Login UI with account creation
- `lib/services/cloud_sync_service.dart` - User data synchronization
- `lib/services/remote_config_service.dart` - Feature flags for auth controls
- `test/account_deletion_test.dart` - Account deletion flow tests

## Best practices

- Keep login, logout, account deletion, and session restoration flows explicit and testable.
- Ensure the app behaves safely when the user is unauthenticated, offline, or when session recovery fails.
- Do not expose user data or account actions through unsafe UI flows.
- Keep account-related actions centralized in service or auth-oriented layers instead of scattered across screens.

**Security patterns in codebase:**
- Remote config controls (allowSignIn, allowRegister) for auth feature toggling
- Firebase Auth handles password security and session tokens
- User data scoped by UID in Firestore collections
- Local data remains accessible when offline (characters, diaries)
- Account deletion requires explicit confirmation
- Auth state persists across app restarts via Firebase SDK

## Rules for implementation

- Validate auth and account states before showing sensitive content or data actions.
- Handle deletion and recovery flows with clear confirmation and error handling.
- Preserve privacy expectations: user data should be removed or migrated consistently when required.

**Account management flows:**
- Login: signInWithEmail() handles both sign-in and account creation
- Logout: Firebase signOut() clears auth state, local data remains
- Session recovery: initialAuthState Completer ensures auth loaded before app proceeds
- Account deletion: requires confirmation, removes user data from Firebase
- Offline behavior: local data accessible, sync resumes when online
- Privacy: user data isolated by UID, no cross-user data access

## Validation

- Check login/logout, session restoration, and account deletion flows.
- Ensure user-facing errors are clear and non-destructive.
- Verify that protected data only appears when the user is properly authenticated.

**Test commands:**
- `flutter test test/account_deletion_test.dart` - Tests account deletion flow
- Test login: sign in with valid/invalid credentials, verify error handling
- Test logout: sign out, verify auth state clears and local data remains
- Test session recovery: close app, reopen, verify user remains logged in
- Test offline: disconnect network, verify local data still accessible
- Test remote config: toggle allowSignIn/allowRegister, verify auth controls
