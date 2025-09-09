import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tkt_pos/widgets/appdrawer.dart';
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
                    Obx(() => SwitchListTile(
                          value: controller.compactTable.value,
                          onChanged: controller.setCompactTable,
                          title: const Text('Compact transactions table'),
                          subtitle:
                              const Text('Reduce paddings to show more rows'),
                        )),
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
