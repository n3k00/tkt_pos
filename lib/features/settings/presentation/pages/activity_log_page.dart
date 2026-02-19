import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/settings/presentation/controllers/activity_log_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/utils/format.dart';
import 'package:tkt_pos/widgets/app_data_table.dart';
import 'package:tkt_pos/widgets/app_drawer.dart';
import 'package:tkt_pos/widgets/edge_drawer_opener.dart';
import 'package:tkt_pos/widgets/page_header.dart';

class ActivityLogPage extends GetView<ActivityLogController> {
  const ActivityLogPage({super.key});

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
                title: 'Activity Log',
                crumbs: const ['Settings', 'Activity Log'],
                showBack: true,
                showBreadcrumbs: true,
                onBack: () => Get.back(),
                trailing: IconButton(
                  tooltip: 'Refresh',
                  onPressed: controller.refreshLogs,
                  icon: const Icon(Icons.refresh),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final logs = controller.logs;
                    if (logs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No activity recorded yet.',
                          style: TextStyle(color: AppColor.textSecondary),
                        ),
                      );
                    }
                    final rows = logs.expand((log) => [
                          _snapshotRow(log, true, context),
                          _snapshotRow(log, false, context),
                        ]).toList();
                    return AppDataTable(
                      table: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        headingRowHeight: 44,
                        columns: const [
                          DataColumn(label: Text('Txn ID')),
                          DataColumn(label: Text('Snapshot')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Driver')),
                          DataColumn(label: Text('Customer')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Parcel')),
                          DataColumn(label: Text('Charges')),
                          DataColumn(label: Text('Payment')),
                          DataColumn(label: Text('Picked')),
                          DataColumn(label: Text('Comment')),
                          DataColumn(label: Text('Time')),
                          DataColumn(label: SizedBox.shrink()),
                        ],
                        rows: rows,
                      ),
                    );
                  }),
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

DataRow _snapshotRow(
  ActivityLogItem entry,
  bool isBefore,
  BuildContext context,
) {
  final TransactionEditHistoryEntry? snapshot =
      isBefore ? entry.before : entry.after;
  final bool showDeletedState = entry.isDeletion && !isBefore;
  final String txnLabel = isBefore ? '#${entry.editId}' : '';
  final String snapshotLabel = isBefore ? 'Before' : 'After';

  String formatField(String? value) {
    if (showDeletedState) return 'Deleted';
    if (value == null || value.trim().isEmpty) return '-';
    return value.trim();
  }

  final String customer = formatField(snapshot?.customerName);
  final String phone = formatField(snapshot?.phone);
  final String parcel = formatField(snapshot?.parcelType);
  final String payment = formatField(snapshot?.paymentStatus);
  final String charges = showDeletedState
      ? 'Deleted'
      : (snapshot == null ? '-' : Format.money(snapshot.charges));
  final String picked = showDeletedState
      ? 'Deleted'
      : (snapshot == null ? '-' : (snapshot.pickedUp ? 'Yes' : 'No'));
  final String comment = showDeletedState
      ? 'Deleted'
      : (snapshot == null ? '-' : _commentValue(snapshot));
  final Widget typeCell =
      isBefore ? _TypeBadge(isDeletion: entry.isDeletion) : const SizedBox.shrink();

  return DataRow(
    cells: [
      DataCell(Text(txnLabel)),
      DataCell(Text(snapshotLabel)),
      DataCell(typeCell),
      DataCell(
        SizedBox(
          width: 160,
          child: Text(entry.driverName ?? '-'),
        ),
      ),
      DataCell(Text(customer)),
      DataCell(Text(phone)),
      DataCell(Text(parcel)),
      DataCell(Text(charges)),
      DataCell(Text(payment)),
      DataCell(Text(picked)),
      DataCell(
        SizedBox(
          width: 180,
          child: Text(comment),
        ),
      ),
      DataCell(Text(Format.dateTime12(entry.editTime))),
      DataCell(
        IconButton(
          tooltip: 'View details',
          onPressed: () => _showHistoryDetailsDialog(context, entry),
          icon: const Icon(Icons.list_alt_outlined),
        ),
      ),
    ],
  );
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isDeletion});

  final bool isDeletion;

  @override
  Widget build(BuildContext context) {
    final color = isDeletion ? Colors.redAccent : AppColor.primaryDark;
    final label = isDeletion ? 'Deleted' : 'Edit';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _commentValue(TransactionEditHistoryEntry? entry) {
  final text = entry?.comment?.trim() ?? '';
  return text.isEmpty ? '-' : text;
}

Future<void> _showHistoryDetailsDialog(
  BuildContext context,
  ActivityLogItem entry,
) async {
  final before = entry.before;
  final after = entry.after;

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Transaction #${entry.editId}'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver: ${entry.driverName ?? '-'} • ${Format.dateTime12(entry.editTime)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColor.textSecondary),
            ),
            const SizedBox(height: 12),
            AppDataTable(
              table: DataTable(
                columnSpacing: 12,
                headingRowHeight: 40,
                columns: const [
                  DataColumn(label: Text('Field')),
                  DataColumn(label: Text('Before')),
                  DataColumn(label: Text('After')),
                ],
                rows: [
                  _detailRow('Customer', before?.customerName ?? '-',
                      after?.customerName),
                  _detailRow('Phone', before?.phone ?? '-', after?.phone),
                  _detailRow('Parcel', before?.parcelType ?? '-',
                      after?.parcelType),
                  _detailRow('Number', before?.number ?? '-', after?.number),
                  _detailRow(
                    'Charges',
                    Format.money(before?.charges ?? 0),
                    after == null ? null : Format.money(after.charges),
                  ),
                  _detailRow(
                    'Cash Advance',
                    Format.money(before?.cashAdvance ?? 0),
                    after == null ? null : Format.money(after.cashAdvance),
                  ),
                  _detailRow('Payment', before?.paymentStatus ?? '-',
                      after?.paymentStatus),
                  _detailRow(
                    'Picked Up',
                    (before?.pickedUp ?? false) ? 'Yes' : 'No',
                    after == null
                        ? (entry.isDeletion ? 'Deleted' : null)
                        : (after.pickedUp ? 'Yes' : 'No'),
                  ),
                  _detailRow(
                    'Comment',
                    _commentValue(before),
                    after == null
                        ? (entry.isDeletion ? 'Deleted' : null)
                        : _commentValue(after),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

DataRow _detailRow(String label, String before, String? after) {
  return DataRow(
    cells: [
      DataCell(Text(label)),
      DataCell(Text(before)),
      DataCell(Text(after ?? '-')),
    ],
  );
}
