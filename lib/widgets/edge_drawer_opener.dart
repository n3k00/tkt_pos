import 'dart:async';
import 'package:flutter/material.dart';

/// Invisible edge zone on the far left that opens the Drawer when the
/// cursor enters (desktop) or when a drag starts (touch/trackpad).
class EdgeDrawerOpener extends StatefulWidget {
  const EdgeDrawerOpener({super.key, this.width = 12});

  final double width;

  @override
  State<EdgeDrawerOpener> createState() => _EdgeDrawerOpenerState();
}

class _EdgeDrawerOpenerState extends State<EdgeDrawerOpener> {
  DateTime _lastOpen = DateTime.fromMillisecondsSinceEpoch(0);
  bool _pending = false;

  bool get _throttled {
    final now = DateTime.now();
    return now.difference(_lastOpen) < const Duration(milliseconds: 800) ||
        _pending;
  }

  Future<void> _openDrawer() async {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold == null) return;
    if (scaffold.isDrawerOpen) return;
    if (_throttled) return;
    _pending = true;
    _lastOpen = DateTime.now();
    // Slight delay prevents accidental flicker when moving diagonally.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (mounted && !scaffold.isDrawerOpen) {
      scaffold.openDrawer();
    }
    _pending = false;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: MouseRegion(
        opaque: false,
        onEnter: (_) => _openDrawer(),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (_) => _openDrawer(),
          child: SizedBox(
            width: widget.width,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}

