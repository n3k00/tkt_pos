import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/driver_print_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/resources/table_widths.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';

class DriverPrintPage extends StatelessWidget {
  const DriverPrintPage({super.key, required this.driverId});
  final int driverId;

  @override
  Widget build(BuildContext context) {
    return GetX<DriverPrintController>(
      init: DriverPrintController(driverId),
      builder: (controller) {
        final driver = controller.driver.value;
        final transactions = controller.transactions;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Print Preview'),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  await controller.saveAdjustments();
                  Get.snackbar(
                    'Print',
                    'Printing workflow coming soon.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text(
                  'Print',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : driver == null
              ? const Center(child: Text('Driver not found.'))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1123),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColor.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.3),
                                            Colors.white.withValues(
                                              alpha: 0.06,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Incoming Parcel Slip',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Driver: ${driver.name}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            'Date: ${Format.date(driver.date)}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: AppColor.border,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AppDataTable(
                                                table: DataTable(
                                                  columnSpacing: 12,
                                                  headingRowHeight: 40,
                                                  horizontalMargin: 12,
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text(
                                                        AppString.colNo,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        AppString
                                                            .colCustomerName,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        AppString.colPhone,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        AppString.colParcelType,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        AppString.colNumber,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        AppString.colCharges,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        AppString
                                                            .colPaymentStatus,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        AppString
                                                            .colCashAdvance,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text('Signed'),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        AppString.colComment,
                                                      ),
                                                    ),
                                                  ],
                                                  rows: [
                                                    ...transactions.asMap().entries.map((
                                                      e,
                                                    ) {
                                                      final idx = e.key + 1;
                                                      final t = e.value;
                                                      return DataRow(
                                                        cells: [
                                                          DataCell(
                                                            Text('$idx'),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              t.customerName ??
                                                                  '-',
                                                            ),
                                                          ),
                                                          DataCell(
                                                            SizedBox(
                                                              width:
                                                                  AppTableWidths
                                                                      .phone,
                                                              child: Text(
                                                                t.phone,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            SizedBox(
                                                              width:
                                                                  AppTableWidths
                                                                      .parcelType,
                                                              child: Text(
                                                                t.parcelType,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            SizedBox(
                                                              width:
                                                                  AppTableWidths
                                                                      .number,
                                                              child: Text(
                                                                t.number,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                Format.money(
                                                                  t.charges,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              t.paymentStatus,
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                Format.money(
                                                                  t.cashAdvance,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              ),
                                                            ),
                                                          ),
                                                          const DataCell(
                                                            Text(
                                                              '______________',
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              t.comment ?? '-',
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                                    DataRow(
                                                      cells: [
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            'Total Charges (Pending)',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .titleSmall
                                                                ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        DataCell(
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Text(
                                                              Format.money(
                                                                controller
                                                                    .totalChargesPending,
                                                              ),
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: AppColor
                                                                        .textPrimary,
                                                                  ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                          ),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        DataCell(
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Text(
                                                              Format.money(
                                                                controller
                                                                    .totalCashAdvance,
                                                              ),
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: AppColor
                                                                        .textPrimary,
                                                                  ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                          ),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                      ],
                                                    ),
                                                    ..._feeRows(
                                                      context,
                                                      controller,
                                                    ),
                                                    DataRow(
                                                      cells: [
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            'Paid Out Amount',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .titleSmall
                                                                ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        DataCell(
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Text(
                                                              Format.money(
                                                                controller
                                                                    .netAmount,
                                                              ),
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: AppColor
                                                                        .textPrimary,
                                                                  ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                          ),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                      ],
                                                    ),
                                                    DataRow(
                                                      cells: [
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            'Paid out status',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .titleSmall
                                                                ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            controller
                                                                    .paidOut
                                                                    .value
                                                                ? 'ငွေထုတ်ပေးပြီး'
                                                                : 'ငွေထုတ်ရန် ကျန်',
                                                            style: TextStyle(
                                                              color:
                                                                  controller
                                                                      .paidOut
                                                                      .value
                                                                  ? Colors.green
                                                                  : Colors
                                                                        .redAccent,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                        const DataCell(
                                                          SizedBox(),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _FeesEditor(controller: controller),
                      ],
                    ),
                  ),
                ),
          backgroundColor: AppColor.surfaceBackground,
        );
      },
    );
  }
}

List<DataRow> _feeRows(BuildContext context, DriverPrintController controller) {
  final rows = <DataRow>[];

  void addRow(String label, double amount) {
    if (amount <= 0) return;
    rows.add(
      DataRow(
        cells: [
          const DataCell(SizedBox()),
          DataCell(
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const DataCell(SizedBox()),
          const DataCell(SizedBox()),
          const DataCell(SizedBox()),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- ${Format.money(amount)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const DataCell(SizedBox()),
          const DataCell(SizedBox()),
          const DataCell(SizedBox()),
          const DataCell(SizedBox()),
        ],
      ),
    );
  }

  addRow('Room Fee', controller.roomFeeValue);
  addRow('Labor Fee', controller.laborFeeValue);
  addRow('Delivery Fee', controller.deliveryFeeValue);
  return rows;
}

class _FeesEditor extends StatelessWidget {
  const _FeesEditor({required this.controller});
  final DriverPrintController controller;

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: AppColor.textSecondary),
      filled: true,
      fillColor: AppColor.surfaceBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColor.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColor.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColor.primaryDark, width: 1.5),
      ),
      isDense: true,
    );

    Widget feeField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
    }) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: decoration(label, icon),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.primary.withValues(alpha: 0.08), Colors.white],
        ),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primary,
                  ),
                  child: const Icon(Icons.edit_note, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'Slip Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                feeField(
                  controller: controller.roomFeeCtrl,
                  label: 'Room Fee',
                  icon: Icons.home_work_outlined,
                ),
                const SizedBox(width: 16),
                feeField(
                  controller: controller.laborFeeCtrl,
                  label: 'Labor Fee',
                  icon: Icons.engineering_outlined,
                ),
                const SizedBox(width: 16),
                feeField(
                  controller: controller.deliveryFeeCtrl,
                  label: 'Delivery Fee',
                  icon: Icons.local_shipping_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColor.surfaceBackground,
                border: Border.all(color: AppColor.border),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Paid out'),
                subtitle: Text(
                  controller.paidOut.value
                      ? 'Cash already settled'
                      : 'Pending payout',
                ),
                value: controller.paidOut.value,
                onChanged: controller.setPaidOut,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () async {
                  await controller.saveAdjustments();
                  Get.snackbar(
                    'Print',
                    'Printing workflow coming soon.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text('Print'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
