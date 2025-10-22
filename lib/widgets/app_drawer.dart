import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/app/router/app_pages.dart';

/// Slim, icon-only sidebar drawer inspired by the provided design.
/// Keeps existing GetX navigation behavior and route names.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute;

    Color iconColor(bool selected) =>
        selected ? AppColor.primaryDark : Colors.black.withOpacity(0.55);

    // Simple nav model to reduce repetition
    const topItems = <_NavItem>[
      _NavItem(icon: Icons.home, tooltip: 'Home', route: Routes.home),
      _NavItem(icon: Icons.inventory_2, tooltip: 'Inventory', route: Routes.inventory),
      _NavItem(icon: Icons.bar_chart, tooltip: 'Reports', route: Routes.reports),
    ];
    const bottomItems = <_NavItem>[
      _NavItem(icon: Icons.settings, tooltip: 'Settings', route: Routes.settings),
    ];

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
                  // Top nav buttons
                  ...topItems.map((it) => _NavIconButton(
                        icon: it.icon,
                        tooltip: it.tooltip,
                        selected: currentRoute == it.route,
                        onTap: () {
                          Get.back();
                          if (currentRoute != it.route) {
                            // Keep existing behavior: clear and go to target
                            Get.offAllNamed(it.route);
                          }
                        },
                        color: iconColor(currentRoute == it.route),
                      )),

                  const Spacer(),

                  // Bottom nav buttons
                  ...bottomItems.map((it) => _NavIconButton(
                        icon: it.icon,
                        tooltip: it.tooltip,
                        selected: currentRoute == it.route,
                        onTap: () {
                          Get.back();
                          if (currentRoute != it.route) {
                            Get.offAllNamed(it.route);
                          }
                        },
                        color: iconColor(currentRoute == it.route),
                      )),

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

class _NavItem {
  final IconData icon;
  final String tooltip;
  final String route;
  const _NavItem({required this.icon, required this.tooltip, required this.route});
}
