import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:tkt_pos/data/local/app_database.dart';

class ActivityLogItem {
  ActivityLogItem({
    required this.editId,
    required this.editTime,
    required this.isDeletion,
    required this.driverId,
  });

  final int editId;
  DateTime editTime;
  bool isDeletion;
  final int driverId;
  String? driverName;
  TransactionEditHistoryEntry? before;
  TransactionEditHistoryEntry? after;
}

class PayoutHistoryItem {
  PayoutHistoryItem({
    required this.row,
    required this.driverName,
    required this.driverDate,
  });

  final DriverPayoutHistoryData row;
  final String driverName;
  final DateTime? driverDate;
}

class ActivityLogController extends GetxController {
  final AppDatabase db = AppDatabase();

  final RxBool isLoading = false.obs;
  final RxList<ActivityLogItem> logs = <ActivityLogItem>[].obs;
  final RxList<PayoutHistoryItem> payoutLogs = <PayoutHistoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  Future<void> loadLogs() async {
    isLoading.value = true;
    try {
      final historyRows =
          await (db.select(db.transactionEditHistory)
                ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.editTime)])
                ..limit(200))
              .get();

      final Map<int, ActivityLogItem> grouped = {};
      final Set<int> driverIds = {};
      for (final row in historyRows) {
        final item = grouped.putIfAbsent(
          row.editId,
          () => ActivityLogItem(
            editId: row.editId,
            editTime: row.editTime,
            isDeletion: row.isDeletion,
            driverId: row.driverId,
          ),
        );
        item.editTime = row.editTime;
        item.isDeletion = row.isDeletion;
        if (!driverIds.contains(row.driverId)) {
          driverIds.add(row.driverId);
        }
        if (row.isBefore) {
          item.before = row;
        } else {
          item.after = row;
        }
      }

      if (driverIds.isNotEmpty) {
        final drivers = await (db.select(
          db.drivers,
        )..where((d) => d.id.isIn(driverIds.toList()))).get();
        final driverMap = {for (final d in drivers) d.id: d};
        for (final item in grouped.values) {
          item.driverName = driverMap[item.driverId]?.name ?? 'Unknown';
        }
      }

      final ordered = grouped.values.toList()
        ..sort((a, b) => b.editTime.compareTo(a.editTime));
      logs.assignAll(ordered);

      final payoutRows =
          await (db.select(db.driverPayoutHistory)
                ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.changedAt)])
                ..limit(200))
              .get();
      final payoutDriverIds = payoutRows.map((row) => row.driverId).toSet();
      final payoutDrivers = payoutDriverIds.isEmpty
          ? const <Driver>[]
          : await (db.select(
              db.drivers,
            )..where((d) => d.id.isIn(payoutDriverIds.toList()))).get();
      final payoutDriverMap = {for (final d in payoutDrivers) d.id: d};
      payoutLogs.assignAll([
        for (final row in payoutRows)
          PayoutHistoryItem(
            row: row,
            driverName: payoutDriverMap[row.driverId]?.name ?? 'Unknown',
            driverDate: payoutDriverMap[row.driverId]?.date,
          ),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshLogs() => loadLogs();
}
