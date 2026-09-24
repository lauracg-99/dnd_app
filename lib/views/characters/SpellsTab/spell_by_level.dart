import 'package:dnd_app/l10n/app_localizations.dart';
import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/character_model.dart';
import '../../../models/spell_model.dart';
import '../../../viewmodels/spells_viewmodel.dart';

/// A widget class that handles the display and management of spells grouped by level
class SpellByLevel extends StatefulWidget {
  final List<String> spells;
  final CharacterSpellPreparation spellPreparation;
  final Character character;
  final TextEditingController classController;
  final TextEditingController levelController;
  final Function(String) onShowSpellDetails;
  final Function(String, bool) onToggleSpellPreparation;
  final Function(String) onToggleAlwaysPrepared;
  final Function(String) onToggleFreeUse;
  final Function(String) onToggleRitual;
  final Function() onAutoSaveCharacter;
  final Function(int) onRemoveSpell;

  const SpellByLevel({
    super.key,
    required this.spells,
    required this.spellPreparation,
    required this.character,
    required this.classController,
    required this.levelController,
    required this.onShowSpellDetails,
    required this.onToggleSpellPreparation,
    required this.onToggleAlwaysPrepared,
    required this.onToggleFreeUse,
    required this.onToggleRitual,
    required this.onAutoSaveCharacter,
    required this.onRemoveSpell,
  });

  @override
  State<SpellByLevel> createState() => _SpellByLevelState();
}

class _SpellByLevelState extends State<SpellByLevel> {
  @override
  Widget build(BuildContext context) {
    return Column(children: _buildSpellsByLevel());
  }

