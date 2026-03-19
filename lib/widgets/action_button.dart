import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A reusable action button component with consistent styling
/// Used throughout the app for primary action buttons
class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Color? shadowColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Size? minimumSize;
  final MainAxisAlignment alignment;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.shadowColor,
    this.padding,
    this.borderRadius,
    this.minimumSize,
    this.alignment = MainAxisAlignment.end,
  });

  /// Creates a primary action button with default styling
  factory ActionButton.primary({
    required BuildContext context,
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return ActionButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 3,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      borderRadius: BorderRadius.circular(12),
      minimumSize: const Size(0, 45),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 18,
            color: foregroundColor ?? Colors.white,
          ),
          label: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: foregroundColor ?? Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: elevation,
            shadowColor: shadowColor,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
            minimumSize: minimumSize,
          ),
        ),
      ],
    );
  }
}
