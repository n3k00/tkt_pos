import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/app_settings.dart';
import 'tables/drivers.dart';
import 'tables/transactions.dart';
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
  int get schemaVersion => 12;

  // Migrations: create new tables when upgrading from v1
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // Create all Drift-managed tables (including trip_main & trip_manifests)
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Create any newly added tables (drivers, transactions)
        await m.createTable(drivers);
        await m.createTable(transactions);
      }
      if (from < 3) {
        // Rebuild transactions to relax NOT NULL on customer_name and cash_advance
        // 1) Rename old table
        await customStatement(
          'ALTER TABLE transactions RENAME TO transactions_old',
        );
        // 2) Create new table with updated schema
        await m.createTable(transactions);
        // 3) Copy data across
        await customStatement('''
              INSERT INTO transactions (
                id, customer_name, phone, parcel_type, number, charges,
                payment_status, cash_advance, picked_up, comment, driver_id,
                created_at, updated_at
              )
              SELECT id, customer_name, phone, parcel_type, number, charges,
                     payment_status, cash_advance, picked_up, comment, driver_id,
                     created_at, updated_at
              FROM transactions_old
            ''');
        // 4) Drop old table
        await customStatement('DROP TABLE transactions_old');
      }
      if (from < 4) {
        // Remove column `no` from transactions by rebuilding
        await customStatement(
          'ALTER TABLE transactions RENAME TO transactions_old',
        );
        await m.createTable(transactions);
        await customStatement('''
              INSERT INTO transactions (
                id, customer_name, phone, parcel_type, number, charges,
                payment_status, cash_advance, picked_up, comment, driver_id,
                created_at, updated_at
              )
              SELECT id, customer_name, phone, parcel_type, number, charges,
                     payment_status, cash_advance, picked_up, comment, driver_id,
                     created_at, updated_at
              FROM transactions_old
            ''');
        await customStatement('DROP TABLE transactions_old');
      }
      if (from < 5) {
        // Make cash_advance NOT NULL with default 0.0
        await customStatement(
          'ALTER TABLE transactions RENAME TO transactions_old',
        );
        await m.createTable(transactions);
        await customStatement('''
              INSERT INTO transactions (
                id, customer_name, phone, parcel_type, number, charges,
                payment_status, cash_advance, picked_up, comment, driver_id,
                created_at, updated_at
              )
              SELECT id, customer_name, phone, parcel_type, number, charges,
                     payment_status, COALESCE(cash_advance, 0.0), picked_up, comment, driver_id,
                     created_at, updated_at
              FROM transactions_old
            ''');
        await customStatement('DROP TABLE transactions_old');
      }
      if (from < 6) {
        await m.createTable(reportTransactions);
      }
      if (from < 9) {
        await customStatement('''
          CREATE TABLE IF NOT EXISTS trip_main (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date INTEGER NOT NULL,
            driver_name TEXT NOT NULL,
            car_id TEXT NOT NULL,
            commission REAL,
            labor_cost REAL,
            support_payment REAL,
            room_fee REAL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        await customStatement('''
          CREATE TABLE IF NOT EXISTS trip_manifests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            driver_id INTEGER,
            customer_name TEXT,
            delivery_city TEXT,
            phone TEXT,
            parcel_type TEXT NOT NULL,
            number_of_parcel INTEGER NOT NULL,
            cash_advance REAL,
            payment_pending REAL,
            payment_paid REAL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(driver_id) REFERENCES trip_main(id)
          )
        ''');
      }
      if (from < 10) {
        try {
          await customStatement('ALTER TABLE trip_main RENAME TO trip_main_old');
          await customStatement('''
            CREATE TABLE trip_main (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date INTEGER NOT NULL,
              driver_name TEXT NOT NULL,
              car_id TEXT NOT NULL,
              commission REAL,
              labor_cost REAL,
              support_payment REAL,
              room_fee REAL,
              created_at TEXT DEFAULT CURRENT_TIMESTAMP,
              updated_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
          ''');
          await customStatement('''
            INSERT INTO trip_main (
              id, date, driver_name, car_id, commission, labor_cost,
              support_payment, room_fee, created_at, updated_at
            )
            SELECT id, date, driver_name, CAST(car_id AS TEXT), commission, labor_cost,
                   support_payment, room_fee, created_at, updated_at
            FROM trip_main_old
          ''');
          await customStatement('DROP TABLE trip_main_old');
        } catch (_) {}
      }
      if (from < 11) {
        // Add indices for common queries
        try {
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_trip_manifests_driver_id ON trip_manifests(driver_id)');
        } catch (_) {}
        try {
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_trip_main_date ON trip_main(date)');
        } catch (_) {}
      }
      if (from < 12) {
        // Ensure trip tables exist with Drift's expected names
        // Drop legacy tables then (re)create via Drift to match naming
        try {
          await customStatement('DROP TABLE IF EXISTS trip_main');
        } catch (_) {}
        try {
          await customStatement('DROP TABLE IF EXISTS trip_manifests');
        } catch (_) {}

        // Create Drift-managed tables using correct names/columns
        await m.createTable(tripMains);
        await m.createTable(tripManifests);
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

  Future<int> deleteDriverById(int id) {
    return (delete(drivers)..where((t) => t.id.equals(id))).go();
  }

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
      update(transactions).replace(companion);

  Future<int> deleteTransactionById(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  // ------ ReportTransactions CRUD ------
  Future<int> insertReportTransaction({
    required int driverId,
    required int transactionId,
  }) async {
    // Prevent duplicates caused by rapid double clicks
    final existing = await (select(reportTransactions)
          ..where((rt) => rt.transactionId.equals(transactionId)))
        .getSingleOrNull();
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
        try { await tmpFile.delete(); } catch (_) {}
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
        try { await bakFile.delete(); } catch (_) {}
      }
      return dbFile.path;
    } catch (e) {
      return null;
    }
  }

  // Merge data from another sqlite database file into the current one.
  // This keeps existing rows and inserts missing ones by primary key.
  Future<void> mergeFromDatabaseFile(String backupPath) async {
    final escaped = backupPath.replaceAll("'", "''");
    // Ensure operations run sequentially
    await customStatement("ATTACH DATABASE '$escaped' AS src");
    try {
      await customStatement('PRAGMA foreign_keys=OFF');
      await customStatement('BEGIN');

      // Drivers
      await customStatement('''
        INSERT INTO drivers (id, date, name)
        SELECT id, date, name FROM src.drivers s
        WHERE NOT EXISTS (SELECT 1 FROM drivers d WHERE d.id = s.id)
      ''');

      // Transactions
      await customStatement('''
        INSERT INTO transactions (
          id, customer_name, phone, parcel_type, number, charges,
          payment_status, cash_advance, picked_up, comment, driver_id,
          created_at, updated_at
        )
        SELECT id, customer_name, phone, parcel_type, number, charges,
               payment_status, cash_advance, picked_up, comment, driver_id,
               created_at, updated_at
        FROM src.transactions s
        WHERE NOT EXISTS (SELECT 1 FROM transactions t WHERE t.id = s.id)
      ''');

      // Report transactions
      await customStatement('''
        INSERT INTO report_transactions (
          id, driver_id, transaction_id, created_at, updated_at
        )
        SELECT id, driver_id, transaction_id, created_at, updated_at
        FROM src.report_transactions s
        WHERE NOT EXISTS (SELECT 1 FROM report_transactions r WHERE r.id = s.id)
      ''');

      // App settings: use INSERT OR REPLACE for broader SQLite compatibility
      await customStatement('''
        INSERT OR REPLACE INTO app_settings (key, value)
        SELECT key, value FROM src.app_settings
      ''');

      await customStatement('COMMIT');
    } catch (_) {
      await customStatement('ROLLBACK');
      rethrow;
    } finally {
      await customStatement('PRAGMA foreign_keys=ON');
      await customStatement('DETACH DATABASE src');
    }
  }

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dir = await getApplicationSupportDirectory();
    final File file = File(p.join(dir.path, 'app.db'));
    // Use a background isolate to avoid jank
    return NativeDatabase.createInBackground(file);
  });
}

