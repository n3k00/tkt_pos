import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/driver_dialogs.dart';
import 'package:tkt_pos/features/inventory/presentation/pages/driver_print_page.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/widgets/app_snackbar.dart';
import 'package:tkt_pos/widgets/glass_popup_menu.dart';

class DriverActionsMenu extends StatelessWidget {
  const DriverActionsMenu({
    super.key,
    required this.driver,
    required this.controller,
  });
  final Driver driver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return GlassPopupMenuButton<String>(
      tooltip: 'More actions',
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: controller.canEditDriver(driver),
          value: 'edit',
          child: const Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'print',
          child: const Row(
            children: [
              Icon(Icons.print_outlined, size: 18),
              SizedBox(width: 8),
              Text('Print'),
            ],
          ),
        ),
        PopupMenuItem(
          value: driver.paidOut ? 'reopen_payout' : 'mark_paid_out',
          child: Row(
            children: [
              Icon(
                driver.paidOut
                    ? Icons.lock_open_outlined
                    : Icons.price_check_outlined,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(driver.paidOut ? 'Reopen payout' : 'Mark paid out'),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await showEditDriverDialog(context, controller, driver);
            break;
          case 'print':
            Get.to(() => DriverPrintPage(driverId: driver.id));
            break;
          case 'mark_paid_out':
            await _confirmMarkPaidOut(context);
            break;
          case 'reopen_payout':
            await _confirmReopenPayout(context);
            break;
        }
      },
      icon: const Icon(Icons.more_horiz),
    );
  }

  Future<void> _confirmMarkPaidOut(BuildContext context) async {
    final amount = controller.currentPayoutAmountForDriver(driver);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark paid out?'),
        content: Text(
          'This will snapshot the current payout amount as ${Format.money(amount)}. Later transaction edits will not change the stored paid out amount.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Mark paid'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await controller.markDriverPaidOut(driver);
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: 'Paid out amount saved: ${Format.money(amount)}',
        type: AppSnackbarType.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: 'Failed to mark paid out: $e',
        type: AppSnackbarType.error,
      );
    }
  }

  Future<void> _confirmReopenPayout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reopen payout?'),
        content: const Text(
          'This will clear the stored paid out amount and move this driver back to pending payout.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reopen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await controller.reopenDriverPayout(driver);
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: 'Payout reopened.',
        type: AppSnackbarType.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: 'Failed to reopen payout: $e',
        type: AppSnackbarType.error,
      );
    }
  }
}
