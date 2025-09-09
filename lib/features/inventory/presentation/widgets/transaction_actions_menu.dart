import 'package:flutter/material.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/transaction_dialogs.dart';
import 'package:tkt_pos/widgets/glass_popup_menu.dart';

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
    return GlassPopupMenuButton<String>(
      tooltip: 'Transaction actions',
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: _MenuRow(icon: Icons.visibility_outlined, label: 'View'),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: _MenuRow(icon: Icons.edit_outlined, label: 'Edit'),
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
      icon: const Icon(Icons.more_horiz),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
