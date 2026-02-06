import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tkt_pos/widgets/app_drawer.dart';
import 'package:tkt_pos/widgets/edge_drawer_opener.dart';
import 'package:tkt_pos/widgets/page_header.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 80,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Settings',
                crumbs: ['Settings'],
                showBack: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'General',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => SwitchListTile(
                        value: controller.compactTable.value,
                        onChanged: controller.setCompactTable,
                        title: const Text('Compact transactions table'),
                        subtitle: const Text(
                          'Reduce paddings to show more rows',
                        ),
                      ),
                    ),
                    const Divider(height: 32),
                    Text(
                      'Database',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.backup_outlined),
                      title: const Text('Backup database'),
                      subtitle: const Text(
                        'Saves a copy into app backups folder',
                      ),
                      onTap: () async {
                        try {
                          final path = await controller.backupDb();
                          if (!context.mounted) return;
                          if (path == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Backup cancelled.'),
                              ),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Backup saved: $path')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Backup failed: $e')),
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
                          final msg = await controller.restoreFromFileReplaceWithMessage();
                          if (!context.mounted) return;
                          if (msg == null) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
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
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Restore failed: $e')),
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.merge_type_outlined),
                      title: const Text('Restore from file (merge)'),
                      subtitle: const Text(
                        'Choose a .db file and merge into current database',
                      ),
                      onTap: () async {
                        try {
                          final ok = await controller.restoreFromFileMerge();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Merge completed successfully.'
                                    : 'Restore cancelled.',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Merge failed: $e')),
                          );
                        }
                      },
                    ),
                    const Divider(height: 32),
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const ListTile(
                      dense: true,
                      title: Text('App'),
                      subtitle: Text('TKT POS — Inventory Demo'),
                    ),
                    Obx(() => ListTile(
                          dense: true,
                          title: const Text('Version'),
                          subtitle: Text(controller.appVersion.value.isEmpty
                              ? 'beta'
                              : controller.appVersion.value),
                        )),
                  ],
                ),
              ),
            ],
          ),
          EdgeDrawerOpener(),
        ],
      ),
    );
  }
}
