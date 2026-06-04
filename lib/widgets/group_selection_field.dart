import 'package:flutter/material.dart';

class GroupSelectionField extends StatelessWidget {
  const GroupSelectionField({
    super.key,
    required this.groupEntries,
    required this.selectedGroupId,
    required this.newGroupController,
    required this.onSelectedGroupChanged,
    required this.onNewGroupChanged,
    required this.onClearNewGroup,
    this.title = 'Group (Optional)',
    this.selectExistingGroupLabel = 'Select existing group',
    this.createNewGroupLabel = 'Create new group',
    this.createNewGroupHint = 'Enter a group name',
    this.helperText =
        'This group will be created for the character.',
  });

  final Map<String, String> groupEntries;
  final String? selectedGroupId;
  final TextEditingController newGroupController;
  final ValueChanged<String?> onSelectedGroupChanged;
  final ValueChanged<String> onNewGroupChanged;
  final VoidCallback onClearNewGroup;
  final String title;
  final String selectExistingGroupLabel;
  final String createNewGroupLabel;
  final String createNewGroupHint;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
          ],
          if (groupEntries.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: selectedGroupId,
              decoration: InputDecoration(
                labelText: selectExistingGroupLabel,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items:
                  groupEntries.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
              onChanged: onSelectedGroupChanged,
            ),
            const SizedBox(height: 16),
          ],
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: newGroupController,
            builder: (context, value, child) {
              return TextFormField(
                controller: newGroupController,
                onChanged: onNewGroupChanged,
                decoration: InputDecoration(
                  labelText: createNewGroupLabel,
                  hintText: createNewGroupHint,
                  border: const OutlineInputBorder(),
                  suffixIcon:
                      value.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: onClearNewGroup,
                          )
                          : null,
                  helperText: helperText,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
