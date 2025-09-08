import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/resources/colors.dart';

/// Slim, icon-only sidebar drawer inspired by the provided design.
/// Keeps existing GetX navigation behavior and route names.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute;

    Color iconColor(bool selected) =>
        selected ? AppColor.primaryDark : Colors.black.withOpacity(0.55);

    return Drawer(
      width: 88,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  // Brand / App icon
                  const _CircleSurface(
                    size: 48,
                    child: Icon(Icons.dashboard, color: AppColor.primaryDark),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 24),

                  // Nav buttons
                  _NavIconButton(
                    icon: Icons.home,
                    tooltip: 'Home',
                    selected: currentRoute == '/home',
                    onTap: () {
                      Get.back();
                      if (currentRoute != '/home') Get.offAllNamed('/home');
                    },
                    color: iconColor(currentRoute == '/home'),
                  ),
                  _NavIconButton(
                    icon: Icons.inventory_2,
                    tooltip: 'Inventory',
                    selected: currentRoute == '/inventory',
                    onTap: () {
                      Get.back();
                      if (currentRoute != '/inventory') {
                        Get.offAllNamed('/inventory');
                      }
                    },
                    color: iconColor(currentRoute == '/inventory'),
                  ),
                  _NavIconButton(
                    icon: Icons.bar_chart,
                    tooltip: 'Reports',
                    selected: currentRoute == '/reports',
                    onTap: () {
                      Get.back();
                      if (currentRoute != '/reports') {
                        Get.offAllNamed('/reports');
                      }
                    },
                    color: iconColor(currentRoute == '/reports'),
                  ),

                  const Spacer(),

                  _NavIconButton(
                    icon: Icons.settings,
                    tooltip: 'Settings',
                    selected: currentRoute == '/settings',
                    onTap: () {
                      Get.back();
                      if (currentRoute != '/settings') {
                        Get.offAllNamed('/settings');
                      }
                    },
                    color: iconColor(currentRoute == '/settings'),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 300),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: selected
                  ? AppColor.primary.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Icon(icon, color: color, size: 26)),
          ),
        ),
      ),
    );
  }
}

class _CircleSurface extends StatelessWidget {
  const _CircleSurface({required this.size, required this.child});
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColor.card,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }
}
