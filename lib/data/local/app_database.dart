import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/app_settings.dart';
import 'tables/drivers.dart';
import 'tables/transactions.dart';
import 'tables/transaction_edit_history.dart';
import 'tables/report_transactions.dart';
import 'tables/trip_main.dart';
import 'tables/trip_manifests.dart';
import 'daos/trip_dao.dart';

part 'app_database.g.dart';

// Tables are now split into separate files under tables/

@DriftDatabase(
  tables: [
    AppSettings,
    Drivers,
    Transactions,
    TransactionEditHistory,
    ReportTransactions,
    TripMains,
    TripManifests,
  ],
  daos: [TripDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 15;

  // Migrations: create new tables when upgrading from v1
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // Create all Drift-managed tables (including trip_main & trip_manifests)
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 6) {
        await m.createTable(reportTransactions);
      }
      if (from < 12) {
        // Rebuild trip tables while preserving any legacy data
        await _rebuildTripTablesWithCopy(m);
      }
      if (from < 13) {
        await m.createTable(transactionEditHistory);
      }
      if (from < 14) {
        await m.addColumn(drivers, drivers.roomFee);
        await m.addColumn(drivers, drivers.laborFee);
        await m.addColumn(drivers, drivers.deliveryFee);
      }
      if (from < 15) {
        await m.addColumn(drivers, drivers.paidOut);
      }
    },
  );

  Future<void> setSetting(String key, String? value) async {
    await into(
      appSettings,
    ).insertOnConflictUpdate(AppSetting(key: key, value: value));
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  // ------ Drivers CRUD ------
  Future<int> insertDriver(DriversCompanion companion) =>
      into(drivers).insert(companion);

  Future<List<Driver>> getAllDrivers() => select(drivers).get();

  Future<Driver?> getDriverById(int id) async {
    return (select(drivers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updateDriver(DriversCompanion companion) =>
      update(drivers).replace(companion);

  // ------ Transactions CRUD ------
  Future<int> insertTransaction(TransactionsCompanion companion) =>
      into(transactions).insert(companion);

  Future<List<DbTransaction>> getAllTransactions() =>
      select(transactions).get();

  Future<List<DbTransaction>> getTransactionsByDriver(int driverId) async {
    return (select(
      transactions,
    )..where((t) => t.driverId.equals(driverId))).get();
  }

  Future<DbTransaction?> getTransactionById(int id) async {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updateTransaction(TransactionsCompanion companion) =>
      transaction(() async {
        final int? id = companion.id.present ? companion.id.value : null;
        if (id == null) {
          throw ArgumentError('Transaction id is required for update');
        }
        final before = await getTransactionById(id);
        if (before == null) return false;

        final success = await update(transactions).replace(companion);
        if (!success) return false;

        final after = await getTransactionById(id);
        if (after == null) return success;

        final DateTime editTime = DateTime.now();
        final int editId = before.id;

        await _insertHistorySnapshot(
          source: before,
          editId: editId,
          editTime: editTime,
          isBefore: true,
          isDeletion: false,
        );
        await _insertHistorySnapshot(
          source: after,
          editId: editId,
          editTime: editTime,
          isBefore: false,
          isDeletion: false,
        );
        return true;
      });

  Future<int> deleteTransactionById(int id) async {
    final before = await getTransactionById(id);
    if (before == null) return 0;
    return transaction(() async {
      final editTime = DateTime.now();
      final editId = before.id;
      await _insertHistorySnapshot(
        source: before,
        editId: editId,
        editTime: editTime,
        isBefore: true,
        isDeletion: true,
      );
      await _insertHistorySnapshot(
        source: before,
        editId: editId,
        editTime: editTime,
        isBefore: false,
        isDeletion: true,
      );
      return (delete(transactions)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> _insertHistorySnapshot({
    required DbTransaction source,
    required int editId,
    required DateTime editTime,
    required bool isBefore,
    required bool isDeletion,
  }) async {
    await into(transactionEditHistory).insert(
      TransactionEditHistoryCompanion.insert(
        editId: editId,
        isBefore: Value(isBefore),
        editTime: Value(editTime),
        isDeletion: Value(isDeletion),
        transactionId: source.id,
        customerName: Value(source.customerName),
        phone: source.phone,
        parcelType: source.parcelType,
        number: source.number,
        charges: Value(source.charges),
        paymentStatus: source.paymentStatus,
        cashAdvance: Value(source.cashAdvance),
        pickedUp: Value(source.pickedUp),
        comment: Value(source.comment),
        driverId: source.driverId,
        createdAt: Value(source.createdAt),
        updatedAt: Value(source.updatedAt),
      ),
    );
  }

  // ------ ReportTransactions CRUD ------
  Future<int> insertReportTransaction({
    required int driverId,
    required int transactionId,
  }) async {
    // Prevent duplicates caused by rapid double clicks
    final existing = await (select(
      reportTransactions,
    )..where((rt) => rt.transactionId.equals(transactionId))).getSingleOrNull();
    if (existing != null) return existing.id;

    return into(reportTransactions).insert(
      ReportTransactionsCompanion.insert(
        driverId: driverId,
        transactionId: transactionId,
      ),
    );
  }

  Future<List<DbTransaction>> getReportedTransactions(
    DateTime start,
    DateTime end,
  ) async {
    final rt = reportTransactions;
    final t = transactions;
    // Convert local day range to UTC because report_transactions timestamps
    // are stored with SQLite's CURRENT_TIMESTAMP (UTC) by default.
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();
    final query =
        select(t).join([innerJoin(rt, rt.transactionId.equalsExp(t.id))])
          ..where(
            rt.createdAt.isBiggerOrEqualValue(startUtc) &
                rt.createdAt.isSmallerThanValue(endUtc),
          );

    final rows = await query.get();
    return rows.map((row) => row.readTable(t)).toList(growable: false);
  }

  Future<void> backfillReportTransactionsForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day).toUtc();
    final end = start.add(const Duration(days: 1));
    // Fetch picked-up transactions in the selected day (by their updatedAt)
    final picked =
        await (select(transactions)..where(
              (t) =>
                  t.pickedUp.equals(true) &
                  t.updatedAt.isBiggerOrEqualValue(start) &
                  t.updatedAt.isSmallerThanValue(end),
            ))
            .get();
    if (picked.isEmpty) return;

    for (final tx in picked) {
      final exists = await (select(
        reportTransactions,
      )..where((rt) => rt.transactionId.equals(tx.id))).getSingleOrNull();
      if (exists == null) {
        await into(reportTransactions).insert(
          ReportTransactionsCompanion.insert(
            driverId: tx.driverId,
            transactionId: tx.id,
            createdAt: Value(tx.updatedAt.toUtc()),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    }
  }

  // ------ Backup & Restore ------
  Future<String> backupDatabaseToPath(String destinationPath) async {
    // Ensure the destination directory exists
    final dirPath = p.dirname(destinationPath);
    final d = Directory(dirPath);
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    // Use SQLite to write a consistent backup without closing the db
    final escaped = destinationPath.replaceAll("'", "''");
    await customStatement("VACUUM INTO '$escaped'");
    return destinationPath;
  }

  Future<String> backupDatabase() async {
    final Directory dir = await getApplicationSupportDirectory();
    final Directory backupsDir = Directory(p.join(dir.path, 'backups'));
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final String dest = p.join(backupsDir.path, 'app-$ts.db');
    // Use SQLite to write a consistent backup without closing the db
    await customStatement("VACUUM INTO '${dest.replaceAll("'", "''")}'");
    return dest;
  }

  static Future<String?> restoreFromBackup(String backupPath) async {
    try {
      final Directory dir = await getApplicationSupportDirectory();
      final File dbFile = File(p.join(dir.path, 'app.db'));
      final File src = File(backupPath);
      if (!await src.exists()) {
        return null;
      }
      // Close current connection to release file lock (especially on Windows)
      try {
        await AppDatabase().close();
      } catch (_) {}
      // small delay to allow background isolate to release handles
      await Future.delayed(const Duration(milliseconds: 500));

      // Ensure directory exists
      await dbFile.parent.create(recursive: true);

      // Move existing db out of the way first (fallback to delete if rename fails)
      final File bakFile = File('${dbFile.path}.bak');
      if (await dbFile.exists()) {
        try {
          if (await bakFile.exists()) {
            await bakFile.delete();
          }
          await dbFile.rename(bakFile.path);
        } catch (_) {
          try {
            await dbFile.delete();
          } catch (_) {}
        }
      }

      // Copy to a temp file then rename into place for atomicity
      final File tmpFile = File('${dbFile.path}.tmp');
      if (await tmpFile.exists()) {
        try {
          await tmpFile.delete();
        } catch (_) {}
      }
      await src.copy(tmpFile.path);
      try {
        await tmpFile.rename(dbFile.path);
      } catch (_) {
        try {
          await tmpFile.copy(dbFile.path);
          await tmpFile.delete();
        } catch (_) {
          return null;
        }
      }

      // Cleanup old backup if we created one
      if (await bakFile.exists()) {
        try {
          await bakFile.delete();
        } catch (_) {}
      }
      return dbFile.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _rebuildTripTablesWithCopy(Migrator m) async {
    await _rebuildTripMainWithCopy(m);
    await _rebuildTripManifestsWithCopy(m);
    await _ensureTripTableIndexes();
  }

  Future<void> _rebuildTripMainWithCopy(Migrator m) async {
    const tableName = 'trip_main';
    const legacyName = 'trip_main_legacy';
    final legacyExists = await _tableExists(legacyName);
    if (legacyExists) {
      await customStatement('DROP TABLE IF EXISTS "$tableName"');
      await m.createTable(tripMains);
      await _copyTripMainData(legacyName);
      await customStatement('DROP TABLE IF EXISTS "$legacyName"');
      return;
    }
    final existed = await _tableExists(tableName);
    if (!existed) {
      await m.createTable(tripMains);
      return;
    }
    await customStatement('ALTER TABLE "$tableName" RENAME TO "$legacyName"');
    try {
      await m.createTable(tripMains);
      await _copyTripMainData(legacyName);
      await customStatement('DROP TABLE IF EXISTS "$legacyName"');
    } catch (_) {
      await customStatement('DROP TABLE IF EXISTS "$tableName"');
      await customStatement('ALTER TABLE "$legacyName" RENAME TO "$tableName"');
      rethrow;
    }
  }

  Future<void> _rebuildTripManifestsWithCopy(Migrator m) async {
    const tableName = 'trip_manifests';
    const legacyName = 'trip_manifests_legacy';
    final legacyExists = await _tableExists(legacyName);
    if (legacyExists) {
      await customStatement('DROP TABLE IF EXISTS "$tableName"');
      await m.createTable(tripManifests);
      await _copyTripManifestData(legacyName);
      await customStatement('DROP TABLE IF EXISTS "$legacyName"');
      return;
    }
    final existed = await _tableExists(tableName);
    if (!existed) {
      await m.createTable(tripManifests);
      return;
    }
    await customStatement('ALTER TABLE "$tableName" RENAME TO "$legacyName"');
    try {
      await m.createTable(tripManifests);
      await _copyTripManifestData(legacyName);
      await customStatement('DROP TABLE IF EXISTS "$legacyName"');
    } catch (_) {
      await customStatement('DROP TABLE IF EXISTS "$tableName"');
      await customStatement('ALTER TABLE "$legacyName" RENAME TO "$tableName"');
      rethrow;
    }
  }

  Future<void> _ensureTripTableIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_trip_manifests_driver_id ON trip_manifests(driver_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_trip_main_date ON trip_main(date)',
    );
  }

  Future<void> _copyTripMainData(String legacyName) async {
    final columns = await _getColumnNames(legacyName);
    if (!columns.contains('id')) {
      return;
    }
    final sql = '''
INSERT INTO trip_main (
  id, date, driver_name, car_id, commission, labor_cost, support_payment, room_fee, created_at, updated_at
)
SELECT
  id,
  ${_legacyDateExpression(columns.contains('date') ? 'date' : null)} AS date,
  ${_selectOrNull(columns, 'driver_name')} AS driver_name,
  ${_selectOrNull(columns, 'car_id')} AS car_id,
  ${_selectOrNull(columns, 'commission')} AS commission,
  ${_selectOrNull(columns, 'labor_cost')} AS labor_cost,
  ${_selectOrNull(columns, 'support_payment')} AS support_payment,
  ${_selectOrNull(columns, 'room_fee')} AS room_fee,
  ${_selectOrNull(columns, 'created_at')} AS created_at,
  ${_selectOrNull(columns, 'updated_at')} AS updated_at
FROM "$legacyName";
''';
    await customStatement(sql);
  }

  Future<void> _copyTripManifestData(String legacyName) async {
    final columns = await _getColumnNames(legacyName);
    if (!columns.contains('id') || !columns.contains('driver_id')) {
      return;
    }
    final sql = '''
INSERT INTO trip_manifests (
  id, driver_id, customer_name, delivery_city, phone, parcel_type, number_of_parcel,
  cash_advance, payment_pending, payment_paid, created_at, updated_at
)
SELECT
  id,
  driver_id,
  ${_selectOrNull(columns, 'customer_name')} AS customer_name,
  ${_selectOrNull(columns, 'delivery_city')} AS delivery_city,
  ${_selectOrNull(columns, 'phone')} AS phone,
  ${_selectOrNull(columns, 'parcel_type')} AS parcel_type,
  ${_selectOrNull(columns, 'number_of_parcel')} AS number_of_parcel,
  ${_selectOrNull(columns, 'cash_advance')} AS cash_advance,
  ${_selectOrNull(columns, 'payment_pending')} AS payment_pending,
  ${_selectOrNull(columns, 'payment_paid')} AS payment_paid,
  ${_selectOrNull(columns, 'created_at')} AS created_at,
  ${_selectOrNull(columns, 'updated_at')} AS updated_at
FROM "$legacyName";
''';
    await customStatement(sql);
  }

  String _legacyDateExpression(String? column) {
    if (column == null) return 'NULL';
    return '''
CASE
  WHEN typeof($column) = 'integer' THEN $column
  WHEN typeof($column) = 'real' THEN CAST($column AS INTEGER)
  WHEN typeof($column) = 'text' THEN COALESCE(CAST(strftime('%s', $column) AS INTEGER) * 1000, CAST($column AS INTEGER))
  ELSE NULL
END
''';
  }

  String _selectOrNull(Set<String> columns, String name) {
    return columns.contains(name) ? name : 'NULL';
  }

  Future<bool> _tableExists(String tableName) async {
    final result = await customSelect(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [
        const Variable<String>('table'),
        Variable<String>(tableName),
      ],
    ).get();
    return result.isNotEmpty;
  }

  Future<Set<String>> _getColumnNames(String tableName) async {
    final rows = await customSelect('PRAGMA table_info("$tableName")').get();
    return rows
        .map((row) => row.data['name'])
        .whereType<String>()
        .toSet();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationSupportDirectory();
    final File file = File(p.join(dir.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
