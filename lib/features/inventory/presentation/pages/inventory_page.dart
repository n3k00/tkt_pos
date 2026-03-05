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
import 'package:tkt_pos/widgets/app_drawer.dart';
import 'package:tkt_pos/widgets/edge_drawer_opener.dart';
import 'package:tkt_pos/widgets/page_header.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';

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
    return Scaffold(
      backgroundColor: AppColor.surfaceBackground,
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 80,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddDriverDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: AppString.inventory,
                crumbs: ['Inventory'],
                showBack: false,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.spacingMD,
                  vertical: Dimens.spacingSM,
                ),
                child: _FiltersToolbar(
                  controller: controller,
                  onPickMonth: () => _openMonthPicker(context),
                ),
              ),
              const SizedBox(height: Dimens.spacingSM),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimens.spacingMD,
                    0,
                    Dimens.spacingMD,
                    Dimens.spacingMD,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimens.spacingMD),
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final all = controller.drivers;
                          if (all.isEmpty) {
                            return const Center(
                              child: Text(AppString.noDrivers),
                            );
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
                            return const Center(
                              child: Text(AppString.noResults),
                            );
                          }
                          final q = controller.searchQuery.value.trim();
                          final bool filterByRows =
                              controller.showUnclaimedOnly.value ||
                              q.isNotEmpty;
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
                            return const Center(
                              child: Text(AppString.noResults),
                            );
                          }

                          return ListView.separated(
                            itemCount: filteredDrivers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: Dimens.spacingXL),
                            itemBuilder: (context, index) {
                              final d = filteredDrivers[index];
                              return _DriverSection(
                                driver: d,
                                controller: controller,
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          EdgeDrawerOpener(),
        ],
      ),
    );
  }
}

class _DriverSection extends StatelessWidget {
  const _DriverSection({required this.driver, required this.controller});
  final Driver driver;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    final dateStr = Format.date(driver.date);
    return _SectionCard(
      title: driver.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Dimens.spacingSM,
            runSpacing: Dimens.spacingXS,
            children: [
              _MetaChip(icon: Icons.event, label: 'Date', value: dateStr),
            ],
          ),
          const SizedBox(height: Dimens.spacingSM),
          Wrap(
            spacing: Dimens.spacingSM,
            runSpacing: Dimens.spacingSM,
            children: [
              _FeeStat(
                label: AppString.driverRoomFee,
                amount: driver.roomFee,
                highlight: (driver.roomFee ?? 0) > 0,
              ),
              _FeeStat(
                label: AppString.driverLaborFee,
                amount: driver.laborFee,
                highlight: (driver.laborFee ?? 0) > 0,
              ),
              _FeeStat(
                label: AppString.driverDeliveryFee,
                amount: driver.deliveryFee,
                highlight: (driver.deliveryFee ?? 0) > 0,
              ),
              _FeeStat(
                label: AppString.driverTotalCharges,
                amount: controller.totalChargesForDriver(driver.id),
                highlight:
                    (controller.totalChargesForDriver(driver.id) ?? 0) > 0,
              ),
              _FeeStat(
                label: AppString.driverPaidOutAmount,
                amount: controller.paidOutAmountForDriver(driver.id),
                highlight:
                    (controller.paidOutAmountForDriver(driver.id) ?? 0) > 0,
              ),
              _StatusBadge(isPaidOut: driver.paidOut),
            ],
          ),
          const SizedBox(height: Dimens.spacingSM),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: Dimens.spacingXS,
              runSpacing: Dimens.spacingXS,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      showAddTransactionDialog(context, controller, driver.id),
                  icon: const Icon(Icons.add),
                  label: const Text(AppString.addTransaction),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimens.spacingMD,
                      vertical: Dimens.spacingSM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimens.radiusXS),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DriverActionsMenu(driver: driver, controller: controller),
              ],
            ),
          ),
          const SizedBox(height: Dimens.spacingSM),
          _DriverTransactionsTable(controller: controller, driverId: driver.id),
        ],
      ),
    );
  }

  // Date formatting moved to Format.date
}

class _UnclaimedSwitch extends StatelessWidget {
  const _UnclaimedSwitch({required this.isActive, required this.onChanged});

  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const Duration duration = Duration(milliseconds: 250);
    const double width = 150;
    const double height = 44;
    const double knobSize = 32;
    final Color activeBg = AppColor.primary;
    final Color inactiveBg = AppColor.surfaceBackground;
    final Color activeBorder = AppColor.secondary;
    final Color inactiveBorder = AppColor.border;

