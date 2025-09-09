import 'package:flutter/material.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/driver_dialogs.dart';
import 'package:tkt_pos/widgets/glass_popup_menu.dart';

class DriverActionsMenu extends StatelessWidget {
  const DriverActionsMenu({super.key, required this.driver, required this.controller});
  final Driver driver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return GlassPopupMenuButton<String>(
      tooltip: 'More actions',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
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
      icon: const Icon(Icons.more_horiz),
    );
  }
}
