---
name: user-account-and-security
description: Use this skill for user accounts, authentication, privacy, session handling, account deletion, and safe user-data flows in this app.
---

# User account and security guidance

## Scope

This app includes authentication, account management, and sensitive user-related data. Security and state consistency are critical.

## Best practices

- Keep login, logout, account deletion, and session restoration flows explicit and testable.
- Ensure the app behaves safely when the user is unauthenticated, offline, or when session recovery fails.
- Do not expose user data or account actions through unsafe UI flows.
- Keep account-related actions centralized in service or auth-oriented layers instead of scattered across screens.

## Rules for implementation

- Validate auth and account states before showing sensitive content or data actions.
- Handle deletion and recovery flows with clear confirmation and error handling.
- Preserve privacy expectations: user data should be removed or migrated consistently when required.

## Validation

- Check login/logout, session restoration, and account deletion flows.
- Ensure user-facing errors are clear and non-destructive.
- Verify that protected data only appears when the user is properly authenticated.
