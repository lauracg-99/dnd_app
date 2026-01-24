import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class SimpleQuillEditor extends StatefulWidget {
  final QuillController controller;
  final QuillSimpleToolbarConfig toolbarConfig;
  final double height;
  final String? placeholder;

  const SimpleQuillEditor({
    super.key,
    required this.controller,
    required this.toolbarConfig,
    this.height = 300,
    this.placeholder
  });

  @override
  State<SimpleQuillEditor> createState() => _SimpleQuillEditorState();
}

class _SimpleQuillEditorState extends State<SimpleQuillEditor> {
  final FocusNode _focusNode = FocusNode();
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final containerColor = colorScheme.surface;
    final headerColor = colorScheme.surfaceVariant;
    final borderColor = colorScheme.outlineVariant;
    final textColor = colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          Container(
            decoration: BoxDecoration(
              color: headerColor,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: QuillSimpleToolbar(
              controller: widget.controller,
              config: widget.toolbarConfig,
            ),
          ),
          // Editor
          GestureDetector(
            onTap: () {
              // Request focus when tapping on the editor area
              _focusNode.requestFocus();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              height: widget.height,
              child: QuillEditor.basic(
                controller: widget.controller,
                focusNode: _focusNode,
                config: QuillEditorConfig(
                  placeholder: widget.placeholder?.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') ?? "",
                  customStyles: DefaultStyles(
                    placeHolder: DefaultTextBlockStyle(
                      const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey, // Standard placeholder color
                      ),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const BoxDecoration(),                   
                    ),
                    paragraph: DefaultTextBlockStyle(
                      const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const BoxDecoration(), 
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
