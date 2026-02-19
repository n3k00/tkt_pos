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
              PageHeader(
                title: AppString.inventory,
                crumbs: const ['Inventory'],
                showBack: false,
                trailing: Obx(() {
                  final selected = controller.selectedDate.value;
                  final label =
                      '${_monthNames[selected.month - 1]} ${selected.year}';
                  final bool isUnclaimedOnly = controller.showUnclaimedOnly.value;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 48,
                        child: FilterChip(
                          label: Text(
                            'Unclaimed',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColor.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          selected: isUnclaimedOnly,
                          onSelected: controller.setUnclaimedOnly,
                          backgroundColor: AppColor.card,
                          selectedColor:
                              AppColor.primary.withOpacity(0.15),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColor.border),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimens.d12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: SizedBox(
                          width: 280,
                          height: 48,
                          child: HeaderSearchField(
                            hint: AppString.searchHint,
                            onChanged: controller.setSearch,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimens.d12),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColor.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.border),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              print('Select month');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    color: AppColor.textPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppColor.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Expanded(
                child: Padding(
                  padding: Dimens.screen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimens.d16),
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
                          final q = controller.searchQuery.value.trim();
                          final filteredDrivers = q.isEmpty
                              ? all
                              : all
                                    .where(
                                      (d) => controller
                                          .filteredTransactionsForDriver(d.id)
                                          .isNotEmpty,
                                    )
                                    .toList(growable: false);

                          if (filteredDrivers.isEmpty) {
                            return const Center(
                              child: Text(AppString.noResults),
                            );
                          }

                          return ListView.separated(
                            itemCount: filteredDrivers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: Dimens.d24),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(dateStr, style: AppTextStyles.sectionTitle(context)),
            ),
            Expanded(
              child: Text(
                driver.name,
                style: AppTextStyles.sectionTitle(context),
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      showAddTransactionDialog(context, controller, driver.id),
                  icon: const Icon(Icons.add),
                  label: const Text(AppString.addTransaction),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: Dimens.d8),
                DriverActionsMenu(driver: driver, controller: controller),
              ],
            ),
          ],
        ),
        const SizedBox(height: Dimens.d8),
        _DriverTransactionsTable(controller: controller, driverId: driver.id),
      ],
    );
  }

  // Date formatting moved to Format.date
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
      final bool showSummaryRow = !widget.controller.showUnclaimedOnly.value &&
          widget.controller.searchQuery.value.trim().isEmpty;
      final headerStyle = AppTextStyles.tableHeader;
      final cellStyle = AppTextStyles.tableCell;
      final totalCharges = rows
          .where((t) => t.paymentStatus.trim() == AppString.paymentPending)
          .fold<double>(0, (s, t) => s + t.charges);
      final totalAdvance = rows.fold<double>(0, (s, t) => s + t.cashAdvance);

      return AppDataTable(
        table: DataTable(
          columnSpacing: 16,
          horizontalMargin: 12,
          columns: [
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.only(left: Dimens.d16),
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
              return DataRow(
                cells: [
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.only(left: Dimens.d16),
                      child: Text(idx.toString(), style: cellStyle),
                    ),
                  ),
                  DataCell(Text(t.customerName ?? '-', style: cellStyle)),
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
                  ),
                  DataCell(
                    SizedBox(
                      width: AppTableWidths.pickedUp,
                      child: Center(
                        child: t.pickedUp
                            ? const Icon(Icons.check, color: Colors.green)
                            : ElevatedButton(
                                onPressed: () => showClaimTransactionDialog(
                                  context,
                                  widget.controller,
                                  t,
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
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
            if (showSummaryRow)
              DataRow(
                cells: [
                  const DataCell(SizedBox()), // No
                  const DataCell(SizedBox()), // Name
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
          ],
        ),
      );
    });
  }
}
