import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/resources/table_widths.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/driver_dialogs.dart';
import 'package:tkt_pos/features/inventory/presentation/dialogs/transaction_dialogs.dart';
import 'package:tkt_pos/features/inventory/presentation/widgets/search_box.dart';
import 'package:tkt_pos/features/inventory/presentation/widgets/transaction_actions_menu.dart';
import 'package:tkt_pos/features/inventory/presentation/widgets/driver_actions_menu.dart';
import 'package:tkt_pos/widgets/appdrawer.dart';

class InventoryPage extends GetView<InventoryController> {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surfaceBackground,
      appBar: AppBar(title: const Text(AppString.inventory)),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddDriverDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: Dimens.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBox(controller: controller),
            const SizedBox(height: Dimens.d16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = controller.drivers;
                if (list.isEmpty) {
                  return const Center(
                    child: Text(AppString.noDrivers),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: Dimens.d24),
                  itemBuilder: (context, index) {
                    final d = list[index];
                    return _DriverSection(driver: d, controller: controller);
                  },
                );
              }),
            ),
          ],
        ),
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
    final dateStr = _formatDate(driver.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                dateStr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColor.textDefault,
                ),
              ),
            ),
            Expanded(
              child: Text(
                driver.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColor.textDefault,
                ),
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

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString().padLeft(4, '0');
    return '$dd/$mm/$yyyy';
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
  final ScrollController _hCtrl = ScrollController();
  final ScrollController _vCtrl = ScrollController();

  @override
  void dispose() {
    _hCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  String _fmtMoney(double v) {
    final isNegative = v < 0;
    var s = v.abs().toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    final parts = s.split('.');
    final intPart = parts[0];
    final fracPart = parts.length > 1 && parts[1].isNotEmpty
        ? '.${parts[1]}'
        : '';

    String groupThousands(String digits) {
      if (digits.length <= 3) return digits;
      final firstLen = digits.length % 3 == 0 ? 3 : digits.length % 3;
      final buf = StringBuffer();
      buf.write(digits.substring(0, firstLen));
      for (int i = firstLen; i < digits.length; i += 3) {
        buf.write(',');
        buf.write(digits.substring(i, i + 3));
      }
      return buf.toString();
    }

    final withCommas = groupThousands(intPart);
    return (isNegative ? '-' : '') + withCommas + fracPart;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = widget.controller.filteredTransactionsForDriver(
        widget.driverId,
      );
      return Card(
        color: AppColor.white,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black12.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
              final headerStyle = const TextStyle(
                color: AppColor.textDefault,
                fontWeight: FontWeight.w600,
              );
              final cellStyle = const TextStyle(color: AppColor.textDefault);
            return Scrollbar(
              controller: _vCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _vCtrl,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 12,
                    columns: [
                      DataColumn(label: Text(AppString.colNo, style: headerStyle)),
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
                        label: Center(
                          child: Text(AppString.colPickedUp, style: headerStyle),
                        ),
                      ),
                      DataColumn(label: Text(AppString.colComment, style: headerStyle)),
                      DataColumn(
                        label: Center(
                            child: Text(AppString.colActions, style: headerStyle),
                        ),
                      ),
                    ],
                    rows: rows.asMap().entries.map((e) {
                      final idx = e.key + 1;
                      final t = e.value;
                      return DataRow(
                        cells: [
                          DataCell(Text(idx.toString(), style: cellStyle)),
                          DataCell(
                            Text(t.customerName ?? '-', style: cellStyle),
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
                                  _fmtMoney(t.charges),
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
                                  _fmtMoney(t.cashAdvance),
                                  style: cellStyle,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Icon(
                                t.pickedUp ? Icons.check : Icons.close,
                                color: t.pickedUp ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                          DataCell(Text(t.comment ?? '-', style: cellStyle)),
                          DataCell(
                            TransactionActionsMenu(
                              transaction: t,
                              driverId: widget.driverId,
                              controller: widget.controller,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
