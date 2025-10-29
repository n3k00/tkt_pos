import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/app_settings.dart';
import 'tables/drivers.dart';
import 'tables/transactions.dart';
import 'tables/report_transactions.dart';

part 'app_database.g.dart';

// Tables are now split into separate files under tables/

@DriftDatabase(tables: [AppSettings, Drivers, Transactions, ReportTransactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 10;

  // Migrations: create new tables when upgrading from v1
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Create requested trip tables if they don't exist
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
    await customStatement("VACUUM INTO '" + escaped + "'");
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
    await customStatement("VACUUM INTO '" + dest.replaceAll("'", "''") + "'");
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
      final File bakFile = File(dbFile.path + '.bak');
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
      final File tmpFile = File(dbFile.path + '.tmp');
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
    await customStatement("ATTACH DATABASE '" + escaped + "' AS src");
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

  // ------ Trip Main: read helpers ------
  Future<List<TripMainRow>> getTripMainRows() async {
    final rows = await customSelect(
      'SELECT id, date, driver_name, car_id, commission, labor_cost, support_payment, room_fee, created_at, updated_at FROM trip_main ORDER BY date DESC, id DESC',
    ).get();
    return rows.map((r) => TripMainRow.fromRow(r)).toList(growable: false);
  }

  Future<int> insertTripMain({
    required DateTime date,
    required String driverName,
    required String carId,
  }) async {
    return await customInsert(
      'INSERT INTO trip_main (date, driver_name, car_id, commission, labor_cost, support_payment, room_fee, created_at, updated_at) '
      'VALUES (?, ?, ?, 0, 0, 0, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)',
      variables: [
        Variable<int>(date.millisecondsSinceEpoch),
        Variable<String>(driverName),
        Variable<String>(carId),
      ],
    );
  }
}

class TripMainRow {
  final int id;
  final DateTime date;
  final String driverName;
  final String carId;
  final double? commission;
  final double? laborCost;
  final double? supportPayment;
  final double? roomFee;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TripMainRow({
    required this.id,
    required this.date,
    required this.driverName,
    required this.carId,
    this.commission,
    this.laborCost,
    this.supportPayment,
    this.roomFee,
    this.createdAt,
    this.updatedAt,
  });

  factory TripMainRow.fromRow(QueryRow r) {
    DateTime? parseTs(String? s) => s == null ? null : DateTime.tryParse(s);
    return TripMainRow(
      id: r.read<int>('id'),
      date: DateTime.fromMillisecondsSinceEpoch(r.read<int>('date')),
      driverName: r.read<String>('driver_name'),
      carId: r.read<String>('car_id'),
      commission: r.read<double?>('commission'),
      laborCost: r.read<double?>('labor_cost'),
      supportPayment: r.read<double?>('support_payment'),
      roomFee: r.read<double?>('room_fee'),
      createdAt: parseTs(r.read<String?>('created_at')),
      updatedAt: parseTs(r.read<String?>('updated_at')),
    );
  }
}

class TripManifestRow {
  final int id;
  final int driverId;
  final String? customerName;
  final String? deliveryCity;
  final String? phone;
  final String parcelType;
  final int numberOfParcel;
  final double? cashAdvance;
  final double? paymentPending;
  final double? paymentPaid;

  TripManifestRow({
    required this.id,
    required this.driverId,
    required this.customerName,
    required this.deliveryCity,
    required this.phone,
    required this.parcelType,
    required this.numberOfParcel,
    required this.cashAdvance,
    required this.paymentPending,
    required this.paymentPaid,
  });

  factory TripManifestRow.fromRow(QueryRow r) {
    return TripManifestRow(
      id: r.read<int>('id'),
      driverId: r.read<int>('driver_id'),
      customerName: r.read<String?>('customer_name'),
      deliveryCity: r.read<String?>('delivery_city'),
      phone: r.read<String?>('phone'),
      parcelType: r.read<String>('parcel_type'),
      numberOfParcel: r.read<int>('number_of_parcel'),
      cashAdvance: r.read<double?>('cash_advance'),
      paymentPending: r.read<double?>('payment_pending'),
      paymentPaid: r.read<double?>('payment_paid'),
    );
  }
}

extension TripManifestsQueries on AppDatabase {
  Future<List<TripManifestRow>> getTripManifests(int driverId) async {
    final rows = await customSelect(
      'SELECT id, driver_id, customer_name, delivery_city, phone, parcel_type, number_of_parcel, cash_advance, payment_pending, payment_paid FROM trip_manifests WHERE driver_id = ? ORDER BY id ASC',
      variables: [Variable<int>(driverId)],
    ).get();
    return rows.map((r) => TripManifestRow.fromRow(r)).toList(growable: false);
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

