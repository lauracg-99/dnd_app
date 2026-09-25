---
name: flutter-accessibility
description: Use this skill for accessible Flutter UI, semantics, keyboard support, and inclusive user experiences.
---

# Accessibility guidance

## Principles

- Build interfaces that work well for screen readers, keyboard users, and users with visual or motor impairments.
- Treat accessibility as part of the feature, not a late add-on.

**Accessibility features in codebase:**
- keyboard_actions library for keyboard navigation between form fields
- FocusNode management for all 33 text input fields in character edit screen
- Next/Previous buttons for keyboard navigation
- Done/Close buttons to dismiss keyboard
- Semantics labels on important interactive elements
- Password obscuring toggle for login screen
- Confirmation dialogs for destructive actions (spell removal)
- Clear error messages via SnackBar for screen reader announcements

## Good practices

- Provide meaningful labels and semantics for interactive elements.
- Use semantic widgets appropriately for buttons, form fields, and navigation items.
- Ensure contrast and readable text sizing are adequate.
- Keep interactive targets large enough and clearly distinguishable.
- Preserve focus order and avoid surprising focus jumps.

**Specific implementations:**
- Character edit screen: 33 FocusNodes for all form fields
- KeyboardActionsConfig with custom toolbar for text fields
- AutofillGroup in login screen for password manager integration
- TextField with proper keyboardType (emailAddress, number, text)
- Dismissible widgets with confirmDismiss for swipe-to-delete confirmation
- AlertDialog with clear titles and content for destructive actions

## For Flutter specifically

- Use `Semantics` and text labels when necessary.
- Prefer material widgets that already include standard semantics when possible.
- Ensure error states and validation messages are announced properly.
- Avoid hidden controls that are only discoverable by color or position.

**Flutter accessibility patterns used:**
- Material Design widgets (Scaffold, AppBar, TextField, etc.) include built-in semantics
- SnackBar for announcements that screen readers can detect
- Focus management with FocusNode for keyboard navigation
- Proper label text in TextField widgets
- Icon buttons with tooltips for discoverability
- Clear visual indicators (loading spinners, success/error messages)

## Validation

Review the screen for discoverability, label quality, focus behavior, and general usability without relying on visual clues alone.