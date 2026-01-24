import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:async';
import '../../../utils/ExpandableQuillEditor.dart';
import '../../../utils/QuillToolbarConfigs.dart';

class CharactersQuickGuide extends StatefulWidget {
  final QuillController controller;
  final VoidCallback onSaveCharacter;

  const CharactersQuickGuide({
    super.key,
    required this.controller,
    required this.onSaveCharacter,
  });

  @override
  State<CharactersQuickGuide> createState() => _CharactersQuickGuideState();
}

class _CharactersQuickGuideState extends State<CharactersQuickGuide> 
    with WidgetsBindingObserver {
  bool _hasUnsavedChanges = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Add listener to detect changes in the QuillController
    widget.controller.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    // Remove listener
    widget.controller.removeListener(_onTextChanged);
    
    // Save any pending changes before disposing (without setState)
    if (_hasUnsavedChanges) {
      widget.onSaveCharacter();
    }
    
    super.dispose();
  }
  
  void _onTextChanged() {
    if (!mounted) return;
    
    if (_hasUnsavedChanges) {
        widget.onSaveCharacter();
        if (mounted) {
          setState(() {
            _hasUnsavedChanges = false;
          });
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto-save Status Indicator
          if (_hasUnsavedChanges) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 20,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto-save in 30 seconds...',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Quick Guide Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Character Quick Guide',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A quick reference guide for your character\'s key information, abilities, and gameplay notes.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ExpandableQuillEditor(
                      controller: widget.controller,
                      toolbarConfig: QuillToolbarConfigs.minimal,
                      title: 'Tools',
                      height: 350,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
