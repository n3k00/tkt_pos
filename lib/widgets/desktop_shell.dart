import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart'
    show Icon, IconData, Icons, Material, MaterialType, StatelessWidget;
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
    this.actions = const <fluent.Widget>[],
  });

  final String title;
  final String? subtitle;
  final fluent.Widget? toolbar;
  final List<fluent.Widget> actions;
  final fluent.Widget child;

  @override
  fluent.Widget build(fluent.BuildContext context) {
    final navItems = _navItems;
    final selectedIndex = navItems.indexWhere(
      (item) => item.route == Get.currentRoute,
    );

    return fluent.NavigationView(
      pane: fluent.NavigationPane(
        selected: selectedIndex < 0 ? 0 : selectedIndex,
        displayMode: fluent.PaneDisplayMode.expanded,
        toggleButton: null,
        size: const fluent.NavigationPaneSize(openWidth: 232),
        header: const _PaneHeader(),
        onChanged: (index) {
          final item = navItems[index];
          if (Get.currentRoute != item.route) {
            Get.offAllNamed(item.route);
          }
        },
        items: [
          for (final item in navItems)
            fluent.PaneItem(
              icon: Icon(item.icon),
              title: fluent.Text(item.label),
              body: const fluent.SizedBox.shrink(),
            ),
        ],
      ),
      paneBodyBuilder: (_, _) => _DesktopShellBody(
        title: title,
        subtitle: subtitle,
        toolbar: toolbar,
        actions: actions,
        child: child,
      ),
    );
  }
}

class _DesktopShellBody extends StatelessWidget {
  const _DesktopShellBody({
    required this.title,
    required this.actions,
    required this.child,
    this.subtitle,
    this.toolbar,
  });

  final String title;
  final String? subtitle;
  final fluent.Widget? toolbar;
  final List<fluent.Widget> actions;
  final fluent.Widget child;

  @override
  fluent.Widget build(fluent.BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: fluent.Container(
        color: AppColor.surfaceBackground,
        child: fluent.Column(
          children: [
            _DesktopTopBar(title: title, subtitle: subtitle, actions: actions),
            if (toolbar != null)
              fluent.Padding(
                padding: const fluent.EdgeInsets.fromLTRB(
                  Dimens.spacingLG,
                  0,
                  Dimens.spacingLG,
                  Dimens.spacingMD,
                ),
                child: toolbar!,
              ),
            fluent.Expanded(
              child: fluent.Padding(
                padding: const fluent.EdgeInsets.fromLTRB(
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
  final List<fluent.Widget> actions;

  @override
  fluent.Widget build(fluent.BuildContext context) {
    return fluent.Container(
      height: 76,
      padding: const fluent.EdgeInsets.symmetric(horizontal: Dimens.spacingLG),
      decoration: const fluent.BoxDecoration(
        color: AppColor.white,
        border: fluent.Border(
          bottom: fluent.BorderSide(color: AppColor.border),
        ),
      ),
      child: fluent.Row(
        children: [
          fluent.Expanded(
            child: fluent.Column(
              mainAxisAlignment: fluent.MainAxisAlignment.center,
              crossAxisAlignment: fluent.CrossAxisAlignment.start,
              children: [
                fluent.Text(
                  title,
                  style: const fluent.TextStyle(
                    fontSize: Dimens.fontSizeTitle,
                    fontWeight: fluent.FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const fluent.SizedBox(height: Dimens.spacingXXS),
                  fluent.Text(
                    subtitle!,
                    style: const fluent.TextStyle(
                      fontSize: Dimens.fontSizeCaption,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const fluent.SizedBox(width: Dimens.spacingMD),
            fluent.Row(
              mainAxisSize: fluent.MainAxisSize.min,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const fluent.SizedBox(width: Dimens.spacingXS),
                  actions[i],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PaneHeader extends StatelessWidget {
  const _PaneHeader();

  @override
  fluent.Widget build(fluent.BuildContext context) {
    return fluent.Padding(
      padding: const fluent.EdgeInsets.fromLTRB(
        Dimens.spacingSM,
        Dimens.spacingSM,
        Dimens.spacingSM,
        Dimens.spacingXS,
      ),
      child: fluent.Row(
        children: [
          const _BrandMark(),
          const fluent.SizedBox(width: Dimens.spacingSM),
          fluent.Expanded(
            child: fluent.Wrap(
              crossAxisAlignment: fluent.WrapCrossAlignment.center,
              spacing: Dimens.spacingXS,
              runSpacing: Dimens.spacingXXS,
              children: [
                fluent.Text(
                  AppString.title,
                  maxLines: 1,
                  overflow: fluent.TextOverflow.ellipsis,
                  style: const fluent.TextStyle(
                    fontSize: Dimens.fontSizeBody,
                    fontWeight: fluent.FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                fluent.Container(
                  padding: const fluent.EdgeInsets.symmetric(
                    horizontal: Dimens.spacingXS,
                    vertical: 2,
                  ),
                  decoration: fluent.BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.12),
                    borderRadius: fluent.BorderRadius.circular(Dimens.radiusXS),
                    border: fluent.Border.all(color: AppColor.primaryLight),
                  ),
                  child: const fluent.Text(
                    AppString.releaseLabel,
                    style: fluent.TextStyle(
                      fontSize: Dimens.fontSizeCaption,
                      fontWeight: fluent.FontWeight.w700,
                      color: AppColor.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  fluent.Widget build(fluent.BuildContext context) {
    return fluent.Container(
      width: 36,
      height: 36,
      decoration: fluent.BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.12),
        borderRadius: fluent.BorderRadius.circular(Dimens.radiusXS),
        border: fluent.Border.all(color: AppColor.primaryLight),
      ),
      child: const fluent.Center(
        child: fluent.Text(
          'B5',
          style: fluent.TextStyle(
            color: AppColor.primaryDark,
            fontWeight: fluent.FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

const _navItems = <_DesktopNavItem>[
  _DesktopNavItem(
    icon: Icons.home_outlined,
    label: AppString.home,
    route: Routes.home,
  ),
  _DesktopNavItem(
    icon: Icons.inventory_2_outlined,
    label: AppString.inventory,
    route: Routes.inventory,
  ),
  _DesktopNavItem(
    icon: Icons.bar_chart_outlined,
    label: AppString.reports,
    route: Routes.reports,
  ),
  _DesktopNavItem(
    icon: Icons.settings_outlined,
    label: 'Settings',
    route: Routes.settings,
  ),
];

class _DesktopNavItem {
  const _DesktopNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
