import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/app/router/app_pages.dart';
import 'package:tkt_pos/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/widgets/app_snackbar.dart';
import 'package:tkt_pos/widgets/desktop_shell.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      title: 'Settings',
      subtitle: 'Application preferences, database tools, and version details',
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            children: [
              Text('General', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Dimens.spacingXS),
              Obx(
                () => SwitchListTile(
                  value: controller.compactTable.value,
                  onChanged: controller.setCompactTable,
                  title: const Text('Compact transactions table'),
                  subtitle: const Text('Reduce paddings to show more rows'),
                ),
              ),
              const Divider(height: Dimens.spacingXXL),
              Text('Database', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Dimens.spacingXS),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('Backup database'),
                subtitle: const Text('Saves a copy into app backups folder'),
                onTap: () async {
                  try {
                    final path = await controller.backupDb();
                    if (!context.mounted) return;
                    if (path == null) {
                      AppSnackBars.show(
                        context,
                        message: AppString.snackbarBackupCancelled,
                        type: AppSnackbarType.info,
                      );
                      return;
                    }
                    AppSnackBars.show(
                      context,
                      message: AppString.snackbarBackupSaved(path),
                      type: AppSnackbarType.success,
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    AppSnackBars.show(
                      context,
                      message: AppString.snackbarBackupFailed('$e'),
                      type: AppSnackbarType.error,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore_outlined),
                title: const Text('Restore from file (replace)'),
                subtitle: const Text(
                  'Choose a .db file and replace current database',
                ),
                onTap: () async {
                  try {
                    final msg = await controller
                        .restoreFromFileReplaceWithMessage();
                    if (!context.mounted) return;
                    if (msg == null) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => PopScope(
                          canPop: false,
                          child: AlertDialog(
                            title: const Text('Restore complete'),
                            content: const Text(
                              'The app will close now. Please reopen it manually to use the restored database.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  exit(0);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      AppSnackBars.show(
                        context,
                        message: msg,
                        type: AppSnackbarType.warning,
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    AppSnackBars.show(
                      context,
                      message: AppString.snackbarRestoreFailed('$e'),
                      type: AppSnackbarType.error,
                    );
                  }
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Activity Log'),
                subtitle: const Text('View transaction edit history'),
                onTap: () => Get.toNamed(Routes.activityLog),
              ),
              const Divider(height: 32),
              Text('About', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Dimens.spacingXS),
              const ListTile(
                dense: true,
                title: Text('App'),
                subtitle: Text('TKT POS — Inventory Demo'),
              ),
              Obx(
                () => ListTile(
                  dense: true,
                  title: const Text('Version'),
                  subtitle: Text(
                    controller.appVersion.value.isEmpty
                        ? 'beta'
                        : controller.appVersion.value,
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
