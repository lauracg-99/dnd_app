import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomGroupExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onRenamePressed;
  final VoidCallback? onDeletePressed;
  final Color? headerBackgroundColor;
  final Color? expandedBackgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? borderRadius;
  final EdgeInsets? headerPadding;
  final EdgeInsets? childrenPadding;
  final bool initiallyExpanded;
  final TextStyle? titleStyle;
  final double? elevation;

  const CustomGroupExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.onRenamePressed,
    this.onDeletePressed,
    this.headerBackgroundColor,
    this.expandedBackgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius = 8.0,
    this.headerPadding,
    this.childrenPadding,
    this.initiallyExpanded = false,
    this.titleStyle,
    this.elevation = 2.0,
  });

  @override
  State<CustomGroupExpansionTile> createState() =>
      _CustomGroupExpansionTileState();
}

class _CustomGroupExpansionTileState extends State<CustomGroupExpansionTile>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(_animationController);

    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerBgColor = widget.headerBackgroundColor ?? Colors.blue.shade100;
    final expandedBgColor =
        widget.expandedBackgroundColor ?? Colors.blue.shade50;
    final textColor = widget.textColor ?? Colors.black87;
    final iconColor = widget.iconColor ?? Colors.blue.shade700;
    final titleStyle =
        widget.titleStyle ??
        TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: widget.elevation ?? 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: headerBgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.borderRadius ?? 8),
                  topRight: Radius.circular(widget.borderRadius ?? 8),
                  bottomLeft: Radius.circular(
                    _isExpanded ? 0 : (widget.borderRadius ?? 8),
                  ),
                  bottomRight: Radius.circular(
                    _isExpanded ? 0 : (widget.borderRadius ?? 8),
                  ),
                ),
              ),
              child: InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.borderRadius ?? 8),
                  topRight: Radius.circular(widget.borderRadius ?? 8),
                  bottomLeft: Radius.circular(
                    _isExpanded ? 0 : (widget.borderRadius ?? 8),
                  ),
                  bottomRight: Radius.circular(
                    _isExpanded ? 0 : (widget.borderRadius ?? 8),
                  ),
                ),
                child: Padding(
                  padding:
                      widget.headerPadding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(child: Text(widget.title, style: titleStyle)),
                      // Delete button
                      if (widget.onDeletePressed != null)
                        IconButton(
                          icon: Icon(Symbols.delete, color: Colors.red.shade700),
                          tooltip: 'Delete group',
                          onPressed: widget.onDeletePressed,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      // Rename button
                      if (widget.onRenamePressed != null)
                        IconButton(
                          icon: Icon(
                            Icons.drive_file_rename_outline,
                            color: iconColor,
                          ),
                          tooltip: 'Rename group',
                          onPressed: widget.onRenamePressed,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      // Rotate icon animation
                      RotationTransition(
                        turns: _rotationAnimation,
                        child: IconButton(
                          icon: Icon(Icons.expand_more, color: iconColor),
                          onPressed: _toggleExpanded,
                          padding: const EdgeInsets.all(0),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Expanded content
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                color: expandedBgColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.borderRadius ?? 8),
                  bottomRight: Radius.circular(widget.borderRadius ?? 8),
                ),
              ),
              child: Padding(
                padding:
                    widget.childrenPadding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(children: widget.children),
              ),
            ),
        ],
      ),
    );
  }
}
