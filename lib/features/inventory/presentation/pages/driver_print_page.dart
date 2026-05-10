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
import 'package:tkt_pos/widgets/app_snackbar.dart';

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
          backgroundColor: AppColor.surfaceBackground,
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : driver == null
              ? const Center(child: Text('Driver not found.'))
              : SafeArea(
                  child: Column(
                    children: [
                      _PrintPreviewCommandBar(controller: controller),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(Dimens.spacingXL),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1123,
                                    ),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColor.white,
                                        borderRadius: BorderRadius.circular(
                                          Dimens.radiusXS,
                                        ),
                                        border: Border.all(
                                          color: AppColor.border,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: IgnorePointer(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Dimens.radiusXS,
                                                      ),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      AppColor.white.withValues(
                                                        alpha: 0.3,
                                                      ),
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
                                            padding: const EdgeInsets.all(
                                              Dimens.spacingXL,
                                            ),
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
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                ),
                                                const SizedBox(
                                                  height: Dimens.spacingSM,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Driver: ${driver.name}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
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
                                                const SizedBox(
                                                  height: Dimens.spacingXL,
                                                ),
                                                DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color: AppColor.white,
                                                    border: Border.all(
                                                      color: AppColor.border,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          Dimens.spacingXL,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        AppDataTable(
                                                          table: DataTable(
                                                            columnSpacing: 12,
                                                            headingRowHeight:
                                                                40,
                                                            horizontalMargin:
                                                                12,
                                                            columns: const [
                                                              DataColumn(
                                                                label: Text(
                                                                  AppString
                                                                      .colNo,
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
                                                                  AppString
                                                                      .colPhone,
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  AppString
                                                                      .colParcelType,
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  AppString
                                                                      .colNumber,
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  AppString
                                                                      .colCharges,
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
                                                                label: Text(
                                                                  'Signed',
                                                                ),
                                                              ),
                                                              DataColumn(
                                                                label: Text(
                                                                  AppString
                                                                      .colComment,
                                                                ),
                                                              ),
                                                            ],
                                                            rows: [
                                                              ...transactions.asMap().entries.map((
                                                                e,
                                                              ) {
                                                                final idx =
                                                                    e.key + 1;
                                                                final t =
                                                                    e.value;
                                                                return DataRow(
                                                                  cells: [
                                                                    DataCell(
                                                                      Text(
                                                                        '$idx',
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      Text(
                                                                        t.customerName ??
                                                                            '-',
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width: AppTableWidths
                                                                            .phone,
                                                                        child: Text(
                                                                          t.phone,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width: AppTableWidths
                                                                            .parcelType,
                                                                        child: Text(
                                                                          t.parcelType,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width: AppTableWidths
                                                                            .number,
                                                                        child: Text(
                                                                          t.number,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child: Text(
                                                                          Format.money(
                                                                            t.charges,
                                                                          ),
                                                                          textAlign:
                                                                              TextAlign.right,
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
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child: Text(
                                                                          Format.money(
                                                                            t.cashAdvance,
                                                                          ),
                                                                          textAlign:
                                                                              TextAlign.right,
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
                                                                        t.comment ??
                                                                            '-',
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }),
                                                              ..._printPreviewSummaryRows(
                                                                context,
                                                                controller,
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
                                ),
                              ),
                            ),
                            const SizedBox(width: Dimens.spacingLG),
                            SizedBox(
                              width: 360,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  Dimens.spacingXL,
                                  Dimens.spacingXL,
                                  Dimens.spacingXL,
                                ),
                                child: _FeesEditor(controller: controller),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

List<DataRow> _printPreviewSummaryRows(
  BuildContext context,
  DriverPrintController controller,
) {
  final rows = <DataRow>[];

  DataRow amountRow(
    String label,
    double amount, {
    bool deduction = false,
    bool emphasized = false,
  }) {
    final labelStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
      color: AppColor.textPrimary,
    );
    final amountStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
      color: AppColor.textPrimary,
    );

    return DataRow(
      cells: [
        const DataCell(SizedBox()),
        DataCell(Text(label, style: labelStyle)),
        const DataCell(SizedBox()),
        const DataCell(SizedBox()),
        const DataCell(SizedBox()),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${deduction ? '- ' : ''}${Format.money(amount)}',
              style: amountStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        const DataCell(SizedBox()),
        const DataCell(SizedBox()),
        const DataCell(SizedBox()),
        const DataCell(SizedBox()),
      ],
    );
  }

  void addFee(String label, double amount) {
    if (amount <= 0) return;
    rows.add(amountRow(label, amount, deduction: true));
  }

  rows.add(
    amountRow('Total Charges', controller.totalCharges, emphasized: true),
  );
  if (controller.totalChargesPaid > 0) {
    rows.add(
      amountRow(
        AppString.paymentPaid,
        controller.totalChargesPaid,
        deduction: true,
      ),
    );
  }
  rows.add(
    amountRow(
      AppString.paymentPending,
      controller.totalChargesPending,
      emphasized: true,
    ),
  );
  if (controller.totalCashAdvance > 0) {
    rows.add(amountRow(AppString.colCashAdvance, controller.totalCashAdvance));
  }
  addFee('Room Fee', controller.roomFeeValue);
  addFee('Labor Fee', controller.laborFeeValue);
  addFee('Delivery Fee', controller.deliveryFeeValue);
  rows.add(
    amountRow('Paid out amount', controller.netAmount, emphasized: true),
  );

  return rows;
}

class _PrintPreviewCommandBar extends StatelessWidget {
  const _PrintPreviewCommandBar({required this.controller});

  final DriverPrintController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingLG),
      decoration: const BoxDecoration(
        color: AppColor.white,
        border: Border(bottom: BorderSide(color: AppColor.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Print Preview',
                  style: TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: Dimens.fontSizeTitle,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Incoming parcel slip preview and print settings',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => Get.back<void>(),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Close'),
          ),
          const SizedBox(width: Dimens.spacingXS),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await _confirmSave(context);
              if (!confirmed) return;
              await controller.saveAdjustments();
              if (!context.mounted) return;
              AppSnackBars.show(
                context,
                title: AppString.snackbarSavedTitle,
                message: AppString.snackbarSlipSaved,
                type: AppSnackbarType.success,
              );
            },
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
          ),
          const SizedBox(width: Dimens.spacingXS),
          FilledButton.icon(
            onPressed: controller.isPrinting.value
                ? null
                : () async {
                    try {
                      await controller.printSlip();
                      if (!context.mounted) return;
                      AppSnackBars.show(
                        context,
                        title: AppString.snackbarPrintTitle,
                        message: AppString.snackbarPrintSent,
                        type: AppSnackbarType.info,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      AppSnackBars.show(
                        context,
                        title: 'Print failed',
                        message: 'Could not build the PDF: $e',
                        type: AppSnackbarType.error,
                      );
                    }
                  },
            icon: controller.isPrinting.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print, size: 18),
            label: Text(controller.isPrinting.value ? 'Preparing...' : 'Print'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmSave(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Save'),
            content: const Text('Save current slip settings to the database?'),
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
  }
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
      return TextField(
        controller: textController,
        enabled: !controller.paidOut.value,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: decoration(label, icon),
      );
    }

    Widget amountPreview(String label, double value, {bool deduction = false}) {
      final prefix = deduction && value > 0 ? '- ' : '';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.spacingXXS),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColor.textSecondary),
              ),
            ),
            Text(
              '$prefix${Format.money(value)}',
              style: const TextStyle(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(Dimens.radiusMD),
        border: Border.all(color: AppColor.border),
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
            feeField(
              textController: controller.roomFeeCtrl,
              label: 'Room Fee',
              icon: Icons.home_work_outlined,
            ),
            const SizedBox(height: Dimens.spacingSM),
            feeField(
              textController: controller.laborFeeCtrl,
              label: 'Labor Fee',
              icon: Icons.engineering_outlined,
            ),
            const SizedBox(height: Dimens.spacingSM),
            feeField(
              textController: controller.deliveryFeeCtrl,
              label: 'Delivery Fee',
              icon: Icons.local_shipping_outlined,
            ),
            const SizedBox(height: Dimens.spacingMD),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimens.spacingMD),
              decoration: BoxDecoration(
                color: AppColor.surfaceBackground,
                borderRadius: BorderRadius.circular(Dimens.radiusXS),
                border: Border.all(color: AppColor.border),
              ),
              child: Column(
                children: [
                  amountPreview('Total Charges', controller.totalCharges),
                  if (controller.totalChargesPaid > 0)
                    amountPreview(
                      AppString.paymentPaid,
                      controller.totalChargesPaid,
                      deduction: true,
                    ),
                  amountPreview(
                    AppString.paymentPending,
                    controller.totalChargesPending,
                  ),
                  if (controller.totalCashAdvance > 0)
                    amountPreview(
                      AppString.colCashAdvance,
                      controller.totalCashAdvance,
                    ),
                  amountPreview(
                    'Total Fees',
                    controller.totalDeductions,
                    deduction: true,
                  ),
                  const Divider(height: Dimens.spacingLG),
                  amountPreview('Paid Out Amount', controller.netAmount),
                ],
              ),
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
          ],
        ),
      ),
    );
  }
}
