import 'package:dnd_app/utils/snackbar_helper.dart';
import 'package:dnd_app/viewmodels/characters_viewmodel.dart';
import 'package:dnd_app/widgets/group_selection_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Asegúrate de tener provider o tu gestor de estado
import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/services/character_service.dart';
// Importa aquí tu CharactersViewModel y GroupSelectionField si están en otras rutas
// import 'package:dnd_app/viewmodels/characters_view_model.dart';
// import 'package:dnd_app/widgets/group_selection_field.dart';

class CharacterHelper {
  static Future<void> showGroupAssignmentDialog(
    BuildContext context,
    Character character,
  ) async {
    final viewModel = context.read<CharactersViewModel>();
    final existingGroups = <String, String>{};

    for (final current in viewModel.characters) {
      if (current.grupo != null && current.grupo!.isNotEmpty) {
        final groupId = getGroupKey(current);
        if (groupId.isNotEmpty) {
          existingGroups[groupId] = current.grupo!;
        }
      }
    }

    String? selectedGroupId = getGroupKey(character);
    if (selectedGroupId.isEmpty ||
        !existingGroups.containsKey(selectedGroupId)) {
      selectedGroupId = null;
    }

    final groupNameController = TextEditingController(
      text: selectedGroupId != null ? existingGroups[selectedGroupId] : '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        // Renombrado para evitar conflictos con el context general
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Group'),
              content: GroupSelectionField(
                groupEntries: existingGroups,
                selectedGroupId: selectedGroupId,
                newGroupController: groupNameController,
                onSelectedGroupChanged: (value) {
                  setState(() {
                    selectedGroupId = value;
                    if (value != null) {
                      groupNameController.text = existingGroups[value] ?? '';
                    }
                  });
                },
                onNewGroupChanged: (value) {
                  setState(() {
                    if (value.trim().isNotEmpty) {
                      selectedGroupId = null;
                    }
                  });
                },
                onClearNewGroup: () {
                  setState(() {
                    groupNameController.clear();
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    String? grupo;
    String? grupoId;
    final newGroupName = groupNameController.text.trim();

    if (selectedGroupId != null &&
        existingGroups.containsKey(selectedGroupId) &&
        newGroupName == existingGroups[selectedGroupId]) {
      grupo = newGroupName;
      grupoId = selectedGroupId;
    } else if (newGroupName.isNotEmpty) {
      grupo = newGroupName;
      grupoId = generateGroupId(newGroupName);
    } else if (selectedGroupId != null) {
      grupoId = selectedGroupId;
      grupo = existingGroups[selectedGroupId];
    }

    if (grupo == null) return;

    final updatedCharacter = character.copyWith(
      grupo: grupo,
      grupoId: grupoId,
      updatedAt: DateTime.now(),
    );

    // Se usa el context original de la vista para asegurar el acceso al ViewModel
    await context.read<CharactersViewModel>().updateCharacter(updatedCharacter);
  }

  static Future<void> showGroupRenameDialogByGroupKey(
    BuildContext context,
    String groupKey,
    String currentGroupName,
  ) async {
    final viewModel = context.read<CharactersViewModel>();
    final groupNameController = TextEditingController(text: currentGroupName);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename Group'),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(
              labelText: 'New group name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final newGroupName = groupNameController.text.trim();
    if (newGroupName.isEmpty || newGroupName == currentGroupName) {
      return;
    }

    await viewModel.renameGroup(groupKey, newGroupName);

    // Al no estar en un State, comprobamos si el contexto sigue montado en el árbol
    if (context.mounted) {
      SnackbarHelper.showSuccess(context, 'Group renamed successfully.');
    }
  }

  static void showDeleteConfirmation(
    BuildContext context,
    Character character,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Character'),
            content: Text(
              'Are you sure you want to delete ${character.name}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<CharactersViewModel>().deleteCharacter(
                    character.id,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  static Future<void> confirmAndDeleteGroup(
    BuildContext context,
    String groupKey,
    String groupName,
    List<Character> members,
  ) async {
    final viewModel = context.read<CharactersViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
          'Are you sure you want to delete the group "$groupName"? '
          'This will remove the group (NOT THE CHARACTERS) from all its members and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      for (final member in members) {
        final updated = member.copyWith(
          grupo: null,
          grupoId: null,
          updatedAt: DateTime.now(),
        );
        await viewModel.updateCharacter(updated);
      }

      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Group deleted successfully.');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Failed to delete group: $e');
      }
    }
  }

  static Future<void> removeCharacterFromGroup(BuildContext context, Character character) async {
    final updatedCharacter = character.copyWith(
      grupo: null,
      grupoId: null,
      updatedAt: DateTime.now(),
    );
    
    await context.read<CharactersViewModel>().updateCharacter(updatedCharacter);
    
    if (context.mounted) {
      SnackbarHelper.showSuccess(context, 'Personaje eliminado del grupo.');
    }
  }

  static String getGroupKey(Character character) {
    final grupoId = character.grupoId?.trim();
    if (grupoId != null && grupoId.isNotEmpty) {
      return grupoId;
    }

    final grupo = character.grupo?.trim();
    if (grupo != null && grupo.isNotEmpty) {
      final normalized = generateGroupId(grupo);
      return normalized.isNotEmpty ? normalized : grupo.toLowerCase();
    }
    return '';
  }

  static String generateGroupId(String groupName) {
    return CharacterService.generateGroupId(groupName);
  }
}
