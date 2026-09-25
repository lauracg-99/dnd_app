---
name: flutter-ui
description: Use this skill for widget composition, layouts, navigation, theming, and reusable UI patterns in Flutter.
---

# Flutter UI guidance

## Principles

- Keep widgets small, composable, and easy to reason about.
- Prefer composition over deeply nested widget trees.
- Use `const` for static widgets and values whenever possible.
- Reuse existing widgets and patterns from the project before creating new ones.

**UI patterns in codebase:**
- Material Design components (Scaffold, AppBar, Card, ListTile, etc.)
- Form widgets with Form and GlobalKey for validation
- TextField with TextEditingController for input management
- FocusNode for keyboard navigation (keyboard_actions library)
- SnackBarHelper for consistent user feedback
- Dismissible widgets for swipe-to-delete (with confirmDismiss for confirmation)
- TabBar and TabBarView for tabbed interfaces
- Custom widgets like ImageCropWidget for specialized functionality

## Layout and UX

- Prefer clear layout semantics: `Column`, `Row`, `Expanded`, `Flexible`, `ListView`, `Stack`, etc., according to the actual need.
- Avoid expensive layout work in frequently rebuilt widgets.
- Keep spacing, padding, and sizing consistent with the current app design.
- Use proper navigation patterns and avoid unclear state transitions between screens.

**Navigation patterns:**
- Navigator.push() for screen transitions
- Navigator.pop() with return values for data flow back
- Parent widgets handle navigation context (see ImageCropWidget pattern)
- Tab-based navigation in character edit screen
- AutofillGroup for password manager integration in login screen

## Visual consistency

- Follow the app's design system and current style patterns.
- Use existing theme colors, text styles, spacing, and widgets where possible.
- Keep screen states explicit: loading, empty, error, and populated.

**State patterns:**
- Loading state: _isLoading boolean with CircularProgressIndicator
- Empty states: conditional rendering when lists are empty
- Error states: try-catch with SnackBar error messages
- Populated states: ListView.builder for large lists
- Real-time updates: setState() for immediate UI feedback

## Accessibility and usability

- Add proper labels and semantics for actions and important content.
- Ensure tappable controls are large enough and easy to interact with.
- Respect focus order and avoid hidden or misleading interactive elements.

**Accessibility features implemented:**
- keyboard_actions library for keyboard navigation between form fields
- FocusNode management for all text input fields
- Semantics labels on important interactive elements
- Password obscuring toggle for login screen
- Confirmation dialogs for destructive actions (spell removal)
- Clear error messages via SnackBar
