import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/app/router/app_pages.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/widgets/app_snackbar.dart';
import 'package:tkt_pos/widgets/desktop_form_dialog.dart';
import 'package:tkt_pos/widgets/desktop_shell.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      title: 'Settings',
      subtitle: 'Application preferences, database tools, and version details',
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(Dimens.radiusXS),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 236,
              child: Obx(() {
                final selectedIndex = controller.selectedCategoryIndex.value;
                return ListView.separated(
                  padding: const EdgeInsets.all(Dimens.spacingSM),
                  itemCount: _settingsCategories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: Dimens.spacingXXS),
                  itemBuilder: (context, index) {
                    final category = _settingsCategories[index];
                    return _SettingsCategoryTile(
                      category: category,
                      selected: selectedIndex == index,
                      onTap: () => controller.selectCategory(index),
                    );
                  },
                );
              }),
            ),
            const VerticalDivider(width: 1, color: AppColor.border),
            Expanded(
              child: Obx(() {
                final selectedIndex = controller.selectedCategoryIndex.value;
                return _SettingsDetailPane(
                  category: _settingsCategories[selectedIndex],
                  controller: controller,
                  onBackup: () => _backupDatabase(context),
                  onRestore: () => _restoreDatabase(context),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupDatabase(BuildContext context) async {
    controller.setDatabaseBusy(true);
    controller.setDatabaseStatus('Creating backup...');
    try {
      final path = await controller.backupDb();
      if (!context.mounted) return;
      if (path == null) {
        controller.setDatabaseStatus('Backup cancelled.');
        AppSnackBars.show(
          context,
          message: AppString.snackbarBackupCancelled,
          type: AppSnackbarType.info,
        );
        return;
      }
      controller.setDatabaseStatus('Backup saved: $path');
      AppSnackBars.show(
        context,
        message: AppString.snackbarBackupSaved(path),
        type: AppSnackbarType.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      controller.setDatabaseStatus('Backup failed: $e');
      AppSnackBars.show(
        context,
        message: AppString.snackbarBackupFailed('$e'),
        type: AppSnackbarType.error,
      );
    } finally {
      controller.setDatabaseBusy(false);
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    controller.setDatabaseBusy(true);
    controller.setDatabaseStatus('Waiting for restore file...');
    try {
      final msg = await controller.restoreFromFileReplaceWithMessage();
      if (!context.mounted) return;
      if (msg == null) {
        controller.setDatabaseStatus('Restore complete. Restart required.');
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => PopScope(
            canPop: false,
            child: fluent.ContentDialog(
              title: const Text('Restore complete'),
              content: const Text(
                'The app will close now. Please reopen it manually to use the restored database.',
              ),
              actions: [
                fluent.FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    exit(0);
                  },
                  child: const Text('Close app'),
                ),
              ],
            ),
          ),
        );
        return;
      }
      controller.setDatabaseStatus(msg);
      AppSnackBars.show(context, message: msg, type: AppSnackbarType.warning);
    } catch (e) {
      if (!context.mounted) return;
      controller.setDatabaseStatus('Restore failed: $e');
      AppSnackBars.show(
        context,
        message: AppString.snackbarRestoreFailed('$e'),
        type: AppSnackbarType.error,
      );
    } finally {
      controller.setDatabaseBusy(false);
    }
  }
}

class _SettingsDetailPane extends StatelessWidget {
  const _SettingsDetailPane({
    required this.category,
    required this.controller,
    required this.onBackup,
    required this.onRestore,
  });

  final _SettingsCategory category;
  final SettingsController controller;
  final VoidCallback onBackup;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailHeader(category: category),
        const Divider(height: 1, color: AppColor.border),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimens.spacingLG),
            child: switch (category.id) {
              _SettingsCategoryId.general => _GeneralSettings(
                controller: controller,
              ),
              _SettingsCategoryId.database => _DatabaseSettings(
                controller: controller,
                onBackup: onBackup,
                onRestore: onRestore,
              ),
              _SettingsCategoryId.drivers => _DriversSettings(
                controller: controller,
              ),
              _SettingsCategoryId.activity => const _ActivitySettings(),
              _SettingsCategoryId.about => _AboutSettings(
                controller: controller,
              ),
            },
          ),
        ),
      ],
    );
  }
}

class _GeneralSettings extends StatelessWidget {
  const _GeneralSettings({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Table display',
      child: Obx(
        () => _CommandRow(
          icon: Icons.table_rows_outlined,
          title: 'Compact transactions table',
          description: 'Reduce row padding to show more transactions at once.',
          trailing: Switch(
            value: controller.compactTable.value,
            onChanged: controller.setCompactTable,
          ),
        ),
      ),
    );
  }
}

class _DatabaseSettings extends StatelessWidget {
  const _DatabaseSettings({
    required this.controller,
    required this.onBackup,
    required this.onRestore,
  });