  /// Build widgets for spells grouped by their level
  List<Widget> _buildSpellsByLevel() {
    debugPrint("================ _buildSpellsByLevel is called ======");
    if (widget.spells.isEmpty) {
      return [
        const Center(
          child: Text(
            'No spells added yet',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      ];
    }

    final spellsViewModel = context.read<SpellsViewModel>();
    final Map<int, List<Map<String, dynamic>>> spellsByLevel = {};

    // Group spells by level
    for (int i = 0; i < widget.spells.length; i++) {
      final spellName = widget.spells[i];
      final spell =
          spellsViewModel.getSpellByName(spellName) ??
          Spell(
            id: 'unknown',
            name: spellName,
            castingTime: 'Unknown',
            range: 'Unknown',
            duration: 'Unknown',
            description: 'Custom spell',
            classes: [],
            dice: [],
            updatedAt: DateTime.now(),
          );

      final level = spell.levelNumber;
      if (!spellsByLevel.containsKey(level)) {
        spellsByLevel[level] = [];
      }
      spellsByLevel[level]!.add({'index': i, 'spell': spell});
    }

    // Sort levels (0-9, where 0 is cantrips)
    final sortedLevels = spellsByLevel.keys.toList()..sort();

    final List<Widget> widgets = [];

    for (final level in sortedLevels) {
      final spellsInLevel = spellsByLevel[level]!;

      // Calculate max prepared spells for this class (used for header and individual spells)
      final currentCalculatedMax =
          CharacterSpellPreparation.calculateMaxPreparedSpells(
            widget.classController.text
                .trim(), // Use current class from controller
            int.tryParse(widget.levelController.text) ??
                1, // Use current level from controller
            CharacterSpellPreparation.getSpellcastingModifier(widget.character),
          );

      // Add level header
      widgets.add(
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      level == 0
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      level == 0 ? Colors.green.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSpellLevelIcon(level),
                    color:
                        level == 0
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    level == 0 ? 'Cantrips' : 'Level $level Spells',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          level == 0
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (level == 0 ? Colors.green : Colors.blue)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${spellsInLevel.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            level == 0
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Only show prepared count if class can prepare spells and level > 0
            if (level > 0 && currentCalculatedMax > 0)
              Positioned(
                top: 12,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${spellsInLevel.where((spellData) {
                      final spell = spellData['spell'] as Spell;
                      final spellId = spell.id; // Use spell.id instead of spell.name
                      final isPrepared = widget.spellPreparation.isSpellPrepared(spellId);
                      return isPrepared;
                    }).length} prepared',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

      // Sort spells within each level: always prepared first, then prepared spells, then others
      spellsInLevel.sort((a, b) {
        final spellA = a['spell'] as Spell;
        final spellB = b['spell'] as Spell;

        final isRitualA = widget.spellPreparation.isSpellRitual(spellA.id);
        final isRitualB = widget.spellPreparation.isSpellRitual(spellB.id);

        if (isRitualA && !isRitualB) return -1;
        if (!isRitualA && isRitualB) return 1;

        final isAlwaysPreparedA = widget.spellPreparation.isSpellAlwaysPrepared(
          spellA.id,
        );
        final isAlwaysPreparedB = widget.spellPreparation.isSpellAlwaysPrepared(
          spellB.id,
        );

        if (isAlwaysPreparedA && !isAlwaysPreparedB) return -1;
        if (!isAlwaysPreparedA && isAlwaysPreparedB) return 1;

        final isPreparedA = widget.spellPreparation.isSpellPrepared(spellA.id);
        final isPreparedB = widget.spellPreparation.isSpellPrepared(spellB.id);

        if (isPreparedA && !isPreparedB) return -1;
        if (!isPreparedA && isPreparedB) return 1;

        return spellA.name.compareTo(spellB.name);
      });

      // Add spells in this level
      for (final spellData in spellsInLevel) {
        final index = spellData['index'] as int;
        final spell = spellData['spell'] as Spell;

        // Check if spell can be prepared (only for classes that prepare spells and non-cantrips)
        final currentMaxPrepared =
            widget.spellPreparation.maxPreparedSpells == 0
                ? currentCalculatedMax
                : widget.spellPreparation.maxPreparedSpells;

        final canPrepare =
            spell.levelNumber > 0 && // Cantrips (level 0) cannot be prepared
            currentMaxPrepared > 0;

        // Check spell status
        final isPrepared = widget.spellPreparation.isSpellPrepared(spell.id);
        final isAlwaysPrepared = widget.spellPreparation.isSpellAlwaysPrepared(
          spell.id,
        );
        final isFreeUse = widget.spellPreparation.isSpellFreeUse(spell.id);
        final isRitual = widget.spellPreparation.isSpellRitual(spell.id);

        // Check if we can prepare more spells
        final canPrepareMore =
            widget.spellPreparation.currentPreparedCount < currentMaxPrepared ||
            isAlwaysPrepared;

        widgets.add(
          Dismissible(
            key: Key('spell_${spell.id}_$index'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white, size: 24),
            ),
            confirmDismiss: (direction) async {
              // Show confirmation dialog and wait for user response
              final shouldRemove = await _showRemoveSpellConfirmation(
                spell,
                index,
                isPrepared,
                isAlwaysPrepared,
                isFreeUse,
                isRitual,
              );
              return shouldRemove;
            },
            onDismissed: (direction) {
              // This will only be called if confirmDismiss returns true
              widget.onRemoveSpell(index);
              // Remove from preparation lists if it was prepared
              if (isPrepared) {
                widget.onToggleSpellPreparation(spell.id, false);
              }
              if (isAlwaysPrepared) {
                widget.onToggleAlwaysPrepared(spell.id);
              }
              if (isFreeUse) {
                widget.onToggleFreeUse(spell.id);
              }
              if (isRitual) {
                widget.onToggleRitual(spell.id);
              }

              // Auto-save the character when a spell is removed
              widget.onAutoSaveCharacter();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isPrepared
                          ? Colors.blue.shade200
                          : isRitual && !isPrepared
                          ? Colors.amber.shade300
                          : Colors.grey.shade300,
                  width: isPrepared || (isRitual && !isPrepared) ? 1.3 : 1,
                ),
                color:
                    isPrepared
                        ? Colors.blue.shade50
                        : isRitual && !isPrepared
                        ? Colors.amber.shade50
                        : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isPrepared
                            ? Colors.blue
                            : isRitual && !isPrepared
                            ? Colors.amber
                            : Colors.black)
                        .withValues(
                          alpha:
                              isPrepared || (isRitual && !isPrepared)
                                  ? 0.08
                                  : 0.03,
                        ),
                    blurRadius: isPrepared || (isRitual && !isPrepared) ? 6 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SelectionArea(
                child: ListTile(
                  leading:
                      canPrepare
                          ? AnimatedScale(
                            scale: isPrepared ? 1.12 : 0.96,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutBack,
                            child: Checkbox(
                              shape: const CircleBorder(),
                              value: isPrepared,
                              onChanged: (bool? value) {
                                if (value == true) {
                                  if (canPrepareMore || isAlwaysPrepared) {
                                    widget.onToggleSpellPreparation(
                                      spell.id,
                                      true,
                                    );
                                  } else {
                                    SnackbarHelper.showError(
                                      context,
                                      'Cannot prepare more spells. Maximum: $currentMaxPrepared',
                                    );
                                  }
                                } else {
                                  widget.onToggleSpellPreparation(
                                    spell.id,
                                    false,
                                  );
                                }
                              },
                            ),
                          )
                          : null,
                  title: InkWell(
                    child: Text(
                      spell.name,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    onTap: () => widget.onShowSpellDetails(spell.name),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${spell.schoolName.split('_').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ')} • ${spell.castingTime}${spell.ritual ? ' • (ritual)' : ''}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (isAlwaysPrepared ||
                          isFreeUse ||
                          isRitual ||
                          canPrepare ||
                          spell.levelNumber > 0) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (isAlwaysPrepared) ...[
                              GestureDetector(
                                onTap:
                                    () =>
                                        widget.onToggleAlwaysPrepared(spell.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.purple.shade700,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Always prepared',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.purple.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else if (canPrepare) ...[
                              GestureDetector(
                                onTap:
                                    () =>
                                        widget.onToggleAlwaysPrepared(spell.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_border,
                                        size: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Always prepared',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (isFreeUse) ...[
                              GestureDetector(
                                onTap: () => widget.onToggleFreeUse(spell.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bolt,
                                        size: 12,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Free use',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              GestureDetector(
                                onTap: () => widget.onToggleFreeUse(spell.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bolt_outlined,
                                        size: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Free use',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (isRitual) ...[
                              GestureDetector(
                                onTap: () => widget.onToggleRitual(spell.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 12,
                                        color: Colors.amber.shade800,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Ritual',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              GestureDetector(
                                onTap: () => widget.onToggleRitual(spell.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_outlined,
                                        size: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Ritual',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing:
                      const SizedBox.shrink(), // No trailing buttons needed anymore
                ),
              ),
            ),
          ),
        );
      }

      // Add spacing between levels
      if (level != sortedLevels.last) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  /// Show confirmation dialog before removing a spell
  Future<bool> _showRemoveSpellConfirmation(
    Spell spell,
    int index,
    bool isPrepared,
    bool isAlwaysPrepared,
    bool isFreeUse,
    bool isRitual,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.removeSpell),
          content: Text(l10n.removeSpellConfirmation(spell.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                l10n.remove,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    // If user confirmed (result is true), perform the removal
    if (result == true) {
      // Remove the spell
      widget.onRemoveSpell(index);

      // Remove from preparation lists if it was prepared
      if (isPrepared) {
        widget.onToggleSpellPreparation(spell.id, false);
      }
      if (isAlwaysPrepared) {
        widget.onToggleAlwaysPrepared(spell.id);
      }
      if (isFreeUse) {
        widget.onToggleFreeUse(spell.id);
      }
      if (isRitual) {
        widget.onToggleRitual(spell.id);
      }

      // Auto-save the character when a spell is removed
      widget.onAutoSaveCharacter();

      // Show success message - use mounted check to avoid async context issues
      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          '${spell.name} removed from spell list',
        );
      }
    }

    return result ?? false; // Return false if dialog was dismissed
  }

  /// Get the appropriate icon for a spell level
  IconData _getSpellLevelIcon(int level) {
    switch (level) {
      case 0:
        return Icons.auto_awesome;
      case 1:
        return Icons.filter_1;
      case 2:
        return Icons.filter_2;
      case 3:
        return Icons.filter_3;
      case 4:
        return Icons.filter_4;
      case 5:
        return Icons.filter_5;
      case 6:
        return Icons.filter_6;
      case 7:
        return Icons.filter_7;
      case 8:
        return Icons.filter_8;
      case 9:
        return Icons.filter_9;
      default:
        return Icons.star;
    }
  }
}
