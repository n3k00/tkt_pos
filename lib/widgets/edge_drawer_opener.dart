import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Invisible edge zone on the far left that opens the Drawer when the
/// cursor enters (desktop) or when a drag starts (touch/trackpad).
class EdgeDrawerOpener extends StatefulWidget {
  const EdgeDrawerOpener({
    super.key,
    this.width = 12,
    this.handleHeight = 80,
    this.showHandle = true,
  });

  final double width;
  final double handleHeight;
  final bool showHandle;

  @override
  State<EdgeDrawerOpener> createState() => _EdgeDrawerOpenerState();
}

class _EdgeDrawerOpenerState extends State<EdgeDrawerOpener> {
  DateTime _lastOpen = DateTime.fromMillisecondsSinceEpoch(0);
  bool _pending = false;
  bool _hover = false;

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
        onEnter: (_) {
          setState(() => _hover = true);
          _openDrawer();
        },
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (_) => _openDrawer(),
          child: SizedBox(
            width: widget.width,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.showHandle)
                  IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hover ? 0.95 : 0.7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: widget.width - 2,
                            height: widget.handleHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.35),
                                  Colors.white.withOpacity(0.18),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

