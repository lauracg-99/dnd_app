---
name: mobile-desktop-ux
description: Use this skill for responsive Flutter UX across mobile, desktop, and web platforms in this D&D app.
---

# Mobile and desktop UX guidance

## Scope

This app supports mobile, desktop, and web experiences. User experience should stay coherent across platforms without over-engineering the code.

**Platform support:**
- iOS: `ios/` directory with Runner configuration
- Android: `android/` directory with Gradle build
- Web: `web/` directory with index.html and manifest
- macOS: `macos/` directory with Runner configuration
- Linux: `linux/` directory with CMakeLists.txt
- Windows: `windows/` directory with CMakeLists.txt

## Best practices

- Use responsive layouts that adapt to screen size without breaking core flows.
- Prefer platform-aware patterns only when they clearly improve the experience.
- Keep keyboard, touch, and pointer interactions consistent across devices.
- Avoid assuming a mobile-only layout when the app supports wider screens.

**Responsive patterns in codebase:**
- SingleChildScrollView for forms to handle different screen heights
- Column/Row with Expanded/Flexible for adaptive layouts
- ListView.builder for scrollable lists that work on all screen sizes
- MediaQuery for screen size detection when needed
- SafeArea to respect device notches and system UI
- Material Design components that adapt to platform automatically

## Rules for implementation

- Ensure controls remain usable on smaller screens and still function on larger displays.
- Keep navigation patterns understandable for both touch and desktop pointer interactions.
- Preserve the existing app structure and avoid introducing platform-specific logic unless necessary.

**Cross-platform considerations:**
- keyboard_actions library works on both iOS and Android for keyboard navigation
- Firebase Auth and Firestore work consistently across all platforms
- File storage uses platform-agnostic paths via path_provider
- Image picker uses image_picker library with cross-platform support
- AutofillGroup in login screen works on iOS and Android password managers
- Material Design components provide platform-appropriate styling automatically

## Validation

- Check that key screens remain usable across different widths and orientations.
- Verify that forms and list views remain readable and interactive in both compact and wide layouts.
- Ensure no platform-specific regression is introduced in shared screens.

**Test commands:**
- Test on iOS simulator: `flutter run -d ios`
- Test on Android emulator: `flutter run -d android`
- Test on web: `flutter run -d chrome`
- Test on macOS: `flutter run -d macos`
- Test responsive layout: resize window during testing
- Test keyboard navigation on desktop platforms
