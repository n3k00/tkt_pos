import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/features/reports/presentation/controllers/reports_controller.dart';
import 'package:tkt_pos/widgets/appdrawer.dart';
import 'package:tkt_pos/widgets/edge_drawer_opener.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/widgets/page_header.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(),
        drawerEnableOpenDragGesture: true,
        drawerEdgeDragWidth: 80,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Reports',
                  crumbs: const ['Home', 'Reports'],
                  showBack: false,
                  trailing: HeaderSearchField(
                    hint: 'Search reports...',
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
                        'Report Transaction List',
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
              title: 'Total Count',
              value: controller.totalCount.toString(),
            ),
            const SizedBox(width: 12),
            _StatCard(
              title: 'Total Charges',
              value: _fmt(controller.totalChargesAll),
            ),
          ],
        );
      }),
    );
  }

  static String _fmt(double v) => _money(v);
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

class _ReportsTable extends StatelessWidget {
  const _ReportsTable({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.filtered;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Card(
          margin: EdgeInsets.zero,
          color: AppColor.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColor.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('No')),
                      DataColumn(label: Text('Driver')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Parcel')),
                      DataColumn(label: Text('Number')),
                      DataColumn(label: Text('Charges')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Cash Advance')),
                    ],
                    rows: [
                      ...rows.asMap().entries.map((e) {
                        final i = e.key + 1;
                        final t = e.value;
                        return DataRow(
                          cells: [
                            DataCell(Text('$i')),
                            DataCell(
                              Text(controller.driverNameFor(t.driverId)),
                            ),
                            DataCell(Text(t.customerName ?? '-')),
                            DataCell(Text(t.phone)),
                            DataCell(Text(t.parcelType)),
                            DataCell(Text(t.number)),
                            DataCell(Text(_money(t.charges))),
                            DataCell(Text(t.paymentStatus)),
                            DataCell(Text(_money(t.cashAdvance))),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
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

String _money(double v) {
  final isNegative = v < 0;
  // Convert the absolute value of v to a string with two decimal places
  var s = v.abs().toStringAsFixed(2);

  // Remove trailing zeros and the decimal point if it becomes the last character
  s = s.replaceAll(RegExp(r'0*$'), '');
  if (s.endsWith('.')) {
    s = s.substring(0, s.length - 1);
  }

  // Split the string into integer and fractional parts
  final parts = s.split('.');
  final intPart = parts[0];
  final fracPart = parts.length > 1 ? '.${parts[1]}' : '';

  // Add commas to the integer part
  String group(String d) {
    if (d.length <= 3) return d;
    final first = d.length % 3 == 0 ? 3 : d.length % 3;
    final buf = StringBuffer(d.substring(0, first));
    for (int i = first; i < d.length; i += 3) {
      buf.write(',');
      buf.write(d.substring(i, i + 3));
    }
    return buf.toString();
  }

  final withCommas = group(intPart);

  // Return the formatted string with the negative sign if needed
  return (isNegative ? '-' : '') + withCommas + fracPart;
}

String _fmtDateTime(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString().padLeft(4, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final mi = d.minute.toString().padLeft(2, '0');
  return '$dd/$mm/$yyyy $hh:$mi';
}
