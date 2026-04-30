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

        final selectedId = controller.selectedDriverId.value;
        final selectedDriver = filteredDrivers.firstWhere(
          (driver) => driver.id == selectedId,
          orElse: () => filteredDrivers.first,
        );

        return _InventoryMasterDetail(
          drivers: filteredDrivers,
          selectedDriver: selectedDriver,
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
          width: 420,
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
    return AppDataTable(
      table: DataTable(
        columnSpacing: 12,
        horizontalMargin: 12,
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text(AppString.colDriver)),
          DataColumn(label: Text('Txn')),
          DataColumn(label: Text(AppString.colCharges)),
          DataColumn(label: Text('Status')),
        ],
        rows: [
          for (final driver in drivers)
            DataRow(
              selected: driver.id == selectedDriverId,
              onSelectChanged: (_) =>
                  controller.selectedDriverId.value = driver.id,
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
                ),
                DataCell(
                  Text(
                    '${controller.filteredTransactionsForDriver(driver.id).length}',
                  ),
                ),
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      Format.money(
                        controller.totalChargesForDriver(driver.id) ?? 0,
                      ),
                    ),
                  ),
                ),
                DataCell(_CompactStatus(isPaidOut: driver.paidOut)),
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
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingSM),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${driver.name}  •  ${Format.date(driver.date)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: Dimens.fontSizeSubtitle,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
          ),
          fluent.Button(
            onPressed: () =>
                showAddTransactionDialog(context, controller, driver.id),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16),
                SizedBox(width: Dimens.spacingXXS),
                Text(AppString.addTransaction),
              ],
            ),
          ),
          const SizedBox(width: Dimens.spacingXS),
          DriverActionsMenu(driver: driver, controller: controller),
        ],
      ),
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
    final totalCharges = rows.fold<double>(0, (sum, t) => sum + t.charges);
    final totalAdvance = rows.fold<double>(0, (sum, t) => sum + t.cashAdvance);
    final roomFee = driver.roomFee ?? 0;
    final laborFee = driver.laborFee ?? 0;
    final deliveryFee = driver.deliveryFee ?? 0;
    final paidOutAmount = totalCharges - roomFee - laborFee - deliveryFee;

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
            value: Format.money(totalCharges),
          ),
          _SummaryCell(
            label: AppString.colCashAdvance,
            value: Format.money(totalAdvance),
          ),
          _SummaryCell(
            label: AppString.driverRoomFee,
            value: Format.money(roomFee),
          ),
          _SummaryCell(
            label: AppString.driverLaborFee,
            value: Format.money(laborFee),
          ),
          _SummaryCell(
            label: AppString.driverDeliveryFee,
            value: Format.money(deliveryFee),
          ),
          _SummaryCell(
            label: AppString.driverPaidOutAmount,
            value: Format.money(paidOutAmount),
          ),
          _CompactStatus(isPaidOut: driver.paidOut),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({required this.label, required this.value});

  final String label;
  final String value;

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
              style: const TextStyle(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.w700,
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
      final bool isPaidOut = driverInfo?.paidOut ?? false;
      final bool showSummaryRow =
          !widget.controller.showUnclaimedOnly.value &&
          widget.controller.searchQuery.value.trim().isEmpty;
      final headerStyle = AppTextStyles.tableHeader;
      final cellStyle = AppTextStyles.tableCell;
      final double roomFee = driverInfo?.roomFee ?? 0;
      final double laborFee = driverInfo?.laborFee ?? 0;
      final double deliveryFee = driverInfo?.deliveryFee ?? 0;
      final totalCharges = rows.fold<double>(0, (s, t) => s + t.charges);
      final totalAdvance = rows.fold<double>(0, (s, t) => s + t.cashAdvance);
      final double totalDeductions = roomFee + laborFee + deliveryFee;
      final double paidOutAmount = totalCharges - totalDeductions;
      List<DataRow> buildFeeRows(Driver? info) {
        final feeRows = <DataRow>[];
        void addFee(String label, double? amount) {
          if (amount == null || amount <= 0) return;
          feeRows.add(
            DataRow(
              cells: [
                const DataCell(SizedBox()), // No
                DataCell(
                  Padding(
                    padding: const EdgeInsets.only(left: Dimens.spacingMD),
                    child: Text(
                      label,
                      style: cellStyle.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const DataCell(SizedBox()), // Phone placeholder
                const DataCell(SizedBox()), // Parcel type
                const DataCell(SizedBox()), // Number
                DataCell(
                  SizedBox(
                    width: AppTableWidths.charges,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '- ${Format.money(amount)}',
                        style: headerStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const DataCell(SizedBox()), // Payment status
                const DataCell(SizedBox()), // Cash advance
                const DataCell(SizedBox()), // Picked up
                const DataCell(SizedBox()), // Collect time
                const DataCell(SizedBox()), // Actions
              ],
            ),
          );
        }

        addFee(AppString.driverRoomFee, info?.roomFee);
        addFee(AppString.driverLaborFee, info?.laborFee);
        addFee(AppString.driverDeliveryFee, info?.deliveryFee);
        return feeRows;
      }

      return AppDataTable(
        table: DataTable(
          columnSpacing: 16,
          horizontalMargin: 12,
          columns: [
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.only(left: Dimens.spacingMD),
                child: Text(AppString.colNo, style: headerStyle),
              ),
            ),
            DataColumn(
              label: Center(
                child: Text(AppString.colCustomerName, style: headerStyle),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: AppTableWidths.phone,
                child: Center(
                  child: Text(AppString.colPhone, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: AppTableWidths.parcelType,
                child: Center(
                  child: Text(AppString.colParcelType, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: AppTableWidths.number,
                child: Center(
                  child: Text(AppString.colNumber, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: AppTableWidths.charges,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(AppString.colCharges, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: AppTableWidths.paymentStatus,
                child: Center(
                  child: Text(AppString.colPaymentStatus, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: AppTableWidths.cashAdvance,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(AppString.colCashAdvance, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: AppTableWidths.pickedUp,
                child: Center(
                  child: Text(AppString.colPickedUp, style: headerStyle),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: AppTableWidths.collectTime,
                child: Center(
                  child: Text(AppString.colCollectTime, style: headerStyle),
                ),
              ),
            ),
            // Actions
            const DataColumn(label: SizedBox.shrink()),
          ],
          rows: [
            ...rows.asMap().entries.map((e) {
              final idx = e.key + 1;
              final t = e.value;
              void openDetails() => showViewTransactionDialog(context, t);
              return DataRow(
                cells: [
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.only(left: Dimens.spacingMD),
                      child: Text(idx.toString(), style: cellStyle),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    Text(t.customerName ?? '-', style: cellStyle),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.phone,
                      child: Center(
                        child: Text(
                          t.phone,
                          style: cellStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.parcelType,
                      child: Center(
                        child: Text(
                          t.parcelType,
                          style: cellStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.number,
                      child: Center(
                        child: Text(
                          t.number,
                          style: cellStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.charges,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          Format.money(t.charges),
                          style: cellStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.paymentStatus,
                      child: Center(
                        child: Text(
                          t.paymentStatus,
                          style: cellStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.cashAdvance,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          Format.money(t.cashAdvance),
                          style: cellStyle,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.pickedUp,
                      child: Center(
                        child: t.pickedUp
                            ? const Icon(Icons.check, color: AppColor.success)
                            : OutlinedButton(
                                onPressed: () => showClaimTransactionDialog(
                                  context,
                                  widget.controller,
                                  t,
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimens.spacingSM,
                                    vertical: Dimens.spacingXS,
                                  ),
                                ),
                                child: const Text('Claim'),
                              ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.collectTime,
                      child: Center(
                        child: Text(
                          t.pickedUp ? Format.dateTime12(t.updatedAt) : '-',
                          style: cellStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: openDetails,
                  ),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: TransactionActionsMenu(
                        transaction: t,
                        driverId: widget.driverId,
                        controller: widget.controller,
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (showSummaryRow) ...[
              DataRow(
                cells: [
                  const DataCell(SizedBox()), // No
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.only(left: Dimens.spacingMD),
                      child: Text(
                        AppString.driverTotalCharges,
                        style: headerStyle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ), // Name
                  const DataCell(SizedBox()), // Phone placeholder
                  const DataCell(SizedBox()), // Parcel type
                  const DataCell(SizedBox()), // Number
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.charges,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          Format.money(totalCharges),
                          style: headerStyle.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  const DataCell(SizedBox()), // Payment status
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.cashAdvance,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          Format.money(totalAdvance),
                          style: headerStyle.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  const DataCell(SizedBox()), // Picked up
                  const DataCell(SizedBox()), // Collect time
                  const DataCell(SizedBox()), // Actions
                ],
              ),
              ...buildFeeRows(driverInfo),
              if (totalDeductions > 0 && totalCharges > 0)
                DataRow(
                  cells: [
                    const DataCell(SizedBox()), // No
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.only(left: Dimens.spacingMD),
                        child: Text(
                          'Paid out amount',
                          style: headerStyle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const DataCell(SizedBox()), // Phone placeholder
                    const DataCell(SizedBox()), // Parcel type
                    const DataCell(SizedBox()), // Number
                    DataCell(
                      SizedBox(
                        width: AppTableWidths.charges,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            Format.money(paidOutAmount),
                            style: headerStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const DataCell(SizedBox()), // Payment status
                    const DataCell(SizedBox()), // Cash advance
                    const DataCell(SizedBox()), // Picked up
                    const DataCell(SizedBox()), // Collect time
                    const DataCell(SizedBox()), // Actions
                  ],
                ),
              DataRow(
                cells: [
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.only(left: Dimens.spacingMD),
                      child: Text(
                        AppString.paidOutStatusLabel,
                        style: headerStyle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      isPaidOut
                          ? AppString.paidOutStatusPaidMm
                          : AppString.paidOutStatusPendingMm,
                      style: cellStyle.copyWith(
                        color: isPaidOut ? AppColor.success : AppColor.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const DataCell(SizedBox()),
                  const DataCell(SizedBox()),
                  const DataCell(SizedBox()),
                  const DataCell(SizedBox()),
                  const DataCell(SizedBox()),
                  const DataCell(SizedBox()),
                  const DataCell(SizedBox()),
                  const DataCell(SizedBox()),
                  const DataCell(SizedBox()),
                ],
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