    return GestureDetector(
      onTap: () => onChanged(!isActive),
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeInOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isActive ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(Dimens.radiusXXXL),
          border: Border.all(
            width: 3,
            color: isActive ? activeBorder : inactiveBorder,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: duration,
              curve: Curves.easeInOut,
              alignment: isActive
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: AnimatedPadding(
                duration: duration,
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(
                  left: isActive ? 16 : knobSize + 14,
                  right: isActive ? knobSize + 14 : 16,
                ),
                child: Text(
                  AppString.filterUnclaimedOnly,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isActive ? AppColor.primaryDark : AppColor.white,
                  ),
                ),
              ),
            ),
            AnimatedAlign(
              duration: duration,
              curve: Curves.easeInOut,
              alignment: isActive
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: knobSize,
                height: knobSize,
                margin: const EdgeInsets.symmetric(
                  horizontal: Dimens.spacingMicro,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.textPrimary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeStat extends StatelessWidget {
  const _FeeStat({
    required this.label,
    required this.amount,
    this.highlight = false,
  });

  final String label;
  final double? amount;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacingSM),
      decoration: BoxDecoration(
        color: highlight
            ? AppColor.primary.withValues(alpha: 0.08)
            : AppColor.surfaceBackground,
        borderRadius: BorderRadius.circular(Dimens.radiusSM),
        border: Border.all(
          color: highlight ? AppColor.primary : AppColor.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColor.textSecondary),
          ),
          const SizedBox(height: Dimens.spacingXXS),
          Text(
            Format.money(amount ?? 0),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: highlight ? AppColor.primaryDark : AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isPaidOut});
  final bool isPaidOut;

  @override
  Widget build(BuildContext context) {
    final color = isPaidOut ? AppColor.success : AppColor.warning;
    final label = isPaidOut ? 'Paid out' : 'Pending payout';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingSM,
        vertical: Dimens.spacingXXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimens.radiusSM),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
      final totalCharges =
          rows.fold<double>(0, (s, t) => s + t.charges);
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
                            : ElevatedButton(
                                onPressed: () => showClaimTransactionDialog(
                                  context,
                                  widget.controller,
                                  t,
                                ),
                                style: ElevatedButton.styleFrom(
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
                        'Paid out status',
                        style: headerStyle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      isPaidOut ? 'ငွေထုတ်ပေးပြီး' : 'ငွေထုတ်ရန်ကျန်',
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
          return AlertDialog(
            title: const Text('Select Month'),
            content: Column(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  width: 320,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
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
  const _FiltersToolbar({required this.controller, required this.onPickMonth});

  final InventoryController controller;
  final VoidCallback onPickMonth;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedDate.value;
      final monthLabel = '${_monthNames[selected.month - 1]} ${selected.year}';
      final bool isUnclaimedOnly = controller.showUnclaimedOnly.value;
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingSM,
          vertical: Dimens.spacingXXS,
        ),
        child: Row(
          children: [
            Expanded(
              child: HeaderSearchField(
                hint: AppString.searchHint,
                onChanged: controller.setSearch,
                borderRadius: BorderRadius.circular(Dimens.radiusSM),
              ),
            ),
            const SizedBox(width: Dimens.spacingSM),
            _MonthChip(label: monthLabel, onTap: onPickMonth),
            const SizedBox(width: Dimens.spacingSM),
            Row(
              children: [
                Text(
                  AppString.filterUnclaimedOnly,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(width: Dimens.spacingXS),
                Switch.adaptive(
                  value: isUnclaimedOnly,
                  activeColor: AppColor.primary,
                  onChanged: controller.setUnclaimedOnly,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingSM,
        vertical: Dimens.spacingXXS,
      ),
      decoration: BoxDecoration(
        color: AppColor.surfaceBackground,
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColor.textSecondary),
          const SizedBox(width: Dimens.spacingXXS),
          Text(
            '$label: $value',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColor.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title, this.subtitle});

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(Dimens.radiusSM),
        border: Border.all(color: AppColor.border),
      ),
      padding: const EdgeInsets.all(Dimens.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: Dimens.spacingXXS),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColor.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: Dimens.spacingSM),
          ],
          child,
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.radiusSM),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.spacingMD,
          vertical: Dimens.spacingXXS,
        ),
        decoration: BoxDecoration(
          color: AppColor.surfaceBackground,
          borderRadius: BorderRadius.circular(Dimens.radiusSM),
          border: Border.all(color: AppColor.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month,
              color: AppColor.textPrimary,
              size: 18,
            ),
            const SizedBox(width: Dimens.spacingXXS),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
