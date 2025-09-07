import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/app_settings.dart';
import 'tables/drivers.dart';
import 'tables/transactions.dart';

part 'app_database.g.dart';

// Tables are now split into separate files under tables/

@DriftDatabase(tables: [AppSettings, Drivers, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  // Migrations: create new tables when upgrading from v1
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
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
            await customStatement('ALTER TABLE transactions RENAME TO transactions_old');
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
            await customStatement('ALTER TABLE transactions RENAME TO transactions_old');
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
            await customStatement('ALTER TABLE transactions RENAME TO transactions_old');
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
        },
      );

  Future<void> setSetting(String key, String? value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSetting(key: key, value: value),
    );
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  // ------ Drivers CRUD ------
  Future<int> insertDriver(DriversCompanion companion) => into(drivers).insert(companion);

  Future<List<Driver>> getAllDrivers() => select(drivers).get();

  Future<Driver?> getDriverById(int id) async {
    return (select(drivers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updateDriver(DriversCompanion companion) => update(drivers).replace(companion);

  Future<int> deleteDriverById(int id) {
    return (delete(drivers)..where((t) => t.id.equals(id))).go();
  }

  // ------ Transactions CRUD ------
  Future<int> insertTransaction(TransactionsCompanion companion) => into(transactions).insert(companion);

  Future<List<DbTransaction>> getAllTransactions() => select(transactions).get();

  Future<List<DbTransaction>> getTransactionsByDriver(int driverId) async {
    return (select(transactions)..where((t) => t.driverId.equals(driverId))).get();
  }

  Future<DbTransaction?> getTransactionById(int id) async {
    return (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updateTransaction(TransactionsCompanion companion) => update(transactions).replace(companion);

  Future<int> deleteTransactionById(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
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
