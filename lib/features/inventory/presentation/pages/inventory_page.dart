import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/resources/table_widths.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/resources/styles.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/driver_dialogs.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/transaction_dialogs.dart';
import 'package:tkt_pos/features/inventory/presentation/widgets/transaction_actions_menu.dart';
import 'package:tkt_pos/features/inventory/presentation/widgets/driver_actions_menu.dart';
import 'package:tkt_pos/widgets/page_header.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/utils/payout_calculator.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';
import 'package:tkt_pos/widgets/desktop_shell.dart';

const _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class InventoryPage extends GetView<InventoryController> {
  const InventoryPage({super.key});

  Future<void> _openMonthPicker(BuildContext context) async {
    final initial = controller.selectedDate.value;
    final result = await _showMonthYearPickerDialog(context, initial);
    if (result != null) {
      controller.selectedDate.value = DateTime(result.year, result.month, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      title: AppString.inventory,
      subtitle: 'Drivers, parcels, collection status, and payout tracking',
      toolbar: _DesktopToolbar(
        controller: controller,
        onPickMonth: () => _openMonthPicker(context),
        onAddDriver: () => showAddDriverDialog(context, controller),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = controller.drivers;
        if (all.isEmpty) {
          return const Center(child: Text(AppString.noDrivers));
        }
        final selectedMonth = controller.selectedDate.value;
        final monthFiltered = all
            .where(
              (d) =>
                  d.date.year == selectedMonth.year &&
                  d.date.month == selectedMonth.month,
            )
            .toList(growable: false);
        if (monthFiltered.isEmpty) {
          return const Center(child: Text(AppString.noResults));
        }
        final q = controller.searchQuery.value.trim();
        final bool filterByRows =
            controller.showUnclaimedOnly.value || q.isNotEmpty;
        final filteredDrivers = filterByRows
            ? monthFiltered
                  .where(
                    (d) => controller
                        .filteredTransactionsForDriver(d.id)
                        .isNotEmpty,
                  )
                  .toList(growable: false)
            : monthFiltered;

        if (filteredDrivers.isEmpty) {
          return const Center(child: Text(AppString.noResults));
        }

        return _InventoryTabbedContent(
          drivers: filteredDrivers,
          controller: controller,
        );
      }),
    );
  }
}

class _DesktopToolbar extends StatelessWidget {
  const _DesktopToolbar({
    required this.controller,
    required this.onPickMonth,
    required this.onAddDriver,
  });

  final InventoryController controller;
  final VoidCallback onPickMonth;
  final VoidCallback onAddDriver;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(Dimens.spacingSM),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: AppColor.border),
      ),
      child: _FiltersToolbar(
        controller: controller,
        onPickMonth: onPickMonth,
        onAddDriver: onAddDriver,
      ),
    );
  }
}

class _InventoryTabbedContent extends StatelessWidget {
  const _InventoryTabbedContent({
    required this.drivers,
    required this.controller,
  });

