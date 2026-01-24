import 'package:dnd_app/models/background_model.dart';
import 'package:dnd_app/models/race_model.dart';
import 'package:dnd_app/viewmodels/backgrounds_viewmodel.dart';
import 'package:dnd_app/viewmodels/characters_viewmodel.dart';
import 'package:dnd_app/viewmodels/races_viewmodel.dart';
import 'package:dnd_app/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';


class CharacterHeaderSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController levelController;
  final TextEditingController classController;
  final TextEditingController subclassController;
  final TextEditingController raceController;
  final TextEditingController backgroundController;

  final String? customImagePath;
  final String? customImageData;
  final bool isEditing;
  final void Function(bool) onEditToggle;
  final VoidCallback onPickImage;
  final VoidCallback onSave;
  final bool hasUnsavedClassChanges;

  final List<String> Function(String) getSubclassesForClass;
  final void Function(String) onClassChanged;
  final void Function(String) onSubclassChanged;
  final void Function(String) onRaceChanged;
  final void Function(String) onBackgroundChanged;
  final Widget Function() buildPickImageButton;
  final void Function(Race) showRaceDetailsModal;
  final void Function(Background) showBackgroundDetailsModal;
  final String selectedBackground;

  const CharacterHeaderSection({
    super.key,
    required this.nameController,
    required this.levelController,
    required this.classController,
    required this.subclassController,
    required this.raceController,
    required this.backgroundController,
    this.customImagePath,
    this.customImageData,
    required this.isEditing,
    required this.onEditToggle,
    required this.onPickImage,
    required this.onSave,
    required this.hasUnsavedClassChanges,
    required this.getSubclassesForClass,
    required this.onClassChanged,
    required this.onSubclassChanged,
    required this.onRaceChanged,
    required this.onBackgroundChanged,
    required this.buildPickImageButton,
    required this.showRaceDetailsModal,
    required this.showBackgroundDetailsModal,
    required this.selectedBackground,
  });

  @override
  State<CharacterHeaderSection> createState() =>
      _CharacterHeaderSectionState();
}

