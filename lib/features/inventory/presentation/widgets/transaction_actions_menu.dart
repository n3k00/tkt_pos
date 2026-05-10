import 'package:flutter/material.dart';

import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/transaction_dialogs.dart';
import 'package:tkt_pos/widgets/glass_popup_menu.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';

class TransactionActionsMenu extends StatelessWidget {
  const TransactionActionsMenu({
    super.key,
    required this.transaction,
    required this.driverId,
    required this.driver,
    required this.controller,
  });

  final DbTransaction transaction;
  final int driverId;
  final Driver? driver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    final canEdit = controller.canEditTransaction(
      transaction: transaction,
      driver: driver,
    );
    final canDelete = controller.canDeleteTransaction(
      transaction: transaction,
      driver: driver,
    );
    final lockReason = driver?.paidOut == true
        ? 'Reopen payout before editing.'
        : null;

    return GlassPopupMenuButton<String>(
      tooltip: 'Transaction actions',
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: _MenuRow(icon: Icons.visibility_outlined, label: 'View'),
        ),
        PopupMenuItem(
          enabled: canEdit,
          value: 'edit',
          child: Tooltip(
            message: canEdit ? 'Edit transaction' : lockReason ?? 'Unavailable',
            child: _MenuRow(
              icon: Icons.edit_outlined,
              label: 'Edit',
              reason: canEdit ? null : lockReason,
              enabled: canEdit,
            ),
          ),
        ),
        PopupMenuItem(
          enabled: canDelete,
          value: 'delete',
          child: Tooltip(
            message: canDelete
                ? 'Delete transaction'
                : lockReason ?? 'Unavailable',
            child: _MenuRow(
              icon: Icons.delete_outline,
              label: 'Delete',
              reason: canDelete ? null : lockReason,
              enabled: canDelete,
              color: AppColor.error,
            ),
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
              await controller.deleteTransaction(
                transaction: transaction,
                driver: driver,
              );
            }
            break;
        }
      },
      icon: const Icon(Icons.more_horiz),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.reason,
    this.enabled = true,
    this.color,
  });

  final IconData icon;
  final String label;
  final String? reason;
  final bool enabled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled
        ? (color ?? AppColor.textPrimary)
        : AppColor.textMuted;
    return Row(
      children: [
        Icon(icon, size: 18, color: effectiveColor),
        const SizedBox(width: Dimens.spacingXS),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: effectiveColor)),
              if (reason != null)
                Text(
                  reason!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: Dimens.fontSizeCaption,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
