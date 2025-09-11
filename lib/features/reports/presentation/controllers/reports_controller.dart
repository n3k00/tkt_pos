import 'package:get/get.dart';
import 'package:drift/drift.dart';
import 'package:tkt_pos/data/local/app_database.dart';

class ReportsController extends GetxController {
  final AppDatabase db = AppDatabase();

  final RxInt currentTabIndex = 0.obs; // legacy
  final RxString search = ''.obs;
  final Rx<DateTime> selectedDate = Rx<DateTime>(DateTime.now());
  final RxList<DbTransaction> all = <DbTransaction>[].obs;
  final RxMap<int, Driver> driverMap = <int, Driver>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final base = selectedDate.value;
    final start = DateTime(base.year, base.month, base.day);
    final end = start.add(const Duration(days: 1));
    final list = await db.getReportedTransactions(start, end);
    if (list.isEmpty) {
      // Backfill once for this day from picked-up transactions, then reload
      await db.backfillReportTransactionsForDay(base);
      final list2 = await db.getReportedTransactions(start, end);
      all.assignAll(list2);
    } else {
      all.assignAll(list);
    }
    // fetch driver names for displayed rows in one query
    final ids = list.map((e) => e.driverId).toSet().toList();
    if (all.isNotEmpty) {
      final ids = all.map((e) => e.driverId).toSet().toList();
      final ds = await (db.select(db.drivers)
            ..where((d) => d.id.isIn(ids)))
          .get();
      driverMap
        ..clear()
        ..addEntries(ds.map((d) => MapEntry(d.id, d)));
    } else {
      driverMap.clear();
    }
  }

  void setTab(int index) {
    currentTabIndex.value = index;
  }

  void setSearch(String v) => search.value = v;
  void setDate(DateTime d) {
    selectedDate.value = d;
    load();
  }

  List<DbTransaction> get filtered {
    final q = search.value.trim().toLowerCase();
    final src = all;
    if (q.isEmpty) return src;
    return src.where((t) {
      final f = <String?>[
        t.customerName,
        t.phone,
        t.parcelType,
        t.number,
        t.paymentStatus,
        driverNameFor(t.driverId),
      ];
      return f.any((s) => (s ?? '').toLowerCase().contains(q));
    }).toList(growable: false);
  }

  double get totalChargesAll => filtered.fold(0.0, (s, t) => s + t.charges);
  double get totalChargesPending => filtered
      .where((t) => t.paymentStatus.trim() == 'ငွေတောင်းရန်')
      .fold(0.0, (s, t) => s + t.charges);
  int get totalCount => filtered.length;

  String driverNameFor(int driverId) => driverMap[driverId]?.name ?? '-';
}
