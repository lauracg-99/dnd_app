import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ExpandableQuillEditor extends StatefulWidget {
  final QuillController controller;
  final QuillSimpleToolbarConfig toolbarConfig;
  final String title;
  final double height;
  final bool initiallyExpanded;

  const ExpandableQuillEditor({
    super.key,
    required this.controller,
    required this.toolbarConfig,
    this.title = 'Tools',
    this.height = 300,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableQuillEditor> createState() => _ExpandableQuillEditorState();
}

class _ExpandableQuillEditorState extends State<ExpandableQuillEditor>
    with TickerProviderStateMixin {
  late bool _toolbarExpanded;

  @override
  void initState() {
    super.initState();
    _toolbarExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final containerColor = colorScheme.surface;
    final headerColor = colorScheme.surfaceVariant;
    final borderColor = colorScheme.outlineVariant;
    final textColor = colorScheme.onSurfaceVariant;
    final iconColor = colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _toolbarExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                      color: iconColor
                  ),
                  onPressed: () {
                    setState(() => _toolbarExpanded = !_toolbarExpanded);
                  },
                ),
              ],
            ),
          ),

          // Toolbar
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _toolbarExpanded
                ? Container(
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    child: QuillSimpleToolbar(
                      controller: widget.controller,
                      config: widget.toolbarConfig,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

        
          // Editor
          Container(
            padding: const EdgeInsets.all(10),
            height: widget.height,
            child: QuillEditor.basic(
              controller: widget.controller,
            ),
          ),
        ],
      ),
    );
  }
}
