import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/settings/presentation/controllers/activity_log_controller.dart';
import 'package:tkt_pos/resources/colors.dart';
import 'package:tkt_pos/resources/dimens.dart';
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
                  padding: const EdgeInsets.fromLTRB(
                    Dimens.spacingMD,
                    0,
                    Dimens.spacingMD,
                    Dimens.spacingMD,
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TabBar(
                          isScrollable: true,
                          tabs: [
                            Tab(text: 'Transactions'),
                            Tab(text: 'Payouts'),
                          ],
                        ),
                        const SizedBox(height: Dimens.spacingSM),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _TransactionHistoryTable(controller: controller),
                              _PayoutHistoryTable(controller: controller),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _TransactionHistoryTable extends StatelessWidget {
  const _TransactionHistoryTable({required this.controller});

  final ActivityLogController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final logs = controller.logs;
      if (logs.isEmpty) {
        return const Center(
          child: Text(
            'No transaction activity recorded yet.',
            style: TextStyle(color: AppColor.textSecondary),
          ),
        );
      }
      final rows = logs
          .expand(
            (log) => [
              _snapshotRow(log, true, context),
              _snapshotRow(log, false, context),
            ],
          )
          .toList();
      return AppDataTable(
        table: DataTable(
          columnSpacing: Dimens.spacingMD,
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
    });
  }
}

class _PayoutHistoryTable extends StatelessWidget {
  const _PayoutHistoryTable({required this.controller});

  final ActivityLogController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final logs = controller.payoutLogs;
      if (logs.isEmpty) {
        return const Center(
          child: Text(
            'No payout activity recorded yet.',
            style: TextStyle(color: AppColor.textSecondary),
          ),
        );
      }
      return AppDataTable(
        table: DataTable(
          columnSpacing: Dimens.spacingMD,
          horizontalMargin: 12,
          headingRowHeight: 44,
          columns: const [
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Driver')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('Before')),
            DataColumn(label: Text('After')),
            DataColumn(label: Text('Before Amount')),
            DataColumn(label: Text('After Amount')),
            DataColumn(label: Text('Before Paid At')),
            DataColumn(label: Text('After Paid At')),
          ],
          rows: [for (final item in logs) _payoutHistoryRow(item)],
        ),
      );
    });
  }
}

DataRow _payoutHistoryRow(PayoutHistoryItem item) {
  final row = item.row;
  return DataRow(
    cells: [
      DataCell(Text(Format.dateTime12(row.changedAt))),
      DataCell(SizedBox(width: 160, child: Text(item.driverName))),
      DataCell(
        Text(item.driverDate == null ? '-' : Format.date(item.driverDate!)),
      ),
      DataCell(_PayoutActionBadge(action: row.action)),
      DataCell(Text(_paidLabel(row.previousPaidOut))),
      DataCell(Text(_paidLabel(row.newPaidOut))),
      DataCell(Text(_moneyOrDash(row.previousPaidOutAmount))),
      DataCell(Text(_moneyOrDash(row.newPaidOutAmount))),
      DataCell(Text(_timeOrDash(row.previousPaidOutAt))),
      DataCell(Text(_timeOrDash(row.newPaidOutAt))),
    ],
  );
}

DataRow _snapshotRow(
  ActivityLogItem entry,
  bool isBefore,
  BuildContext context,
) {
  final TransactionEditHistoryEntry? snapshot = isBefore
      ? entry.before
      : entry.after;
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
  final Widget typeCell = isBefore
      ? _TypeBadge(isDeletion: entry.isDeletion)
      : const SizedBox.shrink();

  return DataRow(
    cells: [
      DataCell(Text(txnLabel)),
      DataCell(Text(snapshotLabel)),
      DataCell(typeCell),
      DataCell(SizedBox(width: 160, child: Text(entry.driverName ?? '-'))),
      DataCell(Text(customer)),
      DataCell(Text(phone)),
      DataCell(Text(parcel)),
      DataCell(Text(charges)),
      DataCell(Text(payment)),
      DataCell(Text(picked)),
      DataCell(SizedBox(width: 180, child: Text(comment))),
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
    final color = isDeletion ? AppColor.error : AppColor.primaryDark;
    final label = isDeletion ? 'Deleted' : 'Edit';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingXS,
        vertical: Dimens.spacingXXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimens.radiusMD),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PayoutActionBadge extends StatelessWidget {
  const _PayoutActionBadge({required this.action});

  final String action;

  @override
  Widget build(BuildContext context) {
    final bool isReopen = action == 'reopen_payout';
    final color = isReopen ? AppColor.warning : AppColor.success;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingXS,
        vertical: Dimens.spacingXXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimens.radiusMD),
      ),
      child: Text(
        _payoutActionLabel(action),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _commentValue(TransactionEditHistoryEntry? entry) {
  final text = entry?.comment?.trim() ?? '';
  return text.isEmpty ? '-' : text;
}

String _moneyOrDash(double? value) {
  return value == null ? '-' : Format.money(value);
}

String _timeOrDash(DateTime? value) {
  return value == null ? '-' : Format.dateTime12(value);
}

String _paidLabel(bool value) {
  return value ? 'Paid' : 'Pending';
}

String _payoutActionLabel(String action) {
  switch (action) {
    case 'mark_paid_out':
      return 'Mark paid out';
    case 'reopen_payout':
      return 'Reopen payout';
    default:
      return action;
  }
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
              'Driver: ${entry.driverName ?? '-'} - ${Format.dateTime12(entry.editTime)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColor.textSecondary),
            ),
            const SizedBox(height: Dimens.spacingSM),
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
                  _detailRow(
                    'Customer',
                    before?.customerName ?? '-',
                    after?.customerName,
                  ),
                  _detailRow('Phone', before?.phone ?? '-', after?.phone),
                  _detailRow(
                    'Parcel',
                    before?.parcelType ?? '-',
                    after?.parcelType,
                  ),
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
                  _detailRow(
                    'Payment',
                    before?.paymentStatus ?? '-',
                    after?.paymentStatus,
                  ),
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
