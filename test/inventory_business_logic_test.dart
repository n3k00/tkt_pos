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
