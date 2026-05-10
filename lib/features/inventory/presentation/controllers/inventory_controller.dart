import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/utils/payout_calculator.dart';

class InventoryController extends GetxController {
  InventoryController({AppDatabase? database}) : db = database ?? AppDatabase();

  final AppDatabase db;

  final Rx<DateTime> selectedDate = Rx<DateTime>(DateTime.now());
  final RxList<Driver> drivers = <Driver>[].obs;
  final Rx<int?> selectedDriverId = Rx<int?>(null);
  final RxList<DbTransaction> transactions =
      <DbTransaction>[].obs; // legacy single-driver view
  final RxMap<int, List<DbTransaction>> transactionsByDriver =
      <int, List<DbTransaction>>{}.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool showUnclaimedOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load all drivers initially for sectioned UI
    loadAllDrivers();
  }

  Future<void> loadDriversForDate(DateTime date) async {
    isLoading.value = true;
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      final query = (db.select(db.drivers)
        ..where(
          (d) =>
              d.date.isBiggerOrEqualValue(start) &
              d.date.isSmallerThanValue(end),
        )
        ..orderBy([(d) => drift.OrderingTerm.asc(d.name)]));
      final list = await query.get();
      drivers.assignAll(list);
      // Reset selection if current selection not in list
      if (selectedDriverId.value == null ||
          !list.any((e) => e.id == selectedDriverId.value)) {
        selectedDriverId.value = list.isNotEmpty ? list.first.id : null;
      }
      if (selectedDriverId.value != null) {
        await loadTransactionsByDriver(selectedDriverId.value!);
      } else {
        transactions.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllDrivers() async {
    isLoading.value = true;
    List<Driver> list = const <Driver>[];
    try {
      list =
          await (db.select(db.drivers)..orderBy([
                (d) => drift.OrderingTerm.desc(d.date),
                (d) => drift.OrderingTerm.asc(d.name),
              ]))
              .get();
      drivers.assignAll(list);
    } finally {
      isLoading.value = false;
    }
    // Populate transactions map without blocking the loader
    await Future.wait(list.map((d) => loadTransactionsByDriverToMap(d.id)));
  }

  Future<void> setDate(DateTime date) async {
    selectedDate.value = date;
    await loadDriversForDate(date);
  }

  Future<void> setDriver(int? driverId) async {
    selectedDriverId.value = driverId;
    if (driverId != null) {
      await loadTransactionsByDriver(driverId);
    } else {
      transactions.clear();
    }
  }

  Future<void> loadTransactionsByDriver(int driverId) async {
    isLoading.value = true;
    try {
      final list = await db.getTransactionsByDriver(driverId);
      transactions.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTransactionsByDriverToMap(int driverId) async {
    final list = await db.getTransactionsByDriver(driverId);
    transactionsByDriver[driverId] = list;
    // trigger RxMap update
    transactionsByDriver.refresh();
  }

  Future<void> refreshDriverById(int driverId) async {
    final query = db.select(db.drivers)..where((d) => d.id.equals(driverId));
    final results = await query.get();
    if (results.isEmpty) return;
    final updatedDriver = results.first;
    final index = drivers.indexWhere((d) => d.id == driverId);
    if (index >= 0) {
      drivers[index] = updatedDriver;
      drivers.refresh();
    } else {
      drivers.add(updatedDriver);
    }
    await loadTransactionsByDriverToMap(driverId);
  }

  void setSearch(String q) {
    searchQuery.value = q;
  }

  void setUnclaimedOnly(bool value) {
    showUnclaimedOnly.value = value;
  }

  List<DbTransaction> get filteredTransactions {
    final q = searchQuery.value.trim().toLowerCase();
    Iterable<DbTransaction> filtered = transactions;
    if (showUnclaimedOnly.value) {
      filtered = filtered.where((t) => !t.pickedUp);
    }
    if (q.isEmpty) return filtered.toList(growable: false);
    return filtered
        .where((t) {
          final fields = <String?>[
            t.customerName,
            t.phone,
            t.parcelType,
            t.number,
            t.paymentStatus,
            t.cashAdvance.toString(),
            t.charges.toString(),
          ];
          return fields.any((f) => (f ?? '').toLowerCase().contains(q));
        })
        .toList(growable: false);
  }

  List<DbTransaction> filteredTransactionsForDriver(int driverId) {
    final q = searchQuery.value.trim().toLowerCase();
    final source = transactionsByDriver[driverId] ?? const <DbTransaction>[];
    Iterable<DbTransaction> filtered = source;
    if (showUnclaimedOnly.value) {
      filtered = filtered.where((t) => !t.pickedUp);
    }
    if (q.isEmpty) return filtered.toList(growable: false);
    return filtered
        .where((t) {
          final fields = <String?>[
            t.customerName,
            t.phone,
            t.parcelType,
            t.number,
            t.paymentStatus,
            t.cashAdvance.toString(),
            t.charges.toString(),
          ];
          return fields.any((f) => (f ?? '').toLowerCase().contains(q));
        })
        .toList(growable: false);
  }

  bool canAddTransaction(Driver driver) {
    return !driver.paidOut;
  }

  bool canEditDriver(Driver driver) {
    return !driver.paidOut;
  }

  bool canEditDriverFees(Driver driver) {
    return !driver.paidOut;
  }

  bool canEditTransaction({
    required DbTransaction transaction,
    required Driver? driver,
  }) {
    if (driver == null) return false;
    return !driver.paidOut;
  }

  bool canDeleteTransaction({
    required DbTransaction transaction,
    required Driver? driver,
  }) {
    if (driver == null) return false;
    return !driver.paidOut;
  }

  bool canClaimTransaction({
    required DbTransaction transaction,
    required Driver? driver,
  }) {
    return !transaction.pickedUp;
  }

  Future<List<DriverProfile>> activeDriverProfiles() {
    return db.getDriverProfiles(includeInactive: false);
  }

  Future<int> addDriver({
    required DateTime date,
    required String name,
    int? profileId,
  }) async {
    final resolvedProfileId =
        profileId ?? await db.getOrCreateDriverProfile(name: name);
    final id = await db.insertDriver(
      DriversCompanion.insert(
        profileId: drift.Value(resolvedProfileId),
        date: date,
        name: name,
      ),
    );
    // reload list
    await loadAllDrivers();
    return id;
  }

  Future<void> updateDriver({
    required int id,
    required DateTime date,
    required String name,
  }) async {
    final profileId = await db.getOrCreateDriverProfile(name: name);
    await (db.update(db.drivers)..where((d) => d.id.equals(id))).write(
      DriversCompanion(
        profileId: drift.Value(profileId),
        date: drift.Value(date),
        name: drift.Value(name),
      ),
    );
    await refreshDriverById(id);
  }

  Future<void> updateDriverFees({
    required Driver driver,
    required double roomFee,
    required double laborFee,
    required double deliveryFee,
  }) async {
    if (!canEditDriverFees(driver)) {
      throw StateError('Reopen payout before editing fees.');
    }
    await (db.update(db.drivers)..where((d) => d.id.equals(driver.id))).write(
      DriversCompanion(
        roomFee: drift.Value(roomFee),
        laborFee: drift.Value(laborFee),
        deliveryFee: drift.Value(deliveryFee),
      ),
    );
    await refreshDriverById(driver.id);
  }

  Future<void> addTransaction({
    required int driverId,
    String? customerName,
    required String phone,
    required String parcelType,
    required String number,
    required double charges,
    required String paymentStatus,
    double? cashAdvance,
    required bool pickedUp,
    String? comment,
  }) async {
    final driver = await (db.select(
      db.drivers,
    )..where((d) => d.id.equals(driverId))).getSingleOrNull();
    if (driver == null || !canAddTransaction(driver)) {
      throw StateError('Reopen payout before adding transactions.');
    }
    await db.insertTransaction(
      TransactionsCompanion.insert(
        customerName: drift.Value(customerName),
        phone: phone,
        parcelType: parcelType,
        number: number,
        charges: drift.Value(charges),
        paymentStatus: paymentStatus,
        cashAdvance: cashAdvance == null
            ? const drift.Value.absent()
            : drift.Value(cashAdvance),
        pickedUp: drift.Value(pickedUp),
        comment: drift.Value(comment),
        driverId: driverId,
      ),
    );
    await loadTransactionsByDriverToMap(driverId);
  }

  Future<void> updateTransaction(TransactionsCompanion companion) async {
    final success = await db.updateTransaction(companion);
    if (!success) return;
    final driverId = companion.driverId.present
        ? companion.driverId.value
        : null;
    if (driverId != null) {
      await loadTransactionsByDriverToMap(driverId);
    } else if (selectedDriverId.value != null) {
      await loadTransactionsByDriverToMap(selectedDriverId.value!);
    }
  }

  Future<void> claimTransaction({
    required DbTransaction tx,
    String? comment,
  }) async {
    if (!canClaimTransaction(transaction: tx, driver: null)) {
      return;
    }
    await db.transaction(() async {
      // Partial update: only set pickedUp/comment/updatedAt
      await (db.update(
        db.transactions,
      )..where((t) => t.id.equals(tx.id))).write(
        TransactionsCompanion(
          pickedUp: const drift.Value(true),
          comment: (comment == null || comment.trim().isEmpty)
              ? const drift.Value.absent()
              : drift.Value(comment.trim()),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      // Record this claim event into report_transactions (guarded against duplicates)
      await db.insertReportTransaction(
        driverId: tx.driverId,
        transactionId: tx.id,
      );
    });
    await loadTransactionsByDriverToMap(tx.driverId);
  }

  Future<void> deleteTransaction({
    required DbTransaction transaction,
    required Driver? driver,
  }) async {
    if (!canDeleteTransaction(transaction: transaction, driver: driver)) {
      throw StateError('Reopen payout before deleting transactions.');
    }
    await db.deleteTransactionById(transaction.id);
    await loadTransactionsByDriverToMap(transaction.driverId);
  }

  double? totalChargesForDriver(int driverId) {
    final list = transactionsByDriver[driverId];
    if (list == null) return 0;
    return list.fold<double>(0, (sum, t) => sum + t.charges);
  }

  double? paidOutAmountForDriver(int driverId) {
    final list = transactionsByDriver[driverId];
    if (list == null) return 0;
    return list.fold<double>(
      0,
      (sum, t) => sum + (_isPaymentPaid(t) ? t.charges : 0),
    );
  }

  double pendingPaymentAmountForDriver(int driverId) {
    final list = transactionsByDriver[driverId];
    if (list == null) return 0;
    return list.fold<double>(
      0,
      (sum, t) => sum + (_isPaymentPaid(t) ? 0 : t.charges),
    );
  }

  double currentPayoutAmountForDriver(Driver driver) {
    final list = transactionsByDriver[driver.id] ?? const <DbTransaction>[];
    return PayoutCalculator.forDriver(driver, list).currentPayable;
  }

  double paidOutDifferenceForDriver(Driver driver) {
    final list = transactionsByDriver[driver.id] ?? const <DbTransaction>[];
    return PayoutCalculator.forDriver(driver, list).difference;
  }

  Future<void> markDriverPaidOut(Driver driver) async {
    final amount = currentPayoutAmountForDriver(driver);
    final paidOutAt = DateTime.now();
    await db.transaction(() async {
      await (db.update(db.drivers)..where((d) => d.id.equals(driver.id))).write(
        DriversCompanion(
          paidOut: const drift.Value(true),
          paidOutAmount: drift.Value(amount),
          paidOutAt: drift.Value(paidOutAt),
        ),
      );
      await db
          .into(db.driverPayoutHistory)
          .insert(
            DriverPayoutHistoryCompanion.insert(
              driverId: driver.id,
              action: 'mark_paid_out',
              previousPaidOut: driver.paidOut,
              newPaidOut: true,
              previousPaidOutAmount: drift.Value(driver.paidOutAmount),
              newPaidOutAmount: drift.Value(amount),
              previousPaidOutAt: drift.Value(driver.paidOutAt),
              newPaidOutAt: drift.Value(paidOutAt),
            ),
          );
    });
    await refreshDriverById(driver.id);
  }

  Future<void> reopenDriverPayout(Driver driver) async {
    await db.transaction(() async {
      await (db.update(db.drivers)..where((d) => d.id.equals(driver.id))).write(
        const DriversCompanion(
          paidOut: drift.Value(false),
          paidOutAmount: drift.Value(null),
          paidOutAt: drift.Value(null),
        ),
      );
      await db
          .into(db.driverPayoutHistory)
          .insert(
            DriverPayoutHistoryCompanion.insert(
              driverId: driver.id,
              action: 'reopen_payout',
              previousPaidOut: driver.paidOut,
              newPaidOut: false,
              previousPaidOutAmount: drift.Value(driver.paidOutAmount),
              newPaidOutAmount: const drift.Value(null),
              previousPaidOutAt: drift.Value(driver.paidOutAt),
              newPaidOutAt: const drift.Value(null),
            ),
          );
    });
    await refreshDriverById(driver.id);
  }

  bool _isPaymentPaid(DbTransaction transaction) {
    return PayoutCalculator.isPaymentPaid(transaction.paymentStatus);
  }
}