  final SettingsController controller;
  final VoidCallback onBackup;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.databaseBusy.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsSection(
            title: 'Backup',
            child: _CommandRow(
              icon: Icons.backup_outlined,
              title: 'Backup database',
              description: 'Save a copy of the current database to a file.',
              status: controller.databaseStatus.value,
              trailing: fluent.FilledButton(
                onPressed: busy ? null : onBackup,
                child: const Text('Backup...'),
              ),
            ),
          ),
          const SizedBox(height: Dimens.spacingLG),
          _DangerSettingsSection(
            child: _CommandRow(
              icon: Icons.restore_outlined,
              title: 'Restore from file',
              description:
                  'Replace the current database with a selected .db file. The app must close after a successful restore.',
              status: 'This action overwrites existing local data.',
              trailing: OutlinedButton.icon(
                onPressed: busy ? null : onRestore,
                icon: const Icon(Icons.warning_amber_outlined, size: 18),
                label: const Text('Restore...'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.error,
                  side: const BorderSide(color: AppColor.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimens.radiusXS),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ActivitySettings extends StatelessWidget {
  const _ActivitySettings();

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Audit trail',
      child: _CommandRow(
        icon: Icons.history,
        title: 'Activity Log',
        description: 'View transaction edit and delete history snapshots.',
        trailing: fluent.Button(
          onPressed: () => Get.toNamed(Routes.activityLog),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

class _DriversSettings extends StatelessWidget {
  const _DriversSettings({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Driver profiles',
      headerTrailing: fluent.FilledButton(
        onPressed: () => _showDriverProfileDialog(context, controller),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 18),
            SizedBox(width: Dimens.spacingXS),
            Text('Add driver'),
          ],
        ),
      ),
      child: Obx(() {
        final profiles = controller.driverProfiles.toList(growable: false);
        final busy = controller.driverProfilesBusy.value;
        if (busy && profiles.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (profiles.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'No driver profiles yet.',
                style: TextStyle(color: AppColor.textSecondary),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 720),
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: Dimens.spacingMD,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 44,
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final profile in profiles)
                  DataRow(
                    color: WidgetStatePropertyAll(
                      profile.active
                          ? AppColor.white
                          : AppColor.surfaceBackground,
                    ),
                    cells: [
                      DataCell(
                        Text(
                          profile.name,
                          style: TextStyle(
                            color: profile.active
                                ? AppColor.textPrimary
                                : AppColor.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(Text(profile.phone ?? '-')),
                      DataCell(_DriverStatusBadge(active: profile.active)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            fluent.Button(
                              onPressed: () => _showDriverProfileDialog(
                                context,
                                controller,
                                profile: profile,
                              ),
                              child: const Text('Edit'),
                            ),
                            const SizedBox(width: Dimens.spacingXS),
                            fluent.Button(
                              onPressed: () => _toggleProfileActive(
                                context,
                                controller,
                                profile,
                              ),
                              child: Text(
                                profile.active ? 'Deactivate' : 'Activate',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _toggleProfileActive(
    BuildContext context,
    SettingsController controller,
    DriverProfile profile,
  ) async {
    final active = !profile.active;
    try {
      await controller.setDriverProfileActive(profile: profile, active: active);
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: active ? 'Driver activated.' : 'Driver deactivated.',
        type: AppSnackbarType.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: 'Failed to update driver: $e',
        type: AppSnackbarType.error,
      );
    }
  }
}

class _DriverStatusBadge extends StatelessWidget {
  const _DriverStatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColor.success : AppColor.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingXS,
        vertical: Dimens.spacingXXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontSize: Dimens.fontSizeCaption,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> _showDriverProfileDialog(
  BuildContext context,
  SettingsController controller, {
  DriverProfile? profile,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: profile?.name ?? '');
  final phoneController = TextEditingController(text: profile?.phone ?? '');
  var active = profile?.active ?? true;

  try {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> save() async {
              if (!formKey.currentState!.validate()) return;
              try {
                if (profile == null) {
                  await controller.addDriverProfile(
                    name: nameController.text,
                    phone: phoneController.text,
                  );
                } else {
                  await controller.updateDriverProfile(
                    profile: profile,
                    name: nameController.text,
                    phone: phoneController.text,
                    active: active,
                  );
                }
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                AppSnackBars.show(
                  context,
                  message: profile == null
                      ? 'Driver profile added.'
                      : 'Driver profile updated.',
                  type: AppSnackbarType.success,
                );
              } catch (e) {
                if (!context.mounted) return;
                AppSnackBars.show(
                  context,
                  message: 'Failed to save driver: $e',
                  type: AppSnackbarType.error,
                );
              }
            }

            return DesktopFormDialog(
              onCancel: () => Navigator.of(ctx).pop(),
              onSubmit: save,
              maxWidth: 640,
              contentWidth: 560,
              title: Text(profile == null ? 'Add driver' : 'Edit driver'),
              actions: [
                fluent.Button(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                fluent.FilledButton(onPressed: save, child: const Text('Save')),
              ],
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: DesktopFormSection(
                  title: 'Driver profile',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: Dimens.spacingSM),
                      TextFormField(
                        controller: phoneController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => save(),
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: Dimens.spacingSM),
                      SwitchListTile(
                        value: active,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        subtitle: const Text(
                          'Inactive drivers stay in history but should not be used for new daily entries.',
                        ),
                        onChanged: (value) => setState(() => active = value),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  } finally {
    nameController.dispose();
    phoneController.dispose();
  }
}

class _AboutSettings extends StatelessWidget {
  const _AboutSettings({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Application',
      child: Column(
        children: [
          const _InfoRow(label: 'App', value: 'TKT POS - Inventory Demo'),
          const Divider(height: 1, color: AppColor.border),
          Obx(
            () => _InfoRow(
              label: 'Version',
              value: controller.appVersion.value.isEmpty
                  ? 'beta'
                  : controller.appVersion.value,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.category});

  final _SettingsCategory category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingLG),
        child: Row(
          children: [
            Icon(category.icon, size: 22, color: AppColor.textSecondary),
            const SizedBox(width: Dimens.spacingSM),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeSubtitle,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Dimens.spacingXXS),
                  Text(
                    category.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeCaption,
                      color: AppColor.textSecondary,
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

class _SettingsCategoryTile extends StatelessWidget {
  const _SettingsCategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _SettingsCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimens.radiusXS),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingSM),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.drawerItemSelectedBackground
              : AppColor.transparent,
          borderRadius: BorderRadius.circular(Dimens.radiusXS),
          border: Border.all(
            color: selected ? AppColor.primaryLight : AppColor.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              category.icon,
              size: 20,
              color: selected
                  ? AppColor.drawerItemSelectedIconText
                  : AppColor.textSecondary,
            ),
            const SizedBox(width: Dimens.spacingSM),
            Expanded(
              child: Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColor.primaryDark : AppColor.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
    this.headerTrailing,
  });

  final String title;
  final Widget child;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.border),
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimens.spacingMD,
              Dimens.spacingSM,
              Dimens.spacingMD,
              Dimens.spacingSM,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
                if (headerTrailing != null) headerTrailing!,
              ],
            ),
          ),
          const Divider(height: 1, color: AppColor.border),
          child,
        ],
      ),
    );
  }
}

class _DangerSettingsSection extends StatelessWidget {
  const _DangerSettingsSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.error.withValues(alpha: 0.04),
        border: Border.all(color: AppColor.error.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              Dimens.spacingMD,
              Dimens.spacingSM,
              Dimens.spacingMD,
              Dimens.spacingSM,
            ),
            child: Text(
              'Dangerous action',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColor.error,
              ),
            ),
          ),
          Divider(height: 1, color: AppColor.error.withValues(alpha: 0.35)),
          child,
        ],
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  const _CommandRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.trailing,
    this.status,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? status;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.spacingMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColor.surfaceBackground,
              border: Border.all(color: AppColor.border),
              borderRadius: BorderRadius.circular(Dimens.radiusXS),
            ),
            child: Icon(icon, size: 20, color: AppColor.textSecondary),
          ),
          const SizedBox(width: Dimens.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: Dimens.spacingXXS),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeCaption,
                    color: AppColor.textSecondary,
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: Dimens.spacingXS),
                  Text(
                    status!,
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeCaption,
                      color: AppColor.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Dimens.spacingLG),
          trailing,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingMD,
        vertical: Dimens.spacingSM,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColor.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SettingsCategoryId { general, database, drivers, activity, about }

class _SettingsCategory {
  const _SettingsCategory({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });

  final _SettingsCategoryId id;
  final IconData icon;
  final String title;
  final String description;
}

const _settingsCategories = <_SettingsCategory>[
  _SettingsCategory(
    id: _SettingsCategoryId.general,
    icon: Icons.tune_outlined,
    title: 'General',
    description: 'Display preferences used across the app.',
  ),
  _SettingsCategory(
    id: _SettingsCategoryId.database,
    icon: Icons.storage_outlined,
    title: 'Database',
    description: 'Backup, restore, and local database operations.',
  ),
  _SettingsCategory(
    id: _SettingsCategoryId.drivers,
    icon: Icons.badge_outlined,
    title: 'Drivers',
    description: 'Driver master data, phone numbers, and active status.',
  ),
  _SettingsCategory(
    id: _SettingsCategoryId.activity,
    icon: Icons.history,
    title: 'Activity Log',
    description: 'Transaction history and audit trail.',
  ),
  _SettingsCategory(
    id: _SettingsCategoryId.about,
    icon: Icons.info_outline,
    title: 'About',
    description: 'Application name and version.',
  ),
];
