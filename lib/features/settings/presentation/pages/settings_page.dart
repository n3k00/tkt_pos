import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tkt_pos/widgets/appdrawer.dart';
import 'package:tkt_pos/widgets/edge_drawer_opener.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
      ),
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 80,
      body: Stack(
        children: [
          ListView(
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
                    subtitle: const Text('Reduce paddings to show more rows'),
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
          EdgeDrawerOpener(),
        ],
      ),
    );
  }
}
