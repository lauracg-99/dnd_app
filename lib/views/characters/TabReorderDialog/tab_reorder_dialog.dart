import 'package:flutter/material.dart';
import '../../../models/tab_config_model.dart';

class TabReorderDialog extends StatefulWidget {
  final List<String> currentOrder;
  final Function(List<String>) onOrderChanged;

  const TabReorderDialog({
    super.key,
    required this.currentOrder,
    required this.onOrderChanged,
  });

  @override
  State<TabReorderDialog> createState() => _TabReorderDialogState();
}

class _TabReorderDialogState extends State<TabReorderDialog> {
  late List<String> _tabOrder;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabOrder = List.from(widget.currentOrder);
  }

  void _reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = _tabOrder.removeAt(oldIndex);
    _tabOrder.insert(newIndex, item);
    _hasChanges = true;
    setState(() {});
  }

  void _resetToDefault() {
    setState(() {
      _tabOrder = List.from(CharacterTabManager.getDefaultTabOrder());
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reorder Tabs'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Text(
              'Drag and drop tabs to reorder them:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _tabOrder.length,
                onReorder: _reorderTabs,
                itemBuilder: (context, index) {
                  final tabId = _tabOrder[index];
                  final tabConfig = CharacterTabManager.getTabConfig(tabId);
                  
                  return Card(
                    key: ValueKey(tabId),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        tabConfig?.icon ?? Icons.help,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(tabConfig?.label ?? tabId),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _resetToDefault();
          },
          child: const Text('Reset to Default'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _hasChanges
              ? () {
                  widget.onOrderChanged(_tabOrder);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
