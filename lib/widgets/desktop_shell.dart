import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/app/router/app_pages.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/strings.dart';

class DesktopShell extends StatelessWidget {
  const DesktopShell({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.toolbar,
    this.actions = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final Widget? toolbar;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceBackground,
      body: SafeArea(
        child: Row(
          children: [
            const _DesktopSidebar(),
            Expanded(
              child: Column(
                children: [
                  _DesktopTopBar(
                    title: title,
                    subtitle: subtitle,
                    actions: actions,
                  ),
                  if (toolbar != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        Dimens.spacingLG,
                        0,
                        Dimens.spacingLG,
                        Dimens.spacingMD,
                      ),
                      child: toolbar!,
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimens.spacingLG,
                        0,
                        Dimens.spacingLG,
                        Dimens.spacingLG,
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({
    required this.title,
    required this.actions,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingLG),
      decoration: const BoxDecoration(
        color: AppColor.white,
        border: Border(bottom: BorderSide(color: AppColor.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeTitle,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: Dimens.spacingXXS),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeCaption,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: Dimens.spacingMD),
            Wrap(
              spacing: Dimens.spacingXS,
              runSpacing: Dimens.spacingXS,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar();

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    const items = <_DesktopNavItem>[
      _DesktopNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: AppString.home,
        route: Routes.home,
      ),
      _DesktopNavItem(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        label: AppString.inventory,
        route: Routes.inventory,
      ),
      _DesktopNavItem(
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        label: AppString.reports,
        route: Routes.reports,
      ),
      _DesktopNavItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: 'Settings',
        route: Routes.settings,
      ),
    ];

    return Container(
      width: 224,
      decoration: const BoxDecoration(
        color: AppColor.white,
        border: Border(right: BorderSide(color: AppColor.border)),
      ),
      child: Column(
        children: [
          Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMD),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColor.border)),
            ),
            child: const Row(
              children: [
                _BrandMark(),
                SizedBox(width: Dimens.spacingSM),
                Expanded(
                  child: Text(
                    AppString.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Dimens.fontSizeBody,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Dimens.spacingSM),
              children: [
                for (final item in items)
                  _DesktopNavButton(
                    item: item,
                    selected: currentRoute == item.route,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopNavButton extends StatelessWidget {
  const _DesktopNavButton({required this.item, required this.selected});

  final _DesktopNavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.spacingXXS),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        onTap: () {
          if (!selected) {
            Get.offAllNamed(item.route);
          }
        },
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingSM),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.primary.withValues(alpha: 0.12)
                : AppColor.transparent,
            borderRadius: BorderRadius.circular(Dimens.radiusXS),
            border: selected ? Border.all(color: AppColor.primaryLight) : null,
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 20,
                color: selected ? AppColor.primaryDark : AppColor.textSecondary,
              ),
              const SizedBox(width: Dimens.spacingSM),
              Expanded(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Dimens.fontSizeBody,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColor.primaryDark
                        : AppColor.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: AppColor.primaryLight),
      ),
      child: const Icon(
        Icons.point_of_sale,
        color: AppColor.primaryDark,
        size: 20,
      ),
    );
  }
}

class _DesktopNavItem {
  const _DesktopNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
}
