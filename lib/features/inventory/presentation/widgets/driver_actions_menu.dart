import 'package:flutter/material.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/driver_dialogs.dart';

class DriverActionsMenu extends StatelessWidget {
  const DriverActionsMenu({super.key, required this.driver, required this.controller});
  final Driver driver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More actions',
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await showEditDriverDialog(context, controller, driver);
            break;
          case 'delete':
            final confirmed = await confirmDeleteDriver(context, driver);
            if (confirmed == true) {
              await controller.deleteDriver(driver.id);
            }
            break;
        }
      },
      icon: const Icon(Icons.more_vert),
    );
  }
}

