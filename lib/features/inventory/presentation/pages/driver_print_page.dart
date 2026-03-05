import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/driver_print_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/resources/table_widths.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/resources/shapes.dart';

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
          appBar: AppBar(title: const Text('Print Preview')),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : driver == null
              ? const Center(child: Text('Driver not found.'))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimens.spacingXL),
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1123),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(Dimens.radiusXLPlus),
                              border: Border.all(color: AppColor.border),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.textPrimary.withValues(alpha: 0.05),
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
                                        borderRadius: BorderRadius.circular(Dimens.radiusXLPlus),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColor.white.withValues(alpha: 0.3),
                                            AppColor.white.withValues(
                                              alpha: 0.06,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(Dimens.spacingXL),
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
                                      const SizedBox(height: Dimens.spacingSM),
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
                                      const SizedBox(height: Dimens.spacingXL),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: AppColor.white,
                                          border: Border.all(
                                            color: AppColor.border,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(Dimens.spacingXL),
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
                                                    if (controller
                                                            .totalChargesPending >
                                                        0)
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
                                                              alignment:
                                                                  Alignment
                                                                      .centerRight,
                                                              child: Text(
                                                                Format.money(
                                                                  controller
                                                                      .netAmount,
                                                                ),
                                                                style: Theme.of(
                                                                  context,
                                                                )
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
                                                                  ? AppColor
                                                                      .success
                                                                  : AppColor
                                                                      .error,
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
                        const SizedBox(height: Dimens.spacingXL),
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
          contentPadding: Dimens.inputPaddingDense,
          border: AppShapes.inputBorder(color: AppColor.border),
          enabledBorder: AppShapes.inputBorder(color: AppColor.border),
          focusedBorder: AppShapes.inputBorder(
            color: AppColor.primaryDark,
            width: 1.5,
          ),
          isDense: true,
        );

    Widget feeField({
      required TextEditingController textController,
      required String label,
      required IconData icon,
    }) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: textController,
              enabled: !controller.paidOut.value,
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
        borderRadius: BorderRadius.circular(Dimens.radiusXLPlus),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.primary.withValues(alpha: 0.08), AppColor.white],
        ),
        border: Border.all(color: AppColor.border),
        boxShadow: [
          BoxShadow(
            color: AppColor.textPrimary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.spacingLG),
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
                  child: const Icon(Icons.edit_note, color: AppColor.white),
                ),
                const SizedBox(width: Dimens.spacingSM),
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
                  textController: controller.roomFeeCtrl,
                  label: 'Room Fee',
                  icon: Icons.home_work_outlined,
                ),
                const SizedBox(width: Dimens.spacingMD),
                feeField(
                  textController: controller.laborFeeCtrl,
                  label: 'Labor Fee',
                  icon: Icons.engineering_outlined,
                ),
                const SizedBox(width: Dimens.spacingMD),
                feeField(
                  textController: controller.deliveryFeeCtrl,
                  label: 'Delivery Fee',
                  icon: Icons.local_shipping_outlined,
                ),
              ],
            ),
            const SizedBox(height: Dimens.spacingSM),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMD),
              decoration: BoxDecoration(
                borderRadius: Dimens.borderRadiusInput,
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
            const SizedBox(height: Dimens.spacingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed =
                        await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Save'),
                            content: const Text(
                              'Save current slip settings to the database?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Yes, Save'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                    if (!confirmed) return;
                    await controller.saveAdjustments();
                    Get.snackbar(
                      'Saved',
                      'Slip settings updated in database.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
                const SizedBox(width: Dimens.spacingSM),
                FilledButton.icon(
                  onPressed: () async {
                    await controller.printSlip();
                    Get.snackbar(
                      'Print',
                      'Sent to printer.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