  final List<Driver> drivers;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border.all(color: AppColor.border),
              borderRadius: BorderRadius.circular(Dimens.radiusXS),
            ),
            child: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Transactions'),
                Tab(text: 'Drivers'),
              ],
            ),
          ),
          const SizedBox(height: Dimens.spacingSM),
          Expanded(
            child: TabBarView(
              children: [
                _AllTransactionsTable(drivers: drivers, controller: controller),
                Obx(() {
                  final selectedId = controller.selectedDriverId.value;
                  final selectedDriver = drivers.firstWhere(
                    (driver) => driver.id == selectedId,
                    orElse: () => drivers.first,
                  );

                  return _InventoryMasterDetail(
                    drivers: drivers,
                    selectedDriver: selectedDriver,
                    controller: controller,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverTransactionGroup {
  const _DriverTransactionGroup({
    required this.driver,
    required this.transactions,
  });

  final Driver driver;
  final List<DbTransaction> transactions;
}

class _AllTransactionsTable extends StatelessWidget {
  const _AllTransactionsTable({
    required this.drivers,
    required this.controller,
  });

  final List<Driver> drivers;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = <_DriverTransactionGroup>[
        for (final driver in drivers)
          if (controller.filteredTransactionsForDriver(driver.id).isNotEmpty)
            _DriverTransactionGroup(
              driver: driver,
              transactions: controller.filteredTransactionsForDriver(driver.id),
            ),
      ];

      groups.sort((a, b) {
        final dateCompare = b.driver.date.compareTo(a.driver.date);
        if (dateCompare != 0) return dateCompare;
        return a.driver.name.compareTo(b.driver.name);
      });

      if (groups.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: AppColor.card,
            border: Border.all(color: AppColor.border),
            borderRadius: BorderRadius.circular(Dimens.radiusXS),
          ),
          child: const Center(
            child: Text(
              AppString.noResults,
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: groups.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: Dimens.spacingSM),
        itemBuilder: (context, index) => _AllTransactionsGroupSection(
          group: groups[index],
          controller: controller,
        ),
      );
    });
  }
}

class _AllTransactionsGroupSection extends StatelessWidget {
  const _AllTransactionsGroupSection({
    required this.group,
    required this.controller,
  });

  final _DriverTransactionGroup group;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    final totalCharges = group.transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.charges,
    );
    final paidAmount = group.transactions.fold<double>(
      0,
      (sum, transaction) =>
          sum + (_isPaymentPaid(transaction) ? transaction.charges : 0),
    );
    final pendingAmount = group.transactions.fold<double>(
      0,
      (sum, transaction) =>
          sum + (_isPaymentPaid(transaction) ? 0 : transaction.charges),
    );
    final pendingClaimedAmount = group.transactions.fold<double>(
      0,
      (sum, transaction) =>
          sum +
          (!_isPaymentPaid(transaction) && transaction.pickedUp
              ? transaction.charges
              : 0),
    );
    final pendingUnclaimedAmount = group.transactions.fold<double>(
      0,
      (sum, transaction) =>
          sum +
          (!_isPaymentPaid(transaction) && !transaction.pickedUp
              ? transaction.charges
              : 0),
    );
    final claimedCount = group.transactions
        .where((transaction) => transaction.pickedUp)
        .length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.border),
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.spacingMD,
              vertical: Dimens.spacingSM,
            ),
            decoration: const BoxDecoration(
              color: AppColor.card,
              border: Border(bottom: BorderSide(color: AppColor.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${group.driver.name}  •  ${Format.date(group.driver.date)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: Dimens.fontSizeBody,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimens.spacingSM),
                    _PayoutStatusBadge(isPaidOut: group.driver.paidOut),
                  ],
                ),
                const SizedBox(height: Dimens.spacingSM),
                Wrap(
                  spacing: Dimens.spacingMD,
                  runSpacing: Dimens.spacingXS,
                  children: [
                    _GroupMetric(
                      label: 'Transactions',
                      value: '${group.transactions.length}',
                    ),
                    _GroupMetric(
                      label: 'Claimed',
                      value: '$claimedCount/${group.transactions.length}',
                    ),
                    _GroupMetric(
                      label: AppString.colCharges,
                      value: Format.money(totalCharges),
                      alignRight: true,
                    ),
                    _GroupMetric(
                      label: 'Payment Paid',
                      value: Format.money(paidAmount),
                      alignRight: true,
                    ),
                    _GroupMetric(
                      label: 'Payment Pending',
                      value: Format.money(pendingAmount),
                      alignRight: true,
                    ),
                    _GroupMetric(
                      label: 'Pending Claimed',
                      value: Format.money(pendingClaimedAmount),
                      alignRight: true,
                    ),
                    _GroupMetric(
                      label: 'Pending Unclaimed',
                      value: Format.money(pendingUnclaimedAmount),
                      alignRight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppDataTable(
            table: DataTable(
              columnSpacing: 16,
              horizontalMargin: 12,
              dataRowMinHeight: 42,
              dataRowMaxHeight: 42,
              showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text(AppString.colNo)),
                DataColumn(label: Text(AppString.colCustomerName)),
                DataColumn(label: Text(AppString.colPhone)),
                DataColumn(label: Text(AppString.colParcelType)),
                DataColumn(label: Text(AppString.colNumber)),
                DataColumn(label: Text(AppString.colCharges)),
                DataColumn(label: Text(AppString.colPaymentStatus)),
                DataColumn(label: Text(AppString.colCashAdvance)),
                DataColumn(label: Text(AppString.colPickedUp)),
                DataColumn(label: Text(AppString.colComment)),
                DataColumn(label: SizedBox.shrink()),
              ],
              rows: [
                for (final entry in group.transactions.asMap().entries)
                  _groupTransactionDataRow(
                    context: context,
                    index: entry.key + 1,
                    driver: group.driver,
                    transaction: entry.value,
                    controller: controller,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

bool _isPaymentPaid(DbTransaction transaction) {
  return transaction.paymentStatus == AppString.paymentPaid ||
      transaction.paymentStatus == AppString.paymentPaidLegacy ||
      transaction.paymentStatus == AppString.paymentPaidAltMm;
}

class _GroupMetric extends StatelessWidget {
  const _GroupMetric({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.textSecondary,
              fontSize: Dimens.fontSizeCaption,
            ),
          ),
          const SizedBox(height: Dimens.spacingMicro),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: Dimens.fontSizeBody,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

DataRow _groupTransactionDataRow({
  required BuildContext context,
  required int index,
  required Driver driver,
  required DbTransaction transaction,
  required InventoryController controller,
}) {
  void openDetails() => showViewTransactionDialog(context, transaction);

  return DataRow(
    cells: [
      DataCell(Text('$index'), onTap: openDetails),
      DataCell(
        SizedBox(
          width: 170,
          child: Text(
            transaction.customerName ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onTap: openDetails,
      ),
      DataCell(Text(transaction.phone), onTap: openDetails),
      DataCell(
        SizedBox(
          width: AppTableWidths.parcelType,
          child: Text(
            transaction.parcelType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onTap: openDetails,
      ),
      DataCell(Text(transaction.number), onTap: openDetails),
      DataCell(
        Align(
          alignment: Alignment.centerRight,
          child: Text(Format.money(transaction.charges)),
        ),
        onTap: openDetails,
      ),
      DataCell(Text(transaction.paymentStatus), onTap: openDetails),
      DataCell(
        Align(
          alignment: Alignment.centerRight,
          child: Text(Format.money(transaction.cashAdvance)),
        ),
        onTap: openDetails,
      ),
      DataCell(
        Center(
          child:
              !controller.canClaimTransaction(
                transaction: transaction,
                driver: driver,
              )
              ? const Icon(Icons.check, color: AppColor.success)
              : fluent.Button(
                  onPressed: () => showClaimTransactionDialog(
                    context,
                    controller,
                    transaction,
                  ),
                  child: const Text('Claim'),
                ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 180,
          child: Text(
            (transaction.comment?.trim().isNotEmpty ?? false)
                ? transaction.comment!.trim()
                : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onTap: openDetails,
      ),
      DataCell(
        Align(
          alignment: Alignment.centerRight,
          child: TransactionActionsMenu(
            transaction: transaction,
            driverId: driver.id,
            driver: driver,
            controller: controller,
          ),
        ),
      ),
    ],
  );
}

class _InventoryMasterDetail extends StatelessWidget {
  const _InventoryMasterDetail({
    required this.drivers,
    required this.selectedDriver,
    required this.controller,
  });

  final List<Driver> drivers;
  final Driver selectedDriver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 300,
          child: _DriversTable(
            drivers: drivers,
            selectedDriverId: selectedDriver.id,
            controller: controller,
          ),
        ),
        const SizedBox(width: Dimens.spacingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailHeader(driver: selectedDriver, controller: controller),
              const SizedBox(height: Dimens.spacingSM),
              Expanded(
                child: _DriverTransactionsTable(
                  controller: controller,
                  driverId: selectedDriver.id,
                ),
              ),
              const SizedBox(height: Dimens.spacingSM),
              _DriverSummaryStrip(
                driver: selectedDriver,
                controller: controller,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriversTable extends StatelessWidget {
  const _DriversTable({
    required this.drivers,
    required this.selectedDriverId,
    required this.controller,
  });

  final List<Driver> drivers;
  final int selectedDriverId;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    void selectDriver(Driver driver) {
      controller.selectedDriverId.value = driver.id;
    }

    return AppDataTable(
      table: DataTable(
        columnSpacing: 12,
        horizontalMargin: 12,
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text(AppString.colDriver)),
          DataColumn(label: Text('Status')),
        ],
        rows: [
          for (final driver in drivers)
            DataRow(
              selected: driver.id == selectedDriverId,
              onSelectChanged: (_) => selectDriver(driver),
              cells: [
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          Format.date(driver.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColor.textSecondary,
                            fontSize: Dimens.fontSizeCaption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => selectDriver(driver),
                ),
                DataCell(
                  _CompactStatus(isPaidOut: driver.paidOut),
                  onTap: () => selectDriver(driver),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.driver, required this.controller});

  final Driver driver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    final locked = driver.paidOut;
    final lockedMessage = driver.paidOutAt == null
        ? 'Paid out - reopen to edit'
        : 'Paid out ${Format.dateTime12(driver.paidOutAt!)} - reopen to edit';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingSM),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(
          color: locked
              ? AppColor.success.withValues(alpha: 0.35)
              : AppColor.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${driver.name}  •  ${Format.date(driver.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeSubtitle,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                if (locked) ...[
                  const SizedBox(height: Dimens.spacingMicro),
                  _LockedHint(message: lockedMessage),
                ],
              ],
            ),
          ),
          Tooltip(
            message: locked
                ? 'Reopen payout before adding transactions.'
                : AppString.addTransaction,
            child: fluent.Button(
              onPressed: controller.canAddTransaction(driver)
                  ? () =>
                        showAddTransactionDialog(context, controller, driver.id)
                  : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: Dimens.spacingXXS),
                  Text(AppString.addTransaction),
                ],
              ),
            ),
          ),
          const SizedBox(width: Dimens.spacingXS),
          Tooltip(
            message: locked
                ? 'Reopen payout before editing fees.'
                : 'Edit room, labor, and delivery fees',
            child: fluent.Button(
              onPressed: controller.canEditDriverFees(driver)
                  ? () => showEditDriverFeesDialog(context, controller, driver)
                  : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.price_change_outlined, size: 16),
                  SizedBox(width: Dimens.spacingXXS),
                  Text('Edit fees'),
                ],
              ),
            ),
          ),
          const SizedBox(width: Dimens.spacingXS),
          DriverActionsMenu(driver: driver, controller: controller),
        ],
      ),
    );
  }
}

class _LockedHint extends StatelessWidget {
  const _LockedHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.lock_outline,
          size: 13,
          color: AppColor.success.withValues(alpha: 0.95),
        ),
        const SizedBox(width: Dimens.spacingXXS),
        Flexible(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColor.success.withValues(alpha: 0.95),
              fontSize: Dimens.fontSizeCaption,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DriverSummaryStrip extends StatelessWidget {
  const _DriverSummaryStrip({required this.driver, required this.controller});

  final Driver driver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    final rows = controller.filteredTransactionsForDriver(driver.id);
    final payout = PayoutCalculator.forDriver(driver, rows);

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMD),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          _SummaryCell(
            label: AppString.driverTotalCharges,
            value: Format.money(payout.totalCharges),
          ),
          _SummaryCell(
            label: 'Payment Pending',
            value: Format.money(payout.paymentPending),
            subValue: 'Payable base',
          ),
          _SummaryCell(
            label: AppString.driverRoomFee,
            value: Format.money(payout.roomFee),
          ),
          _SummaryCell(
            label: AppString.driverLaborFee,
            value: Format.money(payout.laborFee),
          ),
          _SummaryCell(
            label: AppString.driverDeliveryFee,
            value: Format.money(payout.deliveryFee),
          ),
          _SummaryCell(
            label: AppString.driverPaidOutAmount,
            value: Format.money(payout.displayedPaidOutAmount),
            subValue: driver.paidOutAt == null
                ? (driver.paidOut ? 'Snapshot saved' : 'Current')
                : Format.dateTime12(driver.paidOutAt!),
          ),
          if (driver.paidOut)
            _SummaryCell(
              label: 'Difference',
              value: Format.money(payout.difference),
              valueColor: payout.difference == 0
                  ? AppColor.textPrimary
                  : payout.difference > 0
                  ? AppColor.error
                  : AppColor.success,
            )
          else
            const SizedBox.shrink(),
          _CompactStatus(isPaidOut: driver.paidOut),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    this.subValue,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? subValue;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: Dimens.spacingSM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontSize: Dimens.fontSizeCaption,
              ),
            ),
            const SizedBox(height: Dimens.spacingMicro),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ?? AppColor.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subValue != null)
              Text(
                subValue!,
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
    );
  }
}

class _CompactStatus extends StatelessWidget {
  const _CompactStatus({required this.isPaidOut});

  final bool isPaidOut;

  @override
  Widget build(BuildContext context) {
    final color = isPaidOut ? AppColor.success : AppColor.warning;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingXS,
        vertical: Dimens.spacingMicro,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        isPaidOut ? 'Paid' : 'Pending',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: Dimens.fontSizeCaption,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PayoutStatusBadge extends StatelessWidget {
  const _PayoutStatusBadge({required this.isPaidOut});

  final bool isPaidOut;

  @override
  Widget build(BuildContext context) {
    final color = isPaidOut ? AppColor.success : AppColor.warning;
    final foreground = isPaidOut ? AppColor.success : const Color(0xFF7A4F00);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingMD,
        vertical: Dimens.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isPaidOut ? 0.14 : 0.24),
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: color.withValues(alpha: 0.70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaidOut ? Icons.check_circle_outline : Icons.schedule,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: Dimens.spacingXXS),
          Text(
            isPaidOut ? 'Paid Out' : 'Pending Payout',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: Dimens.fontSizeBody,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverTransactionsTable extends StatefulWidget {
  const _DriverTransactionsTable({
    required this.controller,
    required this.driverId,
  });
  final InventoryController controller;
  final int driverId;

  @override
  State<_DriverTransactionsTable> createState() =>
      _DriverTransactionsTableState();
}

class _DriverTransactionsTableState extends State<_DriverTransactionsTable> {
  static const double _noWidth = 24;
  static const double _customerWidth = 112;
  static const double _phoneWidth = 92;
  static const double _parcelTypeWidth = 88;
  static const double _numberWidth = 48;
  static const double _chargesWidth = 78;
  static const double _paymentStatusWidth = 76;
  static const double _cashAdvanceWidth = 78;
  static const double _pickedUpWidth = 70;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = widget.controller.filteredTransactionsForDriver(
        widget.driverId,
      );
      Driver? driverInfo;
      for (final d in widget.controller.drivers) {
        if (d.id == widget.driverId) {
          driverInfo = d;
          break;
        }
      }
      final bool showSummaryRow =
          !widget.controller.showUnclaimedOnly.value &&
          widget.controller.searchQuery.value.trim().isEmpty;
      final headerStyle = AppTextStyles.tableHeader;
      final cellStyle = AppTextStyles.tableCell;
      final payout = driverInfo == null
          ? null
          : PayoutCalculator.forDriver(driverInfo, rows);
      final totalCharges =
          payout?.totalCharges ?? rows.fold<double>(0, (s, t) => s + t.charges);
      final pendingPayment = payout?.paymentPending ?? 0;
      final paidPayment = payout?.paymentPaid ?? 0;
      final totalCashAdvance = payout?.cashAdvance ?? 0;

      DataRow buildAmountRow({
        required String label,
        required double amount,
        bool deduction = false,
        bool emphasized = false,
        Color? valueColor,
      }) {
        final style = (emphasized ? headerStyle : cellStyle).copyWith(
          fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
          color: valueColor ?? AppColor.textPrimary,
        );
        final amountText = deduction
            ? '- ${Format.money(amount)}'
            : Format.money(amount);

        return DataRow(
          cells: [
            const DataCell(SizedBox()), // No
            DataCell(
              Padding(
                padding: const EdgeInsets.only(left: Dimens.spacingMD),
                child: Text(label, style: style),
              ),
            ),
            const DataCell(SizedBox()), // Phone
            const DataCell(SizedBox()), // Parcel type
            const DataCell(SizedBox()), // Number
            DataCell(
              SizedBox(
                width: _chargesWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(amountText, style: style),
                ),
              ),
            ),
            const DataCell(SizedBox()), // Payment status
            const DataCell(SizedBox()), // Cash advance
            const DataCell(SizedBox()), // Picked up
            const DataCell(SizedBox()), // Actions
          ],
        );
      }

      List<DataRow> buildFeeRows(Driver? info) {
        final feeRows = <DataRow>[];
        void addFee(String label, double? amount) {
          if (amount == null || amount <= 0) return;
          feeRows.add(
            buildAmountRow(label: label, amount: amount, deduction: true),
          );
        }

        addFee(AppString.driverRoomFee, info?.roomFee);
        addFee(AppString.driverLaborFee, info?.laborFee);
        addFee(AppString.driverDeliveryFee, info?.deliveryFee);
        return feeRows;
      }

      final displayedPaidOutAmount = payout?.displayedPaidOutAmount ?? 0;
      final paidOutDifference = payout?.difference ?? 0;

      return AppDataTable(
        table: DataTable(
          columnSpacing: 8,
          horizontalMargin: 8,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 40,
          columns: [
            DataColumn(
              columnWidth: const FixedColumnWidth(_noWidth),
              label: SizedBox(
                width: _noWidth,
                child: Center(child: Text(AppString.colNo, style: headerStyle)),
              ),
            ),
            DataColumn(
              columnWidth: const FixedColumnWidth(_customerWidth),
              label: SizedBox(
                width: _customerWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppString.colCustomerName, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              columnWidth: const FixedColumnWidth(_phoneWidth),
              label: SizedBox(
                width: _phoneWidth,
                child: Center(
                  child: Text(AppString.colPhone, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              columnWidth: const FixedColumnWidth(_parcelTypeWidth),
              label: SizedBox(
                width: _parcelTypeWidth,
                child: Center(
                  child: Text(AppString.colParcelType, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              columnWidth: const FixedColumnWidth(_numberWidth),
              label: SizedBox(
                width: _numberWidth,
                child: Center(
                  child: Text(AppString.colNumber, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              columnWidth: const FixedColumnWidth(_chargesWidth),
              label: SizedBox(
                width: _chargesWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(AppString.colCharges, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              columnWidth: const FixedColumnWidth(_paymentStatusWidth),
              label: SizedBox(
                width: _paymentStatusWidth,
                child: Center(
                  child: Text(AppString.colPaymentStatus, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              columnWidth: const FixedColumnWidth(_cashAdvanceWidth),
              label: SizedBox(
                width: _cashAdvanceWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(AppString.colCashAdvance, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              columnWidth: const FixedColumnWidth(_pickedUpWidth),
              label: SizedBox(
                width: _pickedUpWidth,
                child: Center(
                  child: Text(AppString.colPickedUp, style: headerStyle),
                ),
              ),
            ),
            // Actions
            const DataColumn(
              columnWidth: FixedColumnWidth(48),
              label: SizedBox.shrink(),
            ),
          ],
          rows: [
            ...rows.asMap().entries.map((e) {
              final idx = e.key + 1;
              final t = e.value;
              void openDetails() => showViewTransactionDialog(context, t);
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: _noWidth,
                      child: Center(
                        child: Text(idx.toString(), style: cellStyle),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: _customerWidth,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          t.customerName ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: cellStyle,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: _phoneWidth,
                      child: Center(
                        child: Text(
                          t.phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: cellStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: _parcelTypeWidth,
                      child: Center(
                        child: Text(
                          t.parcelType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: cellStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: _numberWidth,
                      child: Center(
                        child: Text(
                          t.number,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: cellStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: _chargesWidth,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          Format.money(t.charges),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: cellStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: _paymentStatusWidth,
                      child: Center(
                        child: Text(
                          t.paymentStatus,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: cellStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: _cashAdvanceWidth,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          Format.money(t.cashAdvance),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: cellStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: _pickedUpWidth,
                      child: Center(
                        child:
                            !widget.controller.canClaimTransaction(
                              transaction: t,
                              driver: driverInfo,
                            )
                            ? const Icon(Icons.check, color: AppColor.success)
                            : fluent.Button(
                                onPressed: () => showClaimTransactionDialog(
                                  context,
                                  widget.controller,
                                  t,
                                ),
                                child: const Text('Claim'),
                              ),
                      ),
                    ),
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: TransactionActionsMenu(
                        transaction: t,
                        driverId: widget.driverId,
                        driver: driverInfo,
                        controller: widget.controller,
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (showSummaryRow) ...[
              buildAmountRow(
                label: AppString.driverTotalCharges,
                amount: totalCharges,
                emphasized: true,
              ),
              if (paidPayment > 0)
                buildAmountRow(
                  label: AppString.paymentPaid,
                  amount: paidPayment,
                  deduction: true,
                ),
              buildAmountRow(
                label: AppString.paymentPending,
                amount: pendingPayment,
                emphasized: true,
              ),
              if (totalCashAdvance > 0)
                buildAmountRow(
                  label: AppString.colCashAdvance,
                  amount: totalCashAdvance,
                ),
              ...buildFeeRows(driverInfo),
              buildAmountRow(
                label: 'Paid out amount',
                amount: displayedPaidOutAmount,
                emphasized: true,
              ),
              if ((driverInfo?.paidOut ?? false) &&
                  driverInfo?.paidOutAt != null)
                DataRow(
                  cells: [
                    const DataCell(SizedBox()),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.only(left: Dimens.spacingMD),
                        child: Text(
                          'Paid out at',
                          style: headerStyle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(Format.dateTime12(driverInfo!.paidOutAt!))),
                    const DataCell(SizedBox()),
                    const DataCell(SizedBox()),
                    const DataCell(SizedBox()),
                    const DataCell(SizedBox()),
                    const DataCell(SizedBox()),
                    const DataCell(SizedBox()),
                    const DataCell(SizedBox()),
                  ],
                ),
              if ((driverInfo?.paidOut ?? false) && paidOutDifference != 0)
                buildAmountRow(
                  label: 'Difference after edits',
                  amount: paidOutDifference,
                  emphasized: true,
                  valueColor: paidOutDifference > 0
                      ? AppColor.error
                      : AppColor.success,
                ),
            ],
          ],
        ),
      );
    });
  }
}

Future<DateTime?> _showMonthYearPickerDialog(
  BuildContext context,
  DateTime initial,
) {
  const int minYear = 2000;
  final int maxYear = DateTime.now().year + 5;
  int tempYear = initial.year;
  int tempMonth = initial.month;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final textTheme = Theme.of(context).textTheme;
          return fluent.ContentDialog(
            constraints: const BoxConstraints(maxWidth: 460),
            title: const Text('Select Month'),
            content: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: tempYear > minYear
                            ? () => setState(() => tempYear -= 1)
                            : null,
                      ),
                      Text(
                        tempYear.toString(),
                        style: AppTextStyles.subtitle(
                          textTheme,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: tempYear < maxYear
                            ? () => setState(() => tempYear += 1)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimens.spacingSM),
                  SizedBox(
                    width: Dimens.spacingMD * 20,
                    child: Wrap(
                      spacing: Dimens.spacingXS,
                      runSpacing: Dimens.spacingXS,
                      children: List.generate(12, (index) {
                        final monthIndex = index + 1;
                        final bool isSelected = tempMonth == monthIndex;
                        return ChoiceChip(
                          label: Text(_monthNames[index]),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => tempMonth = monthIndex),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              fluent.Button(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              fluent.FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(DateTime(tempYear, tempMonth, 1)),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _FiltersToolbar extends StatelessWidget {
  const _FiltersToolbar({
    required this.controller,
    required this.onPickMonth,
    required this.onAddDriver,
  });

  final InventoryController controller;
  final VoidCallback onPickMonth;
  final VoidCallback onAddDriver;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedDate.value;
      final monthLabel = '${_monthNames[selected.month - 1]} ${selected.year}';
      final bool isUnclaimedOnly = controller.showUnclaimedOnly.value;

      Widget buildFilters() {
        return Wrap(
          spacing: Dimens.spacingSM,
          runSpacing: Dimens.spacingXS,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            fluent.Button(
              onPressed: onPickMonth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month, size: 16),
                  const SizedBox(width: Dimens.spacingXXS),
                  Text(monthLabel),
                ],
              ),
            ),
            fluent.ToggleSwitch(
              checked: isUnclaimedOnly,
              onChanged: controller.setUnclaimedOnly,
              content: const Text(AppString.filterUnclaimedOnly),
            ),
          ],
        );
      }

      Widget buildPrimaryAction() {
        return fluent.FilledButton(
          onPressed: onAddDriver,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16),
              SizedBox(width: Dimens.spacingXXS),
              Text('Add Driver'),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 860) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeaderSearchField(
                  hint: AppString.searchHint,
                  onChanged: controller.setSearch,
                  borderRadius: BorderRadius.circular(Dimens.radiusMD),
                ),
                const SizedBox(height: Dimens.spacingSM),
                Row(
                  children: [
                    Expanded(child: buildFilters()),
                    buildPrimaryAction(),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              SizedBox(
                width: 360,
                child: HeaderSearchField(
                  hint: AppString.searchHint,
                  onChanged: controller.setSearch,
                  borderRadius: BorderRadius.circular(Dimens.radiusMD),
                ),
              ),
              const SizedBox(width: Dimens.spacingMD),
              Expanded(child: buildFilters()),
              const SizedBox(width: Dimens.spacingMD),
              buildPrimaryAction(),
            ],
          );
        },
      );
    });
  }
}
