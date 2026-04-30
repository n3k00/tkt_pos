import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/reports/presentation/controllers/reports_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/widgets/page_header.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/widgets/app_snackbar.dart';
import 'package:tkt_pos/widgets/desktop_shell.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      title: AppString.reports,
      subtitle: 'Daily collections, payment status, and cash advance totals',
      toolbar: _ReportCommandBar(controller: controller),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _StatStrip(controller: controller),
                const SizedBox(height: Dimens.spacingSM),
                Expanded(child: _ReportsTable(controller: controller)),
                const SizedBox(height: Dimens.spacingSM),
                _PinnedTotalsFooter(controller: controller),
              ],
            ),
          ),
          const SizedBox(width: Dimens.spacingSM),
          SizedBox(
            width: 300,
            child: _GroupSummaryPane(controller: controller),
          ),
        ],
      ),
    );
  }
}

class _ReportCommandBar extends StatelessWidget {
  const _ReportCommandBar({required this.controller});

  final ReportsController controller;

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
      child: Row(
        children: [
          SizedBox(
            width: 260,
            child: HeaderSearchField(
              hint: AppString.searchReportsHint,
              onChanged: controller.setSearch,
              borderRadius: BorderRadius.circular(Dimens.radiusXS),
            ),
          ),
          const SizedBox(width: Dimens.spacingMD),
          _PresetButton(label: 'Today', onPressed: controller.setPresetToday),
          const SizedBox(width: Dimens.spacingXS),
          _PresetButton(
            label: 'Yesterday',
            onPressed: controller.setPresetYesterday,
          ),
          const SizedBox(width: Dimens.spacingXS),
          _PresetButton(
            label: 'This month',
            onPressed: controller.setPresetThisMonth,
          ),
          const SizedBox(width: Dimens.spacingMD),
          _DateRangeButton(controller: controller),
          const SizedBox(width: Dimens.spacingMD),
          _GroupModeSelector(controller: controller),
          const Spacer(),
          fluent.Button(
            onPressed: () => _exportCsv(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_download_outlined, size: 18),
                SizedBox(width: Dimens.spacingXS),
                Text('Export'),
              ],
            ),
          ),
          const SizedBox(width: Dimens.spacingXS),
          fluent.FilledButton(
            onPressed: () => _printReport(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.print_outlined, size: 18),
                SizedBox(width: Dimens.spacingXS),
                Text('Print'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final path = await controller.exportCsv();
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: path == null ? 'Export cancelled.' : 'CSV exported: $path',
        type: path == null ? AppSnackbarType.info : AppSnackbarType.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: 'Export failed: $e',
        type: AppSnackbarType.error,
      );
    }
  }

  Future<void> _printReport(BuildContext context) async {
    try {
      await controller.printReport();
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: AppString.snackbarPrintSent,
        type: AppSnackbarType.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBars.show(
        context,
        message: 'Print failed: $e',
        type: AppSnackbarType.error,
      );
    }
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return fluent.Button(onPressed: onPressed, child: Text(label));
  }
}

class _GroupModeSelector extends StatelessWidget {
  const _GroupModeSelector({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SegmentedButton<ReportGroupMode>(
        segments: const [
          ButtonSegment(
            value: ReportGroupMode.driver,
            label: Text('Driver'),
            icon: Icon(Icons.person_outline),
          ),
          ButtonSegment(
            value: ReportGroupMode.paymentStatus,
            label: Text('Status'),
            icon: Icon(Icons.payments_outlined),
          ),
        ],
        selected: {controller.groupMode.value},
        showSelectedIcon: false,
        onSelectionChanged: (value) => controller.setGroupMode(value.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.radiusXS),
            ),
          ),
        ),
      );
    });
  }
}

