import 'dart:ffi';

import 'package:flutter/material.dart';

/// Helper class for showing SnackBar messages with custom text and colors
class SnackbarHelper {
  /// Shows a SnackBar with the specified message and background color
  /// 
  /// [context] - The build context
  /// [message] - The text message to display
  /// [backgroundColor] - The background color of the SnackBar (default: Colors.green)
  /// [duration] - How long the SnackBar should be displayed (default: 3 seconds)
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 3),
    bool showCloseIcon = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,  
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        showCloseIcon: showCloseIcon, 
      ),
    );
  }

  /// Shows a success SnackBar (green background)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      backgroundColor: Colors.green,
      duration: duration,     
    );
  }

  /// Shows an error SnackBar (red background)
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// Shows an info SnackBar (blue background)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  /// Shows a warning SnackBar (orange background)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  /// Shows a top-positioned notification (appears at the top of the screen)
  /// 
  /// [context] - The build context
  /// [message] - The text message to display
  /// [backgroundColor] - The background color of the notification (default: Colors.green)
  /// [duration] - How long the notification should be displayed (default: 3 seconds)
  static void showTop(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 70,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// Shows a success notification at the top (green background)
  static void showTopSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showTop(
      context,
      message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// Shows an error notification at the top (red background)
  static void showTopError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showTop(
      context,
      message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// Shows an info notification at the top (blue background)
  static void showTopInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showTop(
      context,
      message,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  /// Shows a warning notification at the top (orange background)
  static void showTopWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showTop(
      context,
      message,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }
}
