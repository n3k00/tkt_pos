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
      ],
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await showEditDriverDialog(context, controller, driver);
            break;
        }
      },
      icon: const Icon(Icons.more_horiz),
    );
  }
}
