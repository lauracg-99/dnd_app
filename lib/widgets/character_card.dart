import 'package:flutter/material.dart';

import '../models/character_model.dart';
import 'cached_profile_image.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final List<PopupMenuEntry<String>>? popupMenuItems;
  final void Function(String)? onPopupMenuSelected;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;
  final TextStyle? titleStyle;
  final TextStyle? subtitleTextStyle;
  final Widget? leading;

  const CharacterCard({
    super.key,
    required this.character,
    this.subtitle,
    this.onTap,
    this.popupMenuItems,
    this.onPopupMenuSelected,
    this.trailing,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    this.titleStyle,
    this.subtitleTextStyle,
    this.leading,
  });

  static String defaultSubtitle(Character character) {
    final subclass =
        character.subclass != null && character.subclass!.isNotEmpty
            ? ' (${character.subclass})'
            : '';
    final race =
        character.race != null && character.race!.isNotEmpty
            ? ' • ${character.race}'
            : '';

    return '${character.characterClass}$subclass$race';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Color(0xFFE2E8F0), // Color del borde
          width: 1.0,         // Grosor del borde
        ),
        borderRadius: BorderRadius.circular(12.0), // Radio de las esquinas
      ),
      child: ListTile(
        leading:
            leading ??
            CharacterAvatar(
              base64ImageData: character.customImageData,
              imagePath: character.customImagePath,
              size: 40,
            ),
        title: Text(
          character.name,
          style: titleStyle ?? TextStyle(
            fontWeight: FontWeight.bold, 
            color: const Color(0xFF1A1A1A),
          ),
        ),
        subtitle:
            subtitle ??
            Text(defaultSubtitle(character), style: subtitleTextStyle ?? TextStyle(            
            color: const Color(0xFF4B5563),
          ),),
        trailing:
            trailing ??
            (popupMenuItems != null
                ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: onPopupMenuSelected,
                  itemBuilder: (context) => popupMenuItems!,
                )
                : null),
        onTap: onTap,
      ),
    );
  }
}
