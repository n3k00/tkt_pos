import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tkt_pos/data/local/app_database.dart';
import 'package:tkt_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:tkt_pos/resources/strings.dart';

void main() {
  late AppDatabase db;
  late InventoryController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = InventoryController(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'claiming a transaction marks it picked up and reports it once',
    () async {
      final driverId = await _insertDriver(db);
      final txId = await _insertTransaction(db, driverId: driverId);
      final tx = await db.getTransactionById(txId);

      await controller.claimTransaction(tx: tx!, comment: 'delivered');
      await controller.claimTransaction(tx: tx, comment: 'duplicate click');

      final updated = await db.getTransactionById(txId);
      final reports = await db.select(db.reportTransactions).get();

      expect(updated?.pickedUp, isTrue);
      expect(updated?.comment, isNotNull);
      expect(reports, hasLength(1));
      expect(reports.single.driverId, driverId);
      expect(reports.single.transactionId, txId);
    },
  );

  test(
    'updating and deleting a transaction records history snapshots',
    () async {
      final driverId = await _insertDriver(db);
      final txId = await _insertTransaction(
        db,
        driverId: driverId,
        customerName: 'Before',
        charges: 1000,
        cashAdvance: 100,
      );

      final original = await db.getTransactionById(txId);
      await db.updateTransaction(
        TransactionsCompanion(
          id: drift.Value(txId),
          customerName: const drift.Value('After'),
          phone: drift.Value(original!.phone),
          parcelType: drift.Value(original.parcelType),
          number: drift.Value(original.number),
          charges: const drift.Value(1500),
          paymentStatus: drift.Value(original.paymentStatus),
          cashAdvance: drift.Value(original.cashAdvance),
          pickedUp: drift.Value(original.pickedUp),
          comment: drift.Value(original.comment),
          driverId: drift.Value(original.driverId),
          createdAt: drift.Value(original.createdAt),
          updatedAt: drift.Value(DateTime(2026, 1, 2)),
        ),
      );

      final updateHistory =
          await (db.select(db.transactionEditHistory)
                ..where((h) => h.transactionId.equals(txId))
                ..orderBy([(h) => drift.OrderingTerm.asc(h.id)]))
              .get();

      expect(updateHistory, hasLength(2));
      expect(updateHistory.map((h) => h.isBefore), [true, false]);
      expect(updateHistory.every((h) => !h.isDeletion), isTrue);
      expect(updateHistory.first.customerName, 'Before');
      expect(updateHistory.last.customerName, 'After');
      expect(updateHistory.last.charges, 1500);

      await db.deleteTransactionById(txId);

      final allHistory =
          await (db.select(db.transactionEditHistory)
                ..where((h) => h.transactionId.equals(txId))
                ..orderBy([(h) => drift.OrderingTerm.asc(h.id)]))
              .get();
      final deletionHistory = allHistory.where((h) => h.isDeletion).toList();

      expect(allHistory, hasLength(4));
      expect(deletionHistory, hasLength(2));
      expect(deletionHistory.map((h) => h.isBefore), [true, false]);
      expect(await db.getTransactionById(txId), isNull);
    },
  );

  test(
    'driver totals include all charges but paid out only includes paid rows',
    () async {
      final driverId = await _insertDriver(db);
      await _insertTransaction(
        db,
        driverId: driverId,
        charges: 1200,
        paymentStatus: AppString.paymentPaid,
      );
      await _insertTransaction(
        db,
        driverId: driverId,
        charges: 800,
        paymentStatus: AppString.paymentPending,
      );

      await controller.loadTransactionsByDriverToMap(driverId);

      expect(controller.totalChargesForDriver(driverId), 2000);
      expect(controller.paidOutAmountForDriver(driverId), 1200);
    },
  );

  test('adding a driver creates and links a driver profile', () async {
    final driverId = await controller.addDriver(
      date: DateTime(2026, 1, 1),
      name: 'Driver One',
    );

    final driver = await db.getDriverById(driverId);
    final profiles = await db.select(db.driverProfiles).get();

    expect(profiles, hasLength(1));
    expect(profiles.single.name, 'Driver One');
    expect(profiles.single.active, isTrue);
    expect(driver?.profileId, profiles.single.id);
  });

  test('adding a driver can use an existing active driver profile', () async {
    final activeProfileId = await db.insertDriverProfile(
      name: 'Existing Driver',
      phone: '099999999',
    );
    final inactiveProfileId = await db.insertDriverProfile(
      name: 'Inactive Driver',
    );
    await db.setDriverProfileActive(id: inactiveProfileId, active: false);

    final activeProfiles = await controller.activeDriverProfiles();
    expect(activeProfiles.map((profile) => profile.id), [activeProfileId]);

    final driverId = await controller.addDriver(
      date: DateTime(2026, 1, 2),
      name: activeProfiles.single.name,
      profileId: activeProfiles.single.id,
    );

    final driver = await db.getDriverById(driverId);
    final profiles = await db.select(db.driverProfiles).get();

    expect(profiles, hasLength(2));
    expect(driver?.profileId, activeProfileId);
    expect(driver?.name, 'Existing Driver');
  });

  test('marking driver paid out snapshots payout amount', () async {
    final driverId = await _insertDriver(db);
    await (db.update(db.drivers)..where((d) => d.id.equals(driverId))).write(
      const DriversCompanion(roomFee: drift.Value(100)),
    );
    final txId = await _insertTransaction(
      db,
      driverId: driverId,
      charges: 1000,
    );
    await controller.loadTransactionsByDriverToMap(driverId);

    final driver = await db.getDriverById(driverId);
    await controller.markDriverPaidOut(driver!);

    final paidDriver = await db.getDriverById(driverId);
    var payoutHistory = await db.select(db.driverPayoutHistory).get();
    expect(paidDriver?.paidOut, isTrue);
    expect(paidDriver?.paidOutAmount, 900);
    expect(paidDriver?.paidOutAt, isNotNull);
    expect(payoutHistory, hasLength(1));
    expect(payoutHistory.single.action, 'mark_paid_out');
    expect(payoutHistory.single.previousPaidOut, isFalse);
    expect(payoutHistory.single.newPaidOut, isTrue);
    expect(payoutHistory.single.newPaidOutAmount, 900);

    final tx = await db.getTransactionById(txId);
    await db.updateTransaction(
      TransactionsCompanion(
        id: drift.Value(txId),
        customerName: drift.Value(tx!.customerName),
        phone: drift.Value(tx.phone),
        parcelType: drift.Value(tx.parcelType),
        number: drift.Value(tx.number),
        charges: const drift.Value(1200),
        paymentStatus: drift.Value(tx.paymentStatus),
        cashAdvance: drift.Value(tx.cashAdvance),
        pickedUp: drift.Value(tx.pickedUp),
        comment: drift.Value(tx.comment),
        driverId: drift.Value(tx.driverId),
        createdAt: drift.Value(tx.createdAt),
        updatedAt: drift.Value(DateTime(2026, 1, 2)),
      ),
    );
    await controller.loadTransactionsByDriverToMap(driverId);

    final afterEdit = await db.getDriverById(driverId);
    expect(afterEdit?.paidOutAmount, 900);
    expect(controller.paidOutDifferenceForDriver(afterEdit!), 200);

    await controller.reopenDriverPayout(afterEdit);
    payoutHistory = await db.select(db.driverPayoutHistory).get();
    expect(payoutHistory, hasLength(2));
    expect(payoutHistory.last.action, 'reopen_payout');
    expect(payoutHistory.last.previousPaidOut, isTrue);
    expect(payoutHistory.last.newPaidOut, isFalse);
  });

  test('paid out drivers must be reopened before fee edits', () async {
    final driverId = await _insertDriver(db);
    await _insertTransaction(db, driverId: driverId, charges: 1000);
    await controller.loadTransactionsByDriverToMap(driverId);

    final driver = await db.getDriverById(driverId);
    await controller.markDriverPaidOut(driver!);

    final paidDriver = await db.getDriverById(driverId);
    expect(
      () => controller.updateDriverFees(
        driver: paidDriver!,
        roomFee: 100,
        laborFee: 0,
        deliveryFee: 0,
      ),
      throwsStateError,
    );

    await controller.reopenDriverPayout(paidDriver!);
    final reopenedDriver = await db.getDriverById(driverId);
    await controller.updateDriverFees(
      driver: reopenedDriver!,
      roomFee: 100,
      laborFee: 0,
      deliveryFee: 0,
    );

    final updated = await db.getDriverById(driverId);
    expect(updated?.roomFee, 100);
    expect(updated?.paidOut, isFalse);
    expect(updated?.paidOutAmount, isNull);
  });
}

Future<int> _insertDriver(AppDatabase db, {String name = 'Driver One'}) {
  return db.insertDriver(
    DriversCompanion.insert(date: DateTime(2026, 1, 1), name: name),
  );
}

Future<int> _insertTransaction(
  AppDatabase db, {
  required int driverId,
  String? customerName = 'Customer',
  double charges = 1000,
  double cashAdvance = 0,
  String paymentStatus = AppString.paymentPending,
}) {
  return db.insertTransaction(
    TransactionsCompanion.insert(
      customerName: drift.Value(customerName),
      phone: '09123456789',
      parcelType: 'Box',
      number: '1',
      charges: drift.Value(charges),
      paymentStatus: paymentStatus,
      cashAdvance: drift.Value(cashAdvance),
      pickedUp: const drift.Value(false),
      driverId: driverId,
    ),
  );
}
