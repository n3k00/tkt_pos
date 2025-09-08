import 'package:flutter/material.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/transaction_dialogs.dart';

class TransactionActionsMenu extends StatelessWidget {
  const TransactionActionsMenu({
    super.key,
    required this.transaction,
    required this.driverId,
    required this.controller,
  });

  final DbTransaction transaction;
  final int driverId;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Transaction actions',
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'view', child: Text('View')),
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
          case 'view':
            await showViewTransactionDialog(context, transaction);
            break;
          case 'edit':
            await showEditTransactionDialog(
              context,
              controller,
              driverId,
              transaction,
            );
            break;
          case 'delete':
            final ok = await confirmDeleteTransaction(context, transaction);
            if (ok == true) {
              await controller.db.deleteTransactionById(transaction.id);
              await controller.loadTransactionsByDriverToMap(driverId);
            }
            break;
        }
      },
      icon: const Icon(Icons.more_vert),
    );
  }
}
