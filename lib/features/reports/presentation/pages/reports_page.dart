import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/reports/presentation/controllers/reports_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';
import 'package:tkt_pos/resources/dimens.dart';
import 'package:tkt_pos/widgets/desktop_shell.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      title: AppString.reports,
      subtitle: 'Daily collections, payment status, and cash advance totals',
      toolbar: _ReportCommandBar(controller: controller),
      child: _ReportsMainPane(controller: controller),
    );
  }
}

class _ReportsMainPane extends StatelessWidget {
  const _ReportsMainPane({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
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
                Tab(text: 'Daily Claimed'),
                Tab(text: 'Payout Summary'),
              ],
            ),
          ),
          const SizedBox(height: Dimens.spacingSM),
          Expanded(
            child: TabBarView(
              children: [
                _DailyClaimedTab(controller: controller),
                _PayoutSummaryTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyClaimedTab extends StatelessWidget {
  const _DailyClaimedTab({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatStrip(controller: controller),
        const SizedBox(height: Dimens.spacingSM),
        Expanded(child: _ReportsTable(controller: controller)),
        const SizedBox(height: Dimens.spacingSM),
        _PinnedTotalsFooter(controller: controller),
      ],
    );
  }
}

class _PayoutSummaryTab extends StatelessWidget {
  const _PayoutSummaryTab({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PayoutStatStrip(controller: controller),
        const SizedBox(height: Dimens.spacingSM),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: _PayoutDriversTable(controller: controller),
              ),
              const SizedBox(width: Dimens.spacingSM),
              SizedBox(
                width: 360,
                child: Column(
                  children: [
                    Expanded(child: _PayoutSummaryPane(controller: controller)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
          const Spacer(),
          Obx(
            () => Text(
              'Period: ${controller.rangeLabel()}',
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
          _StatCell(
            title: 'Pending Payout',
            value: Format.money(controller.payoutPendingTotal),
          ),
          _StatCell(
            title: 'Paid Out',
            value: Format.money(controller.payoutPaidOutTotal),
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

class _PayoutStatStrip extends StatelessWidget {
  const _PayoutStatStrip({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _StatCell(
            title: 'Current payable',
            value: Format.money(controller.payoutCurrentPayableTotal),
          ),
          _StatCell(
            title: 'Pending payout',
            value: Format.money(controller.payoutPendingTotal),
          ),
          _StatCell(
            title: 'Paid out',
            value: Format.money(controller.payoutPaidOutTotal),
          ),
          _StatCell(
            title: 'Difference',
            value: Format.money(controller.payoutDifferenceTotal),
          ),
          _StatCell(
            title: 'Room Fee',
            value: Format.money(controller.payoutRoomFeeTotal),
          ),
          _StatCell(
            title: 'Labor Fee',
            value: Format.money(controller.payoutLaborFeeTotal),
          ),
          _StatCell(
            title: 'Delivery Fee',
            value: Format.money(controller.payoutDeliveryFeeTotal),
          ),
        ],
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

class _PayoutDriversTable extends StatelessWidget {
  const _PayoutDriversTable({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.payoutSummaries;
      if (rows.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(Dimens.radiusXS),
            border: Border.all(color: AppColor.border),
          ),
          child: Center(
            child: Text(
              'No payout rows for ${controller.rangeLabel()}',
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
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Center(child: Text('Current payable'))),
            DataColumn(label: Center(child: Text('Paid out'))),
            DataColumn(label: Center(child: Text('Pending'))),
            DataColumn(label: Center(child: Text('Difference'))),
            DataColumn(label: Center(child: Text('Fees'))),
          ],
          rows: [
            for (final entry in rows.asMap().entries)
              _payoutDriverDataRow(entry.key + 1, entry.value),
          ],
        ),
      );
    });
  }
}

DataRow _payoutDriverDataRow(int index, PayoutDriverSummary summary) {
  final driver = summary.driver;
  final differenceColor = summary.difference == 0
      ? AppColor.textPrimary
      : summary.difference > 0
      ? AppColor.error
      : AppColor.success;

  DataCell moneyCell(double value, {Color? color}) {
    return DataCell(
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          Format.money(value),
          textAlign: TextAlign.right,
          style: TextStyle(color: color ?? AppColor.textPrimary),
        ),
      ),
    );
  }

  return DataRow(
    cells: [
      DataCell(Text('$index')),
      DataCell(Text(driver.name)),
      DataCell(Text(Format.date(driver.date))),
      DataCell(_PayoutStatusBadge(isPaidOut: driver.paidOut)),
      moneyCell(summary.currentPayable),
      moneyCell(summary.paidOutAmount),
      moneyCell(summary.pendingAmount),
      moneyCell(summary.difference, color: differenceColor),
      moneyCell(summary.totalFees),
    ],
  );
}

class _PayoutStatusBadge extends StatelessWidget {
  const _PayoutStatusBadge({required this.isPaidOut});

  final bool isPaidOut;

  @override
  Widget build(BuildContext context) {
    final color = isPaidOut ? AppColor.success : AppColor.error;
    final background = color.withValues(alpha: 0.1);
    final border = color.withValues(alpha: 0.45);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingSM,
        vertical: Dimens.spacingXXS,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Dimens.radiusXS),
        border: Border.all(color: border),
      ),
      child: Text(
        isPaidOut ? 'Paid out' : 'Pending',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: Dimens.fontSizeCaption,
        ),
      ),
    );
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                'Period: ${controller.rangeLabel()}',
                style: const TextStyle(
                  color: AppColor.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: Dimens.spacingLG),
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
      padding: const EdgeInsets.only(right: Dimens.spacingLG),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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

class _PayoutSummaryPane extends StatelessWidget {
  const _PayoutSummaryPane({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summaries = controller.payoutSummaries;
      final pending = controller.payoutPendingSummaries;
      return Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(Dimens.radiusXS),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(Dimens.spacingMD),
              child: Text(
                'Payout summary',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColor.border),
            Padding(
              padding: const EdgeInsets.all(Dimens.spacingMD),
              child: Column(
                children: [
                  _PayoutMetricRow(
                    label: 'Current payable',
                    value: Format.money(controller.payoutCurrentPayableTotal),
                  ),
                  _PayoutMetricRow(
                    label: 'Paid out',
                    value:
                        '${Format.money(controller.payoutPaidOutTotal)} (${controller.payoutPaidDriverCount})',
                  ),
                  _PayoutMetricRow(
                    label: 'Pending payout',
                    value:
                        '${Format.money(controller.payoutPendingTotal)} (${controller.payoutPendingDriverCount})',
                  ),
                  _PayoutMetricRow(
                    label: 'Difference',
                    value: Format.money(controller.payoutDifferenceTotal),
                    valueColor: controller.payoutDifferenceTotal == 0
                        ? AppColor.textPrimary
                        : controller.payoutDifferenceTotal > 0
                        ? AppColor.error
                        : AppColor.success,
                  ),
                  const Divider(height: Dimens.spacingLG),
                  _PayoutMetricRow(
                    label: AppString.driverRoomFee,
                    value: Format.money(controller.payoutRoomFeeTotal),
                  ),
                  _PayoutMetricRow(
                    label: AppString.driverLaborFee,
                    value: Format.money(controller.payoutLaborFeeTotal),
                  ),
                  _PayoutMetricRow(
                    label: AppString.driverDeliveryFee,
                    value: Format.money(controller.payoutDeliveryFeeTotal),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColor.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimens.spacingMD,
                Dimens.spacingSM,
                Dimens.spacingMD,
                Dimens.spacingXS,
              ),
              child: Text(
                'Pending payout (${pending.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: summaries.isEmpty
                  ? const Center(
                      child: Text(
                        'No payout rows',
                        style: TextStyle(color: AppColor.textSecondary),
                      ),
                    )
                  : pending.isEmpty
                  ? const Center(
                      child: Text(
                        'All drivers are paid out',
                        style: TextStyle(color: AppColor.success),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        Dimens.spacingMD,
                        0,
                        Dimens.spacingMD,
                        Dimens.spacingMD,
                      ),
                      itemCount: pending.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColor.border),
                      itemBuilder: (context, index) {
                        return _PendingPayoutRow(summary: pending[index]);
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _PayoutMetricRow extends StatelessWidget {
  const _PayoutMetricRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimens.spacingXS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColor.textSecondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? AppColor.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPayoutRow extends StatelessWidget {
  const _PendingPayoutRow({required this.summary});

  final PayoutDriverSummary summary;

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
                  summary.driver.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
              Text(
                Format.date(summary.driver.date),
                style: const TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: Dimens.fontSizeCaption,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.spacingXXS),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${summary.transactionCount} transactions',
                  style: const TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: Dimens.fontSizeCaption,
                  ),
                ),
              ),
              Text(
                Format.money(summary.pendingAmount),
                style: const TextStyle(
                  color: AppColor.error,
                  fontSize: Dimens.fontSizeCaption,
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
