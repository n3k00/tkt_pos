import 'package:flutter/material.dart';

class GlassPopupMenuButton<T> extends StatelessWidget {
  const GlassPopupMenuButton({
    super.key,
    required this.itemBuilder,
    this.onSelected,
    this.tooltip,
    this.icon,
    this.child,
    this.offset = const Offset(0, 8),
    this.minWidth = 180,
  });

  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T>? onSelected;
  final String? tooltip;
  final Widget? icon;
  final Widget? child;
  final Offset offset;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        popupMenuTheme: theme.popupMenuTheme.copyWith(
          color: Colors.white.withOpacity(0.85),
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withOpacity(0.35)),
          ),
        ),
      ),
      child: PopupMenuButton<T>(
        itemBuilder: itemBuilder,
        onSelected: onSelected,
        tooltip: tooltip,
        offset: offset,
        constraints: BoxConstraints(minWidth: minWidth),
        icon: icon,
        child: child,
      ),
    );
  }
}

