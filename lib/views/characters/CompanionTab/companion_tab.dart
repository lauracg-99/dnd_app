import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/utils/quill_toolbar_configs.dart';
import 'package:dnd_app/utils/simple_quill_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'dart:convert';

class CompanionTab extends StatefulWidget {
  final List<CharacterFamiliar> familiars;
  final VoidCallback onAddCompanion;
  final void Function(int index) onRemoveCompanion;
  final void Function(int oldIndex, int newIndex) onReorderCompanion;
  final void Function(List<CharacterFamiliar> updatedFamiliars) onFamiliarsChanged;

  const CompanionTab({
    super.key,
    required this.familiars,
    required this.onAddCompanion,
    required this.onRemoveCompanion,
    required this.onReorderCompanion,
    required this.onFamiliarsChanged,
  });

  @override
  State<CompanionTab> createState() => _CompanionTabState();
}

class _CompanionTabState extends State<CompanionTab> {
  late List<_FamiliarFormEntry> _familiarEntries;

  @override
  void initState() {
    super.initState();
    _initializeFamiliarEntries();
  }

  @override
  void didUpdateWidget(CompanionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.familiars != widget.familiars) {
      _initializeFamiliarEntries();
    }
  }

  void _initializeFamiliarEntries() {
    _familiarEntries = widget.familiars
        .map((familiar) => _FamiliarFormEntry(familiar: familiar))
        .toList();
  }

  void _moveFamiliar(int fromIndex, int toIndex) {
    if (fromIndex < 0 ||
        toIndex < 0 ||
        fromIndex >= _familiarEntries.length ||
        toIndex >= _familiarEntries.length) {
      return;
    }

    setState(() {
      final moved = _familiarEntries.removeAt(fromIndex);
      _familiarEntries.insert(toIndex, moved);
      _notifyFamiliarsChanged();
    });
  }

  void _notifyFamiliarsChanged() {
    final updatedFamiliars =
        _familiarEntries.map((entry) => entry.toCharacterFamiliar()).toList();
    widget.onFamiliarsChanged(updatedFamiliars);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _familiarEntries.add(_FamiliarFormEntry());
                    _notifyFamiliarsChanged();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add companion'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_familiarEntries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No companions.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_familiarEntries.length, (index) {
              final entry = _familiarEntries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Companion info',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed:
                                      index > 0
                                          ? () =>
                                              _moveFamiliar(index, index - 1)
                                          : null,
                                  icon: const Icon(
                                    Icons.arrow_upward,
                                    size: 18,
                                  ),
                                  color: Theme.of(context).colorScheme.primary,
                                  tooltip: 'Move companion up',
                                  splashRadius: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      index < _familiarEntries.length - 1
                                          ? () =>
                                              _moveFamiliar(index, index + 1)
                                          : null,
                                  icon: const Icon(
                                    Icons.arrow_downward,
                                    size: 18,
                                  ),
                                  color: Theme.of(context).colorScheme.primary,
                                  tooltip: 'Move companion down',
                                  splashRadius: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              'Delete companion',
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this companion?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                    );

                                    if (confirmed != true) return;

                                    setState(() {
                                      final removed = _familiarEntries.removeAt(
                                        index,
                                      );
                                      removed.nameController.dispose();
                                      removed.armorClassController.dispose();
                                      removed.hpController.dispose();
                                      removed.notesController.dispose();
                                      _notifyFamiliarsChanged();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  color: Colors.red,
                                  tooltip: 'Remove companion',
                                  splashRadius: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: entry.nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          onChanged: (_) {
                            setState(() {});
                            _notifyFamiliarsChanged();
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: entry.armorClassController,
                                decoration: const InputDecoration(
                                  labelText: 'Armor Class',
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                  _notifyFamiliarsChanged();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: entry.hpController,
                                decoration: const InputDecoration(
                                  labelText: 'HP',
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                  _notifyFamiliarsChanged();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: SimpleQuillEditor(
                            controller: entry.notesController,
                            toolbarConfig: QuillToolbarConfigs.minimal,
                            height: 260,
                            placeholder:
                                'Describe your companion, personality, habits, abilities and important details...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final entry in _familiarEntries) {
      entry.nameController.dispose();
      entry.armorClassController.dispose();
      entry.hpController.dispose();
      entry.notesController.dispose();
    }
    super.dispose();
  }
}

class _FamiliarFormEntry {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController armorClassController = TextEditingController();
  final TextEditingController hpController = TextEditingController();
  final QuillController notesController = QuillController.basic();

  _FamiliarFormEntry({CharacterFamiliar? familiar}) {
    if (familiar == null) return;

    nameController.text = familiar.name;
    armorClassController.text = familiar.armorClass;
    hpController.text = familiar.maxHitPoints;

    if (familiar.notes.isNotEmpty) {
      try {
        final List<dynamic> jsonDelta = jsonDecode(familiar.notes);
        notesController.document = Document.fromJson(jsonDelta);
      } catch (_) {
        String text = familiar.notes;
        if (!text.endsWith('\n')) {
          text += '\n';
        }
        final delta = Delta()..insert(text);
        notesController.document = Document.fromDelta(delta);
      }
    }
  }

  CharacterFamiliar toCharacterFamiliar() {
    return CharacterFamiliar(
      name: nameController.text.trim(),
      armorClass: armorClassController.text.trim(),
      maxHitPoints: hpController.text.trim(),
      notes: jsonEncode(notesController.document.toDelta().toJson()),
    );
  }
}
