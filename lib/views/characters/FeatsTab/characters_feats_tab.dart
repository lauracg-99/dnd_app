import 'package:dnd_app/utils/QuillToolbarConfigs.dart';
import 'package:dnd_app/utils/SimpleQuillEditor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import '../../../models/feat_model.dart';
import '../../../viewmodels/feats_viewmodel.dart';

class CharactersFeatsTab extends StatefulWidget {
  final List<String> feats;
  final QuillController featNotesController;
  final Function(List<String>) onFeatsChanged;
  final Function() onAutoSaveCharacter;
  final String characterName;

  const CharactersFeatsTab({
    super.key,
    required this.feats,
    required this.featNotesController,
    required this.onFeatsChanged,
    required this.onAutoSaveCharacter,
    required this.characterName,
  });

  @override
  State<CharactersFeatsTab> createState() => _CharactersFeatsTabState();
}

class _CharactersFeatsTabState extends State<CharactersFeatsTab> {
  late List<String> _feats;
  late QuillController _featNotesController;

  @override
  void initState() {
    super.initState();
    _feats = List.from(widget.feats);
    _featNotesController = widget.featNotesController;
  }

  @override
  void didUpdateWidget(CharactersFeatsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.feats != widget.feats) {
      _feats = List.from(widget.feats);
    }
    if (oldWidget.featNotesController != widget.featNotesController) {
      _featNotesController = widget.featNotesController;
    }
  }

  void _updateFeats(List<String> newFeats) {
    setState(() {
      _feats = newFeats;
    });
    widget.onFeatsChanged(_feats);
    widget.onAutoSaveCharacter();
  }

  void _showAddFeatDialog() {
    // Load feats if not already loaded
    context.read<FeatsViewModel>().loadFeats();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add Feat to ${widget.characterName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Feats list
              Expanded(
                child: Consumer<FeatsViewModel>(
                  builder: (context, featsViewModel, child) {
                    if (featsViewModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (featsViewModel.error != null) {
                      return Center(
                        child: Text('Error: ${featsViewModel.error}'),
                      );
                    }

                    final feats = featsViewModel.feats;
                    final searchQuery = '';
                    final filteredFeats = searchQuery.isEmpty
                        ? feats
                        : feats
                            .where(
                              (feat) => feat.name
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()),
                            )
                            .toList();

                    if (filteredFeats.isEmpty) {
                      return const Center(child: Text('No feats found'));
                    }

                    return ListView.builder(
                      itemCount: filteredFeats.length,
                      itemBuilder: (context, index) {
                        final feat = filteredFeats[index];
                        final isKnown = _feats.contains(feat.name);

                        return ListTile(
                          title: Text(feat.name),
                          subtitle: Text(
                            feat.source,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isKnown
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.add),
                          enabled: !isKnown,
                          onTap: isKnown
                              ? null
                              : () {
                                  final newFeats = List<String>.from(_feats);
                                  newFeats.add(feat.name);
                                  _updateFeats(newFeats);
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added ${feat.name} to ${widget.characterName}',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                        );
                      },
                    );
                  },
                ),
              ),

              // Footer
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    Text(
                      '${_feats.length} feats known',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatDetails(Feat feat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.military_tech, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feat.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Source
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.book,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Source: ${feat.source}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Prerequisite
              if (feat.prerequisite != null && feat.prerequisite!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prerequisite:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(feat.prerequisite!),
                    ],
                  ),
                ),
              if (feat.prerequisite != null && feat.prerequisite!.isNotEmpty)
                const SizedBox(height: 16),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feat.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),

              // Effects
              if (feat.effects.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Effects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        feat.formattedEffects,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Character info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Known by: ${widget.characterName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Character Feats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your character\'s feats',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Feats list
          ..._feats.asMap().entries.map((entry) {
            final index = entry.key;
            final featName = entry.value;

            // Try to find feat details
            final featsViewModel = context.read<FeatsViewModel>();
            final feat = featsViewModel.feats.firstWhere(
              (f) => f.name.toLowerCase() == featName.toLowerCase(),
              orElse: () => Feat(
                id: 'unknown',
                name: featName,
                description: 'Custom feat',
                source: 'Unknown',
              ),
            );

            return Card(
              child: ListTile(
                title: InkWell(
                  child: Text(
                    feat.name,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () => _showFeatDetails(feat),
                ),
                subtitle: Text(
                  feat.source,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final newFeats = List<String>.from(_feats);
                    newFeats.removeAt(index);
                    _updateFeats(newFeats);
                  },
                ),
              ),
            );
          }),

          TextButton.icon(
            onPressed: _showAddFeatDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Feat'),
          ),
          const SizedBox(height: 16),

          // Feat Notes Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Additional notes about your feats and abilities.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: SimpleQuillEditor(
                      controller: _featNotesController, 
                      toolbarConfig: QuillToolbarConfigs.minimal,
                      placeholder: 'Add notes about your feats...\n\n',                           
                            height: 300,
                    )

                  ),                  
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
