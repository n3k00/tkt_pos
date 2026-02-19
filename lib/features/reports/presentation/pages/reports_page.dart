import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/reports/presentation/controllers/reports_controller.dart';
import 'package:tkt_pos/widgets/app_drawer.dart';
import 'package:tkt_pos/widgets/edge_drawer_opener.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/widgets/page_header.dart';
import 'package:tkt_pos/resources/strings.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 80,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: AppString.reports,
                crumbs: const [AppString.home, AppString.reports],
                showBack: false,
                trailing: HeaderSearchField(
                  hint: AppString.searchReportsHint,
                  onChanged: controller.setSearch,
                ),
              ),
              const SizedBox(height: 4),
              _StatCards(controller: controller),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      AppString.reportTransactionsTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _DatePickerButton(controller: controller),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _ReportsTable(controller: controller)),
            ],
          ),
          EdgeDrawerOpener(),
        ],
      ),
    );
  }
}

class _StatCards extends StatelessWidget {
  const _StatCards({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        return Row(
          children: [
            _StatCard(
              title: AppString.totalCount,
              value: controller.totalCount.toString(),
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: AppString.totalCharges,
              value: Format.money(controller.totalChargesPendingAndAdvance),
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: AppString.statPaymentPending,
              value: Format.money(controller.totalChargesPending),
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: AppString.statPaymentPaid,
              value: Format.money(controller.totalChargesPaid),
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: AppString.statCashAdvance,
              value: Format.money(controller.totalCashAdvance),
            ),
          ],
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColor.textSecondary)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColor.textPrimary,
              ),
            ),
            // Chart removed to avoid overflow
          ],
        ),
      ),
    );
  }
}

// Period dropdown removed per request

// Export buttons removed as requested

class _ReportsTable extends StatefulWidget {
  const _ReportsTable({required this.controller});
  final ReportsController controller;

  @override
  State<_ReportsTable> createState() => _ReportsTableState();
}

class _ReportsTableState extends State<_ReportsTable> {
  final ScrollController _vCtrl = ScrollController();
  final ScrollController _hCtrl = ScrollController();

  @override
  void dispose() {
    _vCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = widget.controller;
      final rows = controller.filtered;
      if (rows.isEmpty) {
        final d = controller.selectedDate.value;
        final dd = d.day.toString().padLeft(2, '0');
        final mm = d.month.toString().padLeft(2, '0');
        final yyyy = d.year.toString();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Card(
            margin: EdgeInsets.zero,
            color: AppColor.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColor.border),
            ),
            child: SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  '${AppString.noReportsForDate} $dd/$mm/$yyyy',
                  style: const TextStyle(color: AppColor.textSecondary),
                ),
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: AppDataTable(
          table: DataTable(
            columnSpacing: 16,
            horizontalMargin: 12,
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
        ),
      );
    });
  }
}

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({required this.controller});
  final ReportsController controller;

  String _formatDisplay(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _pickDate(BuildContext context) async {
    final initial = controller.selectedDate.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) {
      controller.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = controller.selectedDate.value;
      final label = _formatDisplay(date);
      return InkWell(
        onTap: () => _pickDate(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColor.card,
            border: Border.all(color: AppColor.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColor.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColor.textPrimary)),
            ],
          ),
        ),
      );
    });
  }
}

// Money/date formatters moved to lib/utils/format.dart