class _CharacterHeaderSectionState extends State<CharacterHeaderSection> {
  bool _useCustomSubclass = false;
  String _selectedClass = '';

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.classController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          // Header with Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48), // Space for profile image alignment                    
              IconButton(
                onPressed: () {
                  widget.onEditToggle(!widget.isEditing);
                  // If exiting edit mode (clicking "Done"), save changes
                  if (widget.isEditing && widget.hasUnsavedClassChanges) {
                    widget.onSave();
                  }
                },
                icon: Icon(
                  widget.isEditing ? Icons.check : Icons.edit,
                  color: Colors.blue.shade700,
                ),
                tooltip: widget.isEditing ? 'Done' : 'Edit Character',
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Profile image
          GestureDetector(
            onTap: widget.isEditing ? widget.onPickImage : null,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: widget.isEditing
                          ? Colors.green.shade300
                          : Colors.blue.shade300,
                      width: 2,
                    ),
                  ),
                  child: _buildProfileImage(),
                ),
                if (widget.isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: widget.buildPickImageButton(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Character Name
          widget.isEditing
              ? TextField(
                  controller: widget.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Character Name',
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(
                  widget.nameController.text.isNotEmpty
                      ? widget.nameController.text
                      : 'Character Name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
          const SizedBox(height: 12),
          // Level
          widget.isEditing
              ? TextField(
                  controller: widget.levelController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Character Level',
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(
                  'Level ${widget.levelController.text.isNotEmpty ? widget.levelController.text : '1'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
          const SizedBox(height: 12),
          // Class and Subclass
          widget.isEditing
              ? Row(
                  children: [
                    Expanded(
                      child: Consumer<CharactersViewModel>(
                        builder: (context, viewModel, child) {
                          return DropdownButtonFormField<String>(
                            value: _selectedClass,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                              border: OutlineInputBorder(),
                            ),
                            items: viewModel.availableClasses.map((className) {
                              return DropdownMenuItem(
                                value: className,
                                child: Text(className),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedClass = value!;
                                widget.classController.text = value;
                                _useCustomSubclass = false;
                              });
                              widget.onClassChanged(value!);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_useCustomSubclass)
                            TextField(
                              controller: widget.subclassController,
                              decoration: InputDecoration(
                                labelText: 'Custom Subclass',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.list),
                                  onPressed: () {
                                    setState(() {
                                      _useCustomSubclass = false;
                                    });
                                  },
                                  tooltip: 'Choose from preset subclasses',
                                ),
                              ),
                              onChanged: (value) {
                                widget.onSubclassChanged(value);
                              },
                            )
                          else
                            DropdownButtonFormField<String>(
                              value: _useCustomSubclass || widget.subclassController.text.isEmpty || !widget.getSubclassesForClass(_selectedClass).contains(widget.subclassController.text) ? null : widget.subclassController.text,
                              decoration: const InputDecoration(
                                labelText: 'Subclass (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              isExpanded: true,
                              items: [
                                ...widget.getSubclassesForClass(_selectedClass).map((subclass) {
                                  return DropdownMenuItem(
                                    value: subclass,
                                    child: SizedBox(
                                      width: 200,
                                      child: Text(
                                        subclass,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  );
                                }),
                                const DropdownMenuItem(
                                  value: 'custom',
                                  child: Text('Custom Subclass'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == 'custom') {
                                  setState(() {
                                    _useCustomSubclass = true;
                                  });
                                } else {
                                  setState(() {
                                    widget.subclassController.text = value!;
                                    _useCustomSubclass = false;
                                  });
                                  widget.onSubclassChanged(value!);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              : Text(
                  widget.classController.text.isNotEmpty
                      ? (widget.subclassController.text.isNotEmpty
                          ? '${widget.classController.text} • ${widget.subclassController.text}'
                          : widget.classController.text)
                      : 'Class • Subclass',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
          const SizedBox(height: 12),
          
          // Race selection
          Consumer<RacesViewModel>(
            builder: (context, racesViewModel, child) {
              // Create unique race items by using race name + source if needed
              final Map<String, Race> uniqueRaces = {};
              for (final race in racesViewModel.races) {
                final key = race.name;
                if (!uniqueRaces.containsKey(key)) {
                  uniqueRaces[key] = race;
                }
              }
              
              final selectedRace = widget.raceController.text.isNotEmpty 
                  ? uniqueRaces[widget.raceController.text]
                  : null;
              
              return widget.isEditing
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: DropdownButtonFormField<String>(
                              value: widget.raceController.text.isEmpty ? null : widget.raceController.text,
                              decoration: InputDecoration(
                                labelText: 'Race (Optional)',
                                border: OutlineInputBorder(),
                                suffixIcon: selectedRace != null 
                                    ? IconButton(
                                        icon: const Icon(Icons.info_outline),
                                        onPressed: () => widget.showRaceDetailsModal(selectedRace),
                                        tooltip: 'View race details',
                                      )
                                    : null,
                              ),
                              items: uniqueRaces.values.map<DropdownMenuItem<String>>((race) {
                                return DropdownMenuItem<String>(
                                  value: race.name,
                                  child: Text(race.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                widget.onRaceChanged(value ?? '');
                              },
                            ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<BackgroundsViewModel>(
                          builder: (context, backgroundsViewModel, child) {
                            Background? selectedBackground;
                            if (widget.backgroundController.text.isNotEmpty && backgroundsViewModel.backgrounds.isNotEmpty) {
                              try {
                                selectedBackground = backgroundsViewModel.backgrounds.firstWhere(
                                  (background) => background.name == widget.backgroundController.text,
                                );
                              } catch (e) {
                                // Background not found, keep selectedBackground as null
                                debugPrint('Background "${widget.backgroundController.text}" not found in list');
                              }
                            }
                            
                            return DropdownButtonFormField<String>(
                              value: widget.backgroundController.text.isEmpty ? null : widget.backgroundController.text,
                              decoration: InputDecoration(
                                labelText: 'Background (Optional)',
                                border: OutlineInputBorder(),
                                suffixIcon: selectedBackground != null 
                                    ? IconButton(
                                        icon: const Icon(Icons.info_outline),
                                        onPressed: () => widget.showBackgroundDetailsModal(selectedBackground!),
                                        tooltip: 'View background details',
                                      )
                                    : null,
                              ),
                              items: backgroundsViewModel.backgrounds.map((background) {
                                return DropdownMenuItem(
                                  value: background.name,
                                  child: Text(background.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                debugPrint('Character cover background dropdown changed to: $value');
                                widget.onBackgroundChanged(value ?? '');
                              },
                            );
                          },
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: selectedRace != null 
                          ? () => widget.showRaceDetailsModal(selectedRace)
                          : null,
                      child: Consumer<BackgroundsViewModel>(
                      builder: (context, backgroundsViewModel, child) {
                        Background? selectedBackground;
                        if (widget.backgroundController.text.isNotEmpty && backgroundsViewModel.backgrounds.isNotEmpty) {
                          try {
                            selectedBackground = backgroundsViewModel.backgrounds.firstWhere(
                              (background) => background.name == widget.backgroundController.text,
                            );
                          } catch (e) {
                            // Background not found, keep selectedBackground as null
                            debugPrint('Background "${widget.backgroundController.text}" not found in list');
                          }
                        }
                        
                        final hasRace = widget.raceController.text.isNotEmpty;
                        final hasBackground = widget.backgroundController.text.isNotEmpty;
                        
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Race display
                            if (hasRace) ...[
                              
                            GestureDetector(
                              onTap: selectedRace != null 
                                  ? () => widget.showRaceDetailsModal(selectedRace)
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                    widget.raceController.text.isNotEmpty 
                                        ? widget.raceController.text
                                        : 'Race',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selectedRace != null 
                                          ? Colors.blue.shade600
                                          : Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                      decoration: selectedRace != null 
                                          ? TextDecoration.underline
                                          : null,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              ),
                            ),],
                            
                            // Background display
                            if (hasBackground) ...[ 
                              Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                      ' • ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: selectedBackground != null 
                                            ? Colors.blue.shade600
                                            : Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,                                            
                                      ),
                                      textAlign: TextAlign.center,
                                  ),
                                ),
                                                              
                              GestureDetector(
                                onTap: selectedBackground != null
                                    ? () => widget.showBackgroundDetailsModal(selectedBackground!)
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                      widget.backgroundController.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: selectedBackground != null 
                                            ? Colors.blue.shade600
                                            : const Color.fromARGB(255, 117, 117, 117),
                                        fontStyle: FontStyle.italic,
                                        decoration: selectedBackground != null 
                                            ? TextDecoration.underline
                                            : null,
                                      ),
                                      textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // Prioritize base64 data if available
    if (widget.customImageData != null && widget.customImageData!.isNotEmpty) {
      final imageBytes = ImageUtils.base64ToImageBytes(widget.customImageData);
      if (imageBytes != null) {
        return ClipOval(
          child: Image.memory(
            imageBytes,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.person,
                size: 40,
                color: Colors.grey,
              );
            },
          ),
        );
      }
    }
    
    // Fallback to file path if base64 is not available
    if (widget.customImagePath != null && widget.customImagePath!.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(widget.customImagePath!),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              size: 40,
              color: Colors.grey,
            );
          },
        ),
      );
    }
    
    // Default icon if no image is available
    return const Icon(
      Icons.person,
      size: 40,
      color: Colors.grey,
    );
  }
}