class _StatStrip extends StatelessWidget {
  const _StatStrip({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          _StatCell(
            title: AppString.totalCount,
            value: controller.totalCount.toString(),
          ),
          _StatCell(
            title: AppString.totalCharges,
            value: Format.money(controller.totalChargesPendingAndAdvance),
          ),
          _StatCell(
            title: AppString.statPaymentPending,
            value: Format.money(controller.totalChargesPending),
          ),
          _StatCell(
            title: AppString.statPaymentPaid,
            value: Format.money(controller.totalChargesPaid),
          ),
          _StatCell(
            title: AppString.statCashAdvance,
            value: Format.money(controller.totalCashAdvance),
          ),
        ],
      );
    });
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMD),
        decoration: BoxDecoration(
          color: AppColor.card,
          border: Border.all(color: AppColor.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontSize: Dimens.fontSizeCaption,
              ),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsTable extends StatelessWidget {
  const _ReportsTable({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.filtered;
      if (rows.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(Dimens.radiusXS),
            border: Border.all(color: AppColor.border),
          ),
          child: Center(
            child: Text(
              '${AppString.noReportsForDate} ${controller.rangeLabel()}',
              style: const TextStyle(color: AppColor.textSecondary),
            ),
          ),
        );
      }
      return AppDataTable(
        table: DataTable(
          columnSpacing: 16,
          horizontalMargin: 12,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 40,
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text(AppString.colNo)),
            DataColumn(label: Text(AppString.colDriver)),
            DataColumn(label: Text(AppString.colCustomerName)),
            DataColumn(label: Text(AppString.colPhone)),
            DataColumn(label: Text(AppString.colParcelType)),
            DataColumn(label: Text(AppString.colNumber)),
            DataColumn(label: Center(child: Text(AppString.colCharges))),
            DataColumn(label: Text(AppString.colPaymentStatus)),
            DataColumn(label: Center(child: Text(AppString.colCashAdvance))),
            DataColumn(label: Text(AppString.colComment)),
          ],
          rows: [
            ...rows.asMap().entries.map((e) {
              final i = e.key + 1;
              final t = e.value;
              return DataRow(
                cells: [
                  DataCell(Text('$i')),
                  DataCell(Text(controller.driverNameFor(t.driverId))),
                  DataCell(Text(t.customerName ?? '-')),
                  DataCell(Text(t.phone)),
                  DataCell(Text(t.parcelType)),
                  DataCell(Text(t.number)),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        Format.money(t.charges),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  DataCell(Text(t.paymentStatus)),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        Format.money(t.cashAdvance),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  DataCell(Text(t.comment ?? '-')),
                ],
              );
            }),
          ],
        ),
      );
    });
  }
}

class _PinnedTotalsFooter extends StatelessWidget {
  const _PinnedTotalsFooter({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingMD),
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(Dimens.radiusXS),
        ),
        child: Row(
          children: [
            Text(
              'Period: ${controller.rangeLabel()}',
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _FooterTotal(
              label: 'Rows',
              value: controller.totalCount.toString(),
            ),
            _FooterTotal(
              label: 'Pending + Advance',
              value: Format.money(controller.totalChargesPendingAndAdvance),
            ),
            _FooterTotal(
              label: 'Paid',
              value: Format.money(controller.totalChargesPaid),
            ),
            _FooterTotal(
              label: 'Cash Advance',
              value: Format.money(controller.totalCashAdvance),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterTotal extends StatelessWidget {
  const _FooterTotal({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimens.spacingLG),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: AppColor.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSummaryPane extends StatelessWidget {
  const _GroupSummaryPane({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summaries = controller.groupedSummaries;
      final title = controller.groupMode.value == ReportGroupMode.driver
          ? 'Grouped by driver'
          : 'Grouped by payment status';

      return Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(Dimens.radiusXS),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimens.spacingMD),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColor.border),
            Expanded(
              child: summaries.isEmpty
                  ? const Center(
                      child: Text(
                        'No summary',
                        style: TextStyle(color: AppColor.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(Dimens.spacingSM),
                      itemCount: summaries.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColor.border),
                      itemBuilder: (context, index) {
                        final item = summaries[index];
                        return _GroupSummaryRow(summary: item);
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _GroupSummaryRow extends StatelessWidget {
  const _GroupSummaryRow({required this.summary});

  final ReportGroupSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.spacingSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${summary.count}',
                style: const TextStyle(color: AppColor.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: Dimens.spacingXXS),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Charges ${Format.money(summary.charges)}',
                  style: const TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: Dimens.fontSizeCaption,
                  ),
                ),
              ),
              Text(
                Format.money(summary.total),
                style: const TextStyle(
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.controller});
  final ReportsController controller;

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: controller.startDate.value,
        end: controller.endDate.value,
      ),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final label = controller.rangeLabel();
      return InkWell(
        onTap: () => _pickDateRange(context),
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingSM),
          decoration: BoxDecoration(
            color: AppColor.card,
            border: Border.all(color: AppColor.border),
            borderRadius: BorderRadius.circular(Dimens.radiusXS),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.date_range_outlined,
                size: 18,
                color: AppColor.textPrimary,
              ),
              const SizedBox(width: Dimens.spacingXS),
              Text(label, style: const TextStyle(color: AppColor.textPrimary)),
            ],
          ),
        ),
      );
    });
  }
}

// Money/date formatters moved to lib/utils/format.dart
